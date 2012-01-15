From: devendra <dev@savarinetworks.com>
Subject: rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
Date: Sun, 15 Jan 2012 23:00:48 +0530
Message-ID: <1326648648.7310.1.camel@devendra-Linux>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ExM9NFgKYmq6NVmUdTC1"
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ExM9NFgKYmq6NVmUdTC1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi folks,

i am getting a lot of prints about *rtl8192c_common: Loading firmware
file rtlwifi/rtl8192cfw.bin*.

is this any kind of problem?

full dmesg attached.

--=-ExM9NFgKYmq6NVmUdTC1
Content-Disposition: attachment; filename="dmesg"
Content-Type: text/plain; name="dmesg"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0+ (root@devendra-Linux) (gcc version 4.5.2 (Ubuntu/Linaro 4.5.2-8ubuntu4) ) #27 SMP Sun Jan 15 21:13:27 IST 2012
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-3.2.0+ root=UUID=6a2b435b-2fbb-420d-ad75-ca1217ab4413 ro quiet splash vt.handoff=7
[    0.000000] Disabled fast string operations
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d800 (usable)
[    0.000000]  BIOS-e820: 000000000009d800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000da99f000 (usable)
[    0.000000]  BIOS-e820: 00000000da99f000 - 00000000dae9f000 (reserved)
[    0.000000]  BIOS-e820: 00000000dae9f000 - 00000000daf9f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000daf9f000 - 00000000dafff000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000dafff000 - 00000000db000000 (usable)
[    0.000000]  BIOS-e820: 00000000db000000 - 00000000dfa00000 (reserved)
[    0.000000]  BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed08000 - 00000000fed09000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed10000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffd20000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000011e600000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.6 present.
[    0.000000] DMI: LENOVO 4177CTO/4177CTO, BIOS 83ET61WW (1.31 ) 07/07/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x11e600 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FE0000000 write-back
[    0.000000]   3 base 0DC000000 mask FFC000000 uncachable
[    0.000000]   4 base 0DB000000 mask FFF000000 uncachable
[    0.000000]   5 base 100000000 mask FE0000000 write-back
[    0.000000]   6 base 11F000000 mask FFF000000 uncachable
[    0.000000]   7 base 11E800000 mask FFF800000 uncachable
[    0.000000]   8 base 11E600000 mask FFFE00000 uncachable
[    0.000000]   9 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] last_pfn = 0xdb000 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 20480
[    0.000000] init_memory_mapping: 0000000000000000-00000000db000000
[    0.000000]  0000000000 - 00db000000 page 2M
[    0.000000] kernel direct mapping tables up to db000000 @ 1fffb000-20000000
[    0.000000] init_memory_mapping: 0000000100000000-000000011e600000
[    0.000000]  0100000000 - 011e600000 page 2M
[    0.000000] kernel direct mapping tables up to 11e600000 @ da999000-da99f000
[    0.000000] RAMDISK: 37a6a000 - 37d2d000
[    0.000000] ACPI: RSDP 00000000000f00e0 00024 (v02 LENOVO)
[    0.000000] ACPI: XSDT 00000000daffe120 000A4 (v01 LENOVO TP-83    00001310 PTEC 00000002)
[    0.000000] ACPI: FACP 00000000dafe9000 000F4 (v04 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: DSDT 00000000dafec000 0DFA4 (v01 LENOVO TP-83    00001310 INTL 20061109)
[    0.000000] ACPI: FACS 00000000daf2d000 00040
[    0.000000] ACPI: SLIC 00000000daffd000 00176 (v01 LENOVO TP-83    00001310 PTEC 00000001)
[    0.000000] ACPI: SSDT 00000000daffc000 00249 (v01 LENOVO TP-SSDT2 00000200 INTL 20061109)
[    0.000000] ACPI: SSDT 00000000daffb000 00033 (v01 LENOVO TP-SSDT1 00000100 INTL 20061109)
[    0.000000] ACPI: SSDT 00000000daffa000 00797 (v01 LENOVO SataAhci 00001000 INTL 20061109)
[    0.000000] ACPI: HPET 00000000dafe8000 00038 (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: APIC 00000000dafe7000 00098 (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: MCFG 00000000dafe6000 0003C (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: ECDT 00000000dafe5000 00052 (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: ASF! 00000000dafeb000 000A5 (v32 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: TCPA 00000000dafe4000 00032 (v02    PTL   LENOVO 06040000 LNVO 00000001)
[    0.000000] ACPI: SSDT 00000000dafe3000 009E5 (v01  PmRef  Cpu0Ist 00003000 INTL 20061109)
[    0.000000] ACPI: SSDT 00000000dafe2000 00996 (v01  PmRef    CpuPm 00003000 INTL 20061109)
[    0.000000] ACPI: UEFI 00000000dafe1000 0003E (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: UEFI 00000000dafe0000 00042 (v01 PTL      COMBUF 00000001 PTL  00000001)
[    0.000000] ACPI: UEFI 00000000dafdf000 0027E (v01 LENOVO TP-83    00001310 PTL  00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000011e600000
[    0.000000] Initmem setup node 0 0000000000000000-000000011e600000
[    0.000000]   NODE_DATA [000000011e5fb000 - 000000011e5fffff]
[    0.000000]  [ffffea0000000000-ffffea00047fffff] PMD -> [ffff880119c00000-ffff88011dbfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x0011e600
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009d
[    0.000000]     0: 0x00000100 -> 0x000da99f
[    0.000000]     0: 0x000dafff -> 0x000db000
[    0.000000]     0: 0x00100000 -> 0x0011e600
[    0.000000] On node 0 totalpages: 1019693
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 5 pages reserved
[    0.000000]   DMA zone: 3912 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 874976 pages, LIFO batch:31
[    0.000000]   Normal zone: 1944 pages used for memmap
[    0.000000]   Normal zone: 122472 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009d000 - 000000000009e000
[    0.000000] PM: Registered nosave memory: 000000000009e000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000da99f000 - 00000000dae9f000
[    0.000000] PM: Registered nosave memory: 00000000dae9f000 - 00000000daf9f000
[    0.000000] PM: Registered nosave memory: 00000000daf9f000 - 00000000dafff000
[    0.000000] PM: Registered nosave memory: 00000000db000000 - 00000000dfa00000
[    0.000000] PM: Registered nosave memory: 00000000dfa00000 - 00000000f8000000
[    0.000000] PM: Registered nosave memory: 00000000f8000000 - 00000000fc000000
[    0.000000] PM: Registered nosave memory: 00000000fc000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed08000
[    0.000000] PM: Registered nosave memory: 00000000fed08000 - 00000000fed09000
[    0.000000] PM: Registered nosave memory: 00000000fed09000 - 00000000fed10000
[    0.000000] PM: Registered nosave memory: 00000000fed10000 - 00000000fed1a000
[    0.000000] PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ffd20000
[    0.000000] PM: Registered nosave memory: 00000000ffd20000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at dfa00000 (gap: dfa00000:18600000)
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:8 nr_node_ids:1
[    0.000000] PERCPU: Embedded 26 pages/cpu @ffff88011e200000 s76864 r8192 d21440 u262144
[    0.000000] pcpu-alloc: s76864 r8192 d21440 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1001360
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.2.0+ root=UUID=6a2b435b-2fbb-420d-ad75-ca1217ab4413 ro quiet splash vt.handoff=7
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave/xrstor: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 3928844k/4691968k available (7543k kernel code, 613196k absent, 149928k reserved, 5400k data, 576k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:4352 nr_irqs:744 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.001000] Detected 2292.662 MHz processor.
[    0.000002] Calibrating delay loop (skipped), value calculated using timer frequency.. 4585.32 BogoMIPS (lpj=2292662)
[    0.000006] pid_max: default: 32768 minimum: 301
[    0.000022] Security Framework initialized
[    0.000025] SELinux:  Initializing.
[    0.000031] SELinux:  Starting in permissive mode
[    0.000363] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.001424] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.001857] Mount-cache hash table entries: 256
[    0.001983] Initializing cgroup subsys cpuacct
[    0.001985] Initializing cgroup subsys freezer
[    0.002007] Disabled fast string operations
[    0.002009] CPU: Physical Processor ID: 0
[    0.002010] CPU: Processor Core ID: 0
[    0.002015] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.002016] ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.002018] mce: CPU supports 7 MCE banks
[    0.002029] CPU0: Thermal monitoring enabled (TM1)
[    0.002035] using mwait in idle threads.
[    0.002088] ACPI: Core revision 20110623
[    0.010862] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.020850] CPU0: Intel(R) Core(TM) i5-2410M CPU @ 2.30GHz stepping 07
[    0.121774] Performance Events: PEBS fmt1+, SandyBridge events, Intel PMU driver.
[    0.121779] PEBS disabled due to CPU errata.
[    0.121781] ... version:                3
[    0.121782] ... bit width:              48
[    0.121783] ... generic registers:      4
[    0.121785] ... value mask:             0000ffffffffffff
[    0.121786] ... max period:             000000007fffffff
[    0.121787] ... fixed-purpose events:   3
[    0.121788] ... event mask:             000000070000000f
[    0.121948] Booting Node   0, Processors  #1
[    0.121950] smpboot cpu 1: start_ip = 98000
[    0.132957] Disabled fast string operations
[    0.153084]  #2
[    0.153085] smpboot cpu 2: start_ip = 98000
[    0.164191] Disabled fast string operations
[    0.184318]  #3
[    0.184319] smpboot cpu 3: start_ip = 98000
[    0.195424] Disabled fast string operations
[    0.215497] Brought up 4 CPUs
[    0.215499] Total of 4 processors activated (18341.29 BogoMIPS).
[    0.218427] PM: Registering ACPI NVS region at dae9f000 (1048576 bytes)
[    0.218518] RTC time: 22:05:51, date: 01/15/12
[    0.218543] NET: Registered protocol family 16
[    0.218617] kworker/u:0 used greatest stack depth: 5600 bytes left
[    0.218858] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.218861] ACPI: bus type pci registered
[    0.219110] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.219113] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.228927] PCI: Using configuration type 1 for base access
[    0.235016] bio: create slab <bio-0> at 0
[    0.235099] ACPI: Added _OSI(Module Device)
[    0.235101] ACPI: Added _OSI(Processor Device)
[    0.235102] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.235104] ACPI: Added _OSI(Processor Aggregator Device)
[    0.237235] ACPI: EC: EC description table is found, configuring boot EC
[    0.242559] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.255234] ACPI: SSDT 00000000dae8c018 008C0 (v01  PmRef  Cpu0Cst 00003001 INTL 20061109)
[    0.255760] ACPI: Dynamic OEM Table Load:
[    0.255762] ACPI: SSDT           (null) 008C0 (v01  PmRef  Cpu0Cst 00003001 INTL 20061109)
[    0.259906] ACPI: SSDT 00000000dae8da98 00303 (v01  PmRef    ApIst 00003000 INTL 20061109)
[    0.260472] ACPI: Dynamic OEM Table Load:
[    0.260474] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst 00003000 INTL 20061109)
[    0.262737] ACPI: SSDT 00000000dae8bd98 00119 (v01  PmRef    ApCst 00003000 INTL 20061109)
[    0.263257] ACPI: Dynamic OEM Table Load:
[    0.263259] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20061109)
[    0.266282] ACPI: Interpreter enabled
[    0.266285] ACPI: (supports S0 S3 S4 S5)
[    0.266305] ACPI: Using IOAPIC for interrupt routing
[    0.273102] ACPI: Power Resource [PUBS] (on)
[    0.277114] ACPI: EC: GPE = 0x11, I/O: command/status = 0x66, data = 0x62
[    0.278192] ACPI: ACPI Dock Station Driver: 2 docks/bays found
[    0.278196] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.278326] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
[    0.278354] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.278356] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.278358] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.278361] pci_root PNP0A08:00: host bridge window [mem 0xdfa00000-0xfebfffff]
[    0.278363] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed4bfff]
[    0.278400] PCI host bridge to bus 0000:00
[    0.278403] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.278405] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.278407] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.278409] pci_bus 0000:00: root bus resource [mem 0xdfa00000-0xfebfffff]
[    0.278411] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed4bfff]
[    0.278419] pci 0000:00:00.0: [8086:0104] type 0 class 0x000600
[    0.278457] pci 0000:00:02.0: [8086:0116] type 0 class 0x000300
[    0.278467] pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf03fffff 64bit]
[    0.278473] pci 0000:00:02.0: reg 18: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.278478] pci 0000:00:02.0: reg 20: [io  0x6000-0x603f]
[    0.278538] pci 0000:00:16.0: [8086:1c3a] type 0 class 0x000780
[    0.278562] pci 0000:00:16.0: reg 10: [mem 0xf2625000-0xf262500f 64bit]
[    0.278640] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.278674] pci 0000:00:19.0: [8086:1502] type 0 class 0x000200
[    0.278692] pci 0000:00:19.0: reg 10: [mem 0xf2600000-0xf261ffff]
[    0.278701] pci 0000:00:19.0: reg 14: [mem 0xf262b000-0xf262bfff]
[    0.278710] pci 0000:00:19.0: reg 18: [io  0x6080-0x609f]
[    0.278774] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    0.278800] pci 0000:00:1a.0: [8086:1c2d] type 0 class 0x000c03
[    0.278821] pci 0000:00:1a.0: reg 10: [mem 0xf262a000-0xf262a3ff]
[    0.278918] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.278946] pci 0000:00:1b.0: [8086:1c20] type 0 class 0x000403
[    0.278962] pci 0000:00:1b.0: reg 10: [mem 0xf2620000-0xf2623fff 64bit]
[    0.279031] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.279056] pci 0000:00:1c.0: [8086:1c10] type 1 class 0x000604
[    0.279135] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.279164] pci 0000:00:1c.1: [8086:1c12] type 1 class 0x000604
[    0.279243] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.279271] pci 0000:00:1c.3: [8086:1c16] type 1 class 0x000604
[    0.279351] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.279381] pci 0000:00:1c.4: [8086:1c18] type 1 class 0x000604
[    0.279511] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.279558] pci 0000:00:1d.0: [8086:1c26] type 0 class 0x000c03
[    0.279579] pci 0000:00:1d.0: reg 10: [mem 0xf2629000-0xf26293ff]
[    0.279669] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.279697] pci 0000:00:1f.0: [8086:1c4f] type 0 class 0x000601
[    0.279824] pci 0000:00:1f.2: [8086:1c03] type 0 class 0x000106
[    0.279843] pci 0000:00:1f.2: reg 10: [io  0x60a8-0x60af]
[    0.279851] pci 0000:00:1f.2: reg 14: [io  0x60bc-0x60bf]
[    0.279859] pci 0000:00:1f.2: reg 18: [io  0x60a0-0x60a7]
[    0.279868] pci 0000:00:1f.2: reg 1c: [io  0x60b8-0x60bb]
[    0.279876] pci 0000:00:1f.2: reg 20: [io  0x6060-0x607f]
[    0.279885] pci 0000:00:1f.2: reg 24: [mem 0xf2628000-0xf26287ff]
[    0.279931] pci 0000:00:1f.2: PME# supported from D3hot
[    0.279950] pci 0000:00:1f.3: [8086:1c22] type 0 class 0x000c05
[    0.279967] pci 0000:00:1f.3: reg 10: [mem 0xf2624000-0xf26240ff 64bit]
[    0.279988] pci 0000:00:1f.3: reg 20: [io  0xefa0-0xefbf]
[    0.280064] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.280146] pci 0000:03:00.0: [10ec:8176] type 0 class 0x000280
[    0.280173] pci 0000:03:00.0: reg 10: [io  0x5000-0x50ff]
[    0.280220] pci 0000:03:00.0: reg 18: [mem 0xf2500000-0xf2503fff 64bit]
[    0.280363] pci 0000:03:00.0: supports D1 D2
[    0.280365] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.281553] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.281563] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[    0.281573] pci 0000:00:1c.1:   bridge window [mem 0xf2500000-0xf25fffff]
[    0.281671] pci 0000:00:1c.3: PCI bridge to [bus 05-0c]
[    0.281675] pci 0000:00:1c.3:   bridge window [io  0x4000-0x4fff]
[    0.281679] pci 0000:00:1c.3:   bridge window [mem 0xf1d00000-0xf24fffff]
[    0.281686] pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.281825] pci 0000:0d:00.0: [1180:e823] type 0 class 0x000880
[    0.281851] pci 0000:0d:00.0: reg 10: [mem 0xf1401000-0xf14010ff]
[    0.282048] pci 0000:0d:00.0: supports D1 D2
[    0.282050] pci 0000:0d:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.282121] pci 0000:0d:00.3: [1180:e832] type 0 class 0x000c00
[    0.282147] pci 0000:0d:00.3: reg 10: [mem 0xf1400000-0xf14007ff]
[    0.282341] pci 0000:0d:00.3: supports D1 D2
[    0.282343] pci 0000:0d:00.3: PME# supported from D0 D1 D2 D3hot D3cold
[    0.283595] pci 0000:00:1c.4: PCI bridge to [bus 0d-0d]
[    0.283605] pci 0000:00:1c.4:   bridge window [io  0x3000-0x3fff]
[    0.283614] pci 0000:00:1c.4:   bridge window [mem 0xf1400000-0xf1cfffff]
[    0.283629] pci 0000:00:1c.4:   bridge window [mem 0xf0c00000-0xf13fffff 64bit pref]
[    0.283671] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.283750] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
[    0.283774] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
[    0.283797] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP4._PRT]
[    0.283826] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP5._PRT]
[    0.283971]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.284159]  pci0000:00: ACPI _OSC request failed (AE_SUPPORT), returned control mask: 0x0d
[    0.284161] ACPI _OSC control for PCIe not granted, disabling ASPM
[    0.286771] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
[    0.286840] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *7 9 10 11)
[    0.286903] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
[    0.286962] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
[    0.287021] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 *10 11)
[    0.287070] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11) *0, disabled.
[    0.287129] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *7 9 10 11)
[    0.287187] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11)
[    0.287303] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.287308] vgaarb: loaded
[    0.287309] vgaarb: bridge control possible 0000:00:02.0
[    0.287412] SCSI subsystem initialized
[    0.287488] libata version 3.00 loaded.
[    0.287622] usbcore: registered new interface driver usbfs
[    0.287650] usbcore: registered new interface driver hub
[    0.287681] usbcore: registered new device driver usb
[    0.287845] Advanced Linux Sound Architecture Driver Version 1.0.24.
[    0.287847] PCI: Using ACPI for IRQ routing
[    0.289444] PCI: pci_cache_line_size set to 64 bytes
[    0.289602] reserve RAM buffer: 000000000009d800 - 000000000009ffff 
[    0.289604] reserve RAM buffer: 00000000da99f000 - 00000000dbffffff 
[    0.289606] reserve RAM buffer: 00000000db000000 - 00000000dbffffff 
[    0.289608] reserve RAM buffer: 000000011e600000 - 000000011fffffff 
[    0.289810] cfg80211: Calling CRDA to update world regulatory domain
[    0.289935] NetLabel: Initializing
[    0.289937] NetLabel:  domain hash size = 128
[    0.289938] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.289949] NetLabel:  unlabeled traffic allowed by default
[    0.290002] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.290007] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.292022] Switching to clocksource hpet
[    0.294508] pnp: PnP ACPI init
[    0.294518] ACPI: bus type pnp registered
[    0.294912] pnp 00:00: [mem 0x00000000-0x0009ffff]
[    0.294914] pnp 00:00: [mem 0x000c0000-0x000c3fff]
[    0.294916] pnp 00:00: [mem 0x000c4000-0x000c7fff]
[    0.294917] pnp 00:00: [mem 0x000c8000-0x000cbfff]
[    0.294919] pnp 00:00: [mem 0x000cc000-0x000cffff]
[    0.294920] pnp 00:00: [mem 0x000d0000-0x000d3fff]
[    0.294922] pnp 00:00: [mem 0x000d4000-0x000d7fff]
[    0.294923] pnp 00:00: [mem 0x000d8000-0x000dbfff]
[    0.294925] pnp 00:00: [mem 0x000dc000-0x000dffff]
[    0.294926] pnp 00:00: [mem 0x000e0000-0x000e3fff]
[    0.294928] pnp 00:00: [mem 0x000e4000-0x000e7fff]
[    0.294929] pnp 00:00: [mem 0x000e8000-0x000ebfff]
[    0.294931] pnp 00:00: [mem 0x000ec000-0x000effff]
[    0.294932] pnp 00:00: [mem 0x000f0000-0x000fffff]
[    0.294934] pnp 00:00: [mem 0x00100000-0xdf9fffff]
[    0.294935] pnp 00:00: [mem 0xfec00000-0xfed3ffff]
[    0.294937] pnp 00:00: [mem 0xfed4c000-0xffffffff]
[    0.295009] system 00:00: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.295011] system 00:00: [mem 0x000c0000-0x000c3fff] could not be reserved
[    0.295013] system 00:00: [mem 0x000c4000-0x000c7fff] could not be reserved
[    0.295015] system 00:00: [mem 0x000c8000-0x000cbfff] has been reserved
[    0.295017] system 00:00: [mem 0x000cc000-0x000cffff] has been reserved
[    0.295019] system 00:00: [mem 0x000d0000-0x000d3fff] has been reserved
[    0.295021] system 00:00: [mem 0x000d4000-0x000d7fff] has been reserved
[    0.295023] system 00:00: [mem 0x000d8000-0x000dbfff] has been reserved
[    0.295025] system 00:00: [mem 0x000dc000-0x000dffff] has been reserved
[    0.295027] system 00:00: [mem 0x000e0000-0x000e3fff] could not be reserved
[    0.295029] system 00:00: [mem 0x000e4000-0x000e7fff] could not be reserved
[    0.295031] system 00:00: [mem 0x000e8000-0x000ebfff] could not be reserved
[    0.295033] system 00:00: [mem 0x000ec000-0x000effff] could not be reserved
[    0.295035] system 00:00: [mem 0x000f0000-0x000fffff] could not be reserved
[    0.295037] system 00:00: [mem 0x00100000-0xdf9fffff] could not be reserved
[    0.295050] system 00:00: [mem 0xfec00000-0xfed3ffff] could not be reserved
[    0.295053] system 00:00: [mem 0xfed4c000-0xffffffff] could not be reserved
[    0.295056] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.295077] pnp 00:01: [bus 00-fe]
[    0.295079] pnp 00:01: [io  0x0cf8-0x0cff]
[    0.295081] pnp 00:01: [io  0x0000-0x0cf7 window]
[    0.295082] pnp 00:01: [io  0x0d00-0xffff window]
[    0.295084] pnp 00:01: [mem 0x000a0000-0x000bffff window]
[    0.295086] pnp 00:01: [mem 0x000c0000-0x000c3fff window]
[    0.295088] pnp 00:01: [mem 0x000c4000-0x000c7fff window]
[    0.295089] pnp 00:01: [mem 0x000c8000-0x000cbfff window]
[    0.295091] pnp 00:01: [mem 0x000cc000-0x000cffff window]
[    0.295093] pnp 00:01: [mem 0x000d0000-0x000d3fff window]
[    0.295094] pnp 00:01: [mem 0x000d4000-0x000d7fff window]
[    0.295098] pnp 00:01: [mem 0x000d8000-0x000dbfff window]
[    0.295100] pnp 00:01: [mem 0x000dc000-0x000dffff window]
[    0.295101] pnp 00:01: [mem 0x000e0000-0x000e3fff window]
[    0.295103] pnp 00:01: [mem 0x000e4000-0x000e7fff window]
[    0.295105] pnp 00:01: [mem 0x000e8000-0x000ebfff window]
[    0.295106] pnp 00:01: [mem 0x000ec000-0x000effff window]
[    0.295108] pnp 00:01: [mem 0xdfa00000-0xfebfffff window]
[    0.295110] pnp 00:01: [mem 0xfed40000-0xfed4bfff window]
[    0.295187] pnp 00:01: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.295254] pnp 00:02: [io  0x0010-0x001f]
[    0.295256] pnp 00:02: [io  0x0090-0x009f]
[    0.295257] pnp 00:02: [io  0x0024-0x0025]
[    0.295259] pnp 00:02: [io  0x0028-0x0029]
[    0.295260] pnp 00:02: [io  0x002c-0x002d]
[    0.295261] pnp 00:02: [io  0x0030-0x0031]
[    0.295263] pnp 00:02: [io  0x0034-0x0035]
[    0.295264] pnp 00:02: [io  0x0038-0x0039]
[    0.295265] pnp 00:02: [io  0x003c-0x003d]
[    0.295267] pnp 00:02: [io  0x00a4-0x00a5]
[    0.295268] pnp 00:02: [io  0x00a8-0x00a9]
[    0.295269] pnp 00:02: [io  0x00ac-0x00ad]
[    0.295271] pnp 00:02: [io  0x00b0-0x00b5]
[    0.295272] pnp 00:02: [io  0x00b8-0x00b9]
[    0.295273] pnp 00:02: [io  0x00bc-0x00bd]
[    0.295275] pnp 00:02: [io  0x0050-0x0053]
[    0.295276] pnp 00:02: [io  0x0072-0x0077]
[    0.295277] pnp 00:02: [io  0x0400-0x047f]
[    0.295279] pnp 00:02: [io  0x0500-0x057f]
[    0.295280] pnp 00:02: [io  0x0800-0x080f]
[    0.295282] pnp 00:02: [io  0x15e0-0x15ef]
[    0.295283] pnp 00:02: [io  0x1600-0x167f]
[    0.295284] pnp 00:02: [mem 0xf8000000-0xfbffffff]
[    0.295286] pnp 00:02: [mem 0x00000000-0x00000fff]
[    0.295288] pnp 00:02: [mem 0xfed1c000-0xfed1ffff]
[    0.295289] pnp 00:02: [mem 0xfed10000-0xfed13fff]
[    0.295291] pnp 00:02: [mem 0xfed18000-0xfed18fff]
[    0.295292] pnp 00:02: [mem 0xfed19000-0xfed19fff]
[    0.295293] pnp 00:02: [mem 0xfed45000-0xfed4bfff]
[    0.295372] system 00:02: [io  0x0400-0x047f] has been reserved
[    0.295374] system 00:02: [io  0x0500-0x057f] has been reserved
[    0.295376] system 00:02: [io  0x0800-0x080f] has been reserved
[    0.295378] system 00:02: [io  0x15e0-0x15ef] has been reserved
[    0.295380] system 00:02: [io  0x1600-0x167f] has been reserved
[    0.295382] system 00:02: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.295384] system 00:02: [mem 0x00000000-0x00000fff] could not be reserved
[    0.295387] system 00:02: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.295389] system 00:02: [mem 0xfed10000-0xfed13fff] has been reserved
[    0.295391] system 00:02: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.295393] system 00:02: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.295397] system 00:02: [mem 0xfed45000-0xfed4bfff] has been reserved
[    0.295399] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.295446] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    0.295498] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.295508] pnp 00:04: [io  0x0000-0x000f]
[    0.295510] pnp 00:04: [io  0x0080-0x008f]
[    0.295511] pnp 00:04: [io  0x00c0-0x00df]
[    0.295515] pnp 00:04: [dma 4]
[    0.295565] pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.295573] pnp 00:05: [io  0x0061]
[    0.295621] pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.295630] pnp 00:06: [io  0x00f0]
[    0.295639] pnp 00:06: [irq 13]
[    0.295690] pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.295699] pnp 00:07: [io  0x0070-0x0071]
[    0.295704] pnp 00:07: [irq 8]
[    0.295755] pnp 00:07: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.295764] pnp 00:08: [io  0x0060]
[    0.295765] pnp 00:08: [io  0x0064]
[    0.295770] pnp 00:08: [irq 1]
[    0.295818] pnp 00:08: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.295830] pnp 00:09: [irq 12]
[    0.295880] pnp 00:09: Plug and Play ACPI device, IDs LEN0015 PNP0f13 (active)
[    0.295917] pnp 00:0a: [mem 0xfed40000-0xfed44fff]
[    0.295973] pnp 00:0a: Plug and Play ACPI device, IDs SMO1200 PNP0c31 (active)
[    0.296402] pnp: PnP ACPI: found 11 devices
[    0.296403] ACPI: ACPI bus type pnp unregistered
[    0.303848] PCI: max bus depth: 1 pci_try_num: 2
[    0.303889] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.303901] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.303905] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[    0.303910] pci 0000:00:1c.1:   bridge window [mem 0xf2500000-0xf25fffff]
[    0.303919] pci 0000:00:1c.3: PCI bridge to [bus 05-0c]
[    0.303922] pci 0000:00:1c.3:   bridge window [io  0x4000-0x4fff]
[    0.303927] pci 0000:00:1c.3:   bridge window [mem 0xf1d00000-0xf24fffff]
[    0.303932] pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.303939] pci 0000:00:1c.4: PCI bridge to [bus 0d-0d]
[    0.303943] pci 0000:00:1c.4:   bridge window [io  0x3000-0x3fff]
[    0.303949] pci 0000:00:1c.4:   bridge window [mem 0xf1400000-0xf1cfffff]
[    0.303955] pci 0000:00:1c.4:   bridge window [mem 0xf0c00000-0xf13fffff 64bit pref]
[    0.303999] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.304001] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.304003] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.304004] pci_bus 0000:00: resource 7 [mem 0xdfa00000-0xfebfffff]
[    0.304006] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfed4bfff]
[    0.304008] pci_bus 0000:03: resource 0 [io  0x5000-0x5fff]
[    0.304010] pci_bus 0000:03: resource 1 [mem 0xf2500000-0xf25fffff]
[    0.304012] pci_bus 0000:05: resource 0 [io  0x4000-0x4fff]
[    0.304013] pci_bus 0000:05: resource 1 [mem 0xf1d00000-0xf24fffff]
[    0.304015] pci_bus 0000:05: resource 2 [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.304017] pci_bus 0000:0d: resource 0 [io  0x3000-0x3fff]
[    0.304018] pci_bus 0000:0d: resource 1 [mem 0xf1400000-0xf1cfffff]
[    0.304020] pci_bus 0000:0d: resource 2 [mem 0xf0c00000-0xf13fffff 64bit pref]
[    0.304054] NET: Registered protocol family 2
[    0.304181] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.305475] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.307306] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.307526] TCP: Hash tables configured (established 524288 bind 65536)
[    0.307528] TCP reno registered
[    0.307537] UDP hash table entries: 2048 (order: 4, 65536 bytes)
[    0.307560] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
[    0.307638] NET: Registered protocol family 1
[    0.307723] RPC: Registered named UNIX socket transport module.
[    0.307725] RPC: Registered udp transport module.
[    0.307726] RPC: Registered tcp transport module.
[    0.307727] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.307736] pci 0000:00:02.0: Boot video device
[    0.307859] PCI: CLS 64 bytes, default 64
[    0.307908] Trying to unpack rootfs image as initramfs...
[    0.356786] Freeing initrd memory: 2828k freed
[    0.357352] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.357357] Placing 64MB software IO TLB between ffff8800d6999000 - ffff8800da999000
[    0.357359] software IO TLB at phys 0xd6999000 - 0xda999000
[    0.358165] microcode: CPU0 sig=0x206a7, pf=0x10, revision=0x18
[    0.358172] microcode: CPU1 sig=0x206a7, pf=0x10, revision=0x18
[    0.358180] microcode: CPU2 sig=0x206a7, pf=0x10, revision=0x18
[    0.358188] microcode: CPU3 sig=0x206a7, pf=0x10, revision=0x18
[    0.358225] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.358457] audit: initializing netlink socket (disabled)
[    0.358469] type=2000 audit(1326665151.197:1): initialized
[    0.374741] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.377689] VFS: Disk quotas dquot_6.5.2
[    0.377757] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.378638] fuse init (API version 7.18)
[    0.378768] msgmni has been set to 7679
[    0.378852] SELinux:  Registering netfilter hooks
[    0.379172] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.379174] io scheduler noop registered
[    0.379175] io scheduler deadline registered
[    0.379224] io scheduler cfq registered (default)
[    0.379548] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.380262] ACPI: AC Adapter [AC] (on-line)
[    0.380431] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
[    0.380798] ACPI: Lid Switch [LID]
[    0.380889] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input1
[    0.380894] ACPI: Sleep Button [SLPB]
[    0.380971] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    0.380974] ACPI: Power Button [PWRF]
[    0.381794] ACPI: acpi_idle registered with cpuidle
[    0.386350] thermal LNXTHERM:00: registered as thermal_zone0
[    0.386352] ACPI: Thermal Zone [THM0] (60 C)
[    0.386495] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.401058] ACPI: Battery Slot [BAT0] (battery present)
[    0.424343] Non-volatile memory driver v1.3
[    0.424346] Linux agpgart interface v0.103
[    0.424459] agpgart-intel 0000:00:00.0: Intel Sandybridge Chipset
[    0.424562] agpgart-intel 0000:00:00.0: detected gtt size: 2097152K total, 262144K mappable
[    0.425623] agpgart-intel 0000:00:00.0: detected 65536K stolen memory
[    0.425741] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
[    0.425829] [drm] Initialized drm 1.1.0 20060810
[    0.425868] i915 0000:00:02.0: power state changed by ACPI to D0
[    0.425872] i915 0000:00:02.0: power state changed by ACPI to D0
[    0.425878] i915 0000:00:02.0: setting latency timer to 64
[    0.471840] mtrr: no more MTRRs available
[    0.471842] [drm] MTRR allocation failed.  Graphics performance may suffer.
[    0.472366] i915 0000:00:02.0: irq 40 for MSI/MSI-X
[    0.472373] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    0.472375] [drm] Driver supports precise vblank timestamp query.
[    0.472402] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    1.160119] fbcon: inteldrmfb (fb0) is primary device
[    1.358639] Refined TSC clocksource calibration: 2292.553 MHz.
[    1.358646] Switching to clocksource tsc
[    1.372200] Console: switching to colour frame buffer device 170x48
[    1.374582] fb0: inteldrmfb frame buffer device
[    1.374583] drm: registered panic notifier
[    1.380905] acpi device:01: registered as cooling_device4
[    1.381048] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input3
[    1.381054] ACPI: Video Device [VID] (multi-head: yes  rom: no  post: no)
[    1.381102] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    1.382408] brd: module loaded
[    1.383081] loop: module loaded
[    1.383250] ahci 0000:00:1f.2: version 3.0
[    1.383303] ahci 0000:00:1f.2: irq 41 for MSI/MSI-X
[    1.383335] ahci: SSS flag set, parallel bus scan disabled
[    1.393453] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x1b impl SATA mode
[    1.393462] ahci 0000:00:1f.2: flags: 64bit ncq sntf ilck stag pm led clo pio slum part ems sxs apst 
[    1.393473] ahci 0000:00:1f.2: setting latency timer to 64
[    1.400045] scsi0 : ahci
[    1.400131] scsi1 : ahci
[    1.400203] scsi2 : ahci
[    1.400275] scsi3 : ahci
[    1.400345] scsi4 : ahci
[    1.400419] scsi5 : ahci
[    1.400966] ata1: SATA max UDMA/133 abar m2048@0xf2628000 port 0xf2628100 irq 41
[    1.400970] ata2: SATA max UDMA/133 abar m2048@0xf2628000 port 0xf2628180 irq 41
[    1.400971] ata3: DUMMY
[    1.400974] ata4: SATA max UDMA/133 abar m2048@0xf2628000 port 0xf2628280 irq 41
[    1.400977] ata5: SATA max UDMA/133 abar m2048@0xf2628000 port 0xf2628300 irq 41
[    1.400979] ata6: DUMMY
[    1.401223] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.401225] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.401255] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    1.401256] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    1.401284] sky2: driver version 1.30
[    1.401477] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.401480] ehci_hcd: block sizes: qh 112 qtd 96 itd 192 sitd 96
[    1.401493] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D0
[    1.401498] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D0
[    1.401521] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[    1.401525] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[    1.401541] drivers/usb/core/inode.c: creating file 'devices'
[    1.401544] drivers/usb/core/inode.c: creating file '001'
[    1.401578] ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    1.401587] ehci_hcd 0000:00:1a.0: reset hcs_params 0x200003 dbg=2 cc=0 pcc=0 ordered !ppc ports=3
[    1.401591] ehci_hcd 0000:00:1a.0: reset hcc_params 36881 caching frame 1024 64 bit addr
[    1.401605] ehci_hcd 0000:00:1a.0: support lpm
[    1.401616] ehci_hcd 0000:00:1a.0: debug port 2
[    1.401620] ehci_hcd 0000:00:1a.0: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[    1.405500] ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
[    1.405502] ehci_hcd 0000:00:1a.0: supports USB remote wakeup
[    1.405516] ehci_hcd 0000:00:1a.0: irq 16, io mem 0xf262a000
[    1.405520] ehci_hcd 0000:00:1a.0: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[    1.411391] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    1.411440] usb usb1: default language 0x0409
[    1.411452] usb usb1: udev 1, busnum 1, minor = 0
[    1.411456] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.411461] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.411467] usb usb1: Product: EHCI Host Controller
[    1.411471] usb usb1: Manufacturer: Linux 3.2.0+ ehci_hcd
[    1.411475] usb usb1: SerialNumber: 0000:00:1a.0
[    1.411562] usb usb1: usb_probe_device
[    1.411565] usb usb1: configuration #1 chosen from 1 choice
[    1.411570] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[    1.411604] hub 1-0:1.0: usb_probe_interface
[    1.411606] hub 1-0:1.0: usb_probe_interface - got id
[    1.411607] hub 1-0:1.0: USB hub found
[    1.411610] hub 1-0:1.0: 3 ports detected
[    1.411612] hub 1-0:1.0: standalone hub
[    1.411613] hub 1-0:1.0: no power switching (usb 1.0)
[    1.411614] hub 1-0:1.0: individual port over-current protection
[    1.411616] hub 1-0:1.0: power on to power good time: 20ms
[    1.411619] hub 1-0:1.0: local power source is good
[    1.411621] hub 1-0:1.0: trying to enable port power on non-switchable hub
[    1.411639] drivers/usb/core/inode.c: creating file '001'
[    1.411664] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    1.411668] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    1.411689] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.411692] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[    1.411696] drivers/usb/core/inode.c: creating file '002'
[    1.411735] ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.411741] ehci_hcd 0000:00:1d.0: reset hcs_params 0x200003 dbg=2 cc=0 pcc=0 ordered !ppc ports=3
[    1.411745] ehci_hcd 0000:00:1d.0: reset hcc_params 36881 caching frame 1024 64 bit addr
[    1.411756] ehci_hcd 0000:00:1d.0: support lpm
[    1.411765] ehci_hcd 0000:00:1d.0: debug port 2
[    1.411769] ehci_hcd 0000:00:1d.0: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[    1.415647] ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
[    1.415649] ehci_hcd 0000:00:1d.0: supports USB remote wakeup
[    1.415661] ehci_hcd 0000:00:1d.0: irq 23, io mem 0xf2629000
[    1.415666] ehci_hcd 0000:00:1d.0: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[    1.421406] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    1.421448] usb usb2: default language 0x0409
[    1.421460] usb usb2: udev 1, busnum 2, minor = 128
[    1.421465] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.421470] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.421475] usb usb2: Product: EHCI Host Controller
[    1.421479] usb usb2: Manufacturer: Linux 3.2.0+ ehci_hcd
[    1.421483] usb usb2: SerialNumber: 0000:00:1d.0
[    1.421550] usb usb2: usb_probe_device
[    1.421552] usb usb2: configuration #1 chosen from 1 choice
[    1.421556] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[    1.421588] hub 2-0:1.0: usb_probe_interface
[    1.421590] hub 2-0:1.0: usb_probe_interface - got id
[    1.421591] hub 2-0:1.0: USB hub found
[    1.421594] hub 2-0:1.0: 3 ports detected
[    1.421595] hub 2-0:1.0: standalone hub
[    1.421596] hub 2-0:1.0: no power switching (usb 1.0)
[    1.421597] hub 2-0:1.0: individual port over-current protection
[    1.421599] hub 2-0:1.0: power on to power good time: 20ms
[    1.421602] hub 2-0:1.0: local power source is good
[    1.421603] hub 2-0:1.0: trying to enable port power on non-switchable hub
[    1.421619] drivers/usb/core/inode.c: creating file '001'
[    1.421661] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.421662] ohci_hcd: block sizes: ed 80 td 96
[    1.421689] uhci_hcd: USB Universal Host Controller Interface driver
[    1.421750] usbcore: registered new interface driver usblp
[    1.421751] Initializing USB Mass Storage driver...
[    1.421780] usbcore: registered new interface driver usb-storage
[    1.421781] USB Mass Storage support registered.
[    1.421811] usbcore: registered new interface driver libusual
[    1.421882] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.424956] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.424960] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.425035] mousedev: PS/2 mouse device common for all mice
[    1.425259] rtc_cmos 00:07: RTC can wake from S4
[    1.425367] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[    1.425405] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    1.425605] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[    1.425685] cpuidle: using governor ladder
[    1.425740] cpuidle: using governor menu
[    1.425741] EFI Variables Facility v0.08 2004-May-17
[    1.426959] usbcore: registered new interface driver usbhid
[    1.426961] usbhid: USB HID core driver
[    1.428431] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    1.428815] modprobe used greatest stack depth: 5560 bytes left
[    1.428945] snd_hda_intel 0000:00:1b.0: irq 42 for MSI/MSI-X
[    1.511301] ehci_hcd 0000:00:1a.0: GetStatus port:1 status 001803 0  ACK POWER sig=j CSC CONNECT
[    1.511315] hub 1-0:1.0: port 1: status 0501 change 0001
[    1.521273] ehci_hcd 0000:00:1d.0: GetStatus port:1 status 001803 0  ACK POWER sig=j CSC CONNECT
[    1.521287] hub 2-0:1.0: port 1: status 0501 change 0001
[    1.611257] hub 1-0:1.0: state 7 ports 3 chg 0002 evt 0000
[    1.611265] hub 1-0:1.0: port 1, status 0501, change 0000, 480 Mb/s
[    1.662290] ehci_hcd 0000:00:1a.0: port 1 high speed
[    1.662294] ehci_hcd 0000:00:1a.0: GetStatus port:1 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    1.705001] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.706865] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    1.706876] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    1.706884] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    1.708629] ata1.00: ATA-8: ST9500420AS, 0003LVM1, max UDMA/100
[    1.708638] ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    1.710788] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    1.710799] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    1.710807] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    1.712548] ata1.00: configured for UDMA/100
[    1.712861] scsi 0:0:0:0: Direct-Access     ATA      ST9500420AS      0003 PQ: 0 ANSI: 5
[    1.712945] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    1.713408] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    1.713465] sd 0:0:0:0: [sda] Write Protect is off
[    1.713468] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.713487] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    1.713491] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.752840]  sda: sda1 sda2 sda3 sda4 < sda5 >
[    1.753496] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.764137] ehci_hcd 0000:00:1a.0: port 1 high speed
[    1.764141] ehci_hcd 0000:00:1a.0: GetStatus port:1 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    1.826990] ehci_hcd 0000:00:1a.0: set dev address 2 for port 1
[    1.827001] ehci_hcd 0000:00:1a.0: LPM: no device attached
[    1.827364] usb 1-1: udev 2, busnum 1, minor = 1
[    1.827372] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    1.827378] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    1.827567] usb 1-1: usb_probe_device
[    1.827569] usb 1-1: configuration #1 chosen from 1 choice
[    1.827698] usb 1-1: adding 1-1:1.0 (config #1, interface 0)
[    1.827853] hub 1-1:1.0: usb_probe_interface
[    1.827855] hub 1-1:1.0: usb_probe_interface - got id
[    1.827857] hub 1-1:1.0: USB hub found
[    1.827987] hub 1-1:1.0: 6 ports detected
[    1.827995] hub 1-1:1.0: standalone hub
[    1.828000] hub 1-1:1.0: individual port power switching
[    1.828004] hub 1-1:1.0: individual port over-current protection
[    1.828008] hub 1-1:1.0: Single TT
[    1.828012] hub 1-1:1.0: TT requires at most 8 FS bit times (666 ns)
[    1.828017] hub 1-1:1.0: power on to power good time: 100ms
[    1.828360] hub 1-1:1.0: local power source is good
[    1.828369] hub 1-1:1.0: enabling power on all ports
[    1.829142] drivers/usb/core/inode.c: creating file '002'
[    1.829180] hub 2-0:1.0: state 7 ports 3 chg 0002 evt 0000
[    1.829186] hub 2-0:1.0: port 1, status 0501, change 0000, 480 Mb/s
[    1.879965] ehci_hcd 0000:00:1d.0: port 1 high speed
[    1.879970] ehci_hcd 0000:00:1d.0: GetStatus port:1 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    1.929583] hub 1-1:1.0: port 6: status 0101 change 0001
[    1.930650] usb 2-1: new high-speed USB device number 2 using ehci_hcd
[    1.944827] HDMI status: Codec=3 Pin=5 Presence_Detect=0 ELD_Valid=0
[    1.944886] HDMI status: Codec=3 Pin=6 Presence_Detect=0 ELD_Valid=0
[    1.944945] HDMI status: Codec=3 Pin=7 Presence_Detect=0 ELD_Valid=0
[    1.945698] ALSA device list:
[    1.945700]   #0: HDA Intel PCH at 0xf2620000 irq 42
[    1.945805] Netfilter messages via NETLINK v0.30.
[    1.945816] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    1.946012] ctnetlink v0.93: registering with nfnetlink.
[    1.946280] ip_tables: (C) 2000-2006 Netfilter Core Team
[    1.946309] TCP cubic registered
[    1.946310] Initializing XFRM netlink socket
[    1.946516] NET: Registered protocol family 10
[    1.946930] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    1.946966] IPv6 over IPv4 tunneling driver
[    1.947421] NET: Registered protocol family 17
[    1.947431] Registering the dns_resolver key type
[    1.947442] openvswitch: Open vSwitch switching datapath
[    1.947650] PM: Hibernation image not present or could not be loaded.
[    1.947659] registered taskstats version 1
[    1.948015]   Magic number: 12:941:97
[    1.948017]   hash matches drivers/base/power/main.c:452
[    1.948075] console [netcon0] enabled
[    1.948076] netconsole: network logging started
[    1.981811] ehci_hcd 0000:00:1d.0: port 1 high speed
[    1.981816] ehci_hcd 0000:00:1d.0: GetStatus port:1 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    2.017537] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    2.019915] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[    2.020176] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[    2.020188] ata2.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    2.021726] ata2.00: ATAPI: HL-DT-STDVDRAM GT33N, LT20, max UDMA/66
[    2.024308] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[    2.024561] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[    2.024572] ata2.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    2.026110] ata2.00: configured for UDMA/66
[    2.029489] usb 1-1: link qh256-0001/ffff880118d73780 start 1 [1/0 us]
[    2.037890] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT33N     LT20 PQ: 0 ANSI: 5
[    2.041042] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[    2.041051] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.041431] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    2.041663] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    2.044665] ehci_hcd 0000:00:1d.0: set dev address 2 for port 1
[    2.044676] ehci_hcd 0000:00:1d.0: LPM: no device attached
[    2.045043] usb 2-1: udev 2, busnum 2, minor = 129
[    2.045052] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    2.045058] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.045292] usb 2-1: usb_probe_device
[    2.045314] usb 2-1: configuration #1 chosen from 1 choice
[    2.045379] usb 2-1: adding 2-1:1.0 (config #1, interface 0)
[    2.045475] hub 2-1:1.0: usb_probe_interface
[    2.045477] hub 2-1:1.0: usb_probe_interface - got id
[    2.045479] hub 2-1:1.0: USB hub found
[    2.045619] hub 2-1:1.0: 8 ports detected
[    2.045624] hub 2-1:1.0: standalone hub
[    2.045627] hub 2-1:1.0: individual port power switching
[    2.045631] hub 2-1:1.0: individual port over-current protection
[    2.045635] hub 2-1:1.0: Single TT
[    2.045640] hub 2-1:1.0: TT requires at most 8 FS bit times (666 ns)
[    2.045644] hub 2-1:1.0: power on to power good time: 100ms
[    2.045986] hub 2-1:1.0: local power source is good
[    2.045989] hub 2-1:1.0: enabling power on all ports
[    2.047143] drivers/usb/core/inode.c: creating file '002'
[    2.047182] hub 1-1:1.0: state 7 ports 6 chg 0040 evt 0000
[    2.047252] hub 1-1:1.0: port 6, status 0101, change 0000, 12 Mb/s
[    2.057607] hub 1-1:1.0: port 6 not reset yet, waiting 10ms
[    2.119637] usb 1-1.6: new high-speed USB device number 3 using ehci_hcd
[    2.130619] hub 1-1:1.0: port 6 not reset yet, waiting 10ms
[    2.147352] usb 2-1: link qh256-0001/ffff880118d73980 start 1 [1/0 us]
[    2.209438] usb 1-1.6: skipped 1 descriptor after configuration
[    2.209447] usb 1-1.6: skipped 5 descriptors after interface
[    2.209453] usb 1-1.6: skipped 1 descriptor after endpoint
[    2.209458] usb 1-1.6: skipped 20 descriptors after interface
[    2.209770] usb 1-1.6: default language 0x0409
[    2.210918] usb 1-1.6: udev 3, busnum 1, minor = 2
[    2.210927] usb 1-1.6: New USB device found, idVendor=04f2, idProduct=b221
[    2.210933] usb 1-1.6: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.210938] usb 1-1.6: Product: Integrated Camera
[    2.210943] usb 1-1.6: Manufacturer: Chicony Electronics Co., Ltd.
[    2.211219] usb 1-1.6: usb_probe_device
[    2.211223] usb 1-1.6: configuration #1 chosen from 1 choice
[    2.211425] usb 1-1.6: adding 1-1.6:1.0 (config #1, interface 0)
[    2.212139] usb 1-1.6: adding 1-1.6:1.1 (config #1, interface 1)
[    2.212384] drivers/usb/core/inode.c: creating file '003'
[    2.212402] hub 2-1:1.0: state 7 ports 8 chg 0000 evt 0000
[    2.212405] hub 1-1:1.0: state 7 ports 6 chg 0000 evt 0040
[    2.283382] psmouse serio1: synaptics: Touchpad model: 1, fw: 7.2, id: 0x1c0b1, caps: 0xd047b3/0xb40000/0xa0000
[    2.283398] psmouse serio1: synaptics: serio: Synaptics pass-through port at isa0060/serio1/input0
[    2.336463] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio1/input/input5
[    2.347051] ata4: SATA link down (SStatus 0 SControl 300)
[    2.651589] ata5: SATA link down (SStatus 0 SControl 300)
[    2.652889] Freeing unused kernel memory: 576k freed
[    2.652992] Write protecting the kernel read-only data: 12288k
[    2.654880] Freeing unused kernel memory: 628k freed
[    2.659783] Freeing unused kernel memory: 1704k freed
[    2.683267] all_generic_ide used greatest stack depth: 5496 bytes left
[    2.700028] ata_id used greatest stack depth: 5432 bytes left
[    2.701327] ata_id used greatest stack depth: 5408 bytes left
[    2.724933] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
[    2.724936] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    2.724983] e1000e 0000:00:19.0: setting latency timer to 64
[    2.725127] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    2.726048] udevadm used greatest stack depth: 3936 bytes left
[    2.914476] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:cc:63:c9:ad
[    2.914480] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    2.914517] e1000e 0000:00:19.0: eth0: MAC: 10, PHY: 11, PBA No: 1000FF-0FF
[    3.248936] EXT4-fs (sda5): mounted filesystem with ordered data mode. Opts: (null)
[    8.703711] IBM TrackPoint firmware: 0x0e, buttons: 3/3
[    8.975042] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/serio2/input/input6
[   20.778673] udev[3827]: starting version 167
[   20.808266] udevadm used greatest stack depth: 3872 bytes left
[   20.879074] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro
[   21.131309] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   21.131851] rtlwifi: wireless switch is on
[   21.562794] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   21.613386] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   21.613751] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   21.706344] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[   22.048729] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   22.333869] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[   23.641958] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
[   27.586342] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
[   42.102467] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[   72.058559] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  112.000402] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  161.925233] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  221.836629] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  281.747456] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  301.625743] kworker/u:0 used greatest stack depth: 3640 bytes left
[  341.657664] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  401.568856] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  461.479960] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  521.390895] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  581.301076] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  641.211910] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  701.123120] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  761.032979] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  820.944436] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  880.855495] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[  940.766182] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1000.676669] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1060.587874] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1120.499384] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1180.410146] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1240.320802] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1300.231884] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1360.142740] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1420.053609] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1479.964681] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1539.874834] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1599.785882] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1659.696894] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1719.607144] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1748.168171] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
[ 1748.168176] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO
[ 1748.168513] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 1758.250267] eth0: no IPv6 routers present
[ 1779.507772] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1839.389894] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1899.270871] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 1959.152107] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2019.033310] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2078.914340] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2138.795501] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2198.676260] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2258.556621] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2318.436718] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2378.318406] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2438.199753] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2498.080417] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2557.961635] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2617.856180] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2677.768781] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2737.680243] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2797.590224] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin
[ 2857.501062] rtl8192c_common: Loading firmware file rtlwifi/rtl8192cfw.bin

--=-ExM9NFgKYmq6NVmUdTC1--
