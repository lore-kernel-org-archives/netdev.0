From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: AF_RXPC build failure
Date: Wed, 2 May 2007 15:34:18 -0700
Message-ID: <20070502153418.2cc27f4f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43591 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766675AbXEBWfA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like new RXRPC code depends on key storage but doesn't
select it.


  CC [M]  net/rxrpc/af_rxrpc.o
net/rxrpc/af_rxrpc.c: In function =E2=80=98rxrpc_kernel_begin_call=E2=80=
=99:
net/rxrpc/af_rxrpc.c:302: error: dereferencing pointer to incomplete ty=
pe
net/rxrpc/af_rxrpc.c: In function =E2=80=98af_rxrpc_init=E2=80=99:
net/rxrpc/af_rxrpc.c:819: warning: implicit declaration of function =E2=
=80=98register_key_type=E2=80=99
net/rxrpc/af_rxrpc.c:838: warning: implicit declaration of function =E2=
=80=98unregister_key_type=E2=80=99
make[2]: *** [net/rxrpc/af_rxrpc.o] Error 1
  CC [M]  net/rxrpc/ar-key.o
net/rxrpc/ar-key.c:36: error: variable =E2=80=98key_type_rxrpc=E2=80=99=
 has initializer but incomplete type
net/rxrpc/ar-key.c:37: error: unknown field =E2=80=98name=E2=80=99 spec=
ified in initializer
net/rxrpc/ar-key.c:37: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:37: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc=E2=80=99)
net/rxrpc/ar-key.c:38: error: unknown field =E2=80=98instantiate=E2=80=99=
 specified in initializer
net/rxrpc/ar-key.c:38: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:38: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc=E2=80=99)
net/rxrpc/ar-key.c:39: error: unknown field =E2=80=98match=E2=80=99 spe=
cified in initializer
net/rxrpc/ar-key.c:39: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:39: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc=E2=80=99)
net/rxrpc/ar-key.c:40: error: unknown field =E2=80=98destroy=E2=80=99 s=
pecified in initializer
net/rxrpc/ar-key.c:40: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:40: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc=E2=80=99)
net/rxrpc/ar-key.c:41: error: unknown field =E2=80=98describe=E2=80=99 =
specified in initializer
net/rxrpc/ar-key.c:41: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:41: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc=E2=80=99)
net/rxrpc/ar-key.c:50: error: variable =E2=80=98key_type_rxrpc_s=E2=80=99=
 has initializer but incomplete type
net/rxrpc/ar-key.c:51: error: unknown field =E2=80=98name=E2=80=99 spec=
ified in initializer
net/rxrpc/ar-key.c:51: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:51: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc_s=E2=80=99)
net/rxrpc/ar-key.c:52: error: unknown field =E2=80=98instantiate=E2=80=99=
 specified in initializer
net/rxrpc/ar-key.c:52: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:52: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc_s=E2=80=99)
net/rxrpc/ar-key.c:53: error: unknown field =E2=80=98match=E2=80=99 spe=
cified in initializer
net/rxrpc/ar-key.c:53: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:53: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc_s=E2=80=99)
net/rxrpc/ar-key.c:54: error: unknown field =E2=80=98destroy=E2=80=99 s=
pecified in initializer
net/rxrpc/ar-key.c:54: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:54: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc_s=E2=80=99)
net/rxrpc/ar-key.c:55: error: unknown field =E2=80=98describe=E2=80=99 =
specified in initializer
net/rxrpc/ar-key.c:55: warning: excess elements in struct initializer
net/rxrpc/ar-key.c:55: warning: (near initialization for =E2=80=98key_t=
ype_rxrpc_s=E2=80=99)
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_instantiate=E2=80=99:
net/rxrpc/ar-key.c:129: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:132: warning: implicit declaration of function =E2=80=
=98key_payload_reserve=E2=80=99
net/rxrpc/ar-key.c:145: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:146: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_instantiate_s=E2=80=99:
net/rxrpc/ar-key.c:167: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:167: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:178: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_destroy=E2=80=99:
net/rxrpc/ar-key.c:188: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_destroy_s=E2=80=99:
net/rxrpc/ar-key.c:196: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:197: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c:198: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_describe=E2=80=99:
net/rxrpc/ar-key.c:207: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_request_key=E2=80=99:
net/rxrpc/ar-key.c:233: warning: implicit declaration of function =E2=80=
=98request_key=E2=80=99
net/rxrpc/ar-key.c:233: warning: assignment makes pointer from integer =
without a cast
net/rxrpc/ar-key.c:242: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_server_keyring=E2=80=99:
net/rxrpc/ar-key.c:270: error: =E2=80=98key_type_keyring=E2=80=99 undec=
lared (first use in this function)
net/rxrpc/ar-key.c:270: error: (Each undeclared identifier is reported =
only once
net/rxrpc/ar-key.c:270: error: for each function it appears in.)
net/rxrpc/ar-key.c:270: warning: assignment makes pointer from integer =
without a cast
net/rxrpc/ar-key.c:279: error: dereferencing pointer to incomplete type
net/rxrpc/ar-key.c: In function =E2=80=98rxrpc_get_server_data_key=E2=80=
=99:
net/rxrpc/ar-key.c:301: warning: implicit declaration of function =E2=80=
=98key_alloc=E2=80=99
net/rxrpc/ar-key.c:302: error: =E2=80=98KEY_ALLOC_NOT_IN_QUOTA=E2=80=99=
 undeclared (first use in this function)
net/rxrpc/ar-key.c:302: warning: assignment makes pointer from integer =
without a cast
net/rxrpc/ar-key.c:319: warning: implicit declaration of function =E2=80=
=98key_instantiate_and_link=E2=80=99
net/rxrpc/ar-key.c:328: warning: implicit declaration of function =E2=80=
=98key_revoke=E2=80=99
make[2]: *** [net/rxrpc/ar-key.o] Error 1
  CC [M]  net/rxrpc/ar-output.o
