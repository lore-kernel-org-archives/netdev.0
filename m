From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Update of the r8169 branch
Date: Thu, 21 Sep 2006 23:07:43 +0200
Message-ID: <20060921210743.GA5083@electric-eye.fr.zoreil.com>
References: <20060726215840.GA4032@electric-eye.fr.zoreil.com> <4511A4F0.6050101@kernelpanic.ru> <20060920214010.GA7879@electric-eye.fr.zoreil.com> <4512B475.1000703@kernelpanic.ru> <20060921165156.GC496@electric-eye.fr.zoreil.com> <4512ED7A.40001@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, mbockol@carleton.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:21223 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751563AbWIUVJt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 17:09:49 -0400
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <4512ED7A.40001@kernelpanic.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Boris B. Zhmurov <bb@kernelpanic.ru> :
[...]
> Is there any chance to get linux worked at least as fast, as freebsd-6.1 
> with small udp packets?
> Any help will be more than welcome!
> Please, CC: me, due to I'm not subscribed to netdev@vger.kernel.org.

Can you publish dmesg, vmstat 1 and /proc/interrupts somewhere ?

> # Thu Sep 21 10:31:58 2006
> #
> CONFIG_X86_32=y
> CONFIG_GENERIC_TIME=y
> CONFIG_LOCKDEP_SUPPORT=y

Disable

> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_SEMAPHORE_SLEEPERS=y

Disable

> CONFIG_X86=y
> CONFIG_MMU=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> CONFIG_DMI=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> 
> #
> # Code maturity level options
> #
> CONFIG_EXPERIMENTAL=y

Disable

> CONFIG_LOCK_KERNEL=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
[...]
> CONFIG_AUDIT=y
> CONFIG_AUDITSYSCALL=y

Disable

> CONFIG_IKCONFIG=y
> CONFIG_IKCONFIG_PROC=y
[...]
> CONFIG_M686=y
> # CONFIG_MPENTIUMII is not set
> # CONFIG_MPENTIUMIII is not set
> # CONFIG_MPENTIUMM is not set
> # CONFIG_MPENTIUM4 is not set

?

[...]
> # CONFIG_PREEMPT_NONE is not set

Enable

> CONFIG_PREEMPT_VOLUNTARY=y

Disable

> # CONFIG_PREEMPT is not set
> CONFIG_PREEMPT_BKL=y

Disable

[...]
> # CONFIG_NOHIGHMEM is not set
> CONFIG_HIGHMEM4G=y
> # CONFIG_HIGHMEM64G is not set
> CONFIG_PAGE_OFFSET=0xC0000000
> CONFIG_HIGHMEM=y
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_FLATMEM_MANUAL=y
> # CONFIG_DISCONTIGMEM_MANUAL is not set
> # CONFIG_SPARSEMEM_MANUAL is not set
> CONFIG_FLATMEM=y
> CONFIG_FLAT_NODE_MEM_MAP=y
> # CONFIG_SPARSEMEM_STATIC is not set
> CONFIG_SPLIT_PTLOCK_CPUS=4
> # CONFIG_RESOURCES_64BIT is not set
> CONFIG_HIGHPTE=y
> # CONFIG_MATH_EMULATION is not set
> CONFIG_MTRR=y
> # CONFIG_EFI is not set
> # CONFIG_IRQBALANCE is not set
> CONFIG_REGPARM=y
> # CONFIG_SECCOMP is not set
> CONFIG_HZ_100=y
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=100

CONFIG_HZ_1000

[...]
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=y
> CONFIG_CPU_FREQ_TABLE=y
> # CONFIG_CPU_FREQ_DEBUG is not set
> CONFIG_CPU_FREQ_STAT=m
> CONFIG_CPU_FREQ_STAT_DETAILS=y
> # CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
> CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
> CONFIG_CPU_FREQ_GOV_POWERSAVE=m
> CONFIG_CPU_FREQ_GOV_USERSPACE=y
> CONFIG_CPU_FREQ_GOV_ONDEMAND=m
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

...

> #
> # CPUFreq processor drivers
> #
> CONFIG_X86_ACPI_CPUFREQ=m
> # CONFIG_X86_POWERNOW_K6 is not set
> CONFIG_X86_POWERNOW_K7=y
> CONFIG_X86_POWERNOW_K8=y
> # CONFIG_X86_GX_SUSPMOD is not set
> CONFIG_X86_SPEEDSTEP_CENTRINO=y
> CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
> CONFIG_X86_SPEEDSTEP_ICH=m
> CONFIG_X86_SPEEDSTEP_SMI=m
> CONFIG_X86_P4_CLOCKMOD=m

...

[...]
> # Instrumentation Support
> #
> # CONFIG_PROFILING is not set
> # CONFIG_KPROBES is not set
> 
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> # CONFIG_PRINTK_TIME is not set
> # CONFIG_MAGIC_SYSRQ is not set
> CONFIG_UNUSED_SYMBOLS=y
> CONFIG_DEBUG_KERNEL=y

Disable

-- 
Ueimor
