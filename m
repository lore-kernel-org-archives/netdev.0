From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Documentation:change all arch/i386 to arch/x86 in
 Documentation
Date: Mon, 13 Jun 2011 10:23:44 -0700
Message-ID: <20110613172344.GC2272@linux.vnet.ibm.com>
References: <1307942898-3728-1-git-send-email-wanlong.gao@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-video@atrey.karlin.mff.cuni.cz,
	xiyoulinuxkernelgroup@googlegroups.com, linux-kernel@zh-kernel.org,
	Dipankar Sarma <dipankar@in.ibm.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Nick Piggin <npiggin@kernel.dk>,
	Karsten Keil <isdn@linux-pingi.de>,
	Michal Marek <mmarek@suse.cz>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Martin Mares <mj@ucw.cz>, Harry Wei <harryxiyou@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Thomas Weber <weber@corscience.de>,
	Mike Frysinger <vapier.adi@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: Wanlong Gao <wanlong.gao@gmail.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307942898-3728-1-git-send-email-wanlong.gao@gmail.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2011 at 01:28:18PM +0800, Wanlong Gao wrote:
> From: Wanlong Gao <wanlong.gao@gmail.com>
> 
> Change all "arch/i386" to "arch/x86" in Documentaion/,
> since the directory has changed.
> 
> Signed-off-by: Wanlong Gao <wanlong.gao@gmail.com>

I have queued the Documentation/RCU/NMI-RCU.txt hunk with your
Signed-off-by, thank you!

							Thanx, Paul