net/rxrpc/ar-output.c: In function =E2=80=98rxrpc_client_sendmsg=E2=80=99=
:
net/rxrpc/ar-output.c:158: error: dereferencing pointer to incomplete t=
ype
make[2]: *** [net/rxrpc/ar-output.o] Error 1
  CC [M]  net/rxrpc/ar-security.o
net/rxrpc/ar-security.c: In function =E2=80=98rxrpc_init_client_conn_se=
curity=E2=80=99:
net/rxrpc/ar-security.c:138: error: dereferencing pointer to incomplete=
 type
net/rxrpc/ar-security.c: In function =E2=80=98rxrpc_init_server_conn_se=
curity=E2=80=99:
net/rxrpc/ar-security.c:163: error: =E2=80=98key_ref_t=E2=80=99 undecla=
red (first use in this function)
net/rxrpc/ar-security.c:163: error: (Each undeclared identifier is repo=
rted only once
net/rxrpc/ar-security.c:163: error: for each function it appears in.)
net/rxrpc/ar-security.c:163: error: expected =E2=80=98;=E2=80=99 before=
 =E2=80=98kref=E2=80=99
net/rxrpc/ar-security.c:164: warning: ISO C90 forbids mixed declaration=
s and code
net/rxrpc/ar-security.c:198: error: =E2=80=98kref=E2=80=99 undeclared (=
first use in this function)
net/rxrpc/ar-security.c:198: warning: implicit declaration of function =
=E2=80=98keyring_search=E2=80=99
net/rxrpc/ar-security.c:198:56: error: macro "make_key_ref" passed 2 ar=
guments, but takes just 1
net/rxrpc/ar-security.c:198: error: =E2=80=98make_key_ref=E2=80=99 unde=
clared (first use in this function)
make[2]: *** [net/rxrpc/ar-security.o] Error 1

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.21
# Wed May  2 14:34:38 2007
#
CONFIG_X86_64=3Dy
CONFIG_64BIT=3Dy
CONFIG_X86=3Dy
CONFIG_GENERIC_TIME=3Dy
CONFIG_GENERIC_TIME_VSYSCALL=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_SEMAPHORE_SLEEPERS=3Dy
CONFIG_MMU=3Dy
CONFIG_ZONE_DMA=3Dy
CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_X86_CMPXCHG=3Dy
CONFIG_EARLY_PRINTK=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
CONFIG_DMI=3Dy
CONFIG_AUDIT_ARCH=3Dy
CONFIG_GENERIC_BUG=3Dy
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=3Dy
CONFIG_LOCK_KERNEL=3Dy
CONFIG_INIT_ENV_ARG_LIMIT=3D32

#
# General setup
#
CONFIG_LOCALVERSION=3D""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
# CONFIG_IPC_NS is not set
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_POSIX_MQUEUE=3Dy
CONFIG_BSD_PROCESS_ACCT=3Dy
CONFIG_BSD_PROCESS_ACCT_V3=3Dy
CONFIG_TASKSTATS=3Dy
CONFIG_TASK_DELAY_ACCT=3Dy
# CONFIG_TASK_XACCT is not set
# CONFIG_UTS_NS is not set
CONFIG_AUDIT=3Dy
CONFIG_AUDITSYSCALL=3Dy
CONFIG_IKCONFIG=3Dy
CONFIG_IKCONFIG_PROC=3Dy
# CONFIG_CPUSETS is not set
CONFIG_SYSFS_DEPRECATED=3Dy
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=3Dy
CONFIG_INITRAMFS_SOURCE=3D""
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
# CONFIG_EMBEDDED is not set
CONFIG_SYSCTL_SYSCALL=3Dy
CONFIG_KALLSYMS=3Dy
CONFIG_KALLSYMS_ALL=3Dy
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SHMEM=3Dy
CONFIG_SLAB=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_RT_MUTEXES=3Dy
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=3D0
# CONFIG_SLOB is not set

#
# Loadable module support
#
CONFIG_MODULES=3Dy
CONFIG_MODULE_UNLOAD=3Dy
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=3Dy
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=3Dy
CONFIG_STOP_MACHINE=3Dy

#
# Block layer
#
CONFIG_BLOCK=3Dy
# CONFIG_BLK_DEV_IO_TRACE is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
CONFIG_IOSCHED_AS=3Dy
CONFIG_IOSCHED_DEADLINE=3Dy
CONFIG_IOSCHED_CFQ=3Dy
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=3Dy
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"cfq"

#
# Processor type and features
#
CONFIG_X86_PC=3Dy
# CONFIG_X86_VSMP is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=3Dy
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_L1_CACHE_BYTES=3D64
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_INTERNODE_CACHE_BYTES=3D64
CONFIG_X86_TSC=3Dy
CONFIG_X86_GOOD_APIC=3Dy
CONFIG_MICROCODE=3Dm
CONFIG_MICROCODE_OLD_INTERFACE=3Dy
CONFIG_X86_MSR=3Dm
CONFIG_X86_CPUID=3Dm
CONFIG_X86_HT=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_MTRR=3Dy
CONFIG_SMP=3Dy
CONFIG_SCHED_SMT=3Dy
CONFIG_SCHED_MC=3Dy
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=3Dy
CONFIG_PREEMPT_BKL=3Dy
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_FLATMEM_ENABLE=3Dy
CONFIG_SELECT_MEMORY_MODEL=3Dy
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=3Dy
CONFIG_SPARSEMEM=3Dy
CONFIG_HAVE_MEMORY_PRESENT=3Dy
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_EXTREME=3Dy

#
# Memory hotplug is currently incompatible with Software Suspend
#
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_RESOURCES_64BIT=3Dy
CONFIG_ZONE_DMA_FLAG=3D1
CONFIG_NR_CPUS=3D2
CONFIG_HOTPLUG_CPU=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
CONFIG_HPET_TIMER=3Dy
CONFIG_IOMMU=3Dy
CONFIG_CALGARY_IOMMU=3Dy
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=3Dy
CONFIG_SWIOTLB=3Dy
CONFIG_X86_MCE=3Dy
CONFIG_X86_MCE_INTEL=3Dy
CONFIG_X86_MCE_AMD=3Dy
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=3D0x200000
CONFIG_SECCOMP=3Dy
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000
# CONFIG_REORDER is not set
CONFIG_K8_NB=3Dy
CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_ISA_DMA_API=3Dy
CONFIG_GENERIC_PENDING_IRQ=3Dy

