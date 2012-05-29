From: =?ISO-8859-1?Q?Alex_Villac=EDs_Lasso?= <a_villacis@palosanto.com>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Mon, 28 May 2012 22:31:10 -0500
Message-ID: <4FC442FE.8040800@palosanto.com>
References: <20120503064726.GA17337@electric-eye.fr.zoreil.com> <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec> <4FA3EE49.7070805@palosanto.com> <4FA59F5B.5000800@palosanto.com> <20120505230155.GA3300@electric-eye.fr.zoreil.com> <4FBE533E.6030107@palosanto.com> <20120526101133.GA6170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301060009020202030701"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:51990 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2E2Dbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 23:31:35 -0400
In-Reply-To: <20120526101133.GA6170@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090301060009020202030701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

El 26/05/12 05:11, Francois Romieu escribió:
> Alex Villací­s Lasso<a_villacis@palosanto.com>  :
> [...]
>> According to my bisection, the first bad commit is 036dafa28da1e2565a8529de2ae663c37b7a0060 . Here is my bisection log:
> There would be something wrong with bql support.
>
> Can you apply the attached patches on top of 3.4 or later then
> send the kernel log output whent the bug happens ?
>
> Thanks.
>
Attached.

--------------090301060009020202030701
Content-Type: text/plain; charset=UTF-8;
 name="dmesg-r8169.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg-r8169.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.4.0 (alex@karlalex.palosanto.com) (gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC) ) #41 SMP PREEMPT Sun May 27 21:27:11 ECT 2012
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.4.0 root=UUID=4837c784-4583-4efc-8a40-260819368469 ro rd.md=0 rd.lvm=0 rd.dm=0 quiet SYSFONT=latarcyrheb-sun16 rhgb rd.luks=0 LANG=es_ES.UTF-8 KEYTABLE=es drm_kms_helper.edid_firmware=edid/1280x1024.bin
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
[    0.000000]  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007f590000 (usable)
[    0.000000]  BIOS-e820: 000000007f590000 - 000000007f5e3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007f5e3000 - 000000007f5f0000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007f5f0000 - 000000007f600000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.5 present.
[    0.000000] DMI: OEM OEM/G31MVP, BIOS 6.00 PG 09/11/2008
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x7f590 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-through
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 07F700000 mask FFFF00000 uncachable
[    0.000000]   2 base 07F800000 mask FFF800000 uncachable
[    0.000000]   3 base 07F600000 mask FFFF00000 uncachable
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
[    0.000000] reg 1, base: 2039MB, range: 1MB, type UC
[    0.000000] reg 2, base: 2040MB, range: 8MB, type UC
[    0.000000] reg 3, base: 2038MB, range: 1MB, type UC
[    0.000000] total RAM covered: 2038M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 16M 	num_reg: 3  	lose cover RAM: 0G
[    0.000000] New variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
[    0.000000] reg 1, base: 2038MB, range: 2MB, type UC
[    0.000000] reg 2, base: 2040MB, range: 8MB, type UC
[    0.000000] found SMP MP-table at [ffff8800000f3df0] f3df0
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000 size 20480
[    0.000000] init_memory_mapping: 0000000000000000-000000007f590000
[    0.000000]  0000000000 - 007f400000 page 2M
[    0.000000]  007f400000 - 007f590000 page 4k
[    0.000000] kernel direct mapping tables up to 7f590000 @ 1fffc000-20000000
[    0.000000] RAMDISK: 3744e000 - 37a1f000
[    0.000000] ACPI: RSDP 00000000000f82c0 00024 (v02 IntelR)
[    0.000000] ACPI: XSDT 000000007f5e3080 00054 (v01 IntelR AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: FACP 000000007f5e80c0 000F4 (v03 IntelR AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: DSDT 000000007f5e3200 04E99 (v01 INTELR AWRDACPI 00001000 MSFT 03000000)
[    0.000000] ACPI: FACS 000000007f590000 00040
[    0.000000] ACPI: HPET 000000007f5e82c0 00038 (v01 IntelR AWRDACPI 42302E31 AWRD 00000098)
[    0.000000] ACPI: MCFG 000000007f5e8300 0003C (v01 IntelR AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: SLIC 000000007f5e8340 00176 (v01 IntelR AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: APIC 000000007f5e81c0 00084 (v01 IntelR AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: SSDT 000000007f5e8b20 007EF (v01  PmRef    CpuPm 00003000 INTL 20041203)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000007f590000
[    0.000000] Initmem setup node 0 0000000000000000-000000007f590000
[    0.000000]   NODE_DATA [000000007f57c000 - 000000007f58ffff]
[    0.000000]  [ffffea0000000000-ffffea0001ffffff] PMD -> [ffff88007cc00000-ffff88007ebfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   empty
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007f590
[    0.000000] On node 0 totalpages: 521503
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 5 pages reserved
[    0.000000]   DMA zone: 3914 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 8087 pages used for memmap
[    0.000000]   DMA32 zone: 509433 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 7f600000 (gap: 7f600000:60a00000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88007f200000 s83776 r8192 d22720 u524288
[    0.000000] pcpu-alloc: s83776 r8192 d22720 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 513347
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.4.0 root=UUID=4837c784-4583-4efc-8a40-260819368469 ro rd.md=0 rd.lvm=0 rd.dm=0 quiet SYSFONT=latarcyrheb-sun16 rhgb rd.luks=0 LANG=es_ES.UTF-8 KEYTABLE=es drm_kms_helper.edid_firmware=edid/1280x1024.bin
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 2030744k/2086464k available (6248k kernel code, 452k absent, 55268k reserved, 6939k data, 996k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	Additional per-CPU info printed with stalls.
[    0.000000] NR_IRQS:16640 nr_irqs:712 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 8388608 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2755.310 MHz processor.
[    0.001004] Calibrating delay loop (skipped), value calculated using timer frequency.. 5510.62 BogoMIPS (lpj=2755310)
[    0.001008] pid_max: default: 32768 minimum: 301
[    0.001030] Security Framework initialized
[    0.001042] SELinux:  Initializing.
[    0.001050] SELinux:  Starting in permissive mode
[    0.001249] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.002340] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.002883] Mount-cache hash table entries: 256
[    0.003123] Initializing cgroup subsys cpuacct
[    0.003126] Initializing cgroup subsys memory
[    0.003139] Initializing cgroup subsys devices
[    0.003141] Initializing cgroup subsys freezer
[    0.003142] Initializing cgroup subsys net_cls
[    0.003144] Initializing cgroup subsys blkio
[    0.003151] Initializing cgroup subsys perf_event
[    0.003176] CPU: Physical Processor ID: 0
[    0.003178] CPU: Processor Core ID: 0
[    0.003180] mce: CPU supports 6 MCE banks
[    0.003187] CPU0: Thermal monitoring enabled (TM2)
[    0.003191] using mwait in idle threads.
[    0.004383] ACPI: Core revision 20120320
[    0.007006] ftrace: allocating 22911 entries in 90 pages
[    0.013309] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.023318] CPU0: Intel Pentium(R) Dual-Core  CPU      E5200  @ 2.50GHz stepping 06
[    0.023998] Performance Events: PEBS fmt0+, 4-deep LBR, Core2 events, Intel PMU driver.
[    0.023998] ... version:                2
[    0.023998] ... bit width:              40
[    0.023998] ... generic registers:      2
[    0.023998] ... value mask:             000000ffffffffff
[    0.023998] ... max period:             000000007fffffff
[    0.023998] ... fixed-purpose events:   3
[    0.023998] ... event mask:             0000000700000003
[    0.029144] NMI watchdog: enabled, takes one hw-pmu counter.
[    0.035023] Booting Node   0, Processors  #1
[    0.047029] NMI watchdog: enabled, takes one hw-pmu counter.
[    0.047079] Brought up 2 CPUs
[    0.047081] Total of 2 processors activated (11021.24 BogoMIPS).
[    0.048080] devtmpfs: initialized
[    0.048172] PM: Registering ACPI NVS region [mem 0x7f590000-0x7f5e2fff] (339968 bytes)
[    0.049380] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.049403] RTC time:  2:28:47, date: 05/29/12
[    0.049436] NET: Registered protocol family 16
[    0.049638] ACPI: bus type pci registered
[    0.049685] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.049687] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.077455] PCI: Using configuration type 1 for base access
[    0.078200] bio: create slab <bio-0> at 0
[    0.078200] ACPI: Added _OSI(Module Device)
[    0.078200] ACPI: Added _OSI(Processor Device)
[    0.078200] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.078200] ACPI: Added _OSI(Processor Aggregator Device)
[    0.079114] ACPI: EC: Look up EC in DSDT
[    0.081900] ACPI: SSDT 000000007f5e8500 002AE (v01  PmRef  Cpu0Ist 00003000 INTL 20041203)
[    0.082132] ACPI: Dynamic OEM Table Load:
[    0.082135] ACPI: SSDT           (null) 002AE (v01  PmRef  Cpu0Ist 00003000 INTL 20041203)
[    0.082295] ACPI: SSDT 000000007f5e89c0 00152 (v01  PmRef  Cpu1Ist 00003000 INTL 20041203)
[    0.082508] ACPI: Dynamic OEM Table Load:
[    0.082511] ACPI: SSDT           (null) 00152 (v01  PmRef  Cpu1Ist 00003000 INTL 20041203)
[    0.082675] ACPI: Interpreter enabled
[    0.082679] ACPI: (supports S0 S3 S4 S5)
[    0.082693] ACPI: Using IOAPIC for interrupt routing
[    0.086069] ACPI: No dock devices found.
[    0.086073] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.086118] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.086172] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.086174] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.086176] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
[    0.086178] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.086180] pci_root PNP0A08:00: host bridge window [mem 0x000c0000-0x000dffff]
[    0.086182] pci_root PNP0A08:00: host bridge window [mem 0x7f600000-0xfebfffff]
[    0.086217] PCI host bridge to bus 0000:00
[    0.086219] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.086221] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.086223] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff]
[    0.086225] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.086227] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff]
[    0.086229] pci_bus 0000:00: root bus resource [mem 0x7f600000-0xfebfffff]
[    0.086238] pci 0000:00:00.0: [8086:29c0] type 00 class 0x060000
[    0.086279] pci 0000:00:02.0: [8086:29c2] type 00 class 0x030000
[    0.086288] pci 0000:00:02.0: reg 10: [mem 0xfdf00000-0xfdf7ffff]
[    0.086293] pci 0000:00:02.0: reg 14: [io  0xff00-0xff07]
[    0.086298] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xdfffffff pref]
[    0.086304] pci 0000:00:02.0: reg 1c: [mem 0xfda00000-0xfdafffff]
[    0.086363] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    0.086376] pci 0000:00:1b.0: reg 10: [mem 0xfdff8000-0xfdffbfff 64bit]
[    0.086435] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.086454] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    0.086514] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.086534] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    0.086594] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.086616] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    0.086651] pci 0000:00:1d.0: reg 20: [io  0xfe00-0xfe1f]
[    0.086678] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    0.086712] pci 0000:00:1d.1: reg 20: [io  0xfd00-0xfd1f]
[    0.086739] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    0.086774] pci 0000:00:1d.2: reg 20: [io  0xfc00-0xfc1f]
[    0.086802] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    0.086837] pci 0000:00:1d.3: reg 20: [io  0xfb00-0xfb1f]
[    0.086872] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    0.086888] pci 0000:00:1d.7: reg 10: [mem 0xfdfff000-0xfdfff3ff]
[    0.086959] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.086976] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.087035] pci 0000:00:1f.0: [8086:27b8] type 00 class 0x060100
[    0.087106] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0800 (mask 003f)
[    0.087109] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0290 (mask 003f)
[    0.087112] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 4700 (mask 000b)
[    0.087148] pci 0000:00:1f.1: [8086:27df] type 00 class 0x01018a
[    0.087159] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.087167] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.087175] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.087183] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.087191] pci 0000:00:1f.1: reg 20: [io  0xfa00-0xfa0f]
[    0.087222] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018f
[    0.087234] pci 0000:00:1f.2: reg 10: [io  0xf900-0xf907]
[    0.087240] pci 0000:00:1f.2: reg 14: [io  0xf800-0xf803]
[    0.087247] pci 0000:00:1f.2: reg 18: [io  0xf700-0xf707]
[    0.087254] pci 0000:00:1f.2: reg 1c: [io  0xf600-0xf603]
[    0.087261] pci 0000:00:1f.2: reg 20: [io  0xf500-0xf50f]
[    0.087291] pci 0000:00:1f.2: PME# supported from D3hot
[    0.087305] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    0.087349] pci 0000:00:1f.3: reg 20: [io  0x0500-0x051f]
[    0.087411] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.087414] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    0.087418] pci 0000:00:1c.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.087423] pci 0000:00:1c.0:   bridge window [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.087477] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
[    0.087494] pci 0000:02:00.0: reg 10: [io  0xee00-0xeeff]
[    0.087522] pci 0000:02:00.0: reg 18: [mem 0xfdcff000-0xfdcfffff 64bit]
[    0.087554] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.087625] pci 0000:02:00.0: supports D1 D2
[    0.087626] pci 0000:02:00.0: PME# supported from D1 D2 D3hot D3cold
[    0.087650] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
[    0.087660] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.087663] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.087666] pci 0000:00:1c.1:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.087671] pci 0000:00:1c.1:   bridge window [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.087723] pci 0000:00:1e.0: PCI bridge to [bus 03-03] (subtractive decode)
[    0.087727] pci 0000:00:1e.0:   bridge window [io  0xd000-0xdfff]
[    0.087730] pci 0000:00:1e.0:   bridge window [mem 0xfd900000-0xfd9fffff]
[    0.087735] pci 0000:00:1e.0:   bridge window [mem 0xfd800000-0xfd8fffff 64bit pref]
[    0.087737] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.087739] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.087741] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfed44fff] (subtractive decode)
[    0.087743] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.087745] pci 0000:00:1e.0:   bridge window [mem 0x000c0000-0x000dffff] (subtractive decode)
[    0.087747] pci 0000:00:1e.0:   bridge window [mem 0x7f600000-0xfebfffff] (subtractive decode)
[    0.087761] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.087829] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
[    0.087851] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
[    0.087878] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[    0.087931]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.087935]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1d
[    0.087936] ACPI _OSC control for PCIe not granted, disabling ASPM
[    0.093384] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 *10 11 12 14 15)
[    0.093423] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 10 *11 12 14 15)
[    0.093460] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 *9 10 11 12 14 15)
[    0.093498] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 11 12 14 *15)
[    0.093535] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12 14 15) *0, disabled.
[    0.093573] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12 14 15) *0, disabled.
[    0.093610] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 7 9 10 11 12 14 15) *0, disabled.
[    0.093648] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 *5 7 9 10 11 12 14 15)
[    0.093712] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.093712] vgaarb: loaded
[    0.093712] vgaarb: bridge control possible 0000:00:02.0
[    0.093712] SCSI subsystem initialized
[    0.094005] libata version 3.00 loaded.
[    0.094044] usbcore: registered new interface driver usbfs
[    0.094057] usbcore: registered new interface driver hub
[    0.094061] usbcore: registered new device driver usb
[    0.094061] PCI: Using ACPI for IRQ routing
[    0.099347] PCI: pci_cache_line_size set to 64 bytes
[    0.099400] reserve RAM buffer: 000000000009f400 - 000000000009ffff 
[    0.099402] reserve RAM buffer: 000000007f590000 - 000000007fffffff 
[    0.099490] NetLabel: Initializing
[    0.099491] NetLabel:  domain hash size = 128
[    0.099493] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.099506] NetLabel:  unlabeled traffic allowed by default
[    0.099553] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.099557] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.099562] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.104012] Switching to clocksource hpet
[    0.112360] pnp: PnP ACPI init
[    0.112378] ACPI: bus type pnp registered
[    0.112476] pnp 00:00: [bus 00-ff]
[    0.112479] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.112480] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.112482] pnp 00:00: [io  0x0d00-0xffff window]
[    0.112484] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    0.112486] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.112487] pnp 00:00: [mem 0x000c0000-0x000dffff window]
[    0.112489] pnp 00:00: [mem 0x7f600000-0xfebfffff window]
[    0.112552] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.112603] pnp 00:01: [io  0x0010-0x001f]
[    0.112605] pnp 00:01: [io  0x0022-0x003f]
[    0.112607] pnp 00:01: [io  0x0044-0x004d]
[    0.112608] pnp 00:01: [io  0x0050-0x005e]
[    0.112610] pnp 00:01: [io  0x0062-0x0063]
[    0.112611] pnp 00:01: [io  0x0065-0x006f]
[    0.112613] pnp 00:01: [io  0x0074-0x007f]
[    0.112614] pnp 00:01: [io  0x0091-0x0093]
[    0.112616] pnp 00:01: [io  0x00a2-0x00bf]
[    0.112617] pnp 00:01: [io  0x00e0-0x00ef]
[    0.112619] pnp 00:01: [io  0x04d0-0x04d1]
[    0.112620] pnp 00:01: [io  0x0290-0x029f]
[    0.112622] pnp 00:01: [io  0x0800-0x087f]
[    0.112623] pnp 00:01: [io  0x0290-0x0297]
[    0.112625] pnp 00:01: [io  0x0880-0x088f]
[    0.112680] system 00:01: [io  0x04d0-0x04d1] has been reserved
[    0.112682] system 00:01: [io  0x0290-0x029f] has been reserved
[    0.112684] system 00:01: [io  0x0800-0x087f] has been reserved
[    0.112687] system 00:01: [io  0x0290-0x0297] has been reserved
[    0.112689] system 00:01: [io  0x0880-0x088f] has been reserved
[    0.112692] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.112702] pnp 00:02: [dma 4]
[    0.112704] pnp 00:02: [io  0x0000-0x000f]
[    0.112706] pnp 00:02: [io  0x0080-0x0090]
[    0.112707] pnp 00:02: [io  0x0094-0x009f]
[    0.112709] pnp 00:02: [io  0x00c0-0x00df]
[    0.112729] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.112768] pnp 00:03: [irq 0 disabled]
[    0.112781] pnp 00:03: [irq 8]
[    0.112782] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    0.112807] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.112828] pnp 00:04: [io  0x0070-0x0073]
[    0.112849] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.112856] pnp 00:05: [io  0x0061]
[    0.112880] pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.112888] pnp 00:06: [io  0x00f0-0x00ff]
[    0.112892] pnp 00:06: [irq 13]
[    0.112913] pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.113031] pnp 00:07: [io  0x03f0-0x03f5]
[    0.113036] pnp 00:07: [io  0x03f7]
[    0.113040] pnp 00:07: [irq 6]
[    0.113042] pnp 00:07: [dma 2]
[    0.113077] pnp 00:07: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.113215] pnp 00:08: [io  0x03f8-0x03ff]
[    0.113220] pnp 00:08: [irq 4]
[    0.113272] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.113467] pnp 00:09: [io  0x02f8-0x02ff]
[    0.113472] pnp 00:09: [irq 3]
[    0.113516] pnp 00:09: Plug and Play ACPI device, IDs PNP0510 (active)
[    0.113743] pnp 00:0a: [io  0x0378-0x037f]
[    0.113745] pnp 00:0a: [io  0x0778-0x077b]
[    0.113749] pnp 00:0a: [irq 7]
[    0.113751] pnp 00:0a: [dma 3]
[    0.113798] pnp 00:0a: Plug and Play ACPI device, IDs PNP0401 (active)
[    0.113831] pnp 00:0b: [irq 12]
[    0.113855] pnp 00:0b: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.113877] pnp 00:0c: [io  0x0060]
[    0.113879] pnp 00:0c: [io  0x0064]
[    0.113884] pnp 00:0c: [irq 1]
[    0.113911] pnp 00:0c: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.113935] pnp 00:0d: [io  0x0400-0x04bf]
[    0.113970] system 00:0d: [io  0x0400-0x04bf] has been reserved
[    0.113973] system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.113987] pnp 00:0e: [mem 0xffb80000-0xffbfffff]
[    0.114023] pnp 00:0e: Plug and Play ACPI device, IDs INT0800 (active)
[    0.114172] pnp 00:0f: [mem 0xe0000000-0xefffffff]
[    0.114215] system 00:0f: [mem 0xe0000000-0xefffffff] has been reserved
[    0.114218] system 00:0f: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.114266] pnp 00:10: [mem 0x000f0000-0x000fffff]
[    0.114268] pnp 00:10: [mem 0x7f600000-0x7f6fffff]
[    0.114270] pnp 00:10: [mem 0xfed00000-0xfed000ff]
[    0.114272] pnp 00:10: [mem 0x7f590000-0x7f5fffff]
[    0.114274] pnp 00:10: [mem 0x00000000-0x0009ffff]
[    0.114275] pnp 00:10: [mem 0x00100000-0x7f58ffff]
[    0.114277] pnp 00:10: [mem 0xfec00000-0xfec00fff]
[    0.114278] pnp 00:10: [mem 0xfed13000-0xfed1dfff]
[    0.114280] pnp 00:10: [mem 0xfed20000-0xfed3ffff]
[    0.114282] pnp 00:10: [mem 0xfed45000-0xfed8ffff]
[    0.114283] pnp 00:10: [mem 0xfee00000-0xfee00fff]
[    0.114285] pnp 00:10: [mem 0xffb00000-0xffb7ffff]
[    0.114287] pnp 00:10: [mem 0xfff00000-0xffffffff]
[    0.114288] pnp 00:10: [mem 0x000e0000-0x000effff]
[    0.114339] system 00:10: [mem 0x000f0000-0x000fffff] could not be reserved
[    0.114341] system 00:10: [mem 0x7f600000-0x7f6fffff] has been reserved
[    0.114344] system 00:10: [mem 0xfed00000-0xfed000ff] has been reserved
[    0.114346] system 00:10: [mem 0x7f590000-0x7f5fffff] could not be reserved
[    0.114348] system 00:10: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.114350] system 00:10: [mem 0x00100000-0x7f58ffff] could not be reserved
[    0.114353] system 00:10: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.114355] system 00:10: [mem 0xfed13000-0xfed1dfff] has been reserved
[    0.114357] system 00:10: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.114359] system 00:10: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.114361] system 00:10: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.114363] system 00:10: [mem 0xffb00000-0xffb7ffff] has been reserved
[    0.114366] system 00:10: [mem 0xfff00000-0xffffffff] has been reserved
[    0.114368] system 00:10: [mem 0x000e0000-0x000effff] has been reserved
[    0.114371] system 00:10: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.114378] pnp: PnP ACPI: found 17 devices
[    0.114380] ACPI: ACPI bus type pnp unregistered
[    0.120789] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.120793] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    0.120797] pci 0000:00:1c.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.120801] pci 0000:00:1c.0:   bridge window [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.120809] pci 0000:02:00.0: BAR 6: assigned [mem 0xfdb00000-0xfdb1ffff pref]
[    0.120812] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.120814] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.120819] pci 0000:00:1c.1:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.120822] pci 0000:00:1c.1:   bridge window [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.120827] pci 0000:00:1e.0: PCI bridge to [bus 03-03]
[    0.120830] pci 0000:00:1e.0:   bridge window [io  0xd000-0xdfff]
[    0.120834] pci 0000:00:1e.0:   bridge window [mem 0xfd900000-0xfd9fffff]
[    0.120837] pci 0000:00:1e.0:   bridge window [mem 0xfd800000-0xfd8fffff 64bit pref]
[    0.120865] pci 0000:00:1e.0: setting latency timer to 64
[    0.120868] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.120870] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.120872] pci_bus 0000:00: resource 6 [mem 0xfed40000-0xfed44fff]
[    0.120874] pci_bus 0000:00: resource 7 [mem 0x000a0000-0x000bffff]
[    0.120876] pci_bus 0000:00: resource 8 [mem 0x000c0000-0x000dffff]
[    0.120878] pci_bus 0000:00: resource 9 [mem 0x7f600000-0xfebfffff]
[    0.120880] pci_bus 0000:01: resource 0 [io  0xc000-0xcfff]
[    0.120882] pci_bus 0000:01: resource 1 [mem 0xfde00000-0xfdefffff]
[    0.120884] pci_bus 0000:01: resource 2 [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.120886] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
[    0.120888] pci_bus 0000:02: resource 1 [mem 0xfdc00000-0xfdcfffff]
[    0.120890] pci_bus 0000:02: resource 2 [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.120892] pci_bus 0000:03: resource 0 [io  0xd000-0xdfff]
[    0.120894] pci_bus 0000:03: resource 1 [mem 0xfd900000-0xfd9fffff]
[    0.120896] pci_bus 0000:03: resource 2 [mem 0xfd800000-0xfd8fffff 64bit pref]
[    0.120898] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
[    0.120899] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
[    0.120901] pci_bus 0000:03: resource 6 [mem 0xfed40000-0xfed44fff]
[    0.120903] pci_bus 0000:03: resource 7 [mem 0x000a0000-0x000bffff]
[    0.120905] pci_bus 0000:03: resource 8 [mem 0x000c0000-0x000dffff]
[    0.120907] pci_bus 0000:03: resource 9 [mem 0x7f600000-0xfebfffff]
[    0.120947] NET: Registered protocol family 2
[    0.121056] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.121614] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    0.123590] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.124143] TCP: Hash tables configured (established 262144 bind 65536)
[    0.124146] TCP: reno registered
[    0.124153] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    0.124176] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    0.124298] NET: Registered protocol family 1
[    0.124317] pci 0000:00:02.0: Boot video device
[    0.124460] PCI: CLS 64 bytes, default 64
[    0.124516] Unpacking initramfs...
[    0.221204] Freeing initrd memory: 5956k freed
[    0.224286] audit: initializing netlink socket (disabled)
[    0.224303] type=2000 audit(1338258527.223:1): initialized
[    0.235457] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.236978] VFS: Disk quotas dquot_6.5.2
[    0.237025] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.237390] msgmni has been set to 3977
[    0.237441] SELinux:  Registering netfilter hooks
[    0.237880] alg: No test for stdrng (krng)
[    0.237887] NET: Registered protocol family 38
[    0.237919] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.237944] io scheduler noop registered
[    0.237946] io scheduler deadline registered
[    0.237994] io scheduler cfq registered (default)
[    0.238128] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    0.238209] pcieport 0000:00:1c.1: irq 41 for MSI/MSI-X
[    0.238276] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.238293] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.238295] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.238574] intel_idle: does not run on family 6 model 23
[    0.238638] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    0.238642] ACPI: Power Button [PWRB]
[    0.238683] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    0.238686] ACPI: Power Button [PWRF]
[    0.238724] ACPI: Fan [FAN] (on)
[    0.238858] ACPI: Requesting acpi_cpufreq
[    0.241553] thermal LNXTHERM:00: registered as thermal_zone0
[    0.241556] ACPI: Thermal Zone [THRM] (202 C)
[    0.241581] GHES: HEST is not enabled!
[    0.241652] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.262110] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.282579] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    0.303194] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.303467] Non-volatile memory driver v1.3
[    0.303469] Linux agpgart interface v0.103
[    0.303528] agpgart-intel 0000:00:00.0: Intel G33 Chipset
[    0.303604] agpgart-intel 0000:00:00.0: detected gtt size: 524288K total, 262144K mappable
[    0.304110] agpgart-intel 0000:00:00.0: detected 8192K stolen memory
[    0.304211] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.304871] loop: module loaded
[    0.304942] ata_piix 0000:00:1f.1: version 2.13
[    0.304980] ata_piix 0000:00:1f.1: setting latency timer to 64
[    0.305230] scsi0 : ata_piix
[    0.305294] scsi1 : ata_piix
[    0.305632] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xfa00 irq 14
[    0.305635] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xfa08 irq 15
[    0.305772] ata2: port disabled--ignoring
[    0.305773] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    0.305799] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.306022] scsi2 : ata_piix
[    0.306082] scsi3 : ata_piix
[    0.306402] ata3: SATA max UDMA/133 cmd 0xf900 ctl 0xf800 bmdma 0xf500 irq 19
[    0.306404] ata4: SATA max UDMA/133 cmd 0xf700 ctl 0xf600 bmdma 0xf508 irq 19
[    0.306466] Fixed MDIO Bus: probed
[    0.306585] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.306615] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    0.306618] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    0.306675] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    0.306695] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    0.306704] ehci_hcd 0000:00:1d.7: debug port 1
[    0.310575] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    0.310588] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfdfff000
[    0.316022] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    0.316053] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.316057] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.316061] usb usb1: Product: EHCI Host Controller
[    0.316065] usb usb1: Manufacturer: Linux 3.4.0 ehci_hcd
[    0.316069] usb usb1: SerialNumber: 0000:00:1d.7
[    0.316175] hub 1-0:1.0: USB hub found
[    0.316179] hub 1-0:1.0: 8 ports detected
[    0.316248] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.316261] uhci_hcd: USB Universal Host Controller Interface driver
[    0.316280] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.316283] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    0.316322] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    0.316344] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fe00
[    0.316374] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    0.316376] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.316378] usb usb2: Product: UHCI Host Controller
[    0.316379] usb usb2: Manufacturer: Linux 3.4.0 uhci_hcd
[    0.316381] usb usb2: SerialNumber: 0000:00:1d.0
[    0.316452] hub 2-0:1.0: USB hub found
[    0.316456] hub 2-0:1.0: 2 ports detected
[    0.316510] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    0.316513] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    0.316547] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    0.316566] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000fd00
[    0.316592] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    0.316595] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.316596] usb usb3: Product: UHCI Host Controller
[    0.316598] usb usb3: Manufacturer: Linux 3.4.0 uhci_hcd
[    0.316600] usb usb3: SerialNumber: 0000:00:1d.1
[    0.316668] hub 3-0:1.0: USB hub found
[    0.316672] hub 3-0:1.0: 2 ports detected
[    0.316724] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    0.316727] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    0.316761] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    0.316790] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000fc00
[    0.316818] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    0.316820] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.316822] usb usb4: Product: UHCI Host Controller
[    0.316824] usb usb4: Manufacturer: Linux 3.4.0 uhci_hcd
[    0.316825] usb usb4: SerialNumber: 0000:00:1d.2
[    0.316893] hub 4-0:1.0: USB hub found
[    0.316897] hub 4-0:1.0: 2 ports detected
[    0.316952] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    0.316954] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    0.316995] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    0.317033] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000fb00
[    0.317062] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    0.317064] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.317066] usb usb5: Product: UHCI Host Controller
[    0.317067] usb usb5: Manufacturer: Linux 3.4.0 uhci_hcd
[    0.317069] usb usb5: SerialNumber: 0000:00:1d.3
[    0.317142] hub 5-0:1.0: USB hub found
[    0.317145] hub 5-0:1.0: 2 ports detected
[    0.317229] usbcore: registered new interface driver usbserial
[    0.317240] usbcore: registered new interface driver usbserial_generic
[    0.317246] USB Serial support registered for generic
[    0.317249] usbserial: USB Serial Driver core
[    0.317284] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    0.317601] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.317627] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.317679] mousedev: PS/2 mouse device common for all mice
[    0.317822] rtc_cmos 00:04: RTC can wake from S4
[    0.317923] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    0.317945] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
[    0.318011] device-mapper: uevent: version 1.0.3
[    0.318068] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[    0.318102] cpuidle: using governor ladder
[    0.318104] cpuidle: using governor menu
[    0.318275] EFI Variables Facility v0.08 2004-May-17
[    0.318374] usbcore: registered new interface driver usbhid
[    0.318376] usbhid: USB HID core driver
[    0.318497] ip_tables: (C) 2000-2006 Netfilter Core Team
[    0.318525] TCP: cubic registered
[    0.318527] Initializing XFRM netlink socket
[    0.318611] NET: Registered protocol family 10
[    0.318796] Mobile IPv6
[    0.318799] NET: Registered protocol family 17
[    0.318809] Registering the dns_resolver key type
[    0.318948] PM: Hibernation image not present or could not be loaded.
[    0.318962] registered taskstats version 1
[    0.319310]   Magic number: 12:308:461
[    0.319404] rtc_cmos 00:04: setting system clock to 2012-05-29 02:28:47 UTC (1338258527)
[    0.319777] Initializing network drop monitor service
[    0.338407] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
[    0.457259] ata4.01: NODEV after polling detection
[    0.458723] ata3.00: ATA-8: WDC WD5000AAKS-00V1A0, 05.01D05, max UDMA/133
[    0.458729] ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    0.461138] ata4.00: ATAPI: Optiarc DVD RW AD-7280S, 1.01, max UDMA/100
[    0.463468] ata1.00: ATA-6: ST3160021A, 8.01, max UDMA/100
[    0.463472] ata1.00: 312581808 sectors, multi 16: LBA48 
[    0.463481] ata1.01: ATAPI: HL-DT-ST GCE-8527B, 1.04, max UDMA/33
[    0.464734] ata3.00: configured for UDMA/133
[    0.467127] ata4.00: configured for UDMA/100
[    0.485388] ata1.00: configured for UDMA/100
[    0.510179] ata1.01: configured for UDMA/33
[    0.510575] scsi 0:0:0:0: Direct-Access     ATA      ST3160021A       8.01 PQ: 0 ANSI: 5
[    0.510784] sd 0:0:0:0: [sda] 312581808 512-byte logical blocks: (160 GB/149 GiB)
[    0.510799] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    0.510902] sd 0:0:0:0: [sda] Write Protect is off
[    0.510908] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.511210] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.511229] scsi 0:0:1:0: CD-ROM            HL-DT-ST CD-RW GCE-8527B  1.04 PQ: 0 ANSI: 5
[    0.514018] sr0: scsi3-mmc drive: 52x/52x writer cd/rw xa/form2 cdda tray
[    0.514023] cdrom: Uniform CD-ROM driver Revision: 3.20
[    0.514178] sr 0:0:1:0: Attached scsi CD-ROM sr0
[    0.514279] sr 0:0:1:0: Attached scsi generic sg1 type 5
[    0.514481] scsi 2:0:0:0: Direct-Access     ATA      WDC WD5000AAKS-0 05.0 PQ: 0 ANSI: 5
[    0.514642] sd 2:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    0.514674] sd 2:0:0:0: Attached scsi generic sg2 type 0
[    0.514735] sd 2:0:0:0: [sdb] Write Protect is off
[    0.514741] sd 2:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    0.514781] sd 2:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.515372] scsi 3:0:0:0: CD-ROM            Optiarc  DVD RW AD-7280S  1.01 PQ: 0 ANSI: 5
[    0.516826] sr1: scsi3-mmc drive: 125x/125x writer dvd-ram cd/rw xa/form2 cdda tray
[    0.516973] sr 3:0:0:0: Attached scsi CD-ROM sr1
[    0.517141] sr 3:0:0:0: Attached scsi generic sg3 type 5
[    0.521581]  sda: sda1
[    0.522107] sd 0:0:0:0: [sda] Attached SCSI disk
[    0.543743]  sdb: sdb1 sdb2 sdb3 sdb4 < sdb5 >
[    0.544122] sd 2:0:0:0: [sdb] Attached SCSI disk
[    0.545814] Freeing unused kernel memory: 996k freed
[    0.546124] Write protecting the kernel read-only data: 12288k
[    0.552835] Freeing unused kernel memory: 1924k freed
[    0.557746] Freeing unused kernel memory: 1476k freed
[    0.629377] dracut: dracut-013-22.fc16
[    0.637928] udevd[101]: starting version 173
[    0.670030] [drm] Initialized drm 1.1.0 20060810
[    0.678857] i915 0000:00:02.0: setting latency timer to 64
[    0.719850] i915 0000:00:02.0: irq 42 for MSI/MSI-X
[    0.719859] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    0.719861] [drm] Driver supports precise vblank timestamp query.
[    0.719894] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    0.730129] [drm] initialized overlay support
[    0.739594] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[    0.747589] fbcon: inteldrmfb (fb0) is primary device
[    0.790726] Console: switching to colour frame buffer device 160x64
[    0.795389] fb0: inteldrmfb frame buffer device
[    0.795391] drm: registered panic notifier
[    0.795434] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    0.798814] dracut: Starting plymouth daemon
[    0.818553] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[    1.074655] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042/serio1/input/input3
[    1.224305] Refined TSC clocksource calibration: 2755.321 MHz.
[    1.224312] Switching to clocksource tsc
[    1.382580] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[    1.479738] dracut: Checking ext4: /dev/disk/by-uuid/4837c784-4583-4efc-8a40-260819368469
[    1.479831] dracut: issuing e2fsck -a  /dev/disk/by-uuid/4837c784-4583-4efc-8a40-260819368469
[    1.516554] dracut: /dev/disk/by-uuid/4837c784-4583-4efc-8a40-260819368469: clean, 408370/2621440 files, 3617977/10485760 blocks
[    1.516891] dracut: Remounting /dev/disk/by-uuid/4837c784-4583-4efc-8a40-260819368469 with -o relatime,ro
[    1.524317] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[    1.546830] dracut: Mounted root filesystem /dev/sdb2
[    1.766298] dracut: Switching root
[    2.076942] type=1404 audit(1338258529.256:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
[    2.142364] SELinux: 2048 avtab hash slots, 98177 rules.
[    2.164749] SELinux: 2048 avtab hash slots, 98177 rules.
[    2.296238] SELinux:  9 users, 13 roles, 3948 types, 218 bools, 1 sens, 1024 cats
[    2.296242] SELinux:  82 classes, 98177 rules
[    2.299806] SELinux:  Completing initialization.
[    2.299809] SELinux:  Setting up existing superblocks.
[    2.299818] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    2.299824] SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
[    2.299828] SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
[    2.299833] SELinux: initialized (dev proc, type proc), uses genfs_contexts
[    2.299841] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    2.299862] SELinux: initialized (dev devtmpfs, type devtmpfs), uses transition SIDs
[    2.300371] SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
[    2.300376] SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
[    2.302212] SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
[    2.302220] SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
[    2.302225] SELinux: initialized (dev devpts, type devpts), uses transition SIDs
[    2.302241] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
[    2.302251] SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
[    2.302258] SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
[    2.302282] SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
[    2.302291] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    2.303183] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    2.303190] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    2.303754] SELinux: initialized (dev sdb2, type ext4), uses xattr
[    2.305943] type=1403 audit(1338258529.484:3): policy loaded auid=4294967295 ses=4294967295
[    2.393908] systemd[1]: Successfully loaded SELinux policy in 334ms 288us.
[    2.435750] systemd[1]: Successfully loaded SELinux database in 41ms 225us, size on heap is 483K.
[    2.452299] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    2.452742] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.497662] systemd[1]: Relabelled /dev and /run in 44ms 836us.
[    2.508814] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.509420] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.510114] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.510639] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.511155] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.511661] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.512221] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.512734] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    2.512822] systemd[1]: systemd 37 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +SYSVINIT +LIBCRYPTSETUP; fedora)
[    2.528443] systemd[1]: Set hostname to <karlalex.palosanto.com>.
[    3.429198] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    5.712716] udevd[326]: starting version 173
[    9.710415] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
[    9.712489] SELinux: initialized (dev securityfs, type securityfs), uses genfs_contexts
[    9.713175] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    9.722829] RPC: Registered named UNIX socket transport module.
[    9.722833] RPC: Registered udp transport module.
[    9.722835] RPC: Registered tcp transport module.
[    9.722836] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.723137] SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
[    9.772137] SELinux: initialized (dev configfs, type configfs), uses genfs_contexts
[    9.872573] SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
[    9.901211] parport_pc 00:0a: reported by Plug and Play ACPI
[    9.901266] parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
[    9.904047] Floppy drive(s): fd0 is 1.44M
[    9.915564] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    9.915681] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
[    9.915859] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc90000352000, 00:22:68:44:17:2f, XID 98500000 IRQ 43
[    9.915863] r8169 0000:02:00.0: eth0: jumbo features [frames: 4080 bytes, tx checksumming: ko]
[    9.918960] FDC 0 is a post-1991 82077
[    9.925893] intel_rng: FWH not detected
[    9.939218] iTCO_vendor_support: vendor-support=0
[    9.939763] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.07
[    9.939854] iTCO_wdt: Found a ICH7 or ICH7R TCO device (Version=2, TCOBASE=0x0460)
[    9.939989] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    9.940310] leds_ss4200: no LED devices found
[    9.963868] input: PC Speaker as /devices/platform/pcspkr/input/input4
[    9.967325] microcode: CPU0 sig=0x10676, pf=0x1, revision=0x60c
[   10.136027] ppdev: user-space parallel port driver
[   10.211006] microcode: CPU0 updated to revision 0x60f, date = 2010-09-29
[   10.216660] microcode: CPU1 sig=0x10676, pf=0x1, revision=0x60c
[   10.219888] r8169 0000:02:00.0: vpd r/w failed.  This is likely a firmware bug on this device.  Contact the card vendor for a firmware update.
[   10.225006] microcode: CPU1 updated to revision 0x60f, date = 2010-09-29
[   10.232847] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   10.242804] snd_hda_intel 0000:00:1b.0: irq 44 for MSI/MSI-X
[   10.243262] udevd[351]: renamed network interface eth0 to p17p1
[   10.258023] ALSA sound/pci/hda/patch_realtek.c:1254 SKU: Nid=0x1d sku_cfg=0x40038601
[   10.258027] ALSA sound/pci/hda/patch_realtek.c:1256 SKU: port_connectivity=0x1
[   10.258029] ALSA sound/pci/hda/patch_realtek.c:1257 SKU: enable_pcbeep=0x0
[   10.258031] ALSA sound/pci/hda/patch_realtek.c:1258 SKU: check_sum=0x00000003
[   10.258034] ALSA sound/pci/hda/patch_realtek.c:1259 SKU: customization=0x00000086
[   10.258036] ALSA sound/pci/hda/patch_realtek.c:1260 SKU: external_amp=0x0
[   10.258039] ALSA sound/pci/hda/patch_realtek.c:1261 SKU: platform_type=0x0
[   10.258041] ALSA sound/pci/hda/patch_realtek.c:1262 SKU: swap=0x0
[   10.258043] ALSA sound/pci/hda/patch_realtek.c:1263 SKU: override=0x1
[   10.258048] ALSA sound/pci/hda/hda_codec.c:5099 autoconfig: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:line
[   10.258051] ALSA sound/pci/hda/hda_codec.c:5103    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[   10.258054] ALSA sound/pci/hda/hda_codec.c:5107    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
[   10.258056] ALSA sound/pci/hda/hda_codec.c:5108    mono: mono_out=0x0
[   10.258059] ALSA sound/pci/hda/hda_codec.c:5111    dig-out=0x1e/0x0
[   10.258061] ALSA sound/pci/hda/hda_codec.c:5112    inputs:
[   10.258064] ALSA sound/pci/hda/hda_codec.c:5116  Rear Mic=0x18
[   10.258066] ALSA sound/pci/hda/hda_codec.c:5116  Front Mic=0x19
[   10.258068] ALSA sound/pci/hda/hda_codec.c:5116  Line=0x1a
[   10.258070] ALSA sound/pci/hda/hda_codec.c:5118 
[   10.259946] ALSA sound/pci/hda/patch_realtek.c:1317 realtek: No valid SSID, checking pincfg 0x40038601 for NID 0x1d
[   10.259950] ALSA sound/pci/hda/patch_realtek.c:1333 realtek: Enabling init ASM_ID=0x8601 CODEC_ID=10ec0662
[   10.273172] input: HDA Intel Line as /devices/pci0000:00/0000:00:1b.0/sound/card0/input5
[   10.273287] input: HDA Intel Front Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input6
[   10.273373] input: HDA Intel Rear Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input7
[   10.273455] input: HDA Intel Front Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input8
[   10.273535] input: HDA Intel Line Out as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[   12.252588] EXT4-fs (sdb2): re-mounted. Opts: (null)
[   12.538902] Adding 8388604k swap on /dev/sdb3.  Priority:0 extents:1 across:8388604k 
[   12.609240] systemd-fsck[623]: /dev/sdb1: limpio, 270/51200 ficheros, 60029/204800 bloques
[   12.795881] systemd-fsck[601]: /dev/sda1: limpio, 68662/9773056 ficheros, 35306812/39072080 bloques
[   12.832572] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[   12.862181] SELinux: initialized (dev sdb1, type ext4), uses xattr
[   13.087886] EXT4-fs (sda1): mounting ext3 file system using the ext4 subsystem
[   13.115765] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[   13.115780] SELinux: initialized (dev sda1, type ext3), uses xattr
[   13.126073] systemd-fsck[638]: /dev/sdb5: limpio, 727628/27369472 ficheros, 99666047/109460736 bloques
[   13.219666] EXT4-fs (sdb5): mounting ext3 file system using the ext4 subsystem
[   13.229265] EXT4-fs (sdb5): mounted filesystem with ordered data mode. Opts: (null)
[   13.229280] SELinux: initialized (dev sdb5, type ext3), uses xattr
[   13.304292] fedora-storage-init[637]: Configurando gestor de vol\xffffffc3\xffffffba\xffffffbamenes l\xffffffc3\xffffffb3\xffffffb3gicos:   No volume groups found
[   13.314946] fedora-storage-init[637]: [  OK  ]
[   13.585812] fedora-storage-init[670]: Configurando gestor de vol\xffffffc3\xffffffba\xffffffbamenes l\xffffffc3\xffffffb3\xffffffb3gicos:   No volume groups found
[   13.596900] fedora-storage-init[670]: [  OK  ]
[   13.786541] lvm[676]: No volume groups found
[   14.277073] systemd-tmpfiles[679]: Successfully loaded SELinux database in 20ms 480us, size on heap is 485K.
[   14.903833] sandbox[688]: Starting sandbox[  OK  ]
[   14.939092] auditd[695]: Started dispatcher: /sbin/audispd pid: 711
[   14.950645] audispd[711]: priority_boost_parser called with: 4
[   14.951711] audispd[711]: max_restarts_parser called with: 10
[   14.960712] audispd[711]: audispd initialized with q_depth=120 and 1 active plugins
[   14.962731] auditctl[699]: No rules
[   14.962743] auditctl[699]: AUDIT_STATUS: enabled=0 flag=1 pid=695 rate_limit=0 backlog_limit=320 lost=0 backlog=0
[   14.973051] /usr/sbin/gpm[725]: *** info [daemon/startup.c(136)]:
[   14.973063] /usr/sbin/gpm[725]: Started gpm successfully. Entered daemon mode.
[   14.978783] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   14.990576] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   15.005819] acpid[738]: starting up with netlink and the input layer
[   15.005832] acpid[738]: skipping incomplete file /etc/acpi/events/videoconf
[   15.005841] acpid[738]: 1 rule loaded
[   15.005848] acpid[738]: waiting for events: event logging is off
[   15.014968] ip6tables.init[689]: ip6tables: Aplicando las reglas del cortafuegos: [  OK  ]
[   15.028563] abrtd[724]: Init complete, entering main loop
[   15.034548] iptables.init[690]: iptables: Aplicando reglas del cortafuegos:[  OK  ]
[   15.058214] auditd[695]: Init complete, auditd 2.2.1 listening for events (startup state enable)
[   15.062696] NetworkManager[754]: <info> NetworkManager (version 0.9.4-3.git20120403.fc16) is starting...
[   15.062790] NetworkManager[754]: <info> Read config file /etc/NetworkManager/NetworkManager.conf
[   15.158924] avahi-daemon[772]: Found user 'avahi' (UID 70) and group 'avahi' (GID 70).
[   15.159056] avahi-daemon[772]: Successfully dropped root privileges.
[   15.159460] avahi-daemon[772]: avahi-daemon 0.6.30 starting up.
[   15.175736] avahi-daemon[772]: WARNING: No NSS support for mDNS detected, consider installing nss-mdns!
[   15.229597] chronyd[779]: chronyd version 1.26-20110831gitb088b7 starting
[   15.230202] chronyd[779]: Linux kernel major=3 minor=4 patch=0
[   15.230271] chronyd[779]: hz=100 shift_hz=7 freq_scale=1.00000000 nominal_tick=10000 slew_delta_tick=833 max_tick_bias=1000
[   15.243771] chronyd[779]: Frequency 40.535 +- 21.990 ppm read from /var/lib/chrony/drift
[   15.570316] NetworkManager[754]: <info> VPN: loaded org.freedesktop.NetworkManager.openswan
[   15.570742] NetworkManager[754]: <info> VPN: loaded org.freedesktop.NetworkManager.vpnc
[   15.570755] NetworkManager[754]: <info> VPN: loaded org.freedesktop.NetworkManager.openconnect
[   15.570765] NetworkManager[754]: <info> VPN: loaded org.freedesktop.NetworkManager.openvpn
[   15.570774] NetworkManager[754]: <info> VPN: loaded org.freedesktop.NetworkManager.pptp
[   15.576587] avahi-daemon[772]: Successfully called chroot().
[   15.576600] avahi-daemon[772]: Successfully dropped remaining capabilities.
[   15.576610] avahi-daemon[772]: Loading service file /services/ssh.service.
[   15.576620] avahi-daemon[772]: Loading service file /services/udisks.service.
[   15.581305] avahi-daemon[772]: Network interface enumeration completed.
[   15.608154] avahi-daemon[772]: Registering HINFO record with values 'X86_64'/'LINUX'.
[   15.608168] avahi-daemon[772]: Server startup complete. Host name is karlalex.local. Local service cookie is 1547664448.
[   15.608179] avahi-daemon[772]: Service "karlalex" (/services/udisks.service) successfully established.
[   15.608189] avahi-daemon[772]: Service "karlalex" (/services/ssh.service) successfully established.
[   15.608200] systemd-logind[764]: New seat seat0.
[   15.608209] dbus[784]: [system] Activating service name='org.freedesktop.PolicyKit1' (using servicehelper)
[   15.608220] dbus-daemon[784]: dbus[784]: [system] Activating service name='org.freedesktop.PolicyKit1' (using servicehelper)
[   15.610688] dkms_autoinstaller[790]: dkms: running auto installation service for kernel 3.4.0
[   15.811701] r8169 0000:02:00.0: p17p1: link down
[   15.836260] ADDRCONF(NETDEV_UP): p17p1: link is not ready
[   16.210621] vboxdrv: Found 2 processor cores.
[   16.223771] vboxdrv: fAsync=0 offMin=0x41a offMax=0x1243
[   16.223891] vboxdrv: TSC mode is 'synchronous', kernel timer mode is 'normal'.
[   16.223895] vboxdrv: Successfully loaded version 4.1.16 (interface 0x00190000).
[   16.384687] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   16.401944] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   16.467478] vboxpci: IOMMU not found (not registered)
[   16.788505] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   17.562873] r8169 0000:02:00.0: p17p1: link up
[   17.563280] ADDRCONF(NETDEV_CHANGE): p17p1: link becomes ready
[   18.117871] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   18.130982] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   18.147674] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   18.162952] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   18.181158] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   19.491045] hda-intel: IRQ timing workaround is activated for card #0. Suggest a bigger bdl_pos_adj.
[   27.834015] p17p1: no IPv6 routers present
[   50.057091] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   74.832072] fuse init (API version 7.18)
[   74.845206] SELinux: initialized (dev fusectl, type fusectl), uses genfs_contexts
[   74.857436] SELinux: initialized (dev fuse, type fuse), uses genfs_contexts
[   76.462143] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   76.526839] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   76.541816] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   76.562280] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   76.576139] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   76.595367] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   78.642571] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[   80.541448] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[  701.898015] p17p1: no IPv6 routers present
[ 2531.712014] ------------[ cut here ]------------
[ 2531.712027] WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
[ 2531.712031] Hardware name: OEM
[ 2531.712034] NETDEV WATCHDOG: p17p1 (r8169): transmit queue 0 timed out
[ 2531.712037] Modules linked in: fuse vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) lockd nf_conntrack_ipv4 nf_defrag_ipv4 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter xt_state nf_conntrack ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ppdev uinput coretemp microcode pcspkr i2c_i801 iTCO_wdt iTCO_vendor_support r8169 mii snd_timer snd soundcore snd_page_alloc parport_pc parport floppy binfmt_misc sunrpc i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[ 2531.712103] Pid: 1695, comm: gnome-shell Tainted: G           O 3.4.0 #41
[ 2531.712107] Call Trace:
[ 2531.712110]  <IRQ>  [<ffffffff8105ab8f>] warn_slowpath_common+0x7f/0xc0
[ 2531.712123]  [<ffffffff8105ac86>] warn_slowpath_fmt+0x46/0x50
[ 2531.712130]  [<ffffffff8151bc07>] dev_watchdog+0x277/0x280
[ 2531.712136]  [<ffffffff81069f31>] run_timer_softirq+0x131/0x440
[ 2531.712142]  [<ffffffff8151b990>] ? qdisc_reset+0x50/0x50
[ 2531.712147]  [<ffffffff81062178>] __do_softirq+0xb8/0x280
[ 2531.712153]  [<ffffffff8101dd62>] ? native_sched_clock+0x22/0x80
[ 2531.712159]  [<ffffffff81091895>] ? sched_clock_local+0x25/0x90
[ 2531.712165]  [<ffffffff8161751c>] call_softirq+0x1c/0x30
[ 2531.712171]  [<ffffffff810182e5>] do_softirq+0x65/0xa0
[ 2531.712176]  [<ffffffff8106266e>] irq_exit+0x9e/0xc0
[ 2531.712181]  [<ffffffff81617e4b>] smp_apic_timer_interrupt+0x6b/0x98
[ 2531.712186]  [<ffffffff81616bca>] apic_timer_interrupt+0x6a/0x70
[ 2531.712189]  <EOI>  [<ffffffff81616250>] ? sysret_audit+0x17/0x21
[ 2531.712197] ---[ end trace 674f0ff95995e3ea ]---
[ 2531.717095] r8169 0000:02:00.0: p17p1: Rx ring: dirty=00060dbe current=00060dbe
[ 2531.717103] r8169 0000:02:00.0: p17p1: [000] 80003fff 00000000 69ea0000
[ 2531.717108] r8169 0000:02:00.0: p17p1: [001] 80003fff 00000000 69fb8000
[ 2531.717112] r8169 0000:02:00.0: p17p1: [002] 80003fff 00000000 69fd0000
[ 2531.717116] r8169 0000:02:00.0: p17p1: [003] 80003fff 00000000 69ed0000
[ 2531.717121] r8169 0000:02:00.0: p17p1: [004] 80003fff 00000000 69eb4000
[ 2531.717125] r8169 0000:02:00.0: p17p1: [005] 80003fff 00000000 69ec8000
[ 2531.717130] r8169 0000:02:00.0: p17p1: [006] 80003fff 00000000 69df8000
[ 2531.717134] r8169 0000:02:00.0: p17p1: [007] 80003fff 00000000 69d48000
[ 2531.717139] r8169 0000:02:00.0: p17p1: [008] 80003fff 00000000 69cc0000
[ 2531.717143] r8169 0000:02:00.0: p17p1: [009] 80003fff 00000000 69d3c000
[ 2531.717148] r8169 0000:02:00.0: p17p1: [010] 80003fff 00000000 69d74000
[ 2531.717152] r8169 0000:02:00.0: p17p1: [011] 80003fff 00000000 69d28000
[ 2531.717156] r8169 0000:02:00.0: p17p1: [012] 80003fff 00000000 6855c000
[ 2531.717161] r8169 0000:02:00.0: p17p1: [013] 80003fff 00000000 69e88000
[ 2531.717165] r8169 0000:02:00.0: p17p1: [014] 80003fff 00000000 69e8c000
[ 2531.717169] r8169 0000:02:00.0: p17p1: [015] 80003fff 00000000 685d8000
[ 2531.717174] r8169 0000:02:00.0: p17p1: [016] 80003fff 00000000 685dc000
[ 2531.717178] r8169 0000:02:00.0: p17p1: [017] 80003fff 00000000 685e0000
[ 2531.717182] r8169 0000:02:00.0: p17p1: [018] 80003fff 00000000 685e4000
[ 2531.717187] r8169 0000:02:00.0: p17p1: [019] 80003fff 00000000 685e8000
[ 2531.717191] r8169 0000:02:00.0: p17p1: [020] 80003fff 00000000 685ec000
[ 2531.717195] r8169 0000:02:00.0: p17p1: [021] 80003fff 00000000 685f0000
[ 2531.717199] r8169 0000:02:00.0: p17p1: [022] 80003fff 00000000 685f4000
[ 2531.717204] r8169 0000:02:00.0: p17p1: [023] 80003fff 00000000 685f8000
[ 2531.717208] r8169 0000:02:00.0: p17p1: [024] 80003fff 00000000 685fc000
[ 2531.717212] r8169 0000:02:00.0: p17p1: [025] 80003fff 00000000 68600000
[ 2531.717217] r8169 0000:02:00.0: p17p1: [026] 80003fff 00000000 68604000
[ 2531.717221] r8169 0000:02:00.0: p17p1: [027] 80003fff 00000000 68608000
[ 2531.717225] r8169 0000:02:00.0: p17p1: [028] 80003fff 00000000 6860c000
[ 2531.717229] r8169 0000:02:00.0: p17p1: [029] 80003fff 00000000 68610000
[ 2531.717234] r8169 0000:02:00.0: p17p1: [030] 80003fff 00000000 68614000
[ 2531.717238] r8169 0000:02:00.0: p17p1: [031] 80003fff 00000000 68618000
[ 2531.717242] r8169 0000:02:00.0: p17p1: [032] 80003fff 00000000 6861c000
[ 2531.717247] r8169 0000:02:00.0: p17p1: [033] 80003fff 00000000 68620000
[ 2531.717251] r8169 0000:02:00.0: p17p1: [034] 80003fff 00000000 68624000
[ 2531.717255] r8169 0000:02:00.0: p17p1: [035] 80003fff 00000000 68628000
[ 2531.717259] r8169 0000:02:00.0: p17p1: [036] 80003fff 00000000 6862c000
[ 2531.717264] r8169 0000:02:00.0: p17p1: [037] 80003fff 00000000 68630000
[ 2531.717268] r8169 0000:02:00.0: p17p1: [038] 80003fff 00000000 68634000
[ 2531.717272] r8169 0000:02:00.0: p17p1: [039] 80003fff 00000000 68638000
[ 2531.717277] r8169 0000:02:00.0: p17p1: [040] 80003fff 00000000 6863c000
[ 2531.717281] r8169 0000:02:00.0: p17p1: [041] 80003fff 00000000 68640000
[ 2531.717285] r8169 0000:02:00.0: p17p1: [042] 80003fff 00000000 68644000
[ 2531.717290] r8169 0000:02:00.0: p17p1: [043] 80003fff 00000000 68648000
[ 2531.717294] r8169 0000:02:00.0: p17p1: [044] 80003fff 00000000 6864c000
[ 2531.717299] r8169 0000:02:00.0: p17p1: [045] 80003fff 00000000 68650000
[ 2531.717303] r8169 0000:02:00.0: p17p1: [046] 80003fff 00000000 68654000
[ 2531.717307] r8169 0000:02:00.0: p17p1: [047] 80003fff 00000000 68658000
[ 2531.717311] r8169 0000:02:00.0: p17p1: [048] 80003fff 00000000 6865c000
[ 2531.717316] r8169 0000:02:00.0: p17p1: [049] 80003fff 00000000 68660000
[ 2531.717320] r8169 0000:02:00.0: p17p1: [050] 80003fff 00000000 68664000
[ 2531.717324] r8169 0000:02:00.0: p17p1: [051] 80003fff 00000000 68668000
[ 2531.717329] r8169 0000:02:00.0: p17p1: [052] 80003fff 00000000 6866c000
[ 2531.717333] r8169 0000:02:00.0: p17p1: [053] 80003fff 00000000 68670000
[ 2531.717337] r8169 0000:02:00.0: p17p1: [054] 80003fff 00000000 68674000
[ 2531.717342] r8169 0000:02:00.0: p17p1: [055] 80003fff 00000000 68678000
[ 2531.717346] r8169 0000:02:00.0: p17p1: [056] 80003fff 00000000 6867c000
[ 2531.717350] r8169 0000:02:00.0: p17p1: [057] 80003fff 00000000 68680000
[ 2531.717354] r8169 0000:02:00.0: p17p1: [058] 80003fff 00000000 68684000
[ 2531.717359] r8169 0000:02:00.0: p17p1: [059] 80003fff 00000000 68688000
[ 2531.717363] r8169 0000:02:00.0: p17p1: [060] 80003fff 00000000 6868c000
[ 2531.717368] r8169 0000:02:00.0: p17p1: [061] 80003fff 00000000 68690000
[ 2531.717372] r8169 0000:02:00.0: p17p1: [062] 80003fff 00000000 68694000
[ 2531.717376] r8169 0000:02:00.0: p17p1: [063] 80003fff 00000000 68698000
[ 2531.717381] r8169 0000:02:00.0: p17p1: [064] 80003fff 00000000 6869c000
[ 2531.717385] r8169 0000:02:00.0: p17p1: [065] 80003fff 00000000 686a0000
[ 2531.717389] r8169 0000:02:00.0: p17p1: [066] 80003fff 00000000 686a4000
[ 2531.717394] r8169 0000:02:00.0: p17p1: [067] 80003fff 00000000 686a8000
[ 2531.717398] r8169 0000:02:00.0: p17p1: [068] 80003fff 00000000 686ac000
[ 2531.717402] r8169 0000:02:00.0: p17p1: [069] 80003fff 00000000 686b0000
[ 2531.717407] r8169 0000:02:00.0: p17p1: [070] 80003fff 00000000 686b4000
[ 2531.717411] r8169 0000:02:00.0: p17p1: [071] 80003fff 00000000 686b8000
[ 2531.717415] r8169 0000:02:00.0: p17p1: [072] 80003fff 00000000 686bc000
[ 2531.717419] r8169 0000:02:00.0: p17p1: [073] 80003fff 00000000 686c0000
[ 2531.717424] r8169 0000:02:00.0: p17p1: [074] 80003fff 00000000 686c4000
[ 2531.717428] r8169 0000:02:00.0: p17p1: [075] 80003fff 00000000 686c8000
[ 2531.717432] r8169 0000:02:00.0: p17p1: [076] 80003fff 00000000 686cc000
[ 2531.717437] r8169 0000:02:00.0: p17p1: [077] 80003fff 00000000 686d0000
[ 2531.717441] r8169 0000:02:00.0: p17p1: [078] 80003fff 00000000 686d4000
[ 2531.717445] r8169 0000:02:00.0: p17p1: [079] 80003fff 00000000 686d8000
[ 2531.717450] r8169 0000:02:00.0: p17p1: [080] 80003fff 00000000 686dc000
[ 2531.717454] r8169 0000:02:00.0: p17p1: [081] 80003fff 00000000 686e0000
[ 2531.717458] r8169 0000:02:00.0: p17p1: [082] 80003fff 00000000 686e4000
[ 2531.717462] r8169 0000:02:00.0: p17p1: [083] 80003fff 00000000 686e8000
[ 2531.717467] r8169 0000:02:00.0: p17p1: [084] 80003fff 00000000 686ec000
[ 2531.717471] r8169 0000:02:00.0: p17p1: [085] 80003fff 00000000 686f0000
[ 2531.717475] r8169 0000:02:00.0: p17p1: [086] 80003fff 00000000 686f4000
[ 2531.717480] r8169 0000:02:00.0: p17p1: [087] 80003fff 00000000 686f8000
[ 2531.717484] r8169 0000:02:00.0: p17p1: [088] 80003fff 00000000 686fc000
[ 2531.717488] r8169 0000:02:00.0: p17p1: [089] 80003fff 00000000 68700000
[ 2531.717493] r8169 0000:02:00.0: p17p1: [090] 80003fff 00000000 68704000
[ 2531.717497] r8169 0000:02:00.0: p17p1: [091] 80003fff 00000000 68708000
[ 2531.717501] r8169 0000:02:00.0: p17p1: [092] 80003fff 00000000 6870c000
[ 2531.717505] r8169 0000:02:00.0: p17p1: [093] 80003fff 00000000 68710000
[ 2531.717510] r8169 0000:02:00.0: p17p1: [094] 80003fff 00000000 68714000
[ 2531.717514] r8169 0000:02:00.0: p17p1: [095] 80003fff 00000000 68718000
[ 2531.717519] r8169 0000:02:00.0: p17p1: [096] 80003fff 00000000 6871c000
[ 2531.717523] r8169 0000:02:00.0: p17p1: [097] 80003fff 00000000 68720000
[ 2531.717527] r8169 0000:02:00.0: p17p1: [098] 80003fff 00000000 68724000
[ 2531.717531] r8169 0000:02:00.0: p17p1: [099] 80003fff 00000000 68728000
[ 2531.717536] r8169 0000:02:00.0: p17p1: [100] 80003fff 00000000 6872c000
[ 2531.717540] r8169 0000:02:00.0: p17p1: [101] 80003fff 00000000 68730000
[ 2531.717545] r8169 0000:02:00.0: p17p1: [102] 80003fff 00000000 68734000
[ 2531.717549] r8169 0000:02:00.0: p17p1: [103] 80003fff 00000000 68738000
[ 2531.717553] r8169 0000:02:00.0: p17p1: [104] 80003fff 00000000 6873c000
[ 2531.717558] r8169 0000:02:00.0: p17p1: [105] 80003fff 00000000 68740000
[ 2531.717562] r8169 0000:02:00.0: p17p1: [106] 80003fff 00000000 68744000
[ 2531.717566] r8169 0000:02:00.0: p17p1: [107] 80003fff 00000000 68748000
[ 2531.717571] r8169 0000:02:00.0: p17p1: [108] 80003fff 00000000 6874c000
[ 2531.717575] r8169 0000:02:00.0: p17p1: [109] 80003fff 00000000 68750000
[ 2531.717579] r8169 0000:02:00.0: p17p1: [110] 80003fff 00000000 68754000
[ 2531.717584] r8169 0000:02:00.0: p17p1: [111] 80003fff 00000000 68758000
[ 2531.717588] r8169 0000:02:00.0: p17p1: [112] 80003fff 00000000 6875c000
[ 2531.717593] r8169 0000:02:00.0: p17p1: [113] 80003fff 00000000 68760000
[ 2531.717597] r8169 0000:02:00.0: p17p1: [114] 80003fff 00000000 68764000
[ 2531.717602] r8169 0000:02:00.0: p17p1: [115] 80003fff 00000000 68768000
[ 2531.717606] r8169 0000:02:00.0: p17p1: [116] 80003fff 00000000 6876c000
[ 2531.717610] r8169 0000:02:00.0: p17p1: [117] 80003fff 00000000 68770000
[ 2531.717615] r8169 0000:02:00.0: p17p1: [118] 80003fff 00000000 68774000
[ 2531.717619] r8169 0000:02:00.0: p17p1: [119] 80003fff 00000000 68778000
[ 2531.717623] r8169 0000:02:00.0: p17p1: [120] 80003fff 00000000 6877c000
[ 2531.717628] r8169 0000:02:00.0: p17p1: [121] 80003fff 00000000 68780000
[ 2531.717632] r8169 0000:02:00.0: p17p1: [122] 80003fff 00000000 68784000
[ 2531.717636] r8169 0000:02:00.0: p17p1: [123] 80003fff 00000000 68788000
[ 2531.717641] r8169 0000:02:00.0: p17p1: [124] 80003fff 00000000 6878c000
[ 2531.717645] r8169 0000:02:00.0: p17p1: [125] 80003fff 00000000 68790000
[ 2531.717649] r8169 0000:02:00.0: p17p1: [126] 80003fff 00000000 68794000
[ 2531.717654] r8169 0000:02:00.0: p17p1: [127] 80003fff 00000000 68798000
[ 2531.717658] r8169 0000:02:00.0: p17p1: [128] 80003fff 00000000 6879c000
[ 2531.717662] r8169 0000:02:00.0: p17p1: [129] 80003fff 00000000 687a0000
[ 2531.717667] r8169 0000:02:00.0: p17p1: [130] 80003fff 00000000 687a4000
[ 2531.717671] r8169 0000:02:00.0: p17p1: [131] 80003fff 00000000 687a8000
[ 2531.717675] r8169 0000:02:00.0: p17p1: [132] 80003fff 00000000 687ac000
[ 2531.717680] r8169 0000:02:00.0: p17p1: [133] 80003fff 00000000 687b0000
[ 2531.717684] r8169 0000:02:00.0: p17p1: [134] 80003fff 00000000 687b4000
[ 2531.717688] r8169 0000:02:00.0: p17p1: [135] 80003fff 00000000 687b8000
[ 2531.717693] r8169 0000:02:00.0: p17p1: [136] 80003fff 00000000 687bc000
[ 2531.717697] r8169 0000:02:00.0: p17p1: [137] 80003fff 00000000 687c0000
[ 2531.717701] r8169 0000:02:00.0: p17p1: [138] 80003fff 00000000 687c4000
[ 2531.717706] r8169 0000:02:00.0: p17p1: [139] 80003fff 00000000 687c8000
[ 2531.717710] r8169 0000:02:00.0: p17p1: [140] 80003fff 00000000 687cc000
[ 2531.717714] r8169 0000:02:00.0: p17p1: [141] 80003fff 00000000 687d0000
[ 2531.717719] r8169 0000:02:00.0: p17p1: [142] 80003fff 00000000 687d4000
[ 2531.717723] r8169 0000:02:00.0: p17p1: [143] 80003fff 00000000 687d8000
[ 2531.717727] r8169 0000:02:00.0: p17p1: [144] 80003fff 00000000 687dc000
[ 2531.717732] r8169 0000:02:00.0: p17p1: [145] 80003fff 00000000 687e0000
[ 2531.717736] r8169 0000:02:00.0: p17p1: [146] 80003fff 00000000 687e4000
[ 2531.717740] r8169 0000:02:00.0: p17p1: [147] 80003fff 00000000 687e8000
[ 2531.717745] r8169 0000:02:00.0: p17p1: [148] 80003fff 00000000 687ec000
[ 2531.717749] r8169 0000:02:00.0: p17p1: [149] 80003fff 00000000 687f0000
[ 2531.717754] r8169 0000:02:00.0: p17p1: [150] 80003fff 00000000 687f4000
[ 2531.717758] r8169 0000:02:00.0: p17p1: [151] 80003fff 00000000 687f8000
[ 2531.717762] r8169 0000:02:00.0: p17p1: [152] 80003fff 00000000 687fc000
[ 2531.717767] r8169 0000:02:00.0: p17p1: [153] 80003fff 00000000 68000000
[ 2531.717771] r8169 0000:02:00.0: p17p1: [154] 80003fff 00000000 68004000
[ 2531.717776] r8169 0000:02:00.0: p17p1: [155] 80003fff 00000000 68008000
[ 2531.717780] r8169 0000:02:00.0: p17p1: [156] 80003fff 00000000 6800c000
[ 2531.717784] r8169 0000:02:00.0: p17p1: [157] 80003fff 00000000 68010000
[ 2531.717788] r8169 0000:02:00.0: p17p1: [158] 80003fff 00000000 68014000
[ 2531.717793] r8169 0000:02:00.0: p17p1: [159] 80003fff 00000000 68018000
[ 2531.717797] r8169 0000:02:00.0: p17p1: [160] 80003fff 00000000 6801c000
[ 2531.717802] r8169 0000:02:00.0: p17p1: [161] 80003fff 00000000 68020000
[ 2531.717806] r8169 0000:02:00.0: p17p1: [162] 80003fff 00000000 68024000
[ 2531.717810] r8169 0000:02:00.0: p17p1: [163] 80003fff 00000000 68028000
[ 2531.717815] r8169 0000:02:00.0: p17p1: [164] 80003fff 00000000 6802c000
[ 2531.717820] r8169 0000:02:00.0: p17p1: [165] 80003fff 00000000 68030000
[ 2531.717824] r8169 0000:02:00.0: p17p1: [166] 80003fff 00000000 68034000
[ 2531.717828] r8169 0000:02:00.0: p17p1: [167] 80003fff 00000000 68038000
[ 2531.717833] r8169 0000:02:00.0: p17p1: [168] 80003fff 00000000 6803c000
[ 2531.717837] r8169 0000:02:00.0: p17p1: [169] 80003fff 00000000 68040000
[ 2531.717841] r8169 0000:02:00.0: p17p1: [170] 80003fff 00000000 68044000
[ 2531.717846] r8169 0000:02:00.0: p17p1: [171] 80003fff 00000000 68048000
[ 2531.717850] r8169 0000:02:00.0: p17p1: [172] 80003fff 00000000 6804c000
[ 2531.717854] r8169 0000:02:00.0: p17p1: [173] 80003fff 00000000 68050000
[ 2531.717859] r8169 0000:02:00.0: p17p1: [174] 80003fff 00000000 68054000
[ 2531.717863] r8169 0000:02:00.0: p17p1: [175] 80003fff 00000000 68058000
[ 2531.717867] r8169 0000:02:00.0: p17p1: [176] 80003fff 00000000 6805c000
[ 2531.717872] r8169 0000:02:00.0: p17p1: [177] 80003fff 00000000 68060000
[ 2531.717876] r8169 0000:02:00.0: p17p1: [178] 80003fff 00000000 68064000
[ 2531.717880] r8169 0000:02:00.0: p17p1: [179] 80003fff 00000000 68068000
[ 2531.717885] r8169 0000:02:00.0: p17p1: [180] 80003fff 00000000 6806c000
[ 2531.717889] r8169 0000:02:00.0: p17p1: [181] 80003fff 00000000 68070000
[ 2531.717893] r8169 0000:02:00.0: p17p1: [182] 80003fff 00000000 68074000
[ 2531.717898] r8169 0000:02:00.0: p17p1: [183] 80003fff 00000000 68078000
[ 2531.717902] r8169 0000:02:00.0: p17p1: [184] 80003fff 00000000 6807c000
[ 2531.717906] r8169 0000:02:00.0: p17p1: [185] 80003fff 00000000 68080000
[ 2531.717911] r8169 0000:02:00.0: p17p1: [186] 80003fff 00000000 68084000
[ 2531.717915] r8169 0000:02:00.0: p17p1: [187] 80003fff 00000000 68088000
[ 2531.717919] r8169 0000:02:00.0: p17p1: [188] 80003fff 00000000 6808c000
[ 2531.717924] r8169 0000:02:00.0: p17p1: [189] 80003fff 00000000 68090000
[ 2531.717928] r8169 0000:02:00.0: p17p1: [190] 80003fff 00000000 68094000
[ 2531.717933] r8169 0000:02:00.0: p17p1: [191] 80003fff 00000000 68098000
[ 2531.717937] r8169 0000:02:00.0: p17p1: [192] 80003fff 00000000 6809c000
[ 2531.717941] r8169 0000:02:00.0: p17p1: [193] 80003fff 00000000 680a0000
[ 2531.717946] r8169 0000:02:00.0: p17p1: [194] 80003fff 00000000 680a4000
[ 2531.717950] r8169 0000:02:00.0: p17p1: [195] 80003fff 00000000 680a8000
[ 2531.717954] r8169 0000:02:00.0: p17p1: [196] 80003fff 00000000 680ac000
[ 2531.717959] r8169 0000:02:00.0: p17p1: [197] 80003fff 00000000 680b0000
[ 2531.717963] r8169 0000:02:00.0: p17p1: [198] 80003fff 00000000 680b4000
[ 2531.717967] r8169 0000:02:00.0: p17p1: [199] 80003fff 00000000 680b8000
[ 2531.717972] r8169 0000:02:00.0: p17p1: [200] 80003fff 00000000 680bc000
[ 2531.717977] r8169 0000:02:00.0: p17p1: [201] 80003fff 00000000 680c0000
[ 2531.717981] r8169 0000:02:00.0: p17p1: [202] 80003fff 00000000 680c4000
[ 2531.717985] r8169 0000:02:00.0: p17p1: [203] 80003fff 00000000 680c8000
[ 2531.717989] r8169 0000:02:00.0: p17p1: [204] 80003fff 00000000 680cc000
[ 2531.717994] r8169 0000:02:00.0: p17p1: [205] 80003fff 00000000 680d0000
[ 2531.717998] r8169 0000:02:00.0: p17p1: [206] 80003fff 00000000 680d4000
[ 2531.718021] r8169 0000:02:00.0: p17p1: [207] 80003fff 00000000 680d8000
[ 2531.718026] r8169 0000:02:00.0: p17p1: [208] 80003fff 00000000 680dc000
[ 2531.718032] r8169 0000:02:00.0: p17p1: [209] 80003fff 00000000 680e0000
[ 2531.718037] r8169 0000:02:00.0: p17p1: [210] 80003fff 00000000 680e4000
[ 2531.718042] r8169 0000:02:00.0: p17p1: [211] 80003fff 00000000 680e8000
[ 2531.718048] r8169 0000:02:00.0: p17p1: [212] 80003fff 00000000 680ec000
[ 2531.718053] r8169 0000:02:00.0: p17p1: [213] 80003fff 00000000 680f0000
[ 2531.718059] r8169 0000:02:00.0: p17p1: [214] 80003fff 00000000 680f4000
[ 2531.718064] r8169 0000:02:00.0: p17p1: [215] 80003fff 00000000 680f8000
[ 2531.718070] r8169 0000:02:00.0: p17p1: [216] 80003fff 00000000 680fc000
[ 2531.718076] r8169 0000:02:00.0: p17p1: [217] 80003fff 00000000 68100000
[ 2531.718082] r8169 0000:02:00.0: p17p1: [218] 80003fff 00000000 68104000
[ 2531.718087] r8169 0000:02:00.0: p17p1: [219] 80003fff 00000000 68108000
[ 2531.718092] r8169 0000:02:00.0: p17p1: [220] 80003fff 00000000 6810c000
[ 2531.718098] r8169 0000:02:00.0: p17p1: [221] 80003fff 00000000 68110000
[ 2531.718103] r8169 0000:02:00.0: p17p1: [222] 80003fff 00000000 68114000
[ 2531.718109] r8169 0000:02:00.0: p17p1: [223] 80003fff 00000000 68118000
[ 2531.718114] r8169 0000:02:00.0: p17p1: [224] 80003fff 00000000 6811c000
[ 2531.718120] r8169 0000:02:00.0: p17p1: [225] 80003fff 00000000 68120000
[ 2531.718126] r8169 0000:02:00.0: p17p1: [226] 80003fff 00000000 68124000
[ 2531.718131] r8169 0000:02:00.0: p17p1: [227] 80003fff 00000000 68128000
[ 2531.718137] r8169 0000:02:00.0: p17p1: [228] 80003fff 00000000 6812c000
[ 2531.718142] r8169 0000:02:00.0: p17p1: [229] 80003fff 00000000 68130000
[ 2531.718148] r8169 0000:02:00.0: p17p1: [230] 80003fff 00000000 68134000
[ 2531.718153] r8169 0000:02:00.0: p17p1: [231] 80003fff 00000000 68138000
[ 2531.718159] r8169 0000:02:00.0: p17p1: [232] 80003fff 00000000 6813c000
[ 2531.718164] r8169 0000:02:00.0: p17p1: [233] 80003fff 00000000 68140000
[ 2531.718169] r8169 0000:02:00.0: p17p1: [234] 80003fff 00000000 68144000
[ 2531.718175] r8169 0000:02:00.0: p17p1: [235] 80003fff 00000000 68148000
[ 2531.718180] r8169 0000:02:00.0: p17p1: [236] 80003fff 00000000 6814c000
[ 2531.718185] r8169 0000:02:00.0: p17p1: [237] 80003fff 00000000 68150000
[ 2531.718191] r8169 0000:02:00.0: p17p1: [238] 80003fff 00000000 68154000
[ 2531.718196] r8169 0000:02:00.0: p17p1: [239] 80003fff 00000000 68158000
[ 2531.718202] r8169 0000:02:00.0: p17p1: [240] 80003fff 00000000 6815c000
[ 2531.718208] r8169 0000:02:00.0: p17p1: [241] 80003fff 00000000 68160000
[ 2531.718213] r8169 0000:02:00.0: p17p1: [242] 80003fff 00000000 68164000
[ 2531.718218] r8169 0000:02:00.0: p17p1: [243] 80003fff 00000000 68168000
[ 2531.718224] r8169 0000:02:00.0: p17p1: [244] 80003fff 00000000 6816c000
[ 2531.718229] r8169 0000:02:00.0: p17p1: [245] 80003fff 00000000 68170000
[ 2531.718235] r8169 0000:02:00.0: p17p1: [246] 80003fff 00000000 68174000
[ 2531.718241] r8169 0000:02:00.0: p17p1: [247] 80003fff 00000000 68178000
[ 2531.718246] r8169 0000:02:00.0: p17p1: [248] 80003fff 00000000 6817c000
[ 2531.718252] r8169 0000:02:00.0: p17p1: [249] 80003fff 00000000 68180000
[ 2531.718257] r8169 0000:02:00.0: p17p1: [250] 80003fff 00000000 68184000
[ 2531.718262] r8169 0000:02:00.0: p17p1: [251] 80003fff 00000000 68188000
[ 2531.718268] r8169 0000:02:00.0: p17p1: [252] 80003fff 00000000 6818c000
[ 2531.718274] r8169 0000:02:00.0: p17p1: [253] 80003fff 00000000 68190000
[ 2531.718279] r8169 0000:02:00.0: p17p1: [254] 80003fff 00000000 68194000
[ 2531.718285] r8169 0000:02:00.0: p17p1: [255] c0003fff 00000000 68198000
[ 2531.718290] r8169 0000:02:00.0: p17p1: Tx ring: dirty=00056279 current=0005627a
[ 2531.718296] r8169 0000:02:00.0: p17p1: [000] 00000000 00000000 799a9a40
[ 2531.718301] r8169 0000:02:00.0: p17p1: [001] 00000000 00000000 799a9a40
[ 2531.718307] r8169 0000:02:00.0: p17p1: [002] 00000000 00000000 799a9a40
[ 2531.718312] r8169 0000:02:00.0: p17p1: [003] 00000000 00000000 799a9a40
[ 2531.718317] r8169 0000:02:00.0: p17p1: [004] 00000000 00000000 799a9a40
[ 2531.718323] r8169 0000:02:00.0: p17p1: [005] 00000000 00000000 799a9a40
[ 2531.718328] r8169 0000:02:00.0: p17p1: [006] 00000000 00000000 799a9a40
[ 2531.718334] r8169 0000:02:00.0: p17p1: [007] 00000000 00000000 799a9a40
[ 2531.718339] r8169 0000:02:00.0: p17p1: [008] 00000000 00000000 799a9a40
[ 2531.718345] r8169 0000:02:00.0: p17p1: [009] 00000000 00000000 799a9a40
[ 2531.718350] r8169 0000:02:00.0: p17p1: [010] 00000000 00000000 799a9a40
[ 2531.718356] r8169 0000:02:00.0: p17p1: [011] 00000000 00000000 799a9a40
[ 2531.718361] r8169 0000:02:00.0: p17p1: [012] 00000000 00000000 799a9a40
[ 2531.718367] r8169 0000:02:00.0: p17p1: [013] 00000000 00000000 799a9a40
[ 2531.718372] r8169 0000:02:00.0: p17p1: [014] 00000000 00000000 799a9a40
[ 2531.718377] r8169 0000:02:00.0: p17p1: [015] 00000000 00000000 799a9a40
[ 2531.718383] r8169 0000:02:00.0: p17p1: [016] 00000000 00000000 799a9a40
[ 2531.718388] r8169 0000:02:00.0: p17p1: [017] 00000000 00000000 799a9a40
[ 2531.718394] r8169 0000:02:00.0: p17p1: [018] 00000000 00000000 799a9a40
[ 2531.718399] r8169 0000:02:00.0: p17p1: [019] 00000000 00000000 799a9a40
[ 2531.718404] r8169 0000:02:00.0: p17p1: [020] 00000000 00000000 799a9a40
[ 2531.718409] r8169 0000:02:00.0: p17p1: [021] 00000000 00000000 799a9a40
[ 2531.718415] r8169 0000:02:00.0: p17p1: [022] 00000000 00000000 799a9a40
[ 2531.718421] r8169 0000:02:00.0: p17p1: [023] 00000000 00000000 799a9a40
[ 2531.718425] r8169 0000:02:00.0: p17p1: [024] 00000000 00000000 799a9a40
[ 2531.718431] r8169 0000:02:00.0: p17p1: [025] 00000000 00000000 799a9a40
[ 2531.718436] r8169 0000:02:00.0: p17p1: [026] 00000000 00000000 799a9a40
[ 2531.718441] r8169 0000:02:00.0: p17p1: [027] 00000000 00000000 799a9a40
[ 2531.718447] r8169 0000:02:00.0: p17p1: [028] 00000000 00000000 799a9a40
[ 2531.718452] r8169 0000:02:00.0: p17p1: [029] 00000000 00000000 799a9a40
[ 2531.718457] r8169 0000:02:00.0: p17p1: [030] 00000000 00000000 799a9a40
[ 2531.718462] r8169 0000:02:00.0: p17p1: [031] 00000000 00000000 799a9a40
[ 2531.718467] r8169 0000:02:00.0: p17p1: [032] 00000000 00000000 799a9a40
[ 2531.718473] r8169 0000:02:00.0: p17p1: [033] 00000000 00000000 799a9a40
[ 2531.718478] r8169 0000:02:00.0: p17p1: [034] 00000000 00000000 799a9a40
[ 2531.718484] r8169 0000:02:00.0: p17p1: [035] 00000000 00000000 799a9a40
[ 2531.718489] r8169 0000:02:00.0: p17p1: [036] 00000000 00000000 799a9a40
[ 2531.718494] r8169 0000:02:00.0: p17p1: [037] 00000000 00000000 799a9a40
[ 2531.718499] r8169 0000:02:00.0: p17p1: [038] 00000000 00000000 799a9a40
[ 2531.718505] r8169 0000:02:00.0: p17p1: [039] 00000000 00000000 799a9a40
[ 2531.718510] r8169 0000:02:00.0: p17p1: [040] 00000000 00000000 799a9a40
[ 2531.718515] r8169 0000:02:00.0: p17p1: [041] 00000000 00000000 799a9a40
[ 2531.718520] r8169 0000:02:00.0: p17p1: [042] 00000000 00000000 799a9a40
[ 2531.718525] r8169 0000:02:00.0: p17p1: [043] 00000000 00000000 799a9a40
[ 2531.718531] r8169 0000:02:00.0: p17p1: [044] 00000000 00000000 799a9a40
[ 2531.718536] r8169 0000:02:00.0: p17p1: [045] 00000000 00000000 799a9a40
[ 2531.718542] r8169 0000:02:00.0: p17p1: [046] 00000000 00000000 799a9a40
[ 2531.718547] r8169 0000:02:00.0: p17p1: [047] 00000000 00000000 799a9a40
[ 2531.718553] r8169 0000:02:00.0: p17p1: [048] 00000000 00000000 799a9a40
[ 2531.718558] r8169 0000:02:00.0: p17p1: [049] 00000000 00000000 799a9a40
[ 2531.718564] r8169 0000:02:00.0: p17p1: [050] 00000000 00000000 799a9a40
[ 2531.718569] r8169 0000:02:00.0: p17p1: [051] 00000000 00000000 799a9a40
[ 2531.718575] r8169 0000:02:00.0: p17p1: [052] 00000000 00000000 799a9a40
[ 2531.718579] r8169 0000:02:00.0: p17p1: [053] 00000000 00000000 799a9a40
[ 2531.718585] r8169 0000:02:00.0: p17p1: [054] 00000000 00000000 799a9a40
[ 2531.718590] r8169 0000:02:00.0: p17p1: [055] 00000000 00000000 799a9a40
[ 2531.718596] r8169 0000:02:00.0: p17p1: [056] 00000000 00000000 799a9a40
[ 2531.718601] r8169 0000:02:00.0: p17p1: [057] 30000000 00000000 ae300ee
[ 2531.718606] r8169 0000:02:00.0: p17p1: [058] 00000000 00000000 799a9a40
[ 2531.718612] r8169 0000:02:00.0: p17p1: [059] 00000000 00000000 799a9a40
[ 2531.718617] r8169 0000:02:00.0: p17p1: [060] 00000000 00000000 799a9a40
[ 2531.718623] r8169 0000:02:00.0: p17p1: [061] 00000000 00000000 799a9a40
[ 2531.718628] r8169 0000:02:00.0: p17p1: [062] 00000000 00000000 799a9a40
[ 2531.718633] r8169 0000:02:00.0: p17p1: [063] 40000000 00000000 799a9a40
[ 2531.718639] r8169 0000:02:00.0: p17p1: [064] b0000050 00000000 799a9a40
[ 2531.718644] r8169 0000:02:00.0: p17p1: [065] b0000050 00000000 799a9a40
[ 2531.718651] r8169 0000:02:00.0: p17p1: [066] b0000050 00000000 799a9a40
[ 2531.718656] r8169 0000:02:00.0: p17p1: [067] b0000050 00000000 799a9a40
[ 2531.718661] r8169 0000:02:00.0: p17p1: [068] b0000050 00000000 799a9a40
[ 2531.718666] r8169 0000:02:00.0: p17p1: [069] b0000050 00000000 799a9a40
[ 2531.718672] r8169 0000:02:00.0: p17p1: [070] b0000050 00000000 799a9a40
[ 2531.718677] r8169 0000:02:00.0: p17p1: [071] b0000050 00000000 799a9a40
[ 2531.718682] r8169 0000:02:00.0: p17p1: [072] b0000050 00000000 799a9a40
[ 2531.718688] r8169 0000:02:00.0: p17p1: [073] b0000050 00000000 799a9a40
[ 2531.718693] r8169 0000:02:00.0: p17p1: [074] b0000050 00000000 799a9a40
[ 2531.718699] r8169 0000:02:00.0: p17p1: [075] b0000050 00000000 799a9a40
[ 2531.718704] r8169 0000:02:00.0: p17p1: [076] b0000050 00000000 799a9a40
[ 2531.718710] r8169 0000:02:00.0: p17p1: [077] b0000050 00000000 799a9a40
[ 2531.718715] r8169 0000:02:00.0: p17p1: [078] b0000050 00000000 799a9a40
[ 2531.718721] r8169 0000:02:00.0: p17p1: [079] f0000050 00000000 799a9a40
[ 2531.718726] r8169 0000:02:00.0: p17p1: Device queue: avail=-840
[ 2531.718731] r8169 0000:02:00.0: p17p1:  num_queued=87647115
[ 2531.718735] r8169 0000:02:00.0: p17p1:  adj_limit=87646275
[ 2531.718740] r8169 0000:02:00.0: p17p1:  last_obj_cnt=1514
[ 2531.718744] r8169 0000:02:00.0: p17p1:  limit=674
[ 2531.718749] r8169 0000:02:00.0: p17p1:  num_completed=87645601
[ 2531.718753] r8169 0000:02:00.0: p17p1:  prev_ovlimit=906
[ 2531.718758] r8169 0000:02:00.0: p17p1:  prev_num_queued=87647115
[ 2531.718763] r8169 0000:02:00.0: p17p1:  prev_last_obj_cnt=1514
[ 2531.718767] r8169 0000:02:00.0: p17p1:  lowest_slack=378
[ 2531.718772] r8169 0000:02:00.0: p17p1:  slack_start_time=4297189248
[ 2531.718777] r8169 0000:02:00.0: p17p1:  max_limit=1879048192
[ 2531.718782] r8169 0000:02:00.0: p17p1:  min_limit=0
[ 2531.718786] r8169 0000:02:00.0: p17p1:  slack_hold_time=1000
[ 2531.718923] r8169 0000:02:00.0: p17p1: link up
[ 2755.572061] [drm] Got built-in EDID base block and 0 extensions from "edid/1280x1024.bin" for connector "VGA-1"
[ 3057.941940] TCP: lp registered

--------------090301060009020202030701--