> ---
>  Documentation/RCU/NMI-RCU.txt             |    4 +-
>  Documentation/blockdev/README.DAC960      |    2 +-
>  Documentation/blockdev/ramdisk.txt        |    8 +++---
>  Documentation/cpu-freq/cpu-drivers.txt    |    2 +-
>  Documentation/filesystems/nfs/nfsroot.txt |    2 +-
>  Documentation/isdn/README.HiSax           |    2 +-
>  Documentation/kbuild/makefiles.txt        |   38 ++++++++++++++--------------
>  Documentation/magic-number.txt            |    2 +-
>  Documentation/mca.txt                     |    6 ++--
>  Documentation/scheduler/sched-arch.txt    |    2 +-
>  Documentation/scsi/BusLogic.txt           |    2 +-
>  Documentation/serial/computone.txt        |    2 +-
>  Documentation/svga.txt                    |    2 +-
>  Documentation/zh_CN/magic-number.txt      |    2 +-
>  14 files changed, 38 insertions(+), 38 deletions(-)
> 
> diff --git a/Documentation/RCU/NMI-RCU.txt b/Documentation/RCU/NMI-RCU.txt
> index a8536cb..bf82851 100644
> --- a/Documentation/RCU/NMI-RCU.txt
> +++ b/Documentation/RCU/NMI-RCU.txt
> @@ -5,8 +5,8 @@ Although RCU is usually used to protect read-mostly data structures,
>  it is possible to use RCU to provide dynamic non-maskable interrupt
>  handlers, as well as dynamic irq handlers.  This document describes
>  how to do this, drawing loosely from Zwane Mwaikambo's NMI-timer
> -work in "arch/i386/oprofile/nmi_timer_int.c" and in
> -"arch/i386/kernel/traps.c".
> +work in "arch/x86/oprofile/nmi_timer_int.c" and in
> +"arch/x86/kernel/traps.c".
> 
>  The relevant pieces of code are listed below, each followed by a
>  brief explanation.
> diff --git a/Documentation/blockdev/README.DAC960 b/Documentation/blockdev/README.DAC960
> index 0e8f618..bd85fb9 100644
> --- a/Documentation/blockdev/README.DAC960
> +++ b/Documentation/blockdev/README.DAC960
> @@ -214,7 +214,7 @@ replacing "/usr/src" with wherever you keep your Linux kernel source tree:
>    make config
>    make bzImage (or zImage)
> 
> -Then install "arch/i386/boot/bzImage" or "arch/i386/boot/zImage" as your
> +Then install "arch/x86/boot/bzImage" or "arch/x86/boot/zImage" as your
>  standard kernel, run lilo if appropriate, and reboot.
> 
>  To create the necessary devices in /dev, the "make_rd" script included in
> diff --git a/Documentation/blockdev/ramdisk.txt b/Documentation/blockdev/ramdisk.txt
> index 6c820ba..fa72e97 100644
> --- a/Documentation/blockdev/ramdisk.txt
> +++ b/Documentation/blockdev/ramdisk.txt
> @@ -64,9 +64,9 @@ the RAM disk dynamically grows as data is being written into it, a size field
>  is not required. Bits 11 to 13 are not currently used and may as well be zero.
>  These numbers are no magical secrets, as seen below:
> 
> -./arch/i386/kernel/setup.c:#define RAMDISK_IMAGE_START_MASK     0x07FF
> -./arch/i386/kernel/setup.c:#define RAMDISK_PROMPT_FLAG          0x8000
> -./arch/i386/kernel/setup.c:#define RAMDISK_LOAD_FLAG            0x4000
> +./arch/x86/kernel/setup.c:#define RAMDISK_IMAGE_START_MASK     0x07FF
> +./arch/x86/kernel/setup.c:#define RAMDISK_PROMPT_FLAG          0x8000
> +./arch/x86/kernel/setup.c:#define RAMDISK_LOAD_FLAG            0x4000
> 
>  Consider a typical two floppy disk setup, where you will have the
>  kernel on disk one, and have already put a RAM disk image onto disk #2.
> @@ -85,7 +85,7 @@ The command line equivalent is: "prompt_ramdisk=1"
>  Putting that together gives 2^15 + 2^14 + 0 = 49152 for an rdev word.
>  So to create disk one of the set, you would do:
> 
> -	/usr/src/linux# cat arch/i386/boot/zImage > /dev/fd0
> +	/usr/src/linux# cat arch/x86/boot/zImage > /dev/fd0
>  	/usr/src/linux# rdev /dev/fd0 /dev/fd0
>  	/usr/src/linux# rdev -r /dev/fd0 49152
> 
> diff --git a/Documentation/cpu-freq/cpu-drivers.txt b/Documentation/cpu-freq/cpu-drivers.txt
> index 6c30e93..ed07e4f 100644
> --- a/Documentation/cpu-freq/cpu-drivers.txt
> +++ b/Documentation/cpu-freq/cpu-drivers.txt
> @@ -168,7 +168,7 @@ in-chipset dynamic frequency switching to policy->min, the upper limit
>  to policy->max, and -if supported- select a performance-oriented
>  setting when policy->policy is CPUFREQ_POLICY_PERFORMANCE, and a
>  powersaving-oriented setting when CPUFREQ_POLICY_POWERSAVE. Also check
> -the reference implementation in arch/i386/kernel/cpu/cpufreq/longrun.c
> +the reference implementation in arch/x86/kernel/cpu/cpufreq/longrun.c
> 
> 
> 
> diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
> index 90c71c6..ffdd9d8 100644
> --- a/Documentation/filesystems/nfs/nfsroot.txt
> +++ b/Documentation/filesystems/nfs/nfsroot.txt
> @@ -226,7 +226,7 @@ They depend on various facilities being available:
>       	cdrecord.
> 
>  	e.g.
> -	  cdrecord dev=ATAPI:1,0,0 arch/i386/boot/image.iso
> +	  cdrecord dev=ATAPI:1,0,0 arch/x86/boot/image.iso
> 
>       	For more information on isolinux, including how to create bootdisks
>       	for prebuilt kernels, see http://syslinux.zytor.com/
> diff --git a/Documentation/isdn/README.HiSax b/Documentation/isdn/README.HiSax
> index 99e87a6..b1a573c 100644
> --- a/Documentation/isdn/README.HiSax
> +++ b/Documentation/isdn/README.HiSax
> @@ -506,7 +506,7 @@ to e.g. the Internet:
>       <ISDN subsystem - ISDN support -- HiSax>
>       make clean; make zImage; make modules; make modules_install
>  2. Install the new kernel
> -     cp /usr/src/linux/arch/i386/boot/zImage /etc/kernel/linux.isdn
> +     cp /usr/src/linux/arch/x86/boot/zImage /etc/kernel/linux.isdn
>       vi /etc/lilo.conf
>       <add new kernel in the bootable image section>
>       lilo
> diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
> index 47435e5..f47cdef 100644
> --- a/Documentation/kbuild/makefiles.txt
> +++ b/Documentation/kbuild/makefiles.txt
> @@ -441,7 +441,7 @@ more details, with real examples.
>  	specified if first option are not supported.
> 
>  	Example:
> -		#arch/i386/kernel/Makefile
> +		#arch/x86/kernel/Makefile
>  		vsyscall-flags += $(call cc-ldoption, -Wl$(comma)--hash-style=sysv)
> 
>  	In the above example, vsyscall-flags will be assigned the option
> @@ -460,7 +460,7 @@ more details, with real examples.
>  	supported to use an optional second option.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		cflags-y += $(call cc-option,-march=pentium-mmx,-march=i586)
> 
>  	In the above example, cflags-y will be assigned the option
> @@ -522,7 +522,7 @@ more details, with real examples.
>  	even though the option was accepted by gcc.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		cflags-y += $(shell \
>  		if [ $(call cc-version) -ge 0300 ] ; then \
>  			echo "-mregparm=3"; fi ;)
> @@ -802,7 +802,7 @@ but in the architecture makefiles where the kbuild infrastructure
>  is not sufficient this sometimes needs to be explicit.
> 
>  	Example:
> -		#arch/i386/boot/Makefile
> +		#arch/x86/boot/Makefile
>  		subdir- := compressed/
> 
>  The above assignment instructs kbuild to descend down in the
> @@ -812,12 +812,12 @@ To support the clean infrastructure in the Makefiles that builds the
>  final bootimage there is an optional target named archclean:
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		archclean:
> -			$(Q)$(MAKE) $(clean)=arch/i386/boot
> +			$(Q)$(MAKE) $(clean)=arch/x86/boot
> 
> -When "make clean" is executed, make will descend down in arch/i386/boot,
> -and clean as usual. The Makefile located in arch/i386/boot/ may use
> +When "make clean" is executed, make will descend down in arch/x86/boot,
> +and clean as usual. The Makefile located in arch/x86/boot/ may use
>  the subdir- trick to descend further down.
> 
>  Note 1: arch/$(ARCH)/Makefile cannot use "subdir-", because that file is
> @@ -882,7 +882,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	LDFLAGS_vmlinux uses the LDFLAGS_$@ support.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		LDFLAGS_vmlinux := -e stext
> 
>      OBJCOPYFLAGS	objcopy flags
> @@ -920,14 +920,14 @@ When kbuild executes, the following steps are followed (roughly):
>  	Often, the KBUILD_CFLAGS variable depends on the configuration.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		cflags-$(CONFIG_M386) += -march=i386
>  		KBUILD_CFLAGS += $(cflags-y)
> 
>  	Many arch Makefiles dynamically run the target C compiler to
>  	probe supported options:
> 
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
> 
>  		...
>  		cflags-$(CONFIG_MPENTIUMII)     += $(call cc-option,\
> @@ -1038,8 +1038,8 @@ When kbuild executes, the following steps are followed (roughly):
>  	into the arch/$(ARCH)/boot/Makefile.
> 
>  	Example:
> -		#arch/i386/Makefile
> -		boot := arch/i386/boot
> +		#arch/x86/Makefile
> +		boot := arch/x86/boot
>  		bzImage: vmlinux
>  			$(Q)$(MAKE) $(build)=$(boot) $(boot)/$@
> 
> @@ -1051,7 +1051,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	To support this, $(archhelp) must be defined.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		define archhelp
>  		  echo  '* bzImage      - Image (arch/$(ARCH)/boot/bzImage)'
>  		endif
> @@ -1065,7 +1065,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	from vmlinux.
> 
>  	Example:
> -		#arch/i386/Makefile
> +		#arch/x86/Makefile
>  		all: bzImage
> 
>  	When "make" is executed without arguments, bzImage will be built.
> @@ -1083,7 +1083,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	2) kbuild knows what files to delete during "make clean"
> 
>  	Example:
> -		#arch/i386/kernel/Makefile
> +		#arch/x86/kernel/Makefile
>  		extra-y := head.o init_task.o
> 
>  	In this example, extra-y is used to list object files that
> @@ -1133,7 +1133,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	Compress target. Use maximum compression to compress target.
> 
>  	Example:
> -		#arch/i386/boot/Makefile
> +		#arch/x86/boot/Makefile
>  		LDFLAGS_bootsect := -Ttext 0x0 -s --oformat binary
>  		LDFLAGS_setup    := -Ttext 0x0 -s --oformat binary -e begtext
> 
> @@ -1193,7 +1193,7 @@ When kbuild executes, the following steps are followed (roughly):
> 
>  	When updating the $(obj)/bzImage target, the line
> 
> -	BUILD    arch/i386/boot/bzImage
> +	BUILD    arch/x86/boot/bzImage
> 
>  	will be displayed with "make KBUILD_VERBOSE=0".
> 
> @@ -1207,7 +1207,7 @@ When kbuild executes, the following steps are followed (roughly):
>  	kbuild knows .lds files and includes a rule *lds.S -> *lds.
> 
>  	Example:
> -		#arch/i386/kernel/Makefile
> +		#arch/x86/kernel/Makefile
>  		always := vmlinux.lds
> 
>  		#Makefile
> diff --git a/Documentation/magic-number.txt b/Documentation/magic-number.txt
> index 4b12abc..20ec3d9 100644
> --- a/Documentation/magic-number.txt
> +++ b/Documentation/magic-number.txt
> @@ -66,7 +66,7 @@ MKISS_DRIVER_MAGIC    0x04bf      mkiss_channel     drivers/net/mkiss.h
>  RISCOM8_MAGIC         0x0907      riscom_port       drivers/char/riscom8.h
>  SPECIALIX_MAGIC       0x0907      specialix_port    drivers/char/specialix_io8.h
>  HDLC_MAGIC            0x239e      n_hdlc            drivers/char/n_hdlc.c
> -APM_BIOS_MAGIC        0x4101      apm_user          arch/i386/kernel/apm.c
> +APM_BIOS_MAGIC        0x4101      apm_user          arch/x86/kernel/apm.c
>  CYCLADES_MAGIC        0x4359      cyclades_port     include/linux/cyclades.h
>  DB_MAGIC              0x4442      fc_info           drivers/net/iph5526_novram.c
>  DL_MAGIC              0x444d      fc_info           drivers/net/iph5526_novram.c
> diff --git a/Documentation/mca.txt b/Documentation/mca.txt
> index 510375d..cf8fd39 100644
> --- a/Documentation/mca.txt
> +++ b/Documentation/mca.txt
> @@ -3,7 +3,7 @@ i386 Micro Channel Architecture Support
> 
>  MCA support is enabled using the CONFIG_MCA define.  A machine with a MCA
>  bus will have the kernel variable MCA_bus set, assuming the BIOS feature
> -bits are set properly (see arch/i386/boot/setup.S for information on
> +bits are set properly (see arch/x86/boot/setup.S for information on
>  how this detection is done).
> 
>  Adapter Detection
> @@ -11,7 +11,7 @@ Adapter Detection
> 
>  The ideal MCA adapter detection is done through the use of the
>  Programmable Option Select registers.  Generic functions for doing
> -this have been added in include/linux/mca.h and arch/i386/kernel/mca.c.
> +this have been added in include/linux/mca.h and arch/x86/kernel/mca.c.
>  Everything needed to detect adapters and read (and write) configuration
>  information is there.  A number of MCA-specific drivers already use
>  this.  The typical probe code looks like the following:
> @@ -81,7 +81,7 @@ more people use shared IRQs on PCI machines.
>  In general, an interrupt must be acknowledged not only at the ICU (which
>  is done automagically by the kernel), but at the device level.  In
>  particular, IRQ 0 must be reset after a timer interrupt (now done in
> -arch/i386/kernel/time.c) or the first timer interrupt hangs the system.
> +arch/x86/kernel/time.c) or the first timer interrupt hangs the system.
>  There were also problems with the 1.3.x floppy drivers, but that seems
>  to have been fixed.
> 
> diff --git a/Documentation/scheduler/sched-arch.txt b/Documentation/scheduler/sched-arch.txt
> index d43dbcb..28aa107 100644
> --- a/Documentation/scheduler/sched-arch.txt
> +++ b/Documentation/scheduler/sched-arch.txt
> @@ -66,7 +66,7 @@ Your cpu_idle routines need to obey the following rules:
>  	    barrier issued (followed by a test of need_resched with
>  	    interrupts disabled, as explained in 3).
> 
> -arch/i386/kernel/process.c has examples of both polling and
> +arch/x86/kernel/process.c has examples of both polling and
>  sleeping idle functions.
> 
> 
> diff --git a/Documentation/scsi/BusLogic.txt b/Documentation/scsi/BusLogic.txt
> index d7fbc94..48e982c 100644
> --- a/Documentation/scsi/BusLogic.txt
> +++ b/Documentation/scsi/BusLogic.txt
> @@ -553,7 +553,7 @@ replacing "/usr/src" with wherever you keep your Linux kernel source tree:
>    make config
>    make zImage
> 
> -Then install "arch/i386/boot/zImage" as your standard kernel, run lilo if
> +Then install "arch/x86/boot/zImage" as your standard kernel, run lilo if
>  appropriate, and reboot.
> 
> 
> diff --git a/Documentation/serial/computone.txt b/Documentation/serial/computone.txt
> index c57ea47..60a6f65 100644
> --- a/Documentation/serial/computone.txt
> +++ b/Documentation/serial/computone.txt
> @@ -87,7 +87,7 @@ c) Set address on ISA cards then:
>  	   edit /usr/src/linux/drivers/char/ip2.c  
>             (Optional - may be specified on kernel command line now)
>  d) Run "make zImage" or whatever target you prefer.
> -e) mv /usr/src/linux/arch/i386/boot/zImage to /boot.
> +e) mv /usr/src/linux/arch/x86/boot/zImage to /boot.
>  f) Add new config for this kernel into /etc/lilo.conf, run "lilo"
>  	or copy to a floppy disk and boot from that floppy disk.
>  g) Reboot using this kernel
> diff --git a/Documentation/svga.txt b/Documentation/svga.txt
> index cd66ec8..e5da082 100644
> --- a/Documentation/svga.txt
> +++ b/Documentation/svga.txt
> @@ -150,7 +150,7 @@ end of the display.
> 
>  4. Options
>  ~~~~~~~~~~
> -   Some options can be set in the source text (in arch/i386/boot/video.S).
> +   Some options can be set in the source text (in arch/x86/boot/video.S).
>  All of them are simple #define's -- change them to #undef's when you want to
>  switch them off. Currently supported:
> 
> diff --git a/Documentation/zh_CN/magic-number.txt b/Documentation/zh_CN/magic-number.txt
> index 4c4ce85..a9e6fdd 100644
> --- a/Documentation/zh_CN/magic-number.txt
> +++ b/Documentation/zh_CN/magic-number.txt
> @@ -66,7 +66,7 @@ MKISS_DRIVER_MAGIC    0x04bf      mkiss_channel     drivers/net/mkiss.h
>  RISCOM8_MAGIC         0x0907      riscom_port       drivers/char/riscom8.h
>  SPECIALIX_MAGIC       0x0907      specialix_port    drivers/char/specialix_io8.h
>  HDLC_MAGIC            0x239e      n_hdlc            drivers/char/n_hdlc.c
> -APM_BIOS_MAGIC        0x4101      apm_user          arch/i386/kernel/apm.c
> +APM_BIOS_MAGIC        0x4101      apm_user          arch/x86/kernel/apm.c
>  CYCLADES_MAGIC        0x4359      cyclades_port     include/linux/cyclades.h
>  DB_MAGIC              0x4442      fc_info           drivers/net/iph5526_novram.c
>  DL_MAGIC              0x444d      fc_info           drivers/net/iph5526_novram.c
> -- 
> 1.7.4.1
> 
