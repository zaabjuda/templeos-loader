#!/bin/sh
set -ex


git clone git://git.musl-libc.org/musl musl-src
cd musl-src
./configure --prefix=$PWD/../build/musl --disable-shared
make install
cd ..
export PATH=$PWD/build/musl/bin:$PATH

git submodule update --init --recursive
cd physfslt-3.0.2
env CC=musl-gcc cmake -DCMAKE_INSTALL_PREFIX:PATH=$PWD/../build/physfs -DPHYSFS_BUILD_SHARED=OFF . && make install
cd ..

mkdir cmake-build-debug
cd cmake-build-debug
env CC=musl-gcc PHYSFSDIR=$PWD/../build/physfs/ cmake ..
cmake --build . --target templeoskernel
cd ..

export COMPILE_OUTPUT=CmpOutput/HolyCRT.BIN

./make-holycrt-s.sh

if [ ! -f $COMPILE_OUTPUT ]; then
    echo error: expected output does not exist >&2 
    exit 1
fi

# m1=$(md5sum $COMPILE_OUTPUT)

# ./remake-holycrt.sh

# m2=$(md5sum $COMPILE_OUTPUT)

# if [ "$m1" == "$m2" ] ; then
#     echo error: file did not change as expected >&2 
#     exit 1
# fi

SIZE=$(wc -c <$COMPILE_OUTPUT)

if [ $SIZE -le 100000 ]; then
    echo error: output is smaller than expected >&2
    exit 1
fi