#
# Power management options
#
CONFIG_PM=3Dy
# CONFIG_PM_LEGACY is not set
# CONFIG_PM_DEBUG is not set
# CONFIG_PM_SYSFS_DEPRECATED is not set
CONFIG_SOFTWARE_SUSPEND=3Dy
CONFIG_PM_STD_PARTITION=3D"/dev/sda3"
CONFIG_SUSPEND_SMP=3Dy

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI=3Dy
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_SLEEP_PROC_FS=3Dy
# CONFIG_ACPI_SLEEP_PROC_SLEEP is not set
# CONFIG_ACPI_PROCFS is not set
CONFIG_ACPI_AC=3Dm
CONFIG_ACPI_BATTERY=3Dm
CONFIG_ACPI_BUTTON=3Dm
CONFIG_ACPI_VIDEO=3Dm
CONFIG_ACPI_FAN=3Dm
CONFIG_ACPI_DOCK=3Dm
CONFIG_ACPI_BAY=3Dm
CONFIG_ACPI_PROCESSOR=3Dm
CONFIG_ACPI_HOTPLUG_CPU=3Dy
CONFIG_ACPI_THERMAL=3Dm
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_BLACKLIST_YEAR=3D0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=3Dy
CONFIG_ACPI_POWER=3Dy
CONFIG_ACPI_SYSTEM=3Dy
CONFIG_X86_PM_TIMER=3Dy
CONFIG_ACPI_CONTAINER=3Dm
CONFIG_ACPI_SBS=3Dm

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_MMCONFIG=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_PCI_MSI=3Dy
# CONFIG_PCI_DEBUG is not set
CONFIG_HT_IRQ=3Dy

#
# PCCARD (PCMCIA/CardBus) support
#
# CONFIG_PCCARD is not set

#
# PCI Hotplug Support
#
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_BINFMT_MISC=3Dm
# CONFIG_IA32_EMULATION is not set

#
# Networking
#
CONFIG_NET=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
CONFIG_PACKET_MMAP=3Dy
CONFIG_UNIX=3Dy
CONFIG_XFRM=3Dy
CONFIG_XFRM_USER=3Dm
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
CONFIG_NET_KEY=3Dm
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
CONFIG_IP_ADVANCED_ROUTER=3Dy
# CONFIG_ASK_IP_FIB_HASH is not set
CONFIG_IP_FIB_TRIE=3Dy
# CONFIG_IP_FIB_HASH is not set
CONFIG_IP_MULTIPLE_TABLES=3Dy
# CONFIG_IP_ROUTE_MULTIPATH is not set
CONFIG_IP_ROUTE_VERBOSE=3Dy
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=3Dm
CONFIG_NET_IPGRE=3Dm
CONFIG_NET_IPGRE_BROADCAST=3Dy
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=3Dy
CONFIG_INET_AH=3Dm
CONFIG_INET_ESP=3Dm
CONFIG_INET_IPCOMP=3Dm
CONFIG_INET_XFRM_TUNNEL=3Dm
CONFIG_INET_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_TRANSPORT=3Dm
CONFIG_INET_XFRM_MODE_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_BEET=3Dm
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
CONFIG_TCP_CONG_ADVANCED=3Dy
CONFIG_TCP_CONG_BIC=3Dm
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_TCP_CONG_WESTWOOD=3Dm
CONFIG_TCP_CONG_HTCP=3Dm
CONFIG_TCP_CONG_HSTCP=3Dm
CONFIG_TCP_CONG_HYBLA=3Dm
CONFIG_TCP_CONG_VEGAS=3Dm
CONFIG_TCP_CONG_SCALABLE=3Dm
CONFIG_TCP_CONG_LP=3Dm
CONFIG_TCP_CONG_VENO=3Dm
CONFIG_TCP_CONG_YEAH=3Dm
CONFIG_TCP_CONG_ILLINOIS=3Dm
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=3Dy
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
CONFIG_TCP_MD5SIG=3Dy

#
# IP: Virtual Server Configuration
#
# CONFIG_IP_VS is not set
CONFIG_IPV6=3Dm
CONFIG_IPV6_PRIVACY=3Dy
CONFIG_IPV6_ROUTER_PREF=3Dy
CONFIG_IPV6_ROUTE_INFO=3Dy
CONFIG_IPV6_OPTIMISTIC_DAD=3Dy
CONFIG_INET6_AH=3Dm
CONFIG_INET6_ESP=3Dm
CONFIG_INET6_IPCOMP=3Dm
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_TUNNEL=3Dm
CONFIG_INET6_TUNNEL=3Dm
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=3Dm
CONFIG_IPV6_TUNNEL=3Dm
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_NETLABEL is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=3Dy
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_BRIDGE_NETFILTER=3Dy

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=3Dm
CONFIG_NETFILTER_NETLINK_QUEUE=3Dm
CONFIG_NETFILTER_NETLINK_LOG=3Dm
CONFIG_NF_CONNTRACK_ENABLED=3Dm
CONFIG_NF_CONNTRACK=3Dm
CONFIG_NF_CT_ACCT=3Dy
CONFIG_NF_CONNTRACK_MARK=3Dy
CONFIG_NF_CONNTRACK_EVENTS=3Dy
CONFIG_NF_CT_PROTO_GRE=3Dm
CONFIG_NF_CT_PROTO_SCTP=3Dm
CONFIG_NF_CONNTRACK_AMANDA=3Dm
CONFIG_NF_CONNTRACK_FTP=3Dm
CONFIG_NF_CONNTRACK_H323=3Dm
CONFIG_NF_CONNTRACK_IRC=3Dm
CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dm
CONFIG_NF_CONNTRACK_PPTP=3Dm
CONFIG_NF_CONNTRACK_SANE=3Dm
CONFIG_NF_CONNTRACK_SIP=3Dm
CONFIG_NF_CONNTRACK_TFTP=3Dm
CONFIG_NF_CT_NETLINK=3Dm
CONFIG_NETFILTER_XTABLES=3Dm
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dm
CONFIG_NETFILTER_XT_TARGET_MARK=3Dm
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dm
CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dm
CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm
# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set
# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
# CONFIG_NETFILTER_XT_MATCH_PHYSDEV is not set
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
CONFIG_NETFILTER_XT_MATCH_STATE=3Dm
CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm

