From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84881] New: [ASRock N68-VGS3 FX with onboard Gigabit LAN
 PHY RTL8211CL] Networking and ACPI conflicts
Date: Mon, 22 Sep 2014 09:00:24 -0700
Message-ID: <20140922090024.5f760c1c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36185 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbaIVQAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:00:32 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so4787260pad.1
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 09:00:31 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id gf5sm9685001pbc.89.2014.09.22.09.00.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:00:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 20 Sep 2014 17:48:33 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84881] New: [ASRock N68-VGS3 FX with onboard Gigabit LAN PHY RTL8211CL] Networking and ACPI conflicts


https://bugzilla.kernel.org/show_bug.cgi?id=84881

            Bug ID: 84881
           Summary: [ASRock N68-VGS3 FX with onboard Gigabit LAN PHY
                    RTL8211CL] Networking and ACPI conflicts
           Product: Networking
           Version: 2.5
    Kernel Version: Linux version 3.14-2-amd64
                    (debian-kernel@lists.debian.org) (gcc version 4.8.3
                    (Debian 4.8.3-7) ) #1 SMP Debian 3.14.15-2
                    (2014-08-09)
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: valdir.marcos@ig.com.br
        Regression: No

[ASRock N68-VGS3 FX with onboard Gigabit LAN PHY RTL8211CL] Networking and ACPI
conflicts

Information on the motherboard:
ASRock N68-VGS3 FX
http://www.asrock.com/mb/NVIDIA/N68-VGS3%20FX/?cat=Specifications

Information on the processor:
AMD FX-6300 Six-Core Processor
http://www.amd.com/pt-br/products/server/6000/6300
http://www.amd.com/en-gb/products/processors/desktop/fx


The problem occurs on both Debian 7 Wheezy (stable) and Debian 8 Jessie
(testing)

The Linux kernal seems to have an issue with my on-board networking adapter and
the ACPI of my computer. The boot log provides this bit of information:

[    6.381529] ACPI Warning: SystemIO range
0x0000000000000700-0x000000000000073f conflicts with OpRegion
0x0000000000000700-0x000000000000073f (\_SB_.PCI0.SM00)
(20131218/utaddress-258)
[    6.381533] ACPI: If an ACPI driver is available for this device, you should
use it instead of the native driver
[    6.388008] systemd-udevd[234]: renamed network interface eth1 to eth0

This bug results in two things:

My on-board networking doesn't work, and trying to restart or shutdown the
computer freezes the system.
To restart or shutdown the computer, I have to turn power off.

The 2 or 3 workarounds proposed below do not work on neither Debian 7 nor on
Debian 8:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1003297


This bug is similar on Ubuntu:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1003297
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1264509
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1281930



