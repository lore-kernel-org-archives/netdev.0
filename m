From: "George Spelvin" <linux@horizon.com>
Subject: Re: NETDEV WATCHDOG: %s (%s): transmit queue %u timed out
Date: 24 May 2012 08:46:07 -0400
Message-ID: <20120524124607.27031.qmail@science.horizon.com>
References: <20120523223210.GA20536@electric-eye.fr.zoreil.com>
Cc: davej@redhat.com, kernel-team@fedoraproject.org, linux@horizon.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:53857 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753147Ab2EXMqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 08:46:09 -0400
In-Reply-To: <20120523223210.GA20536@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com>
> You may try the attached patches on top of current -git. A complete dmesg
> will be welcome. So will an 'ethtool -d eth0' if the device stops working.
>
> You did not label the problem as a serious one. Does it means that the
> driver automatically recovers ?

Same timeout, at 6h20m uptime (dmesg attached),  System is 3.4.0 +
some completely unrelated local patches (to serial port PPS drivers) +
your two patches.

System recovers, is operating normally.

Thank you for your efforts!


Initializing cgroup subsys cpu
Linux version 3.4.0-00020-g3579858 ($USER@$HOST) (gcc version 4.7.0 (Debian 4.7.0-9) ) #156 SMP Wed May 23 22:24:39 EDT 2012
Command line: auto BOOT_IMAGE=Amd64 ro root=905 libata.fua=1 acpi_enforce_resources=lax k10temp.force=1
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 0000000000093800 (usable)
 BIOS-e820: 0000000000093800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dffa0000 (usable)
 BIOS-e820: 00000000dffc0000 - 00000000dffce000 (ACPI data)
 BIOS-e820: 00000000dffce000 - 00000000dfff0000 (ACPI NVS)
 BIOS-e820: 00000000dfff0000 - 00000000dfffe000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000220000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: MICRO-STAR INTERNATIONAL CO.,LTD MS-7376/MS-7376, BIOS V1.7 01/13/2009
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
ie820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn = 0x220000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-EFFFF uncachable
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000000 mask FFFF80000000 write-back
  1 base 000080000000 mask FFFFC0000000 write-back
  2 base 0000C0000000 mask FFFFE0000000 write-back
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
TOM2: 0000000220000000 aka 8704M
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000e0000000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xdffa0 max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000ff780] ff780
initial memory mapped : 0 - 20000000
Base memory trampoline at [ffff880000091000] 91000 size 8192
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000dffa0000
 0000000000 - 00c0000000 page 1G
 00c0000000 - 00dfe00000 page 2M
 00dfe00000 - 00dffa0000 page 4k
kernel direct mapping tables up to dffa0000 @ 1fffd000-20000000
init_memory_mapping: 0000000100000000-0000000220000000
 0100000000 - 0200000000 page 1G
 0200000000 - 0220000000 page 2M