#
# IP: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV4=3Dm
CONFIG_NF_CONNTRACK_PROC_COMPAT=3Dy
CONFIG_IP_NF_QUEUE=3Dm
CONFIG_IP_NF_IPTABLES=3Dm
CONFIG_IP_NF_MATCH_IPRANGE=3Dm
CONFIG_IP_NF_MATCH_TOS=3Dm
CONFIG_IP_NF_MATCH_RECENT=3Dm
CONFIG_IP_NF_MATCH_ECN=3Dm
# CONFIG_IP_NF_MATCH_AH is not set
CONFIG_IP_NF_MATCH_TTL=3Dm
CONFIG_IP_NF_MATCH_OWNER=3Dm
CONFIG_IP_NF_MATCH_ADDRTYPE=3Dm
CONFIG_IP_NF_FILTER=3Dm
CONFIG_IP_NF_TARGET_REJECT=3Dm
CONFIG_IP_NF_TARGET_LOG=3Dm
CONFIG_IP_NF_TARGET_ULOG=3Dm
# CONFIG_NF_NAT is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration (EXPERIMENTAL)
#
# CONFIG_NF_CONNTRACK_IPV6 is not set
# CONFIG_IP6_NF_QUEUE is not set
# CONFIG_IP6_NF_IPTABLES is not set

#
# Bridge: Netfilter Configuration
#
# CONFIG_BRIDGE_NF_EBTABLES is not set

#
# DCCP Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP is not set

#
# SCTP Configuration (EXPERIMENTAL)
#
# CONFIG_IP_SCTP is not set

#
# TIPC Configuration (EXPERIMENTAL)
#
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_BRIDGE=3Dm
CONFIG_VLAN_8021Q=3Dm
# CONFIG_DECNET is not set
CONFIG_LLC=3Dm
CONFIG_LLC2=3Dm
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set

#
# QoS and/or fair queueing
#
CONFIG_NET_SCHED=3Dy
CONFIG_NET_SCH_FIFO=3Dy

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=3Dm
CONFIG_NET_SCH_HTB=3Dm
CONFIG_NET_SCH_HFSC=3Dm
CONFIG_NET_SCH_PRIO=3Dm
CONFIG_NET_SCH_RED=3Dm
CONFIG_NET_SCH_SFQ=3Dm
CONFIG_NET_SCH_TEQL=3Dm
CONFIG_NET_SCH_TBF=3Dm
CONFIG_NET_SCH_GRED=3Dm
CONFIG_NET_SCH_DSMARK=3Dm
CONFIG_NET_SCH_NETEM=3Dm
CONFIG_NET_SCH_INGRESS=3Dm

#
# Classification
#
CONFIG_NET_CLS=3Dy
CONFIG_NET_CLS_BASIC=3Dm
CONFIG_NET_CLS_TCINDEX=3Dm
CONFIG_NET_CLS_ROUTE4=3Dm
CONFIG_NET_CLS_ROUTE=3Dy
CONFIG_NET_CLS_FW=3Dm
CONFIG_NET_CLS_U32=3Dm
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
CONFIG_NET_CLS_RSVP=3Dm
CONFIG_NET_CLS_RSVP6=3Dm
CONFIG_NET_EMATCH=3Dy
CONFIG_NET_EMATCH_STACK=3D32
CONFIG_NET_EMATCH_CMP=3Dm
CONFIG_NET_EMATCH_NBYTE=3Dm
CONFIG_NET_EMATCH_U32=3Dm
CONFIG_NET_EMATCH_META=3Dm
# CONFIG_NET_EMATCH_TEXT is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_POLICE=3Dy
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_ESTIMATOR=3Dy

#
# Network testing
#
CONFIG_NET_PKTGEN=3Dm
CONFIG_NET_TCPPROBE=3Dm
# CONFIG_HAMRADIO is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=3Dm
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_FIB_RULES=3Dy

#
# Wireless
#
# CONFIG_CFG80211 is not set
CONFIG_WIRELESS_EXT=3Dy
# CONFIG_IEEE80211 is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_STANDALONE=3Dy
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
CONFIG_FW_LOADER=3Dm
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set

#
# Connector - unified userspace <-> kernelspace linker
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Plug and Play support
#
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy

#
# Block devices
#
CONFIG_BLK_DEV_FD=3Dm
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=3Dm
CONFIG_BLK_DEV_CRYPTOLOOP=3Dm
CONFIG_BLK_DEV_NBD=3Dm
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=3Dy
CONFIG_BLK_DEV_RAM_COUNT=3D16
CONFIG_BLK_DEV_RAM_SIZE=3D65536
CONFIG_BLK_DEV_RAM_BLOCKSIZE=3D1024
CONFIG_CDROM_PKTCDVD=3Dm
CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set

#
# Misc devices
#
# CONFIG_IBM_ASM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set

#
# ATA/ATAPI/MFM/RLL support
#
CONFIG_IDE=3Dm
CONFIG_BLK_DEV_IDE=3Dm

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_HD_IDE is not set
CONFIG_BLK_DEV_IDEDISK=3Dm
# CONFIG_IDEDISK_MULTI_MODE is not set
CONFIG_BLK_DEV_IDECD=3Dm
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
CONFIG_BLK_DEV_IDESCSI=3Dm
CONFIG_BLK_DEV_IDEACPI=3Dy
# CONFIG_IDE_TASK_IOCTL is not set

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=3Dm
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEPCI=3Dy
CONFIG_IDEPCI_SHARE_IRQ=3Dy
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=3Dm
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
CONFIG_IDEDMA_ONLYDISK=3Dy
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=3Dm
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=3Dm
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
# CONFIG_IDE_ARM is not set
CONFIG_BLK_DEV_IDEDMA=3Dy
# CONFIG_IDEDMA_IVB is not set
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dy
CONFIG_SCSI_TGT=3Dm
CONFIG_SCSI_NETLINK=3Dy
CONFIG_SCSI_PROC_FS=3Dy

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
CONFIG_CHR_DEV_ST=3Dm
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=3Dy
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=3Dm
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=3Dy
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=3Dy
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=3Dm
CONFIG_SCSI_FC_ATTRS=3Dm
CONFIG_SCSI_ISCSI_ATTRS=3Dm
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set