-----------------------------------------------
Detailed extra information:
-----------------------------------------------
# uname -a
Linux thor 3.14-2-amd64 #1 SMP Debian 3.14.15-2 (2014-08-09) x86_64 GNU/Linux
-----------------------------------------------
# dmesg
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.14-2-amd64 (debian-kernel@lists.debian.org) (gcc
version 4.8.3 (Debian 4.8.3-7) ) #1 SMP Debian 3.14.15-2 (2014-08-09)
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.14-2-amd64
root=UUID=07ef08e5-8088-4019-8619-e882508f454b ro quiet
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e4000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cdf9ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cdfa0000-0x00000000cdfaffff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000cdfb0000-0x00000000cdfdffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000cdfe0000-0x00000000cdffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000feefffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000022effffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: To Be Filled By O.E.M. To Be Filled By O.E.M./N68-VGS3 FX,
BIOS P1.70 10/31/2012
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x22f000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
[    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
[    0.000000]   2 base 0000C0000000 mask FFFFF8000000 write-back
[    0.000000]   3 base 0000C8000000 mask FFFFFC000000 write-back
[    0.000000]   4 base 0000CC000000 mask FFFFFE000000 write-back
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 000000022f000000 aka 8944M
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: update [mem 0xce000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xcdfa0 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at
[ffff8800000ff780]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01aaf000, 0x01aaffff] PGTABLE
[    0.000000] BRK [0x01ab0000, 0x01ab0fff] PGTABLE
[    0.000000] BRK [0x01ab1000, 0x01ab1fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x22ee00000-0x22effffff]
[    0.000000]  [mem 0x22ee00000-0x22effffff] page 2M
[    0.000000] BRK [0x01ab2000, 0x01ab2fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x22c000000-0x22edfffff]
[    0.000000]  [mem 0x22c000000-0x22edfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x200000000-0x22bffffff]
[    0.000000]  [mem 0x200000000-0x22bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xcdf9ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xcddfffff] page 2M
[    0.000000]  [mem 0xcde00000-0xcdf9ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1ffffffff]
[    0.000000]  [mem 0x100000000-0x1ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x3660a000-0x372fcfff]
[    0.000000] ACPI: RSDP 00000000000f9e10 000014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000cdfa0000 000040 (v01 103112 RSDT1459 20121031
MSFT 00000097)
[    0.000000] ACPI: FACP 00000000cdfa0200 000084 (v01 A_M_I  OEMFACP  12000601
MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000cdfa0470 004CAE (v01  AS572 AS572161 00000161
INTL 20051117)
[    0.000000] ACPI: FACS 00000000cdfb0000 000040
[    0.000000] ACPI: APIC 00000000cdfa0390 0000A0 (v01 103112 APIC1459 20121031
MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000cdfa0430 00003C (v01 103112 OEMMCFG  20121031
MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000cdfb0040 000072 (v01 103112 OEMB1459 20121031
MSFT 00000097)
[    0.000000] ACPI: AAFT 00000000cdfaa470 000027 (v01 103112 OEMAAFT  20121031
MSFT 00000097)
[    0.000000] ACPI: HPET 00000000cdfaa4a0 000038 (v01 103112 OEMHPET0 20121031
MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000cdfaa4e0 001158 (v01 A M I  POWERNOW 00000001
AMD  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000022effffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x22effffff]
[    0.000000]   NODE_DATA [mem 0x22eff9000-0x22effdfff]
[    0.000000]  [ffffea0000000000-ffffea0007bfffff] PMD ->
[ffff880226600000-ffff88022d7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x22effffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xcdf9ffff]
[    0.000000]   node   0: [mem 0x100000000-0x22effffff]
[    0.000000] On node 0 totalpages: 2084670
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 11479 pages used for memmap
[    0.000000]   DMA32 zone: 839584 pages, LIFO batch:31
[    0.000000]   Normal zone: 16968 pages used for memmap
[    0.000000]   Normal zone: 1241088 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x508
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x86] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x87] disabled)
[    0.000000] ACPI: IOAPIC (id[0x16] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 22, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ14 used by override.
[    0.000000] ACPI: IRQ15 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000e3fff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e4000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcdfa0000-0xcdfaffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcdfb0000-0xcdfdffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcdfe0000-0xcdffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xce000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfeefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfef00000-0xffefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfff00000-0xffffffff]
[    0.000000] e820: [mem 0xce000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:8
nr_node_ids:1
[    0.000000] PERCPU: Embedded 29 pages/cpu @ffff88022ec00000 s86080 r8192
d24512 u262144
[    0.000000] pcpu-alloc: s86080 r8192 d24512 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total
pages: 2056146
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.14-2-amd64
root=UUID=07ef08e5-8088-4019-8619-e882508f454b ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ 0 size 32 MB
[    0.000000] Your BIOS doesn't leave a aperture memory hole
[    0.000000] Please enable the IOMMU option in the BIOS setup
[    0.000000] This costs you 64 MB of RAM
[    0.000000] Mapping aperture over 65536 KB of RAM @ c4000000
[    0.000000] PM: Registered nosave memory: [mem 0xc4000000-0xc7ffffff]
[    0.000000] Memory: 8064844K/8338680K available (4957K kernel code, 747K
rwdata, 1724K rodata, 1008K init, 960K bss, 273836K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000]  RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=8.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=8
[    0.000000] NR_IRQS:33024 nr_irqs:744 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 3515.938 MHz processor
[    0.000022] Calibrating delay loop (skipped), value calculated using timer
frequency.. 7031.87 BogoMIPS (lpj=14063752)
[    0.000024] pid_max: default: 32768 minimum: 301
[    0.000032] ACPI: Core revision 20131218
[    0.001800] ACPI: All ACPI Tables successfully acquired
[    0.002298] Security Framework initialized
[    0.002309] AppArmor: AppArmor disabled by boot time parameter
[    0.002310] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.002806] Dentry cache hash table entries: 1048576 (order: 11, 8388608
bytes)
[    0.004941] Inode-cache hash table entries: 524288 (order: 10, 4194304
bytes)
[    0.005882] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.005893] Mountpoint-cache hash table entries: 16384 (order: 5, 131072
bytes)
[    0.006092] Initializing cgroup subsys memory
[    0.006097] Initializing cgroup subsys devices
[    0.006099] Initializing cgroup subsys freezer
[    0.006100] Initializing cgroup subsys net_cls
[    0.006101] Initializing cgroup subsys blkio
[    0.006103] Initializing cgroup subsys perf_event
[    0.006124] tseg: 0000000000
[    0.006129] CPU: Physical Processor ID: 0
[    0.006130] CPU: Processor Core ID: 0
[    0.006132] mce: CPU supports 7 MCE banks
[    0.006138] LVT offset 1 assigned for vector 0xf9
[    0.006143] Last level iTLB entries: 4KB 512, 2MB 1024, 4MB 512
[    0.006143] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 512, 1GB 0
[    0.006143] tlb_flushall_shift: 6
[    0.006202] Freeing SMP alternatives memory: 20K (ffffffff819b8000 -
ffffffff819bd000)
[    0.007505] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.047157] smpboot: CPU0: AMD FX(tm)-6300 Six-Core Processor (fam: 15,
model: 02, stepping: 00)
[    0.153033] Performance Events: Fam15h core perfctr, AMD PMU driver.
[    0.153037] ... version:                0
[    0.153038] ... bit width:              48
[    0.153039] ... generic registers:      6
[    0.153040] ... value mask:             0000ffffffffffff
[    0.153041] ... max period:             00007fffffffffff
[    0.153042] ... fixed-purpose events:   0
[    0.153042] ... event mask:             000000000000003f
[    0.153487] NMI watchdog: enabled on all CPUs, permanently consumes one
hw-PMU counter.
[    0.153562] x86: Booting SMP configuration:
[    0.153564] .... node  #0, CPUs:      #1 #2 #3 #4 #5
[    0.219530] x86: Booted up 1 node, 6 CPUs
[    0.219533] smpboot: Total of 6 processors activated (42191.25 BogoMIPS)
[    0.227426] devtmpfs: initialized
[    0.230691] PM: Registering ACPI NVS region [mem 0xcdfb0000-0xcdfdffff]
(196608 bytes)
[    0.230841] pinctrl core: initialized pinctrl subsystem
[    0.230901] NET: Registered protocol family 16
[    0.230983] cpuidle: using governor ladder
[    0.230985] cpuidle: using governor menu
[    0.231023] ACPI: bus type PCI registered
[    0.231025] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.231111] PCI: MMCONFIG for domain 0000 [bus 00-7f] at [mem
0xf0000000-0xf7ffffff] (base 0xf0000000)
[    0.231114] PCI: not using MMCONFIG
[    0.231115] PCI: Using configuration type 1 for base access
[    0.231115] PCI: Using configuration type 1 for extended access
[    0.231395] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.231396] mtrr: probably your BIOS does not setup all CPUs.
[    0.231396] mtrr: corrected configuration.
[    0.232096] bio: create slab <bio-0> at 0
[    0.232249] ACPI: Added _OSI(Module Device)
[    0.232251] ACPI: Added _OSI(Processor Device)
[    0.232252] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.232253] ACPI: Added _OSI(Processor Aggregator Device)
[    0.233515] ACPI: Executed 1 blocks of module-level executable AML code
[    0.235488] ACPI: Interpreter enabled
[    0.235495] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S2_] (20131218/hwxface-580)
[    0.235506] ACPI: (supports S0 S1 S3 S4 S5)
[    0.235507] ACPI: Using IOAPIC for interrupt routing
[    0.235522] PCI: MMCONFIG for domain 0000 [bus 00-7f] at [mem
0xf0000000-0xf7ffffff] (base 0xf0000000)
[    0.236301] PCI: MMCONFIG at [mem 0xf0000000-0xf7ffffff] reserved in ACPI
motherboard resources
[    0.236456] PCI: Using host bridge windows from ACPI; if necessary, use
"pci=nocrs" and report a bug
[    0.236536] ACPI: No dock devices found.
[    0.242804] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.242809] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM
Segments MSI]
[    0.243005] acpi PNP0A03:00: _OSC: platform does not support [PCIeHotplug
PCIeCapability]
[    0.243102] acpi PNP0A03:00: _OSC: not requesting control; platform does not
support [PCIeCapability]
[    0.243105] acpi PNP0A03:00: _OSC: OS requested [PCIeHotplug PME AER
PCIeCapability]
[    0.243107] acpi PNP0A03:00: _OSC: platform willing to grant [PME AER]
[    0.243108] acpi PNP0A03:00: _OSC failed (AE_SUPPORT); disabling ASPM
[    0.243229] acpi PNP0A03:00: [Firmware Info]: MMCONFIG for domain 0000 [bus
00-7f] only partially covers this bridge
[    0.243331] PCI host bridge to bus 0000:00
[    0.243333] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.243335] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.243337] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.243338] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.243340] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
[    0.243342] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xefffffff]
[    0.243343] pci_bus 0000:00: root bus resource [mem 0xf8000000-0xfebfffff]
[    0.243363] pci 0000:00:00.0: [10de:03e2] type 00 class 0x050000
[    0.243571] pci 0000:00:01.0: [10de:03e1] type 00 class 0x060100
[    0.243578] pci 0000:00:01.0: reg 0x10: [io  0x0900-0x09ff]
[    0.243651] pci 0000:00:01.1: [10de:03eb] type 00 class 0x0c0500
[    0.243662] pci 0000:00:01.1: reg 0x10: [io  0x0e00-0x0e3f]
[    0.243677] pci 0000:00:01.1: reg 0x20: [io  0x0600-0x063f]
[    0.243682] pci 0000:00:01.1: reg 0x24: [io  0x0700-0x073f]
[    0.243710] pci 0000:00:01.1: PME# supported from D3hot D3cold
[    0.243736] pci 0000:00:01.1: System wakeup disabled by ACPI
[    0.243770] pci 0000:00:01.2: [10de:03f5] type 00 class 0x050000
[    0.243840] pci 0000:00:02.0: [10de:03f1] type 00 class 0x0c0310
[    0.243849] pci 0000:00:02.0: reg 0x10: [mem 0xefeff000-0xefefffff]
[    0.243883] pci 0000:00:02.0: supports D1 D2
[    0.243884] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.243906] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.243944] pci 0000:00:02.1: [10de:03f2] type 00 class 0x0c0320
[    0.243954] pci 0000:00:02.1: reg 0x10: [mem 0xefefec00-0xefefecff]
[    0.243995] pci 0000:00:02.1: supports D1 D2
[    0.243996] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.244019] pci 0000:00:02.1: System wakeup disabled by ACPI
[    0.244061] pci 0000:00:04.0: [10de:03f3] type 01 class 0x060401
[    0.244110] pci 0000:00:04.0: System wakeup disabled by ACPI
[    0.244146] pci 0000:00:05.0: [10de:03f0] type 00 class 0x040300
[    0.244156] pci 0000:00:05.0: reg 0x10: [mem 0xefef8000-0xefefbfff]
[    0.244198] pci 0000:00:05.0: PME# supported from D3hot D3cold
[    0.244221] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.244263] pci 0000:00:06.0: [10de:03ec] type 00 class 0x01018a
[    0.244284] pci 0000:00:06.0: reg 0x20: [io  0xffa0-0xffaf]
[    0.244351] pci 0000:00:07.0: [10de:03ef] type 00 class 0x068000
[    0.244361] pci 0000:00:07.0: reg 0x10: [mem 0xefefd000-0xefefdfff]
[    0.244365] pci 0000:00:07.0: reg 0x14: [io  0xd080-0xd087]
[    0.244399] pci 0000:00:07.0: supports D1 D2
[    0.244400] pci 0000:00:07.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.244424] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.244459] pci 0000:00:08.0: [10de:03f6] type 00 class 0x010185
[    0.244467] pci 0000:00:08.0: reg 0x10: [io  0xd000-0xd007]
[    0.244471] pci 0000:00:08.0: reg 0x14: [io  0xcc00-0xcc03]
[    0.244475] pci 0000:00:08.0: reg 0x18: [io  0xc880-0xc887]
[    0.244479] pci 0000:00:08.0: reg 0x1c: [io  0xc800-0xc803]
[    0.244482] pci 0000:00:08.0: reg 0x20: [io  0xc480-0xc48f]
[    0.244486] pci 0000:00:08.0: reg 0x24: [mem 0xefefc000-0xefefcfff]
[    0.244550] pci 0000:00:08.1: [10de:03f6] type 00 class 0x010185
[    0.244558] pci 0000:00:08.1: reg 0x10: [io  0xc400-0xc407]
[    0.244562] pci 0000:00:08.1: reg 0x14: [io  0xc080-0xc083]
[    0.244566] pci 0000:00:08.1: reg 0x18: [io  0xc000-0xc007]
[    0.244569] pci 0000:00:08.1: reg 0x1c: [io  0xbc00-0xbc03]
[    0.244573] pci 0000:00:08.1: reg 0x20: [io  0xb880-0xb88f]
[    0.244577] pci 0000:00:08.1: reg 0x24: [mem 0xefef7000-0xefef7fff]
[    0.244647] pci 0000:00:09.0: [10de:03e8] type 01 class 0x060400
[    0.244674] pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.244698] pci 0000:00:09.0: System wakeup disabled by ACPI
[    0.244734] pci 0000:00:0b.0: [10de:03e9] type 01 class 0x060400
[    0.244760] pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.244783] pci 0000:00:0b.0: System wakeup disabled by ACPI
[    0.244818] pci 0000:00:0c.0: [10de:03e9] type 01 class 0x060400
[    0.244844] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.244866] pci 0000:00:0c.0: System wakeup disabled by ACPI
[    0.244900] pci 0000:00:0d.0: [10de:03d6] type 00 class 0x030000
[    0.244906] pci 0000:00:0d.0: reg 0x10: [mem 0xee000000-0xeeffffff]
[    0.244912] pci 0000:00:0d.0: reg 0x14: [mem 0xd0000000-0xdfffffff 64bit
pref]
[    0.244916] pci 0000:00:0d.0: reg 0x1c: [mem 0xed000000-0xedffffff 64bit]
[    0.244922] pci 0000:00:0d.0: reg 0x30: [mem 0xefec0000-0xefedffff pref]
[    0.244988] pci 0000:00:18.0: [1022:1600] type 00 class 0x060000
[    0.245041] pci 0000:00:18.1: [1022:1601] type 00 class 0x060000
[    0.245090] pci 0000:00:18.2: [1022:1602] type 00 class 0x060000
[    0.245139] pci 0000:00:18.3: [1022:1603] type 00 class 0x060000
[    0.245192] pci 0000:00:18.4: [1022:1604] type 00 class 0x060000
[    0.245241] pci 0000:00:18.5: [1022:1605] type 00 class 0x060000
[    0.245344] pci 0000:01:0a.0: [1106:3106] type 00 class 0x020000
[    0.245357] pci 0000:01:0a.0: reg 0x10: [io  0xe800-0xe8ff]
[    0.245364] pci 0000:01:0a.0: reg 0x14: [mem 0xeffffc00-0xeffffcff]
[    0.245414] pci 0000:01:0a.0: supports D1 D2
[    0.245415] pci 0000:01:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.245470] pci 0000:00:04.0: PCI bridge to [bus 01] (subtractive decode)
[    0.245473] pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
[    0.245475] pci 0000:00:04.0:   bridge window [mem 0xeff00000-0xefffffff]
[    0.245478] pci 0000:00:04.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.245480] pci 0000:00:04.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.245481] pci 0000:00:04.0:   bridge window [mem 0x000a0000-0x000bffff]
(subtractive decode)
[    0.245483] pci 0000:00:04.0:   bridge window [mem 0x000d0000-0x000dffff]
(subtractive decode)
[    0.245485] pci 0000:00:04.0:   bridge window [mem 0xd0000000-0xefffffff]
(subtractive decode)
[    0.245486] pci 0000:00:04.0:   bridge window [mem 0xf8000000-0xfebfffff]
(subtractive decode)
[    0.245526] pci 0000:00:09.0: PCI bridge to [bus 02]
[    0.245567] pci 0000:00:0b.0: PCI bridge to [bus 03]
[    0.245602] pci 0000:00:0c.0: PCI bridge to [bus 04]
[    0.246058] ACPI: PCI Interrupt Link [LNKA] (IRQs 16 17 18 19) *0, disabled.
[    0.246142] ACPI: PCI Interrupt Link [LNKB] (IRQs 16 17 18 19) *0, disabled.
[    0.246227] ACPI: PCI Interrupt Link [LNKC] (IRQs 16 17 18 19) *10
[    0.246308] ACPI: PCI Interrupt Link [LNKD] (IRQs 16 17 18 19) *0, disabled.
[    0.246389] ACPI: PCI Interrupt Link [LNEA] (IRQs 16 17 18 19) *0, disabled.
[    0.246471] ACPI: PCI Interrupt Link [LNEB] (IRQs 16 17 18 19) *0, disabled.
[    0.246551] ACPI: PCI Interrupt Link [LNEC] (IRQs 16 17 18 19) *0, disabled.
[    0.246631] ACPI: PCI Interrupt Link [LNED] (IRQs 16 17 18 19) *0, disabled.
[    0.246714] ACPI: PCI Interrupt Link [LUB0] (IRQs 20 21 22 23) *10
[    0.246796] ACPI: PCI Interrupt Link [LUB2] (IRQs 20 21 22 23) *11
[    0.246877] ACPI: PCI Interrupt Link [LMAC] (IRQs 20 21 22 23) *10
[    0.246958] ACPI: PCI Interrupt Link [LAZA] (IRQs 20 21 22 23) *10
[    0.247040] ACPI: PCI Interrupt Link [LMC9] (IRQs 20 21 22 23) *10
[    0.247121] ACPI: PCI Interrupt Link [LSMB] (IRQs 20 21 22 23) *11
[    0.247202] ACPI: PCI Interrupt Link [LPMU] (IRQs 20 21 22 23) *0, disabled.
[    0.247284] ACPI: PCI Interrupt Link [LSA0] (IRQs 20 21 22 23) *5
[    0.247365] ACPI: PCI Interrupt Link [LSA1] (IRQs 20 21 22 23) *5
[    0.247479] ACPI: PCI Interrupt Link [LATA] (IRQs 20 21 22 23) *0, disabled.
[    0.247518] ACPI: Enabled 1 GPEs in block 00 to 1F
[    0.247593] vgaarb: device added:
PCI:0000:00:0d.0,decodes=io+mem,owns=io+mem,locks=none
[    0.247595] vgaarb: loaded
[    0.247596] vgaarb: bridge control possible 0000:00:0d.0
[    0.247632] PCI: Using ACPI for IRQ routing
[    0.250804] PCI: pci_cache_line_size set to 64 bytes
[    0.250834] e820: reserve RAM buffer [mem 0x0009f800-0x0009ffff]
[    0.250836] e820: reserve RAM buffer [mem 0xcdfa0000-0xcfffffff]
[    0.250837] e820: reserve RAM buffer [mem 0x22f000000-0x22fffffff]
[    0.250933] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
[    0.250936] hpet0: 3 comparators, 32-bit 25.000000 MHz counter
[    0.252988] Switched to clocksource hpet
[    0.254879] pnp: PnP ACPI init
[    0.254890] ACPI: bus type PNP registered
[    0.254921] pnp 00:00: [dma 4]
[    0.254942] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.254965] pnp 00:01: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.254997] pnp 00:02: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.255326] pnp 00:03: [dma 3]
[    0.255415] pnp 00:03: Plug and Play ACPI device, IDs PNP0401 (active)
[    0.255773] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.255775] system 00:04: [io  0x0500-0x057f] could not be reserved
[    0.255778] system 00:04: [io  0x0580-0x05ff] has been reserved
[    0.255780] system 00:04: [io  0x0800-0x087f] has been reserved
[    0.255781] system 00:04: [io  0x0880-0x08ff] has been reserved
[    0.255783] system 00:04: [io  0x0d00-0x0d7f] has been reserved
[    0.255785] system 00:04: [io  0x0d80-0x0dff] has been reserved
[    0.255786] system 00:04: [io  0x1100-0x117f] has been reserved
[    0.255788] system 00:04: [io  0x1180-0x11ff] has been reserved
[    0.255790] system 00:04: [mem 0x000d0000-0x000d3fff window] has been
reserved
[    0.255792] system 00:04: [mem 0x000d4000-0x000d7fff window] has been
reserved
[    0.255794] system 00:04: [mem 0x000de000-0x000dffff window] has been
reserved
[    0.255797] system 00:04: [mem 0xfec80000-0xfecfffff] has been reserved
[    0.255799] system 00:04: [mem 0xfefe0000-0xfefe01ff] has been reserved
[    0.255800] system 00:04: [mem 0xfefe1000-0xfefe1fff] has been reserved
[    0.255802] system 00:04: [mem 0xfee01000-0xfeefffff] has been reserved
[    0.255804] system 00:04: [mem 0xffb80000-0xffffffff] could not be reserved
[    0.255806] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.255931] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.256016] system 00:06: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.256019] system 00:06: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.256021] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.256215] pnp 00:07: [dma 0 disabled]
[    0.256258] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.256358] system 00:08: [io  0x0280-0x028f] has been reserved
[    0.256360] system 00:08: [io  0x0290-0x029f] has been reserved
[    0.256362] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.256420] system 00:09: [mem 0xf0000000-0xf7ffffff] has been reserved
[    0.256422] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.256602] system 00:0a: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.256605] system 00:0a: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.256607] system 00:0a: [mem 0x00100000-0xcfffffff] could not be reserved
[    0.256608] system 00:0a: [mem 0xfec00000-0xffffffff] could not be reserved
[    0.256610] system 00:0a: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.256813] pnp: PnP ACPI: found 11 devices
[    0.256814] ACPI: bus type PNP unregistered
[    0.263332] pci 0000:00:04.0: PCI bridge to [bus 01]
[    0.263335] pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
[    0.263338] pci 0000:00:04.0:   bridge window [mem 0xeff00000-0xefffffff]
[    0.263343] pci 0000:00:09.0: PCI bridge to [bus 02]
[    0.263347] pci 0000:00:0b.0: PCI bridge to [bus 03]
[    0.263351] pci 0000:00:0c.0: PCI bridge to [bus 04]
[    0.263355] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.263357] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.263358] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.263360] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.263361] pci_bus 0000:00: resource 8 [mem 0xd0000000-0xefffffff]
[    0.263363] pci_bus 0000:00: resource 9 [mem 0xf8000000-0xfebfffff]
[    0.263364] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    0.263365] pci_bus 0000:01: resource 1 [mem 0xeff00000-0xefffffff]
[    0.263367] pci_bus 0000:01: resource 4 [io  0x0000-0x0cf7]
[    0.263368] pci_bus 0000:01: resource 5 [io  0x0d00-0xffff]
[    0.263369] pci_bus 0000:01: resource 6 [mem 0x000a0000-0x000bffff]
[    0.263371] pci_bus 0000:01: resource 7 [mem 0x000d0000-0x000dffff]
[    0.263372] pci_bus 0000:01: resource 8 [mem 0xd0000000-0xefffffff]
[    0.263373] pci_bus 0000:01: resource 9 [mem 0xf8000000-0xfebfffff]
[    0.263458] NET: Registered protocol family 2
[    0.263665] TCP established hash table entries: 65536 (order: 7, 524288
bytes)
[    0.263842] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.264028] TCP: Hash tables configured (established 65536 bind 65536)
[    0.264052] TCP: reno registered
[    0.264064] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.264099] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.264206] NET: Registered protocol family 1
[    0.264422] ACPI: PCI Interrupt Link [LUB0] enabled at IRQ 23
[    0.341168] ACPI: PCI Interrupt Link [LUB2] enabled at IRQ 22
[    0.341271] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341318] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341375] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341430] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341486] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341546] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341610] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341678] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.341683] pci 0000:00:0d.0: Boot video device
[    0.341695] PCI: CLS 64 bytes, default 64
[    0.341734] Unpacking initramfs...
[    0.554755] Freeing initrd memory: 13260K (ffff88003660a000 -
ffff8800372fd000)
[    0.554961] PCI-DMA: Disabling AGP.
[    0.555036] PCI-DMA: aperture base @ c4000000 size 65536 KB
[    0.555037] PCI-DMA: using GART IOMMU.
[    0.555040] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.559236] perf: AMD NB counters detected
[    0.559292] microcode: CPU0: patch_level=0x00000000
[    0.559300] microcode: CPU1: patch_level=0x00000000
[    0.559304] microcode: CPU2: patch_level=0x00000000
[    0.559310] microcode: CPU3: patch_level=0x00000000
[    0.559319] microcode: CPU4: patch_level=0x00000000
[    0.559328] microcode: CPU5: patch_level=0x00000000
[    0.559406] microcode: Microcode Update Driver: v2.00
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.559409] LVT offset 0 assigned for vector 0x400
[    0.559434] perf: AMD IBS detected (0x000000ff)
[    0.559739] futex hash table entries: 2048 (order: 5, 131072 bytes)
[    0.559807] audit: initializing netlink subsys (disabled)
[    0.559827] audit: type=2000 audit(1411258066.452:1): initialized
[    0.569698] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.569913] VFS: Disk quotas dquot_6.5.2
[    0.569936] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.569988] msgmni has been set to 15906
[    0.570236] alg: No test for stdrng (krng)
[    0.570263] Block layer SCSI generic (bsg) driver version 0.4 loaded (major
252)
[    0.570315] io scheduler noop registered
[    0.570316] io scheduler deadline registered
[    0.570341] io scheduler cfq registered (default)
[    0.570418] pcieport 0000:00:09.0: irq 40 for MSI/MSI-X
[    0.570463] pcieport 0000:00:0b.0: irq 41 for MSI/MSI-X
[    0.570503] pcieport 0000:00:0c.0: irq 42 for MSI/MSI-X
[    0.570557] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.570571] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.570624] GHES: HEST is not enabled!
[    0.570671] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.590995] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a
16550A
[    0.591296] Linux agpgart interface v0.103
[    0.591376] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    0.593841] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.593846] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.593978] mousedev: PS/2 mouse device common for all mice
[    0.594026] rtc_cmos 00:05: RTC can wake from S4
[    0.594181] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    0.594220] rtc_cmos 00:05: alarms up to one year, y3k, 114 bytes nvram,
hpet irqs
[    0.594227] AMD IOMMUv2 driver by Joerg Roedel <joerg.roedel@amd.com>
[    0.594228] AMD IOMMUv2 functionality not available on this system
[    0.594322] TCP: cubic registered
[    0.594395] NET: Registered protocol family 10
[    0.594602] mip6: Mobile IPv6
[    0.594604] NET: Registered protocol family 17
[    0.594606] mpls_gso: MPLS GSO support
[    0.595097] registered taskstats version 1
[    0.595437] rtc_cmos 00:05: setting system clock to 2014-09-21 00:07:47 UTC
(1411258067)
[    0.595473] PM: Hibernation image not present or could not be loaded.
[    0.596121] Freeing unused kernel memory: 1008K (ffffffff818bc000 -
ffffffff819b8000)
[    0.596122] Write protecting the kernel read-only data: 8192k
[    0.598242] Freeing unused kernel memory: 1176K (ffff8800014da000 -
ffff880001600000)
[    0.598815] Freeing unused kernel memory: 324K (ffff8800017af000 -
ffff880001800000)
[    0.606895] systemd-udevd[80]: starting version 208
[    0.607155] random: systemd-udevd urandom read with 3 bits of entropy
available
[    0.618539] via_rhine: v1.10-LK1.5.1 2010-10-09 Written by Donald Becker
[    0.618778] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 19
[    0.624139] forcedeth: Reverse Engineered nForce ethernet driver. Version
0.64.
[    0.624208] SCSI subsystem initialized
[    0.624269] via-rhine 0000:01:0a.0 eth0: VIA Rhine III at 0x1e800,
34:08:04:9f:c2:35, IRQ 19
[    0.624396] ACPI: PCI Interrupt Link [LMAC] enabled at IRQ 21
[    0.624760] ACPI: bus type USB registered
[    0.624791] usbcore: registered new interface driver usbfs
[    0.624808] usbcore: registered new interface driver hub
[    0.625079] via-rhine 0000:01:0a.0 eth0: MII PHY found at address 1, status
0x786d advertising 05e1 Link 45e1
[    0.625156] usbcore: registered new device driver usb
[    0.625548] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.625702] ehci-pci: EHCI PCI platform driver
[    0.625732] libata version 3.00 loaded.
[    0.626424] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.689681] forcedeth 0000:00:07.0: ifname eth1, PHY OUI 0x732 @ 3, addr
bc:5f:f4:b3:91:39
[    0.689685] forcedeth 0000:00:07.0: highdma pwrctl mgmt gbit lnktim msi
desc-v3
[    0.689816] ehci-pci 0000:00:02.1: EHCI Host Controller
[    0.689823] ehci-pci 0000:00:02.1: new USB bus registered, assigned bus
number 1
[    0.689833] ehci-pci 0000:00:02.1: debug port 1
[    0.689858] ehci-pci 0000:00:02.1: cache line size of 64 is not supported
[    0.689878] ehci-pci 0000:00:02.1: irq 22, io mem 0xefefec00
[    0.700636] ehci-pci 0000:00:02.1: USB 2.0 started, EHCI 1.00
[    0.700757] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.700760] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.700762] usb usb1: Product: EHCI Host Controller
[    0.700764] usb usb1: Manufacturer: Linux 3.14-2-amd64 ehci_hcd
[    0.700765] usb usb1: SerialNumber: 0000:00:02.1
[    0.700894] hub 1-0:1.0: USB hub found
[    0.700910] hub 1-0:1.0: 10 ports detected
[    0.701225] sata_nv 0000:00:08.0: version 3.5
[    0.701426] ohci-pci: OHCI PCI platform driver
[    0.701435] ACPI: PCI Interrupt Link [LSA0] enabled at IRQ 20
[    0.701777] scsi0 : sata_nv
[    0.701930] scsi1 : sata_nv
[    0.701980] ata1: SATA max UDMA/133 cmd 0xd000 ctl 0xcc00 bmdma 0xc480 irq
20
[    0.701983] ata2: SATA max UDMA/133 cmd 0xc880 ctl 0xc800 bmdma 0xc488 irq
20
[    0.702148] ACPI: PCI Interrupt Link [LSA1] enabled at IRQ 23
[    0.702482] scsi2 : sata_nv
[    0.702601] scsi3 : sata_nv
[    0.702652] ata3: SATA max UDMA/133 cmd 0xc400 ctl 0xc080 bmdma 0xb880 irq
23
[    0.702654] ata4: SATA max UDMA/133 cmd 0xc000 ctl 0xbc00 bmdma 0xb888 irq
23
[    0.702686] pata_amd 0000:00:06.0: version 0.4.1
[    0.703392] scsi4 : pata_amd
[    0.703510] scsi5 : pata_amd
[    0.703554] ata5: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.703556] ata6: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    0.703706] ohci-pci 0000:00:02.0: OHCI PCI host controller
[    0.703711] ohci-pci 0000:00:02.0: new USB bus registered, assigned bus
number 2
[    0.703727] ohci-pci 0000:00:02.0: irq 23, io mem 0xefeff000
[    0.758619] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    0.758621] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.758623] usb usb2: Product: OHCI PCI host controller
[    0.758624] usb usb2: Manufacturer: Linux 3.14-2-amd64 ohci_hcd
[    0.758625] usb usb2: SerialNumber: 0000:00:02.0
[    0.758733] hub 2-0:1.0: USB hub found
[    0.758739] hub 2-0:1.0: 10 ports detected
[    1.026684] ata3: SATA link down (SStatus 0 SControl 300)
[    1.026686] ata1: SATA link down (SStatus 0 SControl 300)
[    1.260187] usb 2-2: new low-speed USB device number 2 using ohci-pci
[    1.474016] usb 2-2: New USB device found, idVendor=0e8f, idProduct=0022
[    1.474018] usb 2-2: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    1.474020] usb 2-2: Product: USB KB V11
[    1.474021] usb 2-2: Manufacturer: GASIA
[    1.480733] hidraw: raw HID events driver (C) Jiri Kosina
[    1.492015] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.494148] usbcore: registered new interface driver usbhid
[    1.494150] usbhid: USB HID core driver
[    1.494662] input: GASIA USB KB V11 as
/devices/pci0000:00/0000:00:02.0/usb2/2-2/2-2:1.0/0003:0E8F:0022.0001/input/input2
[    1.494710] hid-generic 0003:0E8F:0022.0001: input,hidraw0: USB HID v1.10
Keyboard [GASIA USB KB V11] on usb-0000:00:02.0-2/input0
[    1.499067] input: GASIA USB KB V11 as
/devices/pci0000:00/0000:00:02.0/usb2/2-2/2-2:1.1/0003:0E8F:0022.0002/input/input3
[    1.499121] hid-generic 0003:0E8F:0022.0002: input,hidraw1: USB HID v1.10
Device [GASIA USB KB V11] on usb-0000:00:02.0-2/input1
[    1.500240] ata2.00: ATA-8: ST2000DM001-9YN164, CC4B, max UDMA/133
[    1.500243] ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    1.508227] ata2.00: configured for UDMA/133
[    1.508338] scsi 1:0:0:0: Direct-Access     ATA      ST2000DM001-9YN1 CC4B
PQ: 0 ANSI: 5
[    1.555928] tsc: Refined TSC clocksource calibration: 3515.989 MHz
[    1.975605] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    1.983768] ata4.00: ATAPI: TSSTcorp CDDVDW SH-S223C, SB01, max UDMA/100
[    1.999754] ata4.00: configured for UDMA/100
[    2.003411] scsi 3:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S223C  SB01
PQ: 0 ANSI: 5
[    2.003611] ata6: port disabled--ignoring
[    2.005777] sd 1:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00
TB/1.81 TiB)
[    2.005780] sd 1:0:0:0: [sda] 4096-byte physical blocks
[    2.005872] sd 1:0:0:0: [sda] Write Protect is off
[    2.005874] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.005908] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled,
doesn't support DPO or FUA
[    2.014432] sr0: scsi3-mmc drive: 52x/52x writer dvd-ram cd/rw xa/form2 cdda
tray
[    2.014434] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.014560] sr 3:0:0:0: Attached scsi CD-ROM sr0
[    2.015045] sd 1:0:0:0: Attached scsi generic sg0 type 0
[    2.015097] sr 3:0:0:0: Attached scsi generic sg1 type 5
[    2.071105]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 sda9 >
[    2.071731] sd 1:0:0:0: [sda] Attached SCSI disk
[    2.555164] Switched to clocksource tsc
[    3.634227] floppy0: no floppy controllers found
[    3.689561] PM: Starting manual resume from disk
[    3.689565] PM: Hibernation image partition 8:3 present
[    3.689566] PM: Looking for hibernation image.
[    3.689847] PM: Image not found (code -22)
[    3.689850] PM: Hibernation image not present or could not be loaded.
[    3.718034] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts:
(null)
[    4.146473] systemd[1]: systemd 208 running in system mode. (+PAM +LIBWRAP
+AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
[    4.231970] systemd[1]: Inserted module 'autofs4'
[    4.243294] systemd[1]: Set hostname to <thor>.
[    4.327306] random: nonblocking pool is initialized
[    4.667357] systemd[1]: Cannot add dependency job for unit
display-manager.service, ignoring: Unit display-manager.service failed to load:
No such file or directory.
[    4.667576] systemd[1]: Starting Syslog Socket.
[    4.667605] systemd[1]: Listening on Syslog Socket.
[    4.667614] systemd[1]: Starting Forward Password Requests to Wall Directory
Watch.
[    4.667651] systemd[1]: Started Forward Password Requests to Wall Directory
Watch.
[    4.667659] systemd[1]: Starting Remote File Systems (Pre).
[    4.667666] systemd[1]: Reached target Remote File Systems (Pre).
[    4.667673] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[    4.667687] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[    4.667694] systemd[1]: Starting Delayed Shutdown Socket.
[    4.667707] systemd[1]: Listening on Delayed Shutdown Socket.
[    4.667717] systemd[1]: Starting Dispatch Password Requests to Console
Directory Watch.
[    4.667738] systemd[1]: Started Dispatch Password Requests to Console
Directory Watch.
[    4.667758] systemd[1]: Starting Arbitrary Executable File Formats File
System Automount Point.
[    4.667817] systemd[1]: Set up automount Arbitrary Executable File Formats
File System Automount Point.
[    4.667825] systemd[1]: Starting Journal Socket.
[    4.667853] systemd[1]: Listening on Journal Socket.
[    4.667907] systemd[1]: Starting Create list of required static device nodes
for the current kernel...
[    4.668315] systemd[1]: Mounting Debug File System...
[    4.668589] systemd[1]: Mounting POSIX Message Queue File System...
[    4.669688] systemd[1]: Starting Load Kernel Modules...
[    4.669961] systemd[1]: Mounting Huge Pages File System...
[    4.670239] systemd[1]: Starting Syslog.
[    4.670248] systemd[1]: Reached target Syslog.
[    4.670265] systemd[1]: Starting Journal Service...
[    4.670578] systemd[1]: Started Journal Service.
[    5.138147] lp: driver loaded but no devices found
[    5.150522] ppdev: user-space parallel port driver
[    5.151196] parport_pc 00:03: reported by Plug and Play ACPI
[    5.151247] parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
[    5.244967] lp0: using parport0 (interrupt-driven).
[    5.302644] systemd-udevd[197]: starting version 208
[    6.063998] ACPI: acpi_idle registered with cpuidle
[    6.070384] acpi-cpufreq: overriding BIOS provided _PSD data
[    6.131452] input: Power Button as
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input4
[    6.131459] ACPI: Power Button [PWRB]
[    6.131541] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input5
[    6.131545] ACPI: Power Button [PWRF]
[    6.203500] EDAC MC: Ver: 3.0.0
[    6.262857] fam15h_power 0000:00:18.4: Bogus value for ProcessorPwrWatts
(processor_pwr_watts>=16127)
[    6.364156] systemd-udevd[247]: renamed network interface eth0 to rename2
[    6.365920] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.377131] input: PC Speaker as /devices/platform/pcspkr/input/input7
[    6.379937] MCE: In-kernel MCE decoding enabled.
[    6.381525] i2c i2c-0: nForce2 SMBus adapter at 0x600
[    6.381529] ACPI Warning: SystemIO range
0x0000000000000700-0x000000000000073f conflicts with OpRegion
0x0000000000000700-0x000000000000073f (\_SB_.PCI0.SM00)
(20131218/utaddress-258)
[    6.381533] ACPI: If an ACPI driver is available for this device, you should
use it instead of the native driver
[    6.388008] systemd-udevd[234]: renamed network interface eth1 to eth0
[    6.397821] AMD64 EDAC driver v3.4.0
[    6.397849] EDAC amd64: DRAM ECC disabled.
[    6.397858] EDAC amd64: ECC disabled in the BIOS or no ECC capability,
module will not load.
[    6.397858]  Either enable ECC checking or force module loading by setting
'ecc_enable_override'.
[    6.397858]  (Note that use of the override may cause unknown side effects.)
[    6.430658] systemd-udevd[247]: renamed network interface rename2 to eth1
[    6.433164] [drm] Initialized drm 1.1.0 20060810
[    6.495678] ACPI: PCI Interrupt Link [LAZA] enabled at IRQ 22
[    6.495691] hda_intel: Disabling MSI
[    6.853742] AVX version of gcm_enc/dec engaged.
[    6.857000] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    6.908643] wmi: Mapper loaded
[    6.976010] ACPI: PCI Interrupt Link [LMC9] enabled at IRQ 21
[    6.976250] [drm] hdmi device  not found 0 13 1
[    6.976287] nouveau  [  DEVICE][0000:00:0d.0] BOOT0  : 0x04c000a2
[    6.976292] nouveau  [  DEVICE][0000:00:0d.0] Chipset: C61 (NV4C)
[    6.976295] nouveau  [  DEVICE][0000:00:0d.0] Family : NV40
[    6.976344] nouveau  [   VBIOS][0000:00:0d.0] checking PRAMIN for image...
[    7.017946] nouveau  [   VBIOS][0000:00:0d.0] ... appears to be valid
[    7.017951] nouveau  [   VBIOS][0000:00:0d.0] using image from PRAMIN
[    7.018269] nouveau  [   VBIOS][0000:00:0d.0] BIT signature found
[    7.018274] nouveau  [   VBIOS][0000:00:0d.0] version 05.61.32.28.01
[    7.018545] nouveau 0000:00:0d.0: irq 43 for MSI/MSI-X
[    7.018551] nouveau  [     PMC][0000:00:0d.0] MSI interrupts enabled
[    7.018566] nouveau  [     PFB][0000:00:0d.0] RAM type: unknown
[    7.018568] nouveau  [     PFB][0000:00:0d.0] RAM size: 32 MiB
[    7.018569] nouveau  [     PFB][0000:00:0d.0]    ZCOMP: 0 tags
[    7.019242] alg: No test for crc32 (crc32-pclmul)
[    7.045985] nouveau  [  PTHERM][0000:00:0d.0] FAN control: none / external
[    7.045991] nouveau  [  PTHERM][0000:00:0d.0] fan management: automatic
[    7.045993] nouveau  [  PTHERM][0000:00:0d.0] internal sensor: no
[    7.065833] nouveau  [     CLK][0000:00:0d.0] 20: core 425 MHz shader 425
MHz
[    7.065842] nouveau  [     CLK][0000:00:0d.0] --:
[    7.065989] [TTM] Zone  kernel: Available graphics memory: 4073292 kiB
[    7.065990] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    7.065991] [TTM] Initializing pool allocator
[    7.065995] [TTM] Initializing DMA pool allocator
[    7.066004] nouveau  [     DRM] VRAM: 29 MiB
[    7.066005] nouveau  [     DRM] GART: 512 MiB
[    7.066008] nouveau  [     DRM] TMDS table version 1.1
[    7.066009] nouveau  [     DRM] DCB version 3.0
[    7.066011] nouveau  [     DRM] DCB outp 00: 01000310 00000023
[    7.066012] nouveau  [     DRM] DCB outp 01: 00110204 942b0003
[    7.066014] nouveau  [     DRM] DCB conn 00: 0000
[    7.066015] nouveau  [     DRM] DCB conn 01: 1131
[    7.066017] nouveau  [     DRM] DCB conn 02: 0110
[    7.066018] nouveau  [     DRM] DCB conn 03: 0111
[    7.066019] nouveau  [     DRM] DCB conn 04: 0113
[    7.066135] nouveau  [     DRM] Saving VGA fonts
[    7.105721] nouveau W[     DRM] DCB type 4 not known
[    7.105724] nouveau W[     DRM] Unknown-1 has no encoders, removing
[    7.106846] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.106848] [drm] Driver supports precise vblank timestamp query.
[    7.108855] nouveau  [     DRM] MM: using M2MF for buffer copies
[    7.138360] nouveau  [     DRM] allocated 1440x900 fb: 0x9000, bo
ffff8802257fbc00
[    7.138426] fbcon: nouveaufb (fb0) is primary device
[    7.153197] kvm: Nested Virtualization enabled
[    7.153200] kvm: Nested Paging enabled
[    7.193869] Adding 3906556k swap on /dev/sda3.  Priority:-1 extents:1
across:3906556k
[    7.194365] EXT4-fs (sda2): re-mounted. Opts: errors=remount-ro
[    7.216782] Console: switching to colour frame buffer device 180x56
[    7.217978] nouveau 0000:00:0d.0: fb0: nouveaufb frame buffer device
[    7.217979] nouveau 0000:00:0d.0: registered panic notifier
[    7.217984] [drm] Initialized nouveau 1.1.1 20120801 for 0000:00:0d.0 on
minor 0
[    7.818972] input: HDA NVidia Line Out as
/devices/pci0000:00/0000:00:05.0/sound/card0/input10
[    7.819238] input: HDA NVidia Line as
/devices/pci0000:00/0000:00:05.0/sound/card0/input9
[    7.819407] input: HDA NVidia Rear Mic as
/devices/pci0000:00/0000:00:05.0/sound/card0/input8
[    7.890730] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts:
(null)
[    8.118655] EXT4-fs (sda9): mounted filesystem with ordered data mode. Opts:
(null)
[    8.287875] EXT4-fs (sda5): mounted filesystem with ordered data mode. Opts:
(null)
[    8.366032] EXT4-fs (sda7): mounted filesystem with ordered data mode. Opts:
(null)
[    8.393838] EXT4-fs (sda8): mounted filesystem with ordered data mode. Opts:
(null)
[    8.673671] EXT4-fs (sda6): mounted filesystem with ordered data mode. Opts:
(null)
[    8.682786] systemd-journald[178]: Received request to flush runtime journal
from PID 1
[    8.784873] forcedeth 0000:00:07.0: irq 44 for MSI/MSI-X
[    8.784915] forcedeth 0000:00:07.0 eth0: MSI enabled
[    8.785137] forcedeth 0000:00:07.0 eth0: no link during initialization
[    8.785631] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    9.213656] floppy0: no floppy controllers found
[    9.754037] RPC: Registered named UNIX socket transport module.
[    9.754040] RPC: Registered udp transport module.
[    9.754041] RPC: Registered tcp transport module.
[    9.754042] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.776340] FS-Cache: Loaded
[    9.791475] FS-Cache: Netfs 'nfs' registered for caching
[    9.821742] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
-----------------------------------------------

--
You are receiving this mail because:
You are the assignee for the bug.
