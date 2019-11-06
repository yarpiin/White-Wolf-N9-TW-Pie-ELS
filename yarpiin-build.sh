#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb.img"
CROWNDEFCONFIG="yarpiin_defconfig"
CROWNPERM_DEFCONFIG="perm_yarpiin_defconfig"
KERNEL_DIR="/home/yarpiin/Android/Kernel/N9/White-Wolf-N9-TW-Pie-ELS"
RESOURCE_DIR="$KERNEL_DIR/.."
KERNELFLASHER_DIR="/home/yarpiin/Android/Kernel/SGS9/KernelFlasher"
TOOLCHAIN_DIR="/home/yarpiin/Android/Toolchains"

# Kernel Details
BASE_YARPIIN_VER="WHITE.WOLF.N9.PIE"
VER=".028"
PERM=".PERM"
YARPIIN_VER="$BASE_YARPIIN_VER$VER"
YARPIIN_PERM_VER="$BASE_YARPIIN_VER$VER$PERM"

# Vars
export LOCALVERSION=-`echo $YARPIIN_VER`
export CROSS_COMPILE="$TOOLCHAIN_DIR/aarch64-linux-gnu/bin/aarch64-linux-gnu-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=yarpiin
export KBUILD_BUILD_HOST=kernel

# Paths
CROWNREPACK_DIR="/home/yarpiin/Android/Kernel/SGS9/Repack/N960/split_img"
CROWNIMG_DIR="/home/yarpiin/Android/Kernel/SGS9/Repack/N960"
ZIP_MOVE="/home/yarpiin/Android/Kernel/SGS9/Zip"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

# Functions
function clean_all {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		cd $CROWNIMG_DIR
		rm -rf zImage
		rm -rf img.dtb
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_crown_kernel {
		echo
		make $CROWNDEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $CROWNREPACK_DIR/N960.img-zImage
        cp -vr $ZIMAGE_DIR/$DTBIMAGE $CROWNREPACK_DIR/N960.img-dtb
}

function make_crown_permissive_kernel {
		echo
		make $CROWNPERM_DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $CROWNREPACK_DIR/N960.img-zImage
        cp -vr $ZIMAGE_DIR/$DTBIMAGE $CROWNREPACK_DIR/N960.img-dtb
}

function repack_crown {
		/bin/bash /home/yarpiin/Android/Kernel/SGS9/Repack/N960/repackimg.sh
		cd $CROWNIMG_DIR
		cp -vr image-new.img $KERNELFLASHER_DIR/N960.img
		cd $KERNEL_DIR
}

function make_zip {
		cd $KERNELFLASHER_DIR
		zip -r9 `echo $YARPIIN_VER`.zip *
		mv  `echo $YARPIIN_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}
function make_Permissive_zip {
		cd $KERNELFLASHER_DIR
		zip -r9 `echo $YARPIIN_PERM_VER`.zip *
		mv  `echo $YARPIIN_PERM_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "YARPIIN Kernel Creation Script:"
echo

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$YARPIIN_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making YARPIIN Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build N9 permissive kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_crown_permissive_kernel
        repack_crown
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build N9 kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_crown_kernel
        repack_crown
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo


while read -p "Is kernel to be zipped permissive (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_Permissive_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to zip kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