#
# SCSI low-level drivers
#
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_EATA=3Dm
CONFIG_SCSI_EATA_TAGGED_QUEUE=3Dy
CONFIG_SCSI_EATA_LINKED_COMMANDS=3Dy
CONFIG_SCSI_EATA_MAX_TAGS=3D16
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_ESP_CORE is not set
# CONFIG_SCSI_SRP is not set

#
# Serial ATA (prod) and Parallel ATA (experimental) drivers
#
CONFIG_ATA=3Dy
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_SATA_AHCI=3Dy
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=3Dy
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACPI=3Dy
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_ATA_GENERIC=3Dm
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_MPIIX=3Dm
CONFIG_PATA_OLDPIIX=3Dm
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# Fusion MPT device support
#
# CONFIG_FUSION is not set
# CONFIG_FUSION_SPI is not set
# CONFIG_FUSION_FC is not set
# CONFIG_FUSION_SAS is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_IEEE1394 is not set

#
# I2O device support
#
CONFIG_I2O=3Dm
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=3Dy
CONFIG_I2O_EXT_ADAPTEC=3Dy
CONFIG_I2O_EXT_ADAPTEC_DMA64=3Dy
CONFIG_I2O_CONFIG=3Dm
CONFIG_I2O_CONFIG_OLD_IOCTL=3Dy
# CONFIG_I2O_BUS is not set
CONFIG_I2O_BLOCK=3Dm
CONFIG_I2O_SCSI=3Dm
CONFIG_I2O_PROC=3Dm

#
# Macintosh device drivers
#
# CONFIG_MAC_EMUMOUSEBTN is not set

#
# Network device support
#
CONFIG_NETDEVICES=3Dy
CONFIG_DUMMY=3Dm
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_NET_SB1000 is not set

#
# ARCnet devices
#
# CONFIG_ARCNET is not set

#
# PHY device support
#

#
# Ethernet (10 or 100Mbit)
#
# CONFIG_NET_ETHERNET is not set
CONFIG_MII=3Dm

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
CONFIG_SKGE=3Dm
CONFIG_SKY2=3Dm
# CONFIG_SK98LIN is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set

#
# Ethernet (10000 Mbit)
#
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set
# CONFIG_MYRI10GE is not set
CONFIG_NETXEN_NIC=3Dm

#
# Token Ring devices
#
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set

#
# Wan interfaces
#
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set
CONFIG_NETCONSOLE=3Dm
CONFIG_NETPOLL=3Dy
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=3Dy

#
# ISDN subsystem
#
# CONFIG_ISDN is not set

#
# Telephony Support
#
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
# CONFIG_INPUT_FF_MEMLESS is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
CONFIG_INPUT_EVDEV=3Dm
CONFIG_INPUT_EVBUG=3Dm

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy
CONFIG_KEYBOARD_SUNKBD=3Dm
CONFIG_KEYBOARD_LKKBD=3Dm
CONFIG_KEYBOARD_XTKBD=3Dm
CONFIG_KEYBOARD_NEWTON=3Dm
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=3Dy
CONFIG_MOUSE_PS2=3Dm
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=3Dy
CONFIG_INPUT_PCSPKR=3Dm
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_UINPUT is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
CONFIG_SERIO_SERPORT=3Dm
CONFIG_SERIO_CT82C710=3Dm
CONFIG_SERIO_PCIPS2=3Dm
CONFIG_SERIO_LIBPS2=3Dy
CONFIG_SERIO_RAW=3Dm
CONFIG_GAMEPORT=3Dm
CONFIG_GAMEPORT_NS558=3Dm
CONFIG_GAMEPORT_L4=3Dm
CONFIG_GAMEPORT_EMU10K1=3Dm
CONFIG_GAMEPORT_FM801=3Dm

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
# CONFIG_VT_HW_CONSOLE_BINDING is not set
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=3Dy
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_SERIAL_8250_PCI=3Dy
CONFIG_SERIAL_8250_PNP=3Dy
CONFIG_SERIAL_8250_NR_UARTS=3D4
CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
CONFIG_SERIAL_8250_EXTENDED=3Dy
CONFIG_SERIAL_8250_MANY_PORTS=3Dy
CONFIG_SERIAL_8250_SHARE_IRQ=3Dy
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=3Dy

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=3Dy
CONFIG_SERIAL_CORE_CONSOLE=3Dy
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=3Dy
CONFIG_LEGACY_PTYS=3Dy
CONFIG_LEGACY_PTY_COUNT=3D256

#
# IPMI
#
# CONFIG_IPMI_HANDLER is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
CONFIG_HW_RANDOM=3Dy
CONFIG_HW_RANDOM_INTEL=3Dm
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
CONFIG_NVRAM=3Dm
CONFIG_RTC=3Dm
CONFIG_GEN_RTC=3Dm
CONFIG_GEN_RTC_X=3Dy
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_AGP=3Dy
CONFIG_AGP_AMD64=3Dy
CONFIG_AGP_INTEL=3Dy
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_DRM=3Dm
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=3Dm
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I830 is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=3Dy
# CONFIG_HPET_RTC_IRQ is not set
CONFIG_HPET_MMAP=3Dy
CONFIG_HANGCHECK_TIMER=3Dm

#
# TPM devices
#
CONFIG_TCG_TPM=3Dm
CONFIG_TCG_TIS=3Dm
CONFIG_TCG_NSC=3Dm
CONFIG_TCG_ATMEL=3Dm
CONFIG_TCG_INFINEON=3Dm
# CONFIG_TELCLOCK is not set