kernel direct mapping tables up to 220000000 @ dff9e000-dffa0000
ACPI: RSDP 00000000000f9e30 00014 (v00 ACPIAM)
ACPI: RSDT 00000000dffc0000 00038 (v01 011309 RSDT1044 20090113 MSFT 00000097)
ACPI: FACP 00000000dffc0200 00084 (v02 011309 FACP1044 20090113 MSFT 00000097)
ACPI: DSDT 00000000dffc0440 06E9B (v01  1ADNC 1ADNC001 00000001 INTL 20051117)
ACPI: FACS 00000000dffce000 00040
ACPI: APIC 00000000dffc0390 0006C (v01 011309 APIC1044 20090113 MSFT 00000097)
ACPI: MCFG 00000000dffc0400 0003C (v01 011309 OEMMCFG  20090113 MSFT 00000097)
ACPI: OEMB 00000000dffce040 00071 (v01 011309 OEMB1044 20090113 MSFT 00000097)
ACPI: HPET 00000000dffc72e0 00038 (v01 011309 OEMHPET  20090113 MSFT 00000097)
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00087fffff] PMD -> [ffff880217600000-ffff88021f5fffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00220000
Movable zone start PFN for each node
Early memory PFN ranges
    0: 0x00000010 -> 0x00000093
    0: 0x00000100 -> 0x000dffa0
    0: 0x00100000 -> 0x00220000
On node 0 totalpages: 2096931
  DMA zone: 64 pages used for memmap
  DMA zone: 2 pages reserved
  DMA zone: 3905 pages, LIFO batch:0
  DMA32 zone: 16320 pages used for memmap
  DMA32 zone: 896992 pages, LIFO batch:31
  Normal zone: 18432 pages used for memmap
  Normal zone: 1161216 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 33, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8300 base: 0xfed00000
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 40
Allocating PCI resources starting at dfffe000 (gap: dfffe000:1ff02000)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 23 pages/cpu @ffff88021fc00000 s72704 r0 d21504 u524288
pcpu-alloc: s72704 r0 d21504 u524288 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2062113
Kernel command line: auto BOOT_IMAGE=Amd64 ro root=905 libata.fua=1 acpi_enforce_resources=lax k10temp.force=1
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Checking aperture...
No AGP bridge found
Node 0: aperture @ d4000000 size 32 MB
Aperture pointing to e820 RAM. Ignoring.
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ d4000000
Memory: 8105124k/8912896k available (4126k kernel code, 525172k absent, 282600k reserved, 1952k data, 476k init)
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Hierarchical RCU implementation.
NR_IRQS:4352 nr_irqs:712 16
Console: colour VGA+ 80x50
console [tty0] enabled
hpet clockevent registered
Fast TSC calibration failed
TSC: Unable to calibrate against PIT
TSC: using HPET reference calibration
Detected 2500.164 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5000.32 BogoMIPS (lpj=25001640)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
LVT offset 0 assigned for vector 0xf9
using AMD E400 aware idle routine
Freeing SMP alternatives: 12k freed
ACPI: Core revision 20120320
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Phenom(tm) 9850 Quad-Core Processor stepping 03
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
MCE: In-kernel MCE decoding enabled.
NMI watchdog: enabled, takes one hw-pmu counter.
Booting Node   0, Processors  #1
NMI watchdog: enabled, takes one hw-pmu counter.
System has AMD C1E enabled
Switch to broadcast mode on CPU1
 #2
NMI watchdog: enabled, takes one hw-pmu counter.
Switch to broadcast mode on CPU2
 #3 Ok.
NMI watchdog: enabled, takes one hw-pmu counter.
Switch to broadcast mode on CPU3
Brought up 4 CPUs
Total of 4 processors activated (20001.31 BogoMIPS).
Switch to broadcast mode on CPU0
xor: automatically using best checksumming function: generic_sse
   generic_sse:  9968.800 MB/sec
xor: using function: generic_sse (9968.800 MB/sec)
NET: Registered protocol family 16
node 0 link 0: io port [1000, ffffff]
TOM: 00000000e0000000 aka 3584M
Fam 10h mmconf [mem 0xe0000000-0xefffffff]
node 0 link 0: mmio [e0000000, efffffff] ==> none
node 0 link 0: mmio [f0000000, ffffffff]
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [e0000000, dfffffff] ==> none
TOM2: 0000000220000000 aka 8704M
bus: [00, 07] on node 0 link 0
bus: 00 index 0 [io  0x0000-0xffff]
bus: 00 index 1 [mem 0xf0000000-0xffffffff]
bus: 00 index 2 [mem 0x000a0000-0x000bffff]
bus: 00 index 3 [mem 0x220000000-0xfcffffffff]
ACPI: bus type pci registered
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
PCI: not using MMCONFIG
PCI: Using configuration type 1 for base access
PCI: Using configuration type 1 for extended access
bio: create slab <bio-0> at 0
raid6: int64x1   2426 MB/s
raid6: int64x2   2127 MB/s
raid6: int64x4   2237 MB/s
raid6: int64x8   1474 MB/s
raid6: sse2x1    3546 MB/s
raid6: sse2x2    5429 MB/s
raid6: sse2x4    6551 MB/s
raid6: using algorithm sse2x4 (6551 MB/s)
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: EC: Detected MSI hardware, enabling workarounds.
ACPI: EC: Look up EC in DSDT
ACPI: Executed 3 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resources
ACPI: No dock devices found.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A03:00: host bridge window [mem 0x000d0000-0x000dffff]
pci_root PNP0A03:00: host bridge window [mem 0xf0000000-0xfebfffff]
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff]
pci 0000:00:00.0: [1002:5956] type 00 class 0x060000
pci 0000:00:00.0: reg 1c: [mem 0xe0000000-0xffffffff 64bit]
pci 0000:00:02.0: [1002:5978] type 01 class 0x060400
pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: [1002:597b] type 01 class 0x060400
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:09.0: [1002:597e] type 01 class 0x060400
pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
pci 0000:00:12.0: [1002:4380] type 00 class 0x010601
pci 0000:00:12.0: reg 10: [io  0x7000-0x7007]
pci 0000:00:12.0: reg 14: [io  0x6000-0x6003]
pci 0000:00:12.0: reg 18: [io  0x5000-0x5007]
pci 0000:00:12.0: reg 1c: [io  0x4000-0x4003]
pci 0000:00:12.0: reg 20: [io  0x3000-0x300f]
pci 0000:00:12.0: reg 24: [mem 0xfe5ff800-0xfe5ffbff]
pci 0000:00:13.0: [1002:4387] type 00 class 0x0c0310
pci 0000:00:13.0: reg 10: [mem 0xfe5fe000-0xfe5fefff]
pci 0000:00:13.1: [1002:4388] type 00 class 0x0c0310
pci 0000:00:13.1: reg 10: [mem 0xfe5fd000-0xfe5fdfff]
pci 0000:00:13.2: [1002:4389] type 00 class 0x0c0310
pci 0000:00:13.2: reg 10: [mem 0xfe5fc000-0xfe5fcfff]
pci 0000:00:13.3: [1002:438a] type 00 class 0x0c0310
pci 0000:00:13.3: reg 10: [mem 0xfe5fb000-0xfe5fbfff]
pci 0000:00:13.4: [1002:438b] type 00 class 0x0c0310
pci 0000:00:13.4: reg 10: [mem 0xfe5fa000-0xfe5fafff]
pci 0000:00:13.5: [1002:4386] type 00 class 0x0c0320
pci 0000:00:13.5: reg 10: [mem 0xfe5ff000-0xfe5ff0ff]
pci 0000:00:13.5: supports D1 D2
pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
pci 0000:00:14.0: reg 10: [io  0x0b00-0x0b0f]
pci 0000:00:14.1: [1002:438c] type 00 class 0x01018a
pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 20: [io  0xff00-0xff0f]
pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
pci 0000:00:14.2: reg 10: [mem 0xfe5f4000-0xfe5f7fff 64bit]
pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
pci 0000:00:14.3: [1002:438d] type 00 class 0x060100
pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
pci 0000:01:00.0: [1002:5b60] type 00 class 0x030000
pci 0000:01:00.0: reg 10: [mem 0xfc000000-0xfdffffff 64bit pref]
pci 0000:01:00.0: reg 18: [mem 0xfe6f0000-0xfe6fffff 64bit]
pci 0000:01:00.0: reg 20: [io  0x8000-0x80ff]
pci 0000:01:00.0: reg 30: [mem 0xfe6c0000-0xfe6dffff pref]
pci 0000:01:00.0: supports D1 D2
pci 0000:01:00.1: [1002:5b70] type 00 class 0x038000
pci 0000:01:00.1: reg 10: [mem 0xfe6e0000-0xfe6effff 64bit]
pci 0000:01:00.1: supports D1 D2
pci 0000:00:02.0: PCI bridge to [bus 01-01]
pci 0000:00:02.0:   bridge window [io  0x8000-0x8fff]
pci 0000:00:02.0:   bridge window [mem 0xfe600000-0xfe6fffff]
pci 0000:00:02.0:   bridge window [mem 0xfc000000-0xfdffffff 64bit pref]
pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
pci 0000:02:00.0: reg 10: [io  0x9800-0x98ff]
pci 0000:02:00.0: reg 18: [mem 0xfe7ff000-0xfe7fffff 64bit]
pci 0000:02:00.0: reg 30: [mem 0xfe7c0000-0xfe7dffff pref]
pci 0000:02:00.0: supports D1 D2
pci 0000:02:00.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:00:05.0: PCI bridge to [bus 02-02]
pci 0000:00:05.0:   bridge window [io  0x9000-0x9fff]
pci 0000:00:05.0:   bridge window [mem 0xfe700000-0xfe7fffff]
pci 0000:03:00.0: [105a:3f20] type 00 class 0x010400
pci 0000:03:00.0: reg 10: [io  0xa800-0xa87f]
pci 0000:03:00.0: reg 18: [io  0xa400-0xa4ff]
pci 0000:03:00.0: reg 1c: [mem 0xfe8ff000-0xfe8fffff]
pci 0000:03:00.0: reg 20: [mem 0xfe8c0000-0xfe8dffff]
pci 0000:03:00.0: reg 24: [mem 0xfe8fc000-0xfe8fdfff]
pci 0000:03:00.0: supports D1
pci 0000:00:09.0: PCI bridge to [bus 03-03]
pci 0000:00:09.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:09.0:   bridge window [mem 0xfe800000-0xfe8fffff]
pci 0000:04:00.0: [1106:3044] type 00 class 0x0c0010
pci 0000:04:00.0: reg 10: [mem 0xfe9ff800-0xfe9fffff]
pci 0000:04:00.0: reg 14: [io  0xc800-0xc87f]
pci 0000:04:00.0: supports D2
pci 0000:04:00.0: PME# supported from D2 D3hot D3cold
pci 0000:04:02.0: [1415:9501] type 00 class 0x070006
pci 0000:04:02.0: reg 10: [io  0xc400-0xc41f]
pci 0000:04:02.0: reg 14: [mem 0xfe9fe000-0xfe9fefff]
pci 0000:04:02.0: reg 18: [io  0xc000-0xc01f]
pci 0000:04:02.0: reg 1c: [mem 0xfe9fd000-0xfe9fdfff]
pci 0000:04:02.0: supports D2
pci 0000:04:02.0: PME# supported from D0 D2 D3hot
pci 0000:04:02.1: [1415:9513] type 00 class 0x070101
pci 0000:04:02.1: reg 10: [io  0xb800-0xb807]
pci 0000:04:02.1: reg 14: [io  0xb400-0xb407]
pci 0000:04:02.1: reg 18: [io  0xb000-0xb01f]
pci 0000:04:02.1: reg 1c: [mem 0xfe9fc000-0xfe9fcfff]
pci 0000:04:02.1: supports D2
pci 0000:04:02.1: PME# supported from D0 D2 D3hot
pci 0000:04:03.0: [1011:0024] type 01 class 0x060400
pci 0000:00:14.4: PCI bridge to [bus 04-05] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0xb000-0xefff]
pci 0000:00:14.4:   bridge window [mem 0xfe900000-0xfebfffff]
pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff] (subtractive decode)
pci 0000:05:04.0: [1011:0019] type 00 class 0x020000
pci 0000:05:04.0: reg 10: [io  0xe800-0xe87f]
pci 0000:05:04.0: reg 14: [mem 0xfebffc00-0xfebfffff]
pci 0000:05:04.0: reg 30: [mem 0xfeb80000-0xfebbffff pref]
pci 0000:05:05.0: [1011:0019] type 00 class 0x020000
pci 0000:05:05.0: reg 10: [io  0xe400-0xe47f]
pci 0000:05:05.0: reg 14: [mem 0xfebff800-0xfebffbff]
pci 0000:05:05.0: reg 30: [mem 0xfeb40000-0xfeb7ffff pref]
pci 0000:05:06.0: [1011:0019] type 00 class 0x020000
pci 0000:05:06.0: reg 10: [io  0xe000-0xe07f]
pci 0000:05:06.0: reg 14: [mem 0xfebff400-0xfebff7ff]
pci 0000:05:06.0: reg 30: [mem 0xfeb00000-0xfeb3ffff pref]
pci 0000:05:07.0: [1011:0019] type 00 class 0x020000
pci 0000:05:07.0: reg 10: [io  0xd800-0xd87f]
pci 0000:05:07.0: reg 14: [mem 0xfebff000-0xfebff3ff]
pci 0000:05:07.0: reg 30: [mem 0xfeac0000-0xfeafffff pref]
pci 0000:04:03.0: PCI bridge to [bus 05-05]
pci 0000:04:03.0:   bridge window [io  0xd000-0xefff]
pci 0000:04:03.0:   bridge window [mem 0xfea00000-0xfebfffff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE9._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
 pci0000:00: Unable to request _OSC control (_OSC support mask: 0x19)
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs *9)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 *5 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 7 10 11 12 14 15)
vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
vgaarb: bridge control possible 0000:01:00.0
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
Advanced Linux Sound Architecture Driver Version 1.0.25.
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
pci 0000:00:00.0: no compatible bridge window for [mem 0xe0000000-0xffffffff 64bit]
reserve RAM buffer: 0000000000093800 - 000000000009ffff 
reserve RAM buffer: 00000000dffa0000 - 00000000dfffffff 
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 32-bit 14.318180 MHz counter
Switching to clocksource hpet
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-ff]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0000-0x0cf7 window]
pnp 00:00: [io  0x0d00-0xffff window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000d0000-0x000dffff window]
pnp 00:00: [mem 0xe0000000-0xdfffffff window disabled]
pnp 00:00: [mem 0xf0000000-0xfebfffff window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:01: [dma 4]
pnp 00:01: [io  0x0000-0x000f]
pnp 00:01: [io  0x0081-0x0083]
pnp 00:01: [io  0x0087]
pnp 00:01: [io  0x0089-0x008b]
pnp 00:01: [io  0x008f]
pnp 00:01: [io  0x00c0-0x00df]
pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:02: [io  0x0070-0x0071]
pnp 00:02: [irq 8]
pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:03: [io  0x0061]
pnp 00:03: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:04: [io  0x00f0-0x00ff]
pnp 00:04: [irq 13]
pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:05: [io  0x03f8-0x03ff]
pnp 00:05: [irq 4]
pnp 00:05: [dma 0 disabled]
pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:06: [io  0x03f0-0x03f5]
pnp 00:06: [io  0x03f7]
pnp 00:06: [irq 6]
pnp 00:06: [dma 2]
pnp 00:06: Plug and Play ACPI device, IDs PNP0700 (active)
pnp 00:07: [mem 0xfed00000-0xfed003ff]
pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:08: [mem 0xfec00000-0xfec00fff]
pnp 00:08: [mem 0xfee00000-0xfee00fff]
system 00:08: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:08: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0010-0x001f]
pnp 00:09: [io  0x0022-0x003f]
pnp 00:09: [io  0x0062-0x0063]
pnp 00:09: [io  0x0065-0x006f]
pnp 00:09: [io  0x0072-0x007f]
pnp 00:09: [io  0x0080]
pnp 00:09: [io  0x0084-0x0086]
pnp 00:09: [io  0x0088]
pnp 00:09: [io  0x008c-0x008e]
pnp 00:09: [io  0x0090-0x009f]
pnp 00:09: [io  0x00a2-0x00bf]
pnp 00:09: [io  0x00b1]
pnp 00:09: [io  0x00e0-0x00ef]
pnp 00:09: [io  0x04d0-0x04d1]
pnp 00:09: [io  0x040b]
pnp 00:09: [io  0x04d6]
pnp 00:09: [io  0x0c00-0x0c01]
pnp 00:09: [io  0x0c14]
pnp 00:09: [io  0x0c50-0x0c51]
pnp 00:09: [io  0x0c52]
pnp 00:09: [io  0x0c6c]
pnp 00:09: [io  0x0c6f]
pnp 00:09: [io  0x0cd0-0x0cd1]
pnp 00:09: [io  0x0cd2-0x0cd3]
pnp 00:09: [io  0x0cd4-0x0cd5]
pnp 00:09: [io  0x0cd6-0x0cd7]
pnp 00:09: [io  0x0cd8-0x0cdf]
pnp 00:09: [io  0x0800-0x089f]
pnp 00:09: [io  0x0b10-0x0b1f]
pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:09: [io  0x0900-0x090f]
pnp 00:09: [io  0x0910-0x091f]
pnp 00:09: [io  0xfe00-0xfefe]
pnp 00:09: [mem 0xffb80000-0xffbfffff]
system 00:09: [io  0x04d0-0x04d1] has been reserved
system 00:09: [io  0x040b] has been reserved
system 00:09: [io  0x04d6] has been reserved
system 00:09: [io  0x0c00-0x0c01] has been reserved
system 00:09: [io  0x0c14] has been reserved
system 00:09: [io  0x0c50-0x0c51] has been reserved
system 00:09: [io  0x0c52] has been reserved
system 00:09: [io  0x0c6c] has been reserved
system 00:09: [io  0x0c6f] has been reserved
system 00:09: [io  0x0cd0-0x0cd1] has been reserved
system 00:09: [io  0x0cd2-0x0cd3] has been reserved
system 00:09: [io  0x0cd4-0x0cd5] has been reserved
system 00:09: [io  0x0cd6-0x0cd7] has been reserved
system 00:09: [io  0x0cd8-0x0cdf] has been reserved
system 00:09: [io  0x0800-0x089f] has been reserved
system 00:09: [io  0x0b10-0x0b1f] has been reserved
system 00:09: [io  0x0900-0x090f] has been reserved
system 00:09: [io  0x0910-0x091f] has been reserved
system 00:09: [io  0xfe00-0xfefe] has been reserved
system 00:09: [mem 0xffb80000-0xffbfffff] has been reserved
system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0a: [io  0x0060]
pnp 00:0a: [io  0x0064]
pnp 00:0a: [irq 1]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
pnp 00:0b: [irq 12]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0f03 PNP0f13 (active)
pnp 00:0c: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:0c: [io  0x0600-0x06df]
pnp 00:0c: [io  0x0ae0-0x0aef]
system 00:0c: [io  0x0600-0x06df] has been reserved
system 00:0c: [io  0x0ae0-0x0aef] has been reserved
system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0d: [mem 0xe0000000-0xefffffff]
system 00:0d: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0e: [mem 0x00000000-0x0009ffff]
pnp 00:0e: [mem 0x000c0000-0x000cffff]
pnp 00:0e: [mem 0x000e0000-0x000fffff]
pnp 00:0e: [mem 0x00100000-0xdfffffff]
pnp 00:0e: [mem 0xfec00000-0xffffffff]
pnp 00:0e: disabling [mem 0x00000000-0x0009ffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
pnp 00:0e: disabling [mem 0x000c0000-0x000cffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
pnp 00:0e: disabling [mem 0x000e0000-0x000fffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
pnp 00:0e: disabling [mem 0x00100000-0xdfffffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
system 00:0e: [mem 0xfec00000-0xffffffff] could not be reserved
system 00:0e: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
pci 0000:00:02.0: PCI bridge to [bus 01-01]
pci 0000:00:02.0:   bridge window [io  0x8000-0x8fff]
pci 0000:00:02.0:   bridge window [mem 0xfe600000-0xfe6fffff]
pci 0000:00:02.0:   bridge window [mem 0xfc000000-0xfdffffff 64bit pref]
pci 0000:00:05.0: PCI bridge to [bus 02-02]
pci 0000:00:05.0:   bridge window [io  0x9000-0x9fff]
pci 0000:00:05.0:   bridge window [mem 0xfe700000-0xfe7fffff]
pci 0000:00:09.0: PCI bridge to [bus 03-03]
pci 0000:00:09.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:09.0:   bridge window [mem 0xfe800000-0xfe8fffff]
pci 0000:04:03.0: PCI bridge to [bus 05-05]
pci 0000:04:03.0:   bridge window [io  0xd000-0xefff]
pci 0000:04:03.0:   bridge window [mem 0xfea00000-0xfebfffff]
pci 0000:00:14.4: PCI bridge to [bus 04-05]
pci 0000:00:14.4:   bridge window [io  0xb000-0xefff]
pci 0000:00:14.4:   bridge window [mem 0xfe900000-0xfebfffff]
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 8 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:01: resource 0 [io  0x8000-0x8fff]
pci_bus 0000:01: resource 1 [mem 0xfe600000-0xfe6fffff]
pci_bus 0000:01: resource 2 [mem 0xfc000000-0xfdffffff 64bit pref]
pci_bus 0000:02: resource 0 [io  0x9000-0x9fff]
pci_bus 0000:02: resource 1 [mem 0xfe700000-0xfe7fffff]
pci_bus 0000:03: resource 0 [io  0xa000-0xafff]
pci_bus 0000:03: resource 1 [mem 0xfe800000-0xfe8fffff]
pci_bus 0000:04: resource 0 [io  0xb000-0xefff]
pci_bus 0000:04: resource 1 [mem 0xfe900000-0xfebfffff]
pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:04: resource 8 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:05: resource 0 [io  0xd000-0xefff]
pci_bus 0000:05: resource 1 [mem 0xfea00000-0xfebfffff]
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP: reno registered
UDP hash table entries: 4096 (order: 5, 131072 bytes)
UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
pci 0000:01:00.0: Boot video device
PCI: CLS 64 bytes, default 64
PCI-DMA: Disabling AGP.
PCI-DMA: aperture base @ d4000000 size 65536 KB
PCI-DMA: using GART IOMMU.
PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
LVT offset 1 assigned for vector 0x400
IBS: LVT offset 1 assigned
perf: AMD IBS detected (0x00000007)
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
msgmni has been set to 15959
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
ACPI: duty_cycle spans bit 4
ACPI: processor limited to max C-state 1
Serial: 8250/16550 driver, 5 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS4: detected caps 00000700 should be 00000500
0000:04:02.0: ttyS4 at I/O 0xc400 (irq = 22) is a 16C950/954
ttyS1: detected caps 00000700 should be 00000500
0000:04:02.0: ttyS1 at I/O 0xc408 (irq = 22) is a 16C950/954
ttyS2: detected caps 00000700 should be 00000500
0000:04:02.0: ttyS2 at I/O 0xc410 (irq = 22) is a 16C950/954
ttyS3: detected caps 00000700 should be 00000500
0000:04:02.0: ttyS3 at I/O 0xc418 (irq = 22) is a 16C950/954
lp: driver loaded but no devices found
Linux agpgart interface v0.103
PCI parallel port detected: 1415:9513, I/O at 0xb800(0x0), IRQ 23
parport0: PC-style at 0xb800, irq 23 [PCSPP]
lp0: using parport0 (interrupt-driven).
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
loop: module loaded
Uniform Multi-Platform E-IDE driver
atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev 0x00)
atiixp 0000:00:14.1: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xff00-0xff07
Probing IDE interface ide0...
Refined TSC clocksource calibration: 2500.174 MHz.
Switching to clocksource tsc
hda: _NEC DVD_RW ND-3540A, ATAPI CD/DVD-ROM drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/33 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
ide-gd driver 1.18
ide-cd driver 5.00
ide-cd: hda: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048kB Cache
cdrom: Uniform CD-ROM driver Revision: 3.20
ahci 0000:00:12.0: version 3.0
ahci 0000:00:12.0: MSI K9A2 Platinum: enabling 64bit DMA
ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:12.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 abar m1024@0xfe5ff800 port 0xfe5ff900 irq 22
ata2: SATA max UDMA/133 abar m1024@0xfe5ff800 port 0xfe5ff980 irq 22
ata3: SATA max UDMA/133 abar m1024@0xfe5ff800 port 0xfe5ffa00 irq 22
ata4: SATA max UDMA/133 abar m1024@0xfe5ff800 port 0xfe5ffa80 irq 22
ahci 0000:03:00.0: PDC42819 can only drive SATA devices with this driver
ahci 0000:03:00.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl RAID mode
ahci 0000:03:00.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
scsi4 : ahci
scsi5 : ahci
scsi6 : ahci
scsi7 : ahci
ata5: SATA max UDMA/133 abar m8192@0xfe8fc000 port 0xfe8fc100 irq 17
ata6: SATA max UDMA/133 abar m8192@0xfe8fc000 port 0xfe8fc180 irq 17
ata7: SATA max UDMA/133 abar m8192@0xfe8fc000 port 0xfe8fc200 irq 17
ata8: SATA max UDMA/133 abar m8192@0xfe8fc000 port 0xfe8fc280 irq 17
Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
tulip0: EEPROM default media type Autosense
tulip0: Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block
tulip0:  MII transceiver #1 config 3100 status 7869 advertising 01e1
net eth0: Digital DS21142/43 Tulip rev 65 at MMIO 0xfebffc00, 00:80:c8:b9:c1:d5, IRQ 21
tulip1: EEPROM default media type Autosense
tulip1: Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block
tulip1:  MII transceiver #1 config 3100 status 7869 advertising 01e1
net eth1: Digital DS21142/43 Tulip rev 65 at MMIO 0xfebff800, 00:80:c8:b9:c1:d6, IRQ 22
tulip2: EEPROM default media type Autosense
tulip2: Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block
tulip2:  MII transceiver #1 config 3100 status 7849 advertising 01e1
net eth2: Digital DS21142/43 Tulip rev 65 at MMIO 0xfebff400, 00:80:c8:b9:c1:d7, IRQ 23
tulip3: EEPROM default media type Autosense
tulip3: Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block
tulip3:  MII transceiver #1 config 3100 status 7869 advertising 01e1
net eth3: Digital DS21142/43 Tulip rev 65 at MMIO 0xfebff000, 00:80:c8:b9:c1:d8, IRQ 20
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: irq 40 for MSI/MSI-X
r8169 0000:02:00.0: eth4: RTL8168b/8111b at 0xffffc90000020000, 00:21:85:16:51:7f, XID 18000000 IRQ 40
r8169 0000:02:00.0: eth4: jumbo features [frames: 4080 bytes, tx checksumming: ko]
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:13.5: EHCI Host Controller
ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:13.5: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:13.5: debug port 1
ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe5ff000
ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe5fe000
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe5fd000
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.2: OHCI Host Controller
ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe5fc000
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.3: OHCI Host Controller
ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe5fb000
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata7: SATA link down (SStatus 0 SControl 300)
ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata8: SATA link down (SStatus 0 SControl 300)
ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata6.00: ATA-8: Hitachi HDS5C3020ALA632, ML6OA580, max UDMA/133
ata3.00: ATA-8: ST3750330AS, SD1A, max UDMA/133
ata3.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: ATA-8: ST3750330AS, SD1A, max UDMA/133
ata4.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata6.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
ata2.00: ATA-8: ST3750330AS, SD1A, max UDMA/133
ata2.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: ATA-8: ST3750330AS, SD1A, max UDMA/133
ata1.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata5.00: ATA-8: ST3750330AS, SD1A, max UDMA/133
ata5.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata6.00: configured for UDMA/133
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
scsi 0:0:0:0: Direct-Access     ATA      ST3750330AS      SD1A PQ: 0 ANSI: 5
ata2.00: configured for UDMA/133
ata5.00: configured for UDMA/133
sd 0:0:0:0: [sda] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
scsi 1:0:0:0: Direct-Access     ATA      ST3750330AS      SD1A PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
scsi 2:0:0:0: Direct-Access     ATA      ST3750330AS      SD1A PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sdc] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
scsi 3:0:0:0: Direct-Access     ATA      ST3750330AS      SD1A PQ: 0 ANSI: 5
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 3:0:0:0: [sdd] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
sd 3:0:0:0: [sdd] Write Protect is off
sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
scsi 4:0:0:0: Direct-Access     ATA      ST3750330AS      SD1A PQ: 0 ANSI: 5
sd 4:0:0:0: [sde] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
sd 4:0:0:0: [sde] Write Protect is off
sd 4:0:0:0: [sde] Mode Sense: 00 3a 00 00
scsi 5:0:0:0: Direct-Access     ATA      Hitachi HDS5C302 ML6O PQ: 0 ANSI: 5
sd 4:0:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 5:0:0:0: [sdf] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
sd 5:0:0:0: [sdf] Write Protect is off
sd 5:0:0:0: [sdf] Mode Sense: 00 3a 00 10
sd 5:0:0:0: [sdf] Write cache: enabled, read cache: enabled, supports DPO and FUA
 sdf: sdf1
sd 5:0:0:0: [sdf] Attached SCSI disk
 sdb: sdb1 sdb2 sdb3 sdb4
sd 1:0:0:0: [sdb] Attached SCSI disk
 sdc: sdc1 sdc2 sdc3 sdc4
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.4: OHCI Host Controller
ohci_hcd 0000:00:13.4: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe5fa000
sd 2:0:0:0: [sdc] Attached SCSI disk
 sdd: sdd1 sdd2 sdd3 sdd4
sd 3:0:0:0: [sdd] Attached SCSI disk
 sda: sda1 sda2 sda3 sda4
 sde: sde1 sde2 sde3 sde4
sd 0:0:0:0: [sda] Attached SCSI disk
sd 4:0:0:0: [sde] Attached SCSI disk
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usbcore: registered new interface driver usbserial
usbserial: USB Serial Driver core
usbcore: registered new interface driver pl2303
USB Serial support registered for pl2303
i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:02: RTC can wake from S4
rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
i2c /dev entries driver
ACPI Warning: 0x0000000000000b00-0x0000000000000b07 SystemIO conflicts with Region \SOR1 1 (20120320/utaddress-251)
ACPI: This conflict may cause random problems and system instability
ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
pps_ldisc: PPS line discipline registered
f71882fg: Found f71882fg chip at 0x600, revision 32
ACPI Warning: 0x0000000000000600-0x0000000000000607 SystemIO conflicts with Region \HMOR 1 (20120320/utaddress-251)
ACPI: This conflict may cause random problems and system instability
ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
f71882fg f71882fg.1536: Fan: 1 is in duty-cycle mode
f71882fg f71882fg.1536: Fan: 2 is in duty-cycle mode
f71882fg f71882fg.1536: Fan: 3 is in duty-cycle mode
f71882fg f71882fg.1536: Fan: 4 is in duty-cycle mode
k10temp 0000:00:18.3: unreliable CPU thermal sensor; check erratum 319
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
md: raid10 personality registered for level 10
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
EDAC MC: Ver: 2.1.0
AMD64 EDAC driver v3.4.0
EDAC amd64: DRAM ECC disabled.
EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
 Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
 (Note that use of the override may cause unknown side effects.)
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
GACT probability on
netem: version 1.3
u32 classifier
    Actions configured
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
NF_TPROXY: Transparent proxy support initialized, version 4.1.0
NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
ip_set: protocol 6
IPv4 over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP: bic registered
TCP: cubic registered
TCP: westwood registered
TCP: highspeed registered
TCP: hybla registered
TCP: htcp registered
TCP: vegas registered
TCP: veno registered
TCP: scalable registered
TCP: lp registered
TCP: yeah registered
TCP: illinois registered
Initializing XFRM netlink socket
NET: Registered protocol family 10
ip6_tables: (C) 2000-2006 Netfilter Core Team
IPv6 over IPv4 tunneling driver
NET: Registered protocol family 17
NET: Registered protocol family 15
Bridge firewalling registered
8021q: 802.1Q VLAN Support v1.8
registered taskstats version 1
rtc_cmos 00:02: setting system clock to 2012-05-24 02:27:33 UTC (1337826453)
powernow-k8: Found 1 AMD Phenom(tm) 9850 Quad-Core Processor (4 cpu cores) (version 2.20.00)
[Firmware Bug]: powernow-k8: No compatible ACPI _PSS objects found.
[Firmware Bug]: powernow-k8: Try again with latest BIOS.
ALSA device list:
  #0: HDA ATI SB at 0xfe5f4000 irq 16
usb 6-2: new low-speed USB device number 2 using ohci_hcd
input: HID 0430:0100 as /devices/pci0000:00/0000:00:13.4/usb6/6-2/6-2:1.0/input/input1
generic-usb 0003:0430:0100.0001: input: USB HID v1.00 Mouse [HID 0430:0100] on usb-0000:00:13.4-2/input0
input: PS/2 Generic Mouse as /devices/platform/i8042/serio1/input/input2
md: Waiting for all devices to be available before autodetect
md: If you don't use raid, use raid=noautodetect
md: Autodetecting RAID arrays.
md: Scanned 20 and added 20 devices.
md: autorun ...
md: considering sde4 ...
md:  adding sde4 ...
md: sde3 has different UUID to sde4
md: sde2 has different UUID to sde4
md: sde1 has different UUID to sde4
md:  adding sda4 ...
md: sda3 has different UUID to sde4
md: sda2 has different UUID to sde4
md: sda1 has different UUID to sde4
md:  adding sdd4 ...
md: sdd3 has different UUID to sde4
md: sdd2 has different UUID to sde4
md: sdd1 has different UUID to sde4
md:  adding sdc4 ...
md: sdc3 has different UUID to sde4
md: sdc2 has different UUID to sde4
md: sdc1 has different UUID to sde4
md:  adding sdb4 ...
md: sdb3 has different UUID to sde4
md: sdb2 has different UUID to sde4
md: sdb1 has different UUID to sde4
md: created md6
md: bind<sdb4>
md: bind<sdc4>
md: bind<sdd4>
md: bind<sda4>
md: bind<sde4>
md: running: <sde4><sda4><sdd4><sdc4><sdb4>
bio: create slab <bio-1> at 1
md/raid:md6: device sde4 operational as raid disk 4
md/raid:md6: device sda4 operational as raid disk 0
md/raid:md6: device sdd4 operational as raid disk 3
md/raid:md6: device sdc4 operational as raid disk 2
md/raid:md6: device sdb4 operational as raid disk 1
md/raid:md6: allocated 5350kB
md/raid:md6: raid level 5 active with 5 out of 5 devices, algorithm 2
RAID conf printout:
 --- level:5 rd:5 wd:5
 disk 0, o:1, dev:sda4
 disk 1, o:1, dev:sdb4
 disk 2, o:1, dev:sdc4
 disk 3, o:1, dev:sdd4
 disk 4, o:1, dev:sde4
created bitmap (173 pages) for device md6
md6: bitmap initialized from disk: read 11/11 pages, set 0 of 354293 bits
md6: detected capacity change from 0 to 1486011498496
md: considering sde3 ...
md:  adding sde3 ...
md: sde2 has different UUID to sde3
md: sde1 has different UUID to sde3
md:  adding sda3 ...
md: sda2 has different UUID to sde3
md: sda1 has different UUID to sde3
md: sdd3 has different UUID to sde3
md: sdd2 has different UUID to sde3
md: sdd1 has different UUID to sde3
md: sdc3 has different UUID to sde3
md: sdc2 has different UUID to sde3
md: sdc1 has different UUID to sde3
md:  adding sdb3 ...
md: sdb2 has different UUID to sde3
md: sdb1 has different UUID to sde3
md: created md7
md: bind<sdb3>
md: bind<sda3>
md: bind<sde3>
md: running: <sde3><sda3><sdb3>
md/raid1:md7: active with 2 out of 2 mirrors
md7: detected capacity change from 0 to 6144196608
md: considering sde2 ...
RAID1 conf printout:
 --- wd:2 rd:2
 disk 0, wo:0, o:1, dev:sda3
 disk 1, wo:0, o:1, dev:sdb3
md:  adding sde2 ...
md: sde1 has different UUID to sde2
md:  adding sda2 ...
md: sda1 has different UUID to sde2
md: sdd3 has different UUID to sde2
md:  adding sdd2 ...
md: sdd1 has different UUID to sde2
md: sdc3 has different UUID to sde2
md:  adding sdc2 ...
md: sdc1 has different UUID to sde2
md:  adding sdb2 ...
md: sdb1 has different UUID to sde2
md: created md5
md: bind<sdb2>
md: bind<sdc2>
md: bind<sdd2>
md: bind<sda2>
md: bind<sde2>
md: running: <sde2><sda2><sdd2><sdc2><sdb2>
md/raid10:md5: active with 4 out of 4 devices
created bitmap (173 pages) for device md5
md5: bitmap initialized from disk: read 11/11 pages, set 0 of 354293 bits
md5: detected capacity change from 0 to 743005749248
md: considering sde1 ...
RAID10 conf printout:
 --- wd:4 rd:4
 disk 0, wo:0, o:1, dev:sda2
 disk 1, wo:0, o:1, dev:sdb2
 disk 2, wo:0, o:1, dev:sdc2
 disk 3, wo:0, o:1, dev:sdd2
md:  adding sde1 ...
md:  adding sda1 ...
md: sdd3 has different UUID to sde1
md:  adding sdd1 ...
md: sdc3 has different UUID to sde1
md:  adding sdc1 ...
md:  adding sdb1 ...
md: created md0
md: bind<sdb1>
md: bind<sdc1>
md: bind<sdd1>
md: bind<sda1>
md: bind<sde1>
md: running: <sde1><sda1><sdd1><sdc1><sdb1>
md/raid1:md0: active with 5 out of 5 mirrors
md0: detected capacity change from 0 to 1003356160
md: considering sdd3 ...
md:  adding sdd3 ...
md:  adding sdc3 ...
md: created md8
md: bind<sdc3>
md: bind<sdd3>
md: running: <sdd3><sdc3>
md/raid1:md8: active with 2 out of 2 mirrors
md8: detected capacity change from 0 to 6144196608
md: ... autorun DONE.
 md5: unknown partition table
kjournald starting.  Commit interval 5 seconds
EXT3-fs (md5): mounted filesystem with ordered data mode
VFS: Mounted root (ext3 filesystem) readonly on device 9:5.
Freeing unused kernel memory: 476k freed
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
 md8: unknown partition table
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
 md6: unknown partition table
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
 md7: unknown partition table
 md0:
udevd[1132]: renamed network interface eth4 to inside
udevd[1151]: renamed network interface eth0 to cable
udevd[1141]: renamed network interface eth1 to dmz
udevd[1155]: renamed network interface eth2 to t1
udevd[1156]: renamed network interface eth3 to spare
hda: UDMA/33 mode selected
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata5.00: configured for UDMA/133
ata5: EH complete
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata5.00: configured for UDMA/133
ata5: EH complete
ata6.00: configured for UDMA/133
ata6: EH complete
hda: UDMA/33 mode selected
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata1: EH complete
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata2: EH complete
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
ata3.00: configured for UDMA/133
ata3: EH complete
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
ata4.00: configured for UDMA/133
ata4: EH complete
ata5.00: configured for UDMA/133
ata5: EH complete
ata6.00: configured for UDMA/133
ata6: EH complete
Adding 6000188k swap on /dev/md7.  Priority:1 extents:1 across:6000188k 
Adding 6000188k swap on /dev/md8.  Priority:1 extents:1 across:6000188k 
scsi_verify_blk_ioctl: 562 callbacks suppressed
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
EXT3-fs (md5): using internal journal
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
mdadm: sending ioctl 1261 to a partition!
kjournald starting.  Commit interval 5 seconds
EXT3-fs (md6): using internal journal
EXT3-fs (md6): mounted filesystem with writeback data mode
EXT4-fs (sdf1): mounted filesystem with writeback data mode. Opts: data=writeback
r8169 0000:02:00.0: inside: link down
r8169 0000:02:00.0: inside: link down
NOHZ: local_softirq_pending 08
ADDRCONF(NETDEV_UP): inside: link is not ready
r8169 0000:02:00.0: inside: link up
ADDRCONF(NETDEV_CHANGE): inside: link becomes ready
net dmz: Setting full-duplex based on MII#1 link partner capability of 45e1
net cable: Setting full-duplex based on MII#1 link partner capability of 41e1
cable: no IPv6 routers present
dmz: no IPv6 routers present
inside: no IPv6 routers present
postgres (4955): /proc/4955/oom_adj is deprecated, please use /proc/4955/oom_score_adj instead.
pps pps0: new PPS source serial3 at ID 0
pps pps0: source "/dev/ttyS3" added
pps pps1: new PPS source serial4 at ID 1
pps pps1: source "/dev/ttyS4" added
device cable entered promiscuous mode
device dmz entered promiscuous mode
UDP: bad checksum. From yyy.yy.yyy.yy:1215 to xx.xxx.xx.xxx:62901 ulen 38
UDP: short packet: From zzz.zzz.zz.zz:1400 49320/143 to xx.xxx.xx.xxx:6881
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0xe9/0x15c()
Hardware name: MS-7376
NETDEV WATCHDOG: inside (r8169): transmit queue 0 timed out
Pid: 0, comm: swapper/3 Not tainted 3.4.0-00020-g3579858 #156
Call Trace:
 <IRQ>  [<ffffffff813122ba>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff810249a1>] ? warn_slowpath_common+0x71/0x85
 [<ffffffff813121d1>] ? netif_tx_lock+0x7a/0x7a
 [<ffffffff81024a19>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffff813121be>] ? netif_tx_lock+0x67/0x7a
 [<ffffffff813122ba>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff8102ce10>] ? run_timer_softirq+0x17e/0x20b
 [<ffffffff81028d91>] ? __do_softirq+0x80/0x102
 [<ffffffff8140550c>] ? call_softirq+0x1c/0x30
 [<ffffffff81003300>] ? do_softirq+0x2c/0x60
 [<ffffffff81028fc4>] ? irq_exit+0x3a/0x91
 [<ffffffff8100314d>] ? do_IRQ+0x81/0x97
 [<ffffffff81403b27>] ? common_interrupt+0x67/0x67
 <EOI>  [<ffffffff81007c94>] ? default_idle+0x1e/0x32
 [<ffffffff81007db8>] ? amd_e400_idle+0xb7/0xd4
 [<ffffffff81008461>] ? cpu_idle+0x58/0x98
---[ end trace 14c35d45980e4004 ]---
r8169 0000:02:00.0: inside: link up