#
# I2C support
#
CONFIG_I2C=3Dm
CONFIG_I2C_CHARDEV=3Dm

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=3Dm
CONFIG_I2C_ALGOPCF=3Dm
CONFIG_I2C_ALGOPCA=3Dm

#
# I2C Hardware Bus support
#
CONFIG_I2C_ALI1535=3Dm
CONFIG_I2C_ALI1563=3Dm
CONFIG_I2C_ALI15X3=3Dm
CONFIG_I2C_AMD756=3Dm
CONFIG_I2C_AMD756_S4882=3Dm
CONFIG_I2C_AMD8111=3Dm
CONFIG_I2C_I801=3Dm
CONFIG_I2C_I810=3Dm
CONFIG_I2C_PIIX4=3Dm
CONFIG_I2C_NFORCE2=3Dm
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PARPORT_LIGHT=3Dm
CONFIG_I2C_PROSAVAGE=3Dm
CONFIG_I2C_SAVAGE4=3Dm
CONFIG_I2C_SIS5595=3Dm
CONFIG_I2C_SIS630=3Dm
CONFIG_I2C_SIS96X=3Dm
CONFIG_I2C_STUB=3Dm
CONFIG_I2C_VIA=3Dm
CONFIG_I2C_VIAPRO=3Dm
CONFIG_I2C_VOODOO3=3Dm
CONFIG_I2C_PCA_ISA=3Dm

#
# Miscellaneous I2C Chip support
#
CONFIG_SENSORS_DS1337=3Dm
# CONFIG_SENSORS_DS1374 is not set
CONFIG_SENSORS_EEPROM=3Dm
CONFIG_SENSORS_PCF8574=3Dm
# CONFIG_SENSORS_PCA9539 is not set
CONFIG_SENSORS_PCF8591=3Dm
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set

#
# Dallas's 1-wire bus
#
# CONFIG_W1 is not set

#
# Hardware Monitoring support
#
# CONFIG_HWMON is not set
# CONFIG_HWMON_VID is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# Digital Video Broadcasting Devices
#
# CONFIG_DVB is not set
# CONFIG_USB_DABUSB is not set

#
# Graphics support
#
CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
# CONFIG_LCD_CLASS_DEVICE is not set
# CONFIG_BACKLIGHT_PROGEAR is not set
CONFIG_FB=3Dy
CONFIG_FIRMWARE_EDID=3Dy
CONFIG_FB_DDC=3Dm
CONFIG_FB_CFB_FILLRECT=3Dy
CONFIG_FB_CFB_COPYAREA=3Dy
CONFIG_FB_CFB_IMAGEBLIT=3Dy
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=3Dy
CONFIG_FB_MODE_HELPERS=3Dy
CONFIG_FB_TILEBLITTING=3Dy

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=3Dm
CONFIG_FB_VESA=3Dy
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=3Dm
CONFIG_FB_NVIDIA_I2C=3Dy
CONFIG_FB_NVIDIA_BACKLIGHT=3Dy
# CONFIG_FB_RIVA is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=3Dm
CONFIG_FB_RADEON_I2C=3Dy
# CONFIG_FB_RADEON_BACKLIGHT is not set
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=3Dm
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=3Dm
CONFIG_FB_ATY_CT=3Dy
CONFIG_FB_ATY_GENERIC_LCD=3Dy
CONFIG_FB_ATY_GX=3Dy
# CONFIG_FB_ATY_BACKLIGHT is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_VIDEO_SELECT=3Dy
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_FRAMEBUFFER_CONSOLE=3Dm
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=3Dy
CONFIG_FONT_8x16=3Dy

#
# Logo configuration
#
# CONFIG_LOGO is not set

#
# Sound
#
CONFIG_SOUND=3Dm

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=3Dm
CONFIG_SND_TIMER=3Dm
CONFIG_SND_PCM=3Dm
CONFIG_SND_SEQUENCER=3Dm
CONFIG_SND_SEQ_DUMMY=3Dm
CONFIG_SND_OSSEMUL=3Dy
CONFIG_SND_MIXER_OSS=3Dm
CONFIG_SND_PCM_OSS=3Dm
CONFIG_SND_PCM_OSS_PLUGINS=3Dy
CONFIG_SND_SEQUENCER_OSS=3Dy
# CONFIG_SND_RTCTIMER is not set
CONFIG_SND_DYNAMIC_MINORS=3Dy
CONFIG_SND_SUPPORT_OLD_API=3Dy
CONFIG_SND_VERBOSE_PROCFS=3Dy
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set

#
# Generic devices
#
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=3Dm
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set

#
# SoC audio support
#
# CONFIG_SND_SOC is not set

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set

#
# HID Devices
#
CONFIG_HID=3Dy
# CONFIG_HID_DEBUG is not set

#
# USB Input Devices
#
CONFIG_USB_HID=3Dm
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
# CONFIG_HID_FF is not set
# CONFIG_USB_HIDDEV is not set

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set

#
# USB support
#
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB=3Dy
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=3Dy
CONFIG_USB_DEVICE_CLASS=3Dy
CONFIG_USB_DYNAMIC_MINORS=3Dy
CONFIG_USB_SUSPEND=3Dy
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=3Dm
CONFIG_USB_EHCI_SPLIT_ISO=3Dy
CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
CONFIG_USB_EHCI_TT_NEWSCHED=3Dy
# CONFIG_USB_EHCI_BIG_ENDIAN_MMIO is not set
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=3Dm
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
CONFIG_USB_UHCI_HCD=3Dm
# CONFIG_USB_SL811_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=3Dm

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=3Dy
CONFIG_USB_STORAGE_FREECOM=3Dy
CONFIG_USB_STORAGE_ISD200=3Dy
CONFIG_USB_STORAGE_DPCM=3Dy
CONFIG_USB_STORAGE_USBAT=3Dy
CONFIG_USB_STORAGE_SDDR09=3Dy
CONFIG_USB_STORAGE_SDDR55=3Dy
CONFIG_USB_STORAGE_JUMPSHOT=3Dy
CONFIG_USB_STORAGE_ALAUDA=3Dy
# CONFIG_USB_STORAGE_KARMA is not set
CONFIG_USB_LIBUSUAL=3Dy

#
# USB Input Devices
#
# CONFIG_USB_AIPTEK is not set
# CONFIG_USB_WACOM is not set
# CONFIG_USB_ACECAD is not set
# CONFIG_USB_KBTAB is not set
# CONFIG_USB_POWERMATE is not set
# CONFIG_USB_TOUCHSCREEN is not set
# CONFIG_USB_YEALINK is not set
# CONFIG_USB_XPAD is not set
# CONFIG_USB_ATI_REMOTE is not set
# CONFIG_USB_ATI_REMOTE2 is not set
# CONFIG_USB_KEYSPAN_REMOTE is not set
# CONFIG_USB_APPLETOUCH is not set
# CONFIG_USB_GTCO is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=3Dm
CONFIG_USB_KAWETH=3Dm
CONFIG_USB_PEGASUS=3Dm
CONFIG_USB_RTL8150=3Dm
CONFIG_USB_USBNET_MII=3Dm
CONFIG_USB_USBNET=3Dm
CONFIG_USB_NET_CDCETHER=3Dm
# CONFIG_USB_NET_DM9601 is not set
CONFIG_USB_NET_GL620A=3Dm
CONFIG_USB_NET_NET1080=3Dm
CONFIG_USB_NET_PLUSB=3Dm
CONFIG_USB_NET_MCS7830=3Dm
CONFIG_USB_NET_RNDIS_HOST=3Dm
CONFIG_USB_NET_CDC_SUBSET=3Dm
CONFIG_USB_ALI_M5632=3Dy
CONFIG_USB_AN2720=3Dy
CONFIG_USB_BELKIN=3Dy
CONFIG_USB_ARMLINUX=3Dy
CONFIG_USB_EPSON2888=3Dy
# CONFIG_USB_KC2190 is not set
CONFIG_USB_NET_ZAURUS=3Dm
CONFIG_USB_MON=3Dy

#
# USB port drivers
#

#
# USB Serial Converter support
#
CONFIG_USB_SERIAL=3Dm
CONFIG_USB_SERIAL_GENERIC=3Dy
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_AIRPRIME is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP2101 is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_FUNSOFT is not set
CONFIG_USB_SERIAL_VISOR=3Dm
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_HP4X is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set

#
# USB DSL modem support
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set

#
# MMC/SD Card support
#
# CONFIG_MMC is not set

#
# LED devices
#
CONFIG_NEW_LEDS=3Dy
CONFIG_LEDS_CLASS=3Dm

#
# LED drivers
#

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=3Dy
CONFIG_LEDS_TRIGGER_TIMER=3Dm
CONFIG_LEDS_TRIGGER_IDE_DISK=3Dy
CONFIG_LEDS_TRIGGER_HEARTBEAT=3Dm

#
# InfiniBand support
#
# CONFIG_INFINIBAND is not set

#
# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
#
CONFIG_EDAC=3Dy

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=3Dy
# CONFIG_EDAC_E752X is not set
CONFIG_EDAC_POLL=3Dy

#
# Real Time Clock
#
CONFIG_RTC_LIB=3Dy
CONFIG_RTC_CLASS=3Dy
CONFIG_RTC_HCTOSYS=3Dy
CONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=3Dm
CONFIG_RTC_INTF_PROC=3Dm
CONFIG_RTC_INTF_DEV=3Dm
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set

#
# RTC drivers
#
CONFIG_RTC_DRV_CMOS=3Dm
CONFIG_RTC_DRV_X1205=3Dm
CONFIG_RTC_DRV_DS1307=3Dm
CONFIG_RTC_DRV_DS1553=3Dm
CONFIG_RTC_DRV_ISL1208=3Dm
CONFIG_RTC_DRV_DS1672=3Dm
CONFIG_RTC_DRV_DS1742=3Dm
CONFIG_RTC_DRV_PCF8563=3Dm
CONFIG_RTC_DRV_RS5C372=3Dm
CONFIG_RTC_DRV_M48T86=3Dm
CONFIG_RTC_DRV_TEST=3Dm
CONFIG_RTC_DRV_V3020=3Dm

#
# DMA Engine support
#
# CONFIG_DMA_ENGINE is not set

#
# DMA Clients
#

#
# DMA Devices
#

#
# Auxiliary Display support
#

#
# Virtualization
#
# CONFIG_KVM is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set

#
# File systems
#
CONFIG_EXT2_FS=3Dm
CONFIG_EXT2_FS_XATTR=3Dy
CONFIG_EXT2_FS_POSIX_ACL=3Dy
CONFIG_EXT2_FS_SECURITY=3Dy
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=3Dy
CONFIG_EXT3_FS_XATTR=3Dy
CONFIG_EXT3_FS_POSIX_ACL=3Dy
CONFIG_EXT3_FS_SECURITY=3Dy
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=3Dy
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=3Dy
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=3Dy
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_MINIX_FS is not set
CONFIG_ROMFS_FS=3Dm
CONFIG_INOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
# CONFIG_QUOTA is not set
CONFIG_DNOTIFY=3Dy
CONFIG_AUTOFS_FS=3Dm
CONFIG_AUTOFS4_FS=3Dm
CONFIG_FUSE_FS=3Dm

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dm
CONFIG_JOLIET=3Dy
CONFIG_ZISOFS=3Dy
CONFIG_UDF_FS=3Dm
CONFIG_UDF_NLS=3Dy

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dm
CONFIG_MSDOS_FS=3Dm
CONFIG_VFAT_FS=3Dm
CONFIG_FAT_DEFAULT_CODEPAGE=3D437
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
CONFIG_NTFS_FS=3Dm
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_RAMFS=3Dy
CONFIG_CONFIGFS_FS=3Dm

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
CONFIG_CRAMFS=3Dy
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V3=3Dy
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=3Dy
CONFIG_NFS_DIRECTIO=3Dy
CONFIG_NFSD=3Dm
CONFIG_NFSD_V3=3Dy
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_NFSD_TCP=3Dy
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dm
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
CONFIG_RPCSEC_GSS_KRB5=3Dm
CONFIG_RPCSEC_GSS_SPKM3=3Dm
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=3Dy

#
# Native Language Support
#
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"cp437"
CONFIG_NLS_CODEPAGE_437=3Dm
CONFIG_NLS_CODEPAGE_737=3Dm
CONFIG_NLS_CODEPAGE_775=3Dm
CONFIG_NLS_CODEPAGE_850=3Dm
CONFIG_NLS_CODEPAGE_852=3Dm
CONFIG_NLS_CODEPAGE_855=3Dm
CONFIG_NLS_CODEPAGE_857=3Dm
CONFIG_NLS_CODEPAGE_860=3Dm
CONFIG_NLS_CODEPAGE_861=3Dm
CONFIG_NLS_CODEPAGE_862=3Dm
CONFIG_NLS_CODEPAGE_863=3Dm
CONFIG_NLS_CODEPAGE_864=3Dm
CONFIG_NLS_CODEPAGE_865=3Dm
CONFIG_NLS_CODEPAGE_866=3Dm
CONFIG_NLS_CODEPAGE_869=3Dm
CONFIG_NLS_CODEPAGE_936=3Dm
CONFIG_NLS_CODEPAGE_950=3Dm
CONFIG_NLS_CODEPAGE_932=3Dm
CONFIG_NLS_CODEPAGE_949=3Dm
CONFIG_NLS_CODEPAGE_874=3Dm
CONFIG_NLS_ISO8859_8=3Dm
CONFIG_NLS_CODEPAGE_1250=3Dm
CONFIG_NLS_CODEPAGE_1251=3Dm
CONFIG_NLS_ASCII=3Dm
CONFIG_NLS_ISO8859_1=3Dm
CONFIG_NLS_ISO8859_2=3Dm
CONFIG_NLS_ISO8859_3=3Dm
CONFIG_NLS_ISO8859_4=3Dm
CONFIG_NLS_ISO8859_5=3Dm
CONFIG_NLS_ISO8859_6=3Dm
CONFIG_NLS_ISO8859_7=3Dm
CONFIG_NLS_ISO8859_9=3Dm
CONFIG_NLS_ISO8859_13=3Dm
CONFIG_NLS_ISO8859_14=3Dm
CONFIG_NLS_ISO8859_15=3Dm
CONFIG_NLS_KOI8_R=3Dm
CONFIG_NLS_KOI8_U=3Dm
CONFIG_NLS_UTF8=3Dm

#
# Distributed Lock Manager
#
# CONFIG_DLM is not set

#
# Instrumentation Support
#
CONFIG_PROFILING=3Dy
CONFIG_OPROFILE=3Dm
CONFIG_KPROBES=3Dy

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
CONFIG_PRINTK_TIME=3Dy
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_MAGIC_SYSRQ=3Dy
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=3Dy
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_LOG_BUF_SHIFT=3D15
CONFIG_DETECT_SOFTLOCKUP=3Dy
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_PREEMPT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=3Dy
CONFIG_DEBUG_INFO=3Dy
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_LIST is not set
CONFIG_FRAME_POINTER=3Dy
# CONFIG_FORCED_INLINING is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_DEBUG_RODATA=3Dy
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY=3Dy
CONFIG_SECURITY_NETWORK=3Dy
CONFIG_SECURITY_NETWORK_XFRM=3Dy
CONFIG_SECURITY_CAPABILITIES=3Dm
CONFIG_SECURITY_ROOTPLUG=3Dm
# CONFIG_SECURITY_SELINUX is not set

#
# Cryptographic options
#
CONFIG_CRYPTO=3Dy
CONFIG_CRYPTO_ALGAPI=3Dy
CONFIG_CRYPTO_BLKCIPHER=3Dm
CONFIG_CRYPTO_HASH=3Dy
CONFIG_CRYPTO_MANAGER=3Dy
CONFIG_CRYPTO_HMAC=3Dy
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_NULL=3Dm
CONFIG_CRYPTO_MD4=3Dm
CONFIG_CRYPTO_MD5=3Dy
CONFIG_CRYPTO_SHA1=3Dm
CONFIG_CRYPTO_SHA256=3Dm
CONFIG_CRYPTO_SHA512=3Dm
CONFIG_CRYPTO_WP512=3Dm
CONFIG_CRYPTO_TGR192=3Dm
# CONFIG_CRYPTO_GF128MUL is not set
CONFIG_CRYPTO_ECB=3Dm
CONFIG_CRYPTO_CBC=3Dm
CONFIG_CRYPTO_PCBC=3Dm
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_DES=3Dm
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_BLOWFISH=3Dm
CONFIG_CRYPTO_TWOFISH=3Dm
CONFIG_CRYPTO_TWOFISH_COMMON=3Dm
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
CONFIG_CRYPTO_SERPENT=3Dm
CONFIG_CRYPTO_AES=3Dm
# CONFIG_CRYPTO_AES_X86_64 is not set
CONFIG_CRYPTO_CAST5=3Dm
CONFIG_CRYPTO_CAST6=3Dm
CONFIG_CRYPTO_TEA=3Dm
CONFIG_CRYPTO_ARC4=3Dm
CONFIG_CRYPTO_KHAZAD=3Dm
CONFIG_CRYPTO_ANUBIS=3Dm
CONFIG_CRYPTO_DEFLATE=3Dm
CONFIG_CRYPTO_MICHAEL_MIC=3Dm
CONFIG_CRYPTO_CRC32C=3Dm
CONFIG_CRYPTO_CAMELLIA=3Dm
CONFIG_CRYPTO_TEST=3Dm

#
# Hardware crypto devices
#

#
# Library routines
#
CONFIG_BITREVERSE=3Dy
CONFIG_CRC_CCITT=3Dm
# CONFIG_CRC16 is not set
CONFIG_CRC32=3Dy
CONFIG_LIBCRC32C=3Dm
CONFIG_ZLIB_INFLATE=3Dy
CONFIG_ZLIB_DEFLATE=3Dm
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dm
CONFIG_PLIST=3Dy
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT=3Dy




--=20
Stephen Hemminger <shemminger@linux-foundation.org>
