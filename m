From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: iwl rfkill suddenly dropped to hard block
Date: Wed, 15 Dec 2010 22:56:52 +0300
Message-ID: <20101215195651.GA18545@ioremap.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: Intel Linux Wireless <ilw@linux.intel.com>, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:41593 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755231Ab0LOT4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 14:56:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi.

Yesterday the latest git kernel (as of 2 days pull + i915 drm fixes
tree) decided to turn my iwl agn adapter off.
rfkill says it is hard blocked. It worked pretty well for the last
several days for sure, but there was a suspend/wakeup (unsuccessful
because i915 did not flash the display).

With 2.6.33 kernel it worked for months (although without sound).
Other (newer) stock kernels from FC13 do not turn on LCD.

My tree is at 63abf3eda, which likely comes from drm-fixes or
drm-staging kernel tree, but it is just 2 or 3 commits ahead of vanilla
HEAD, but the same happens with 2.6.33.3-85 kernel from FC13.

Attached full dmesg with iwlagn debug=127 and lspci -vvv -H1

Thank you.

-- 
	Evgeniy Polyakov

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.37-rc5-mainline+ (zbr@gavana) (gcc version 4.4.5 20101112 (Red Hat 4.4.5-2) (GCC) ) #4 SMP Sat Dec 11 16:37:52 MSK 2010
Command line: ro root=/dev/mapper/vg_gavana-lv_root rd_LVM_LV=vg_gavana/lv_root rd_LVM_LV=vg_gavana/lv_swap rd_NO_LUKS rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=us rhgb quiet
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009ac00 (usable)
 BIOS-e820: 000000000009ac00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000db65f000 (usable)
 BIOS-e820: 00000000db65f000 - 00000000db67f000 (ACPI data)
 BIOS-e820: 00000000db67f000 - 00000000db76f000 (ACPI NVS)
 BIOS-e820: 00000000db76f000 - 00000000dc000000 (reserved)
 BIOS-e820: 00000000dde00000 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fed10000 - 00000000fed14000 (reserved)
 BIOS-e820: 00000000fed18000 - 00000000fed1a000 (reserved)
 BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 000000011c000000 (usable)
NX (Execute Disable) protection: active
DMI 2.6 present.
DMI: 0T26D8/Latitude E4310, BIOS A04 08/10/2010
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn = 0x11c000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000 mask F80000000 write-back
  1 base 080000000 mask FC0000000 write-back
  2 base 0C0000000 mask FE0000000 write-back
  3 base 0DC000000 mask FFC000000 uncachable
  4 base 100000000 mask FE0000000 write-back
  5 base 11C000000 mask FFC000000 uncachable
  6 disabled
  7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
original variable MTRRs
reg 0, base: 0GB, range: 2GB, type WB
reg 1, base: 2GB, range: 1GB, type WB
reg 2, base: 3GB, range: 512MB, type WB
reg 3, base: 3520MB, range: 64MB, type UC
reg 4, base: 4GB, range: 512MB, type WB
reg 5, base: 4544MB, range: 64MB, type UC
total RAM covered: 3968M
Found optimal setting for mtrr clean up
 gran_size: 64K 	chunk_size: 128M 	num_reg: 6  	lose cover RAM: 0G
New variable MTRRs
reg 0, base: 0GB, range: 2GB, type WB
reg 1, base: 2GB, range: 1GB, type WB
reg 2, base: 3GB, range: 512MB, type WB
reg 3, base: 3520MB, range: 64MB, type UC
reg 4, base: 4GB, range: 512MB, type WB
reg 5, base: 4544MB, range: 64MB, type UC
e820 update range: 00000000dc000000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xdb65f max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000f2280] f2280
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-00000000db65f000
 0000000000 - 00db600000 page 2M
 00db600000 - 00db65f000 page 4k
kernel direct mapping tables up to db65f000 @ 1fffa000-20000000
init_memory_mapping: 0000000100000000-000000011c000000
 0100000000 - 011c000000 page 2M
kernel direct mapping tables up to 11c000000 @ db659000-db65f000
RAMDISK: 373a7000 - 37ff0000
ACPI: RSDP 00000000000fe300 00024 (v02 DELL  )
ACPI: XSDT 00000000db67de18 0005C (v01 DELL    E2      06222004 MSFT 00010013)
ACPI: FACP 00000000db75fc18 000F4 (v04 DELL    E2      06222004 MSFT 00010013)
ACPI Warning: 32/64 FACS address mismatch in FADT - two FACS tables! (20101013/tbfadt-369)
ACPI Warning: 32/64X FACS address mismatch in FADT - 0xDB76BF40/0x00000000DB76ED40, using 32 (20101013/tbfadt-486)
ACPI: DSDT 00000000db750018 09760 (v01 DELL    E2      00001001 INTL 20080729)
ACPI: FACS 00000000db76bf40 00040
ACPI: APIC 00000000db67cf18 0008C (v02 DELL    E2      06222004 MSFT 00010013)
ACPI: MCFG 00000000db76dd18 0003C (v01 A M I  GMCH945. 06222004 MSFT 00000097)
ACPI: HPET 00000000db76dc98 00038 (v01 DELL    E2      00000001 ASL  00000061)
ACPI: BOOT 00000000db76dc18 00028 (v01 DELL   E2       06222004 AMI  00010013)
ACPI: SLIC 00000000db766818 00176 (v03 DELL    E2      06222004 MSFT 00010013)
ACPI: SSDT 00000000db75e018 009F1 (v01  PmRef    CpuPm 00003000 INTL 20080729)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at 0000000000000000-000000011c000000
Initmem setup node 0 0000000000000000-000000011c000000
  NODE_DATA [000000011bfec000 - 000000011bffffff]
 [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff880117e00000-ffff88011b7fffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x0011c000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009a
    0: 0x00000100 -> 0x000db65f
    0: 0x00100000 -> 0x0011c000
On node 0 totalpages: 1013225
  DMA zone: 56 pages used for memmap
  DMA zone: 6 pages reserved
  DMA zone: 3916 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 880279 pages, LIFO batch:31
  Normal zone: 1568 pages used for memmap
  Normal zone: 113120 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] disabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a701 base: 0xfed00000
SMP: Allowing 8 CPUs, 4 hotplug CPUs
nr_irqs_gsi: 40
PM: Registered nosave memory: 000000000009a000 - 000000000009b000
PM: Registered nosave memory: 000000000009b000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
PM: Registered nosave memory: 00000000db65f000 - 00000000db67f000
PM: Registered nosave memory: 00000000db67f000 - 00000000db76f000
PM: Registered nosave memory: 00000000db76f000 - 00000000dc000000
PM: Registered nosave memory: 00000000dc000000 - 00000000dde00000
PM: Registered nosave memory: 00000000dde00000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000f8000000
PM: Registered nosave memory: 00000000f8000000 - 00000000fc000000
PM: Registered nosave memory: 00000000fc000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
PM: Registered nosave memory: 00000000fec01000 - 00000000fed10000
PM: Registered nosave memory: 00000000fed10000 - 00000000fed14000
PM: Registered nosave memory: 00000000fed14000 - 00000000fed18000
PM: Registered nosave memory: 00000000fed18000 - 00000000fed1a000
PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
PM: Registered nosave memory: 00000000fee01000 - 00000000ff800000
PM: Registered nosave memory: 00000000ff800000 - 0000000100000000
Allocating PCI resources starting at e0000000 (gap: e0000000:18000000)
Booting paravirtualized kernel on bare hardware
setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:8 nr_node_ids:1
PERCPU: Embedded 28 pages/cpu @ffff8800db400000 s82752 r8192 d23744 u262144
pcpu-alloc: s82752 r8192 d23744 u262144 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 997315
Policy zone: Normal
Kernel command line: ro root=/dev/mapper/vg_gavana-lv_root rd_LVM_LV=vg_gavana/lv_root rd_LVM_LV=vg_gavana/lv_swap rd_NO_LUKS rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=us rhgb quiet
PID hash table entries: 4096 (order: 3, 32768 bytes)
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 3899920k/4653056k available (4454k kernel code, 600156k absent, 152980k reserved, 7041k data, 924k init)
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
Hierarchical RCU implementation.
	RCU dyntick-idle grace-period acceleration is enabled.
	RCU-based detection of stalled CPUs is disabled.
NR_IRQS:16640 nr_irqs:744 16
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
allocated 41943040 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
hpet clockevent registered
Fast TSC calibration using PIT
spurious 8259A interrupt: IRQ7.
Detected 2526.928 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5053.85 BogoMIPS (lpj=2526928)
pid_max: default: 32768 minimum: 301
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Initializing cgroup subsys blkio
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 9 MCE banks
CPU0: Thermal monitoring handled by SMI
using mwait in idle threads.
Performance Events: PEBS fmt1+, Westmere events, Intel PMU driver.
... version:                3
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             000000007fffffff
... fixed-purpose events:   3
... event mask:             000000070000000f
ACPI: Core revision 20101013
ftrace: allocating 21006 entries in 83 pages
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
CPU0: Intel(R) Core(TM) i5 CPU       M 540  @ 2.53GHz stepping 02
Booting Node   0, Processors  #1
CPU1: Thermal monitoring handled by SMI
 #2
CPU2: Thermal monitoring handled by SMI
 #3
CPU3: Thermal monitoring handled by SMI
Brought up 4 CPUs
Total of 4 processors activated (20215.06 BogoMIPS).
devtmpfs: initialized
Time: 19:04:46  Date: 12/15/10
NET: Registered protocol family 16
ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
ACPI: bus type pci registered
PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
[Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
ACPI: SSDT 00000000db7ea918 00432 (v01  PmRef  Cpu0Ist 00003000 INTL 20080729)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 00432 (v01  PmRef  Cpu0Ist 00003000 INTL 20080729)
ACPI: SSDT 00000000db7e8018 00891 (v01  PmRef  Cpu0Cst 00003001 INTL 20080729)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 00891 (v01  PmRef  Cpu0Cst 00003001 INTL 20080729)
ACPI: SSDT 00000000db7e9a98 00303 (v01  PmRef    ApIst 00003000 INTL 20080729)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst 00003000 INTL 20080729)
ACPI: SSDT 00000000db7e7d98 00119 (v01  PmRef    ApCst 00003000 INTL 20080729)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20080729)
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: EC: GPE = 0x10, I/O: command/status = 0x934, data = 0x930
ACPI: No dock devices found.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 8 1f 
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A08:00: host bridge window [mem 0xe0000000-0xfeafffff]
pci 0000:00:00.0: [8086:0044] type 0 class 0x000600
DMAR: BIOS has allocated no shadow GTT; disabling IOMMU for graphics
pci 0000:00:02.0: [8086:0046] type 0 class 0x000300
pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf03fffff 64bit]
pci 0000:00:02.0: reg 18: [mem 0xe0000000-0xefffffff 64bit pref]
pci 0000:00:02.0: reg 20: [io  0x60b0-0x60b7]
pci 0000:00:19.0: [8086:10ea] type 0 class 0x000200
pci 0000:00:19.0: reg 10: [mem 0xf5400000-0xf541ffff]
pci 0000:00:19.0: reg 14: [mem 0xf5480000-0xf5480fff]
pci 0000:00:19.0: reg 18: [io  0x6040-0x605f]
pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
pci 0000:00:19.0: PME# disabled
pci 0000:00:1a.0: [8086:3b3c] type 0 class 0x000c03
pci 0000:00:1a.0: reg 10: [mem 0xf5470000-0xf54703ff]
pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: PME# disabled
pci 0000:00:1b.0: [8086:3b57] type 0 class 0x000403
pci 0000:00:1b.0: reg 10: [mem 0xf5460000-0xf5463fff 64bit]
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: [8086:3b42] type 1 class 0x000604
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.1: [8086:3b44] type 1 class 0x000604
pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.1: PME# disabled
pci 0000:00:1c.2: [8086:3b46] type 1 class 0x000604
pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.2: PME# disabled
pci 0000:00:1c.3: [8086:3b48] type 1 class 0x000604
pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.3: PME# disabled
pci 0000:00:1d.0: [8086:3b34] type 0 class 0x000c03
pci 0000:00:1d.0: reg 10: [mem 0xf5450000-0xf54503ff]
pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.0: PME# disabled
pci 0000:00:1e.0: [8086:2448] type 1 class 0x000604
pci 0000:00:1f.0: [8086:3b0f] type 0 class 0x000601
pci 0000:00:1f.2: [8086:3b2f] type 0 class 0x000106
pci 0000:00:1f.2: reg 10: [io  0x6090-0x6097]
pci 0000:00:1f.2: reg 14: [io  0x6080-0x6083]
pci 0000:00:1f.2: reg 18: [io  0x6070-0x6077]
pci 0000:00:1f.2: reg 1c: [io  0x6060-0x6063]
pci 0000:00:1f.2: reg 20: [io  0x6020-0x603f]
pci 0000:00:1f.2: reg 24: [mem 0xf5440000-0xf54407ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: [8086:3b30] type 0 class 0x000c05
pci 0000:00:1f.3: reg 10: [mem 0xf5430000-0xf54300ff 64bit]
pci 0000:00:1f.3: reg 20: [io  0x6000-0x601f]
pci 0000:00:1f.6: [8086:3b32] type 0 class 0x001180
pci 0000:00:1f.6: reg 10: [mem 0xf5420000-0xf5420fff 64bit]
pci 0000:00:1c.0: PCI bridge to [bus 01-01]
pci 0000:00:1c.0:   bridge window [io  0x5000-0x5fff]
pci 0000:00:1c.0:   bridge window [mem 0xf4000000-0xf53fffff]
pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:02:00.0: [8086:422c] type 0 class 0x000280
pci 0000:02:00.0: reg 10: [mem 0xf2c00000-0xf2c01fff 64bit]
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:00:1c.1: PCI bridge to [bus 02-02]
pci 0000:00:1c.1:   bridge window [io  0x4000-0x4fff]
pci 0000:00:1c.1:   bridge window [mem 0xf2c00000-0xf3ffffff]
pci 0000:00:1c.1:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:03:00.0: [1180:e822] type 0 class 0x000805
pci 0000:03:00.0: reg 10: [mem 0xf1830000-0xf18300ff]
pci 0000:03:00.0: supports D1 D2
pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:03:00.0: PME# disabled
pci 0000:00:1c.2: PCI bridge to [bus 03-03]
pci 0000:00:1c.2:   bridge window [io  0x3000-0x3fff]
pci 0000:00:1c.2:   bridge window [mem 0xf1800000-0xf2bfffff]
pci 0000:00:1c.2:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:1c.3: PCI bridge to [bus 04-09]
pci 0000:00:1c.3:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf17fffff]
pci 0000:00:1c.3:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:1e.0: PCI bridge to [bus 0a-0a] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xe0000000-0xfeafffff] (subtractive decode)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP03._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP04._PRT]
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 19 1f 
ACPI: PCI Root Bridge [CPBG] (domain 0000 [bus 3f])
pci 0000:3f:00.0: [8086:2c62] type 0 class 0x000600
pci 0000:3f:00.1: [8086:2d01] type 0 class 0x000600
pci 0000:3f:02.0: [8086:2d10] type 0 class 0x000600
pci 0000:3f:02.1: [8086:2d11] type 0 class 0x000600
pci 0000:3f:02.2: [8086:2d12] type 0 class 0x000600
pci 0000:3f:02.3: [8086:2d13] type 0 class 0x000600
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 *10 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 *5 6 7 10 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 1 *3 4 5 6 7 10 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
reserve RAM buffer: 000000000009ac00 - 000000000009ffff 
reserve RAM buffer: 00000000db65f000 - 00000000dbffffff 
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
hpet0: 8 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource tsc
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-3e]
pnp 00:00: [io  0x0000-0x0cf7 window]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0d00-0xffff window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000c0000-0x000c3fff window]
pnp 00:00: [mem 0x000c4000-0x000c7fff window]
pnp 00:00: [mem 0x000c8000-0x000cbfff window]
pnp 00:00: [mem 0x000cc000-0x000cffff window]
pnp 00:00: [mem 0x000d0000-0x000d3fff window]
pnp 00:00: [mem 0x000d4000-0x000d7fff window]
pnp 00:00: [mem 0x000d8000-0x000dbfff window]
pnp 00:00: [mem 0x000dc000-0x000dffff window]
pnp 00:00: [mem 0x000e0000-0x000e3fff window]
pnp 00:00: [mem 0x000e4000-0x000e7fff window]
pnp 00:00: [mem 0x000e8000-0x000ebfff window]
pnp 00:00: [mem 0x000ec000-0x000effff window]
pnp 00:00: [mem 0x000f0000-0x000fffff window]
pnp 00:00: [mem 0xe0000000-0xfeafffff window]
pnp 00:00: [mem 0xfed40000-0xfed44fff window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
pnp 00:01: [io  0x0000-0x001f]
pnp 00:01: [io  0x0081-0x0091]
pnp 00:01: [io  0x0093-0x009f]
pnp 00:01: [io  0x00c0-0x00df]
pnp 00:01: [dma 4]
pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:02: [mem 0xff000000-0xffffffff]
pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
pnp 00:03: [mem 0xfed00000-0xfed003ff]
pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:04: [io  0x00f0]
pnp 00:04: [irq 13]
pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:05: [io  0x002e-0x002f]
pnp 00:05: [io  0x004e-0x004f]
pnp 00:05: [io  0x0061]
pnp 00:05: [io  0x0063]
pnp 00:05: [io  0x0065]
pnp 00:05: [io  0x0067]
pnp 00:05: [io  0x0070]
pnp 00:05: [io  0x0080]
pnp 00:05: [io  0x0092]
pnp 00:05: [io  0x00b2-0x00b3]
pnp 00:05: [io  0x0680-0x069f]
pnp 00:05: [io  0x1000-0x1003]
pnp 00:05: [io  0x1004-0x1013]
pnp 00:05: [io  0xffff]
pnp 00:05: [io  0x0400-0x047f]
pnp 00:05: [io  0x0500-0x057f]
pnp 00:05: [io  0x164e-0x164f]
pnp 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:06: [io  0x0070-0x0077]
pnp 00:06: [irq 8]
pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:07: [io  0x0060]
pnp 00:07: [io  0x0064]
pnp 00:07: [irq 1]
pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
pnp 00:08: Plug and Play ACPI device, IDs PNP0401 (disabled)
pnp 00:09: [irq 12]
pnp 00:09: Plug and Play ACPI device, IDs DLL0410 PNP0f13 (active)
pnp 00:0a: [mem 0xfed1c000-0xfed1ffff]
pnp 00:0a: [mem 0xfed10000-0xfed13fff]
pnp 00:0a: [mem 0xfed18000-0xfed18fff]
pnp 00:0a: [mem 0xfed19000-0xfed19fff]
pnp 00:0a: [mem 0xf8000000-0xfbffffff]
pnp 00:0a: [mem 0xfed20000-0xfed3ffff]
pnp 00:0a: [mem 0xfed90000-0xfed8ffff disabled]
pnp 00:0a: [mem 0xfed45000-0xfed8ffff]
pnp 00:0a: [mem 0xff000000-0xffffffff]
pnp 00:0a: [mem 0xfee00000-0xfeefffff]
pnp 00:0a: [mem 0xf54c0000-0xf54c0fff]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0b: [irq 23]
pnp 00:0b: Plug and Play ACPI device, IDs SMO8800 (active)
pnp 00:0c: [bus 3f]
pnp 00:0c: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
system 00:05: [io  0x0680-0x069f] has been reserved
system 00:05: [io  0x1000-0x1003] has been reserved
system 00:05: [io  0x1004-0x1013] has been reserved
system 00:05: [io  0xffff] has been reserved
system 00:05: [io  0x0400-0x047f] has been reserved
system 00:05: [io  0x0500-0x057f] has been reserved
system 00:05: [io  0x164e-0x164f] has been reserved
system 00:0a: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:0a: [mem 0xfed10000-0xfed13fff] has been reserved
system 00:0a: [mem 0xfed18000-0xfed18fff] has been reserved
system 00:0a: [mem 0xfed19000-0xfed19fff] has been reserved
system 00:0a: [mem 0xf8000000-0xfbffffff] has been reserved
system 00:0a: [mem 0xfed20000-0xfed3ffff] has been reserved
system 00:0a: [mem 0xfed45000-0xfed8ffff] has been reserved
system 00:0a: [mem 0xff000000-0xffffffff] could not be reserved
system 00:0a: [mem 0xfee00000-0xfeefffff] could not be reserved
system 00:0a: [mem 0xf54c0000-0xf54c0fff] has been reserved
pci 0000:00:1c.0: BAR 15: assigned [mem 0xfe900000-0xfeafffff 64bit pref]
pci 0000:00:1c.1: BAR 15: assigned [mem 0xfe700000-0xfe8fffff 64bit pref]
pci 0000:00:1c.2: BAR 15: assigned [mem 0xfe500000-0xfe6fffff 64bit pref]
pci 0000:00:1c.3: BAR 15: assigned [mem 0xfe300000-0xfe4fffff 64bit pref]
pci 0000:00:1c.0: PCI bridge to [bus 01-01]
pci 0000:00:1c.0:   bridge window [io  0x5000-0x5fff]
pci 0000:00:1c.0:   bridge window [mem 0xf4000000-0xf53fffff]
pci 0000:00:1c.0:   bridge window [mem 0xfe900000-0xfeafffff 64bit pref]
pci 0000:00:1c.1: PCI bridge to [bus 02-02]
pci 0000:00:1c.1:   bridge window [io  0x4000-0x4fff]
pci 0000:00:1c.1:   bridge window [mem 0xf2c00000-0xf3ffffff]
pci 0000:00:1c.1:   bridge window [mem 0xfe700000-0xfe8fffff 64bit pref]
pci 0000:00:1c.2: PCI bridge to [bus 03-03]
pci 0000:00:1c.2:   bridge window [io  0x3000-0x3fff]
pci 0000:00:1c.2:   bridge window [mem 0xf1800000-0xf2bfffff]
pci 0000:00:1c.2:   bridge window [mem 0xfe500000-0xfe6fffff 64bit pref]
pci 0000:00:1c.3: PCI bridge to [bus 04-09]
pci 0000:00:1c.3:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf17fffff]
pci 0000:00:1c.3:   bridge window [mem 0xfe300000-0xfe4fffff 64bit pref]
pci 0000:00:1e.0: PCI bridge to [bus 0a-0a]
pci 0000:00:1e.0:   bridge window [io  disabled]
pci 0000:00:1e.0:   bridge window [mem disabled]
pci 0000:00:1e.0:   bridge window [mem pref disabled]
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.1: setting latency timer to 64
pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
pci 0000:00:1c.2: setting latency timer to 64
pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
pci 0000:00:1c.3: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfeafffff]
pci_bus 0000:01: resource 0 [io  0x5000-0x5fff]
pci_bus 0000:01: resource 1 [mem 0xf4000000-0xf53fffff]
pci_bus 0000:01: resource 2 [mem 0xfe900000-0xfeafffff 64bit pref]
pci_bus 0000:02: resource 0 [io  0x4000-0x4fff]
pci_bus 0000:02: resource 1 [mem 0xf2c00000-0xf3ffffff]
pci_bus 0000:02: resource 2 [mem 0xfe700000-0xfe8fffff 64bit pref]
pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
pci_bus 0000:03: resource 1 [mem 0xf1800000-0xf2bfffff]
pci_bus 0000:03: resource 2 [mem 0xfe500000-0xfe6fffff 64bit pref]
pci_bus 0000:04: resource 0 [io  0x2000-0x2fff]
pci_bus 0000:04: resource 1 [mem 0xf0400000-0xf17fffff]
pci_bus 0000:04: resource 2 [mem 0xfe300000-0xfe4fffff 64bit pref]
pci_bus 0000:0a: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:0a: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:0a: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:0a: resource 7 [mem 0xe0000000-0xfeafffff]
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 2048 (order: 4, 65536 bytes)
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
NET: Registered protocol family 1
pci 0000:00:02.0: Boot video device
PCI: CLS 64 bytes, default 64
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 12580k freed
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff8800d7400000 - ffff8800db400000
software IO TLB at phys 0xd7400000 - 0xdb400000
Simple Boot Flag at 0xf1 set to 0x1
audit: initializing netlink socket (disabled)
type=2000 audit(1292439886.925:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 7641
SELinux:  Registering netfilter hooks
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 0 1d 
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 0 1d 
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 0 1d 
\_SB_.PCI0:_OSC invalid UUID
_OSC request data:1 0 1d 
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
acpiphp: Slot [1] registered
pci-stub: invalid id string ""
ACPI: AC Adapter [AC] (off-line)
input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
ACPI: Lid Switch [LID]
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
ACPI: Power Button [PBTN]
input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
ACPI: Sleep Button [SBTN]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
ACPI: Power Button [PWRF]
ACPI: acpi_idle registered with cpuidle
Monitor-Mwait will be used to enter C-1 state
Monitor-Mwait will be used to enter C-2 state
Monitor-Mwait will be used to enter C-3 state
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
agpgart-intel 0000:00:00.0: Intel HD Graphics Chipset
agpgart-intel 0000:00:00.0: detected gtt size: 524288K total, 262144K mappable
agpgart-intel 0000:00:00.0: detected 32768K stolen memory
ACPI: Battery Slot [BAT0] (battery present)
agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
ACPI: Battery Slot [BAT1] (battery absent)
brd: module loaded
loop: module loaded
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ahci 0000:00:1f.2: irq 40 for MSI/MSI-X
ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 3 Gbps 0x33 impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems sxs apst 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 40
ata2: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 40
ata3: DUMMY
ata4: DUMMY
ata5: SATA max UDMA/133 abar m2048@0xf5440000 port 0xf5440300 irq 40
ata6: SATA max UDMA/133 abar m2048@0xf5440000 port 0xf5440380 irq 40
Fixed MDIO Bus: probed
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ehci_hcd 0000:00:1a.0: setting latency timer to 64
ehci_hcd 0000:00:1a.0: EHCI Host Controller
ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.0: debug port 2
ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1a.0: irq 16, io mem 0xf5470000
ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.37-rc5-mainline+ ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ehci_hcd 0000:00:1d.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
ehci_hcd 0000:00:1d.0: setting latency timer to 64
ehci_hcd 0000:00:1d.0: EHCI Host Controller
ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.0: debug port 2
ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1d.0: irq 17, io mem 0xf5450000
ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.37-rc5-mainline+ ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
uhci_hcd: USB Universal Host Controller Interface driver
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
i8042.c: Warning: Keylock active.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
rtc_cmos 00:06: RTC can wake from S4
rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one year, y3k, 242 bytes nvram, hpet irqs
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
Registering the dns_resolver key type
PM: Hibernation image not present or could not be loaded.
IMA: No TPM chip found, activating TPM-bypass!
  Magic number: 6:692:91
rtc_cmos 00:06: setting system clock to 2010-12-15 19:04:47 UTC (1292439887)
Initalizing network drop monitor service
ata6: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
usb 1-1: new high speed USB device using ehci_hcd and address 2
ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
ata2.00: ATAPI: MATSHITA DVD+/-RW UJ892, 1.04, max UDMA/100
ata1.00: ATA-7: SAMSUNG SSD PM800 2.5" 256GB, VBM24D1Q, max UDMA/100
ata1.00: 500118192 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
ata1.00: configured for UDMA/100
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG SSD PM80 VBM2 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
ata2.00: configured for UDMA/100
 sda: sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
usb 1-1: New USB device found, idVendor=8087, idProduct=0020
usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
hub 1-1:1.0: USB hub found
scsi 1:0:0:0: CD-ROM            MATSHITA DVD+-RW UJ892    1.04 PQ: 0 ANSI: 5
hub 1-1:1.0: 6 ports detected
sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sr 1:0:0:0: Attached scsi generic sg1 type 5
Freeing unused kernel memory: 924k freed
Write protecting the kernel read-only data: 10240k
Freeing unused kernel memory: 1672k freed
Freeing unused kernel memory: 1944k freed
dracut: dracut-005-5.fc13
dracut: rd_NO_LUKS: removing cryptoluks activation
udev: starting version 153
udevd (104): /proc/104/oom_adj is deprecated, please use /proc/104/oom_score_adj instead.
usb 2-1: new high speed USB device using ehci_hcd and address 2
[drm] Initialized drm 1.1.0 20060810
i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
i915 0000:00:02.0: setting latency timer to 64
usb 2-1: New USB device found, idVendor=8087, idProduct=0020
usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
hub 2-1:1.0: USB hub found
hub 2-1:1.0: 8 ports detected
i915 0000:00:02.0: irq 41 for MSI/MSI-X
vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
fbcon: inteldrmfb (fb0) is primary device
usb 1-1.4: new high speed USB device using ehci_hcd and address 3
[drm:ironlake_crtc_enable] *ERROR* failed to enable transcoder 0
Console: switching to colour frame buffer device 170x48
fb0: inteldrmfb frame buffer device
drm: registered panic notifier
usb 1-1.4: New USB device found, idVendor=0461, idProduct=4db1
usb 1-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-1.4: Product: Laptop_Integrated_Webcam_2M
usb 1-1.4: Manufacturer: CN0F5CWW7866406901WQA00
usb 2-1.8: new full speed USB device using ehci_hcd and address 3
usb 2-1.8: New USB device found, idVendor=0a5c, idProduct=5800
usb 2-1.8: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 2-1.8: Product: 5880
usb 2-1.8: Manufacturer: Broadcom Corp
usb 2-1.8: SerialNumber: 0123456789ABCD
usb 2-1.8: config 0 descriptor??
ACPI Exception: AE_TIME, Returned by Handler for [EmbeddedControl] (20101013/evregion-474)
ACPI Error: Method parse/execution failed [\_SB_.PCI0.LPCB.ECDV.ECR1] (Node ffff880113653be0), AE_TIME (20101013/psparse-537)
ACPI Error: Method parse/execution failed [\_SB_.PCI0.LPCB.ECDV.ECR2] (Node ffff880113653c08), AE_TIME (20101013/psparse-537)
ACPI Error: Method parse/execution failed [\ECRW] (Node ffff880113653d70), AE_TIME (20101013/psparse-537)
ACPI Error: Method parse/execution failed [\ECG1] (Node ffff880113653dc0), AE_TIME (20101013/psparse-537)
ACPI Error: Method parse/execution failed [\NEVT] (Node ffff880113655140), AE_TIME (20101013/psparse-537)
ACPI Error: Method parse/execution failed [\_SB_.PCI0.LPCB.ECDV._Q66] (Node ffff880113653bb8), AE_TIME (20101013/psparse-537)
acpi device:38: registered as cooling_device4
input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input5
ACPI: Video Device [VID] (multi-head: yes  rom: no  post: no)
[drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
input: PS/2 Generic Mouse as /devices/platform/i8042/serio1/input/input6
dracut: Starting plymouth daemon
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
sdhci-pci 0000:03:00.0: SDHCI controller found [1180:e822] (rev 1)
sdhci-pci 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
sdhci-pci 0000:03:00.0: Will use DMA mode even though HW doesn't fully claim to support it.
sdhci-pci 0000:03:00.0: setting latency timer to 64
Registered led device: mmc0::
mmc0: SDHCI controller on PCI [0000:03:00.0] using DMA
dracut: Scanning devices sda2  for LVM logical volumes vg_gavana/lv_root vg_gavana/lv_swap 
dracut: inactive '/dev/vg_gavana/lv_root' [50.00 GiB] inherit
dracut: inactive '/dev/vg_gavana/lv_home' [182.22 GiB] inherit
dracut: inactive '/dev/vg_gavana/lv_swap' [5.75 GiB] inherit
EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
dracut: Mounted root filesystem /dev/mapper/vg_gavana-lv_root
dracut: Loading SELinux policy
type=1404 audit(1292439892.295:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
SELinux: 2048 avtab hash slots, 205638 rules.
SELinux: 2048 avtab hash slots, 205638 rules.
SELinux:  9 users, 13 roles, 3365 types, 175 bools, 1 sens, 1024 cats
SELinux:  77 classes, 205638 rules
SELinux:  Permission read_policy in class security not defined in policy.
SELinux:  Permission audit_access in class file not defined in policy.
SELinux:  Permission audit_access in class dir not defined in policy.
SELinux:  Permission execmod in class dir not defined in policy.
SELinux:  Permission audit_access in class lnk_file not defined in policy.
SELinux:  Permission open in class lnk_file not defined in policy.
SELinux:  Permission execmod in class lnk_file not defined in policy.
SELinux:  Permission audit_access in class chr_file not defined in policy.
SELinux:  Permission audit_access in class blk_file not defined in policy.
SELinux:  Permission execmod in class blk_file not defined in policy.
SELinux:  Permission audit_access in class sock_file not defined in policy.
SELinux:  Permission execmod in class sock_file not defined in policy.
SELinux:  Permission audit_access in class fifo_file not defined in policy.
SELinux:  Permission execmod in class fifo_file not defined in policy.
SELinux: the above unknown classes and permissions will be allowed
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev devtmpfs, type devtmpfs), uses transition SIDs
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
SELinux: initialized (dev securityfs, type securityfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev dm-0, type ext4), uses xattr
type=1403 audit(1292439892.882:3): policy loaded auid=4294967295 ses=4294967295
dracut: 
dracut: Switching root
readahead: starting
udev: starting version 153
type=1400 audit(1292439894.129:4): avc:  denied  { mmap_zero } for  pid=412 comm="vbetool" scontext=system_u:system_r:vbetool_t:s0-s0:c0.c1023 tcontext=system_u:system_r:vbetool_t:s0-s0:c0.c1023 tclass=memprotect
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
iTCO_wdt: Found a QS57 TCO device (Version=2, TCOBASE=0x0460)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
input: PC Speaker as /devices/platform/pcspkr/input/input7
i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ACPI: resource 0000:00:1f.3 [io  0x6000-0x601f] conflicts with ACPI region SMBI [mem 0x00006000-0x0000600f disabled]
ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
wmi: Mapper loaded
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
microcode: CPU0 sig=0x20652, pf=0x10, revision=0x9
e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
e1000e 0000:00:19.0: setting latency timer to 64
e1000e 0000:00:19.0: irq 42 for MSI/MSI-X
input: Dell WMI hotkeys as /devices/virtual/input/input8
microcode: CPU1 sig=0x20652, pf=0x10, revision=0x9
microcode: CPU2 sig=0x20652, pf=0x10, revision=0x9
microcode: CPU3 sig=0x20652, pf=0x10, revision=0x9
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
cfg80211: Calling CRDA to update world regulatory domain
microcode: CPU0 updated to revision 0xc, date = 2010-06-10
microcode: CPU1 updated to revision 0xc, date = 2010-06-10
microcode: CPU2 updated to revision 0xc, date = 2010-06-10
microcode: CPU3 updated to revision 0xc, date = 2010-06-10
e1000e 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:26:b9:e0:54:fd
e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: 4041ff-0ff
HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
HDA Intel 0000:00:1b.0: irq 43 for MSI/MSI-X
HDA Intel 0000:00:1b.0: setting latency timer to 64
ALSA sound/pci/hda/hda_codec.c:4619: autoconfig: line_outs=1 (0xe/0x0/0x0/0x0/0x0)
ALSA sound/pci/hda/hda_codec.c:4623:    speaker_outs=1 (0xd/0x0/0x0/0x0/0x0)
ALSA sound/pci/hda/hda_codec.c:4627:    hp_outs=1 (0xb/0x0/0x0/0x0/0x0)
ALSA sound/pci/hda/hda_codec.c:4628:    mono: mono_out=0x0
ALSA sound/pci/hda/hda_codec.c:4632:    inputs:
ALSA sound/pci/hda/hda_codec.c:4638: 
ALSA sound/pci/hda/patch_sigmatel.c:3042: stac92xx: dac_nids=1 (0x13/0x0/0x0/0x0/0x0)
cfg80211: World regulatory domain updated:
    (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
    (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
    (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
    (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
    (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
    (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
input: HDA Intel Mic at Sep Left Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
input: HDA Intel Mic at Ext Left Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
input: HDA Intel Line Out at Sep Left Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input11
input: HDA Intel HP Out at Ext Left Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input12
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
iwlagn: Copyright(c) 2003-2010 Intel Corporation
iwlagn 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:02:00.0: setting latency timer to 64
iwlagn 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced-N 6200 AGN, REV=0x74
iwlagn 0000:02:00.0: device EEPROM VER=0x436, CALIB=0x6
iwlagn 0000:02:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
iwlagn 0000:02:00.0: irq 44 for MSI/MSI-X
iwlagn 0000:02:00.0: loaded firmware version 9.221.4.1 build 25532
cfg80211: Calling CRDA for country: RU
ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
cfg80211: Regulatory domain changed to country: RU
    (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
    (2402000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm)
    (5735000 KHz - 5835000 KHz @ 20000 KHz), (N/A, 3000 mBm)
EXT4-fs (dm-0): re-mounted. Opts: (null)
EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
SELinux: initialized (dev sda1, type ext4), uses xattr
EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
SELinux: initialized (dev dm-2, type ext4), uses xattr
Adding 6029308k swap on /dev/mapper/vg_gavana-lv_swap.  Priority:-1 extents:1 across:6029308k 
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
ip6_tables: (C) 2000-2006 Netfilter Core Team
e1000e 0000:00:19.0: irq 42 for MSI/MSI-X
e1000e 0000:00:19.0: irq 42 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth0: link is not ready
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
fuse init (API version 7.15)
SELinux: initialized (dev fuse, type fuse), uses genfs_contexts
wmi: Mapper unloaded
iwlagn 0000:02:00.0: PCI INT A disabled
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
iwlagn: Copyright(c) 2003-2010 Intel Corporation
iwlagn 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:02:00.0: setting latency timer to 64
iwlagn 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced-N 6200 AGN, REV=0x74
iwlagn 0000:02:00.0: device EEPROM VER=0x436, CALIB=0x6
iwlagn 0000:02:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
iwlagn 0000:02:00.0: irq 44 for MSI/MSI-X
iwlagn 0000:02:00.0: loaded firmware version 9.221.4.1 build 25532
ieee80211 phy1: Selected rate control algorithm 'iwl-agn-rs'
iwlagn 0000:02:00.0: PCI INT A disabled
iwlcore: Unknown parameter `debug'
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
iwlagn: Copyright(c) 2003-2010 Intel Corporation
ieee80211 phy2: U iwl_pci_probe *** LOAD DRIVER ***
iwlagn 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:02:00.0: setting latency timer to 64
ieee80211 phy2: U iwl_pci_probe pci_resource_len = 0x00002000
ieee80211 phy2: U iwl_pci_probe pci_resource_base = ffffc90005b14000
ieee80211 phy2: U iwl_hw_detect HW Revision ID = 0x35
iwlagn 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced-N 6200 AGN, REV=0x74
ieee80211 phy2: U iwl_prepare_card_hw iwl_prepare_card_hw enter
ieee80211 phy2: U iwl_set_hw_ready hardware ready
ieee80211 phy2: U iwl_eeprom_init NVM size = 2048
ieee80211 phy2: U iwl_apm_init Init card's basic functions
ieee80211 phy2: U iwl_eeprom_verify_signature EEPROM signature=0x00000001
ieee80211 phy2: U iwl_eeprom_init NVM Type: OTP, version: 0x436
ieee80211 phy2: U iwl_apm_stop Stop card, put in low power state
ieee80211 phy2: U iwl_apm_stop_master stop master
iwlagn 0000:02:00.0: device EEPROM VER=0x436, CALIB=0x6
ieee80211 phy2: U iwl_pci_probe MAC address: 00:27:10:46:ad:04
ieee80211 phy2: U iwlagn_set_rxon_chain rx_chain=0x240C active=2 idle=1
ieee80211 phy2: U iwl_init_channel_map Initializing regulatory info from EEPROM
ieee80211 phy2: U iwl_init_channel_map Parsing data for 56 channels.
ieee80211 phy2: U iwl_init_channel_map Ch. 1 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 2 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 3 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 4 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 5 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 6 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 7 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 8 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 9 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 10 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 11 [2.4GHz] VALID IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_init_channel_map Ch. 12 [2.4GHz] VALID WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 13 [2.4GHz] VALID WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 14 Flags 0 [2.4GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 183 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 184 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 185 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 187 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 188 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 189 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 192 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 196 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 7 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 8 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 11 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 12 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 16 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 34 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 36 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 38 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 40 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 42 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 44 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 46 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 48 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 52 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 56 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 60 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 64 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 100 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 104 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 108 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 112 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 116 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 120 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 124 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 128 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 132 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 136 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 140 [5.2GHz] VALID RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 145 Flags 0 [5.2GHz] - No traffic
ieee80211 phy2: U iwl_init_channel_map Ch. 149 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 153 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 157 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 161 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_init_channel_map Ch. 165 [5.2GHz] VALID WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 1 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 5 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 2 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 6 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 3 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 7 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 4 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 8 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 5 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 9 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 6 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 10 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 7 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 11 [2.4GHz] IBSS ACTIVE WIDE (0x6f 0dBm): Ad-Hoc supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 36 [5.2GHz] WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 40 [5.2GHz] WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 44 [5.2GHz] WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 48 [5.2GHz] WIDE DFS (0xe1 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 52 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 56 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 60 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 64 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 100 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 104 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 108 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 112 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 116 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 120 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 124 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 128 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 132 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 136 [5.2GHz] RADAR WIDE (0x31 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 149 [5.2GHz] WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 153 [5.2GHz] WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 157 [5.2GHz] WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_mod_ht40_chan_info HT40 Ch. 161 [5.2GHz] WIDE (0x61 0dBm): Ad-Hoc not supported
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 15 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 14 dB chain_c: 15 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 13 dB chain_c: 12 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 13 dB chain_c: 12 dB mimo2: 11 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 3 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 4 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 5 - chain_a: 0 dB chain_b: 15 dB chain_c: 15 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 6 - chain_a: 0 dB chain_b: 14 dB chain_c: 13 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 7 - chain_a: 0 dB chain_b: 13 dB chain_c: 12 dB mimo2: 11 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 9 dB chain_c: 9 dB mimo2: 8 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 11 dB chain_c: 11 dB mimo2: 9 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 11 dB chain_c: 11 dB mimo2: 9 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 3 - chain_a: 0 dB chain_b: 9 dB chain_c: 10 dB mimo2: 8 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 4 - chain_a: 0 dB chain_b: 14 dB chain_c: 13 dB mimo2: 11 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 15 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 15 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 3 - chain_a: 0 dB chain_b: 13 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 4 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 5 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 10 dB chain_c: 10 dB mimo2: 9 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 11 dB chain_c: 11 dB mimo2: 10 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 2 - chain_a: 0 dB chain_b: 13 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 13 dB chain_c: 13 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 14 dB chain_c: 13 dB mimo2: 11 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 0 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 0 - chain_a: 0 dB chain_b: 13 dB chain_c: 15 dB mimo2: 12 dB mimo3: 0 dB
ieee80211 phy2: U iwl_get_max_txpower_avg 1 - chain_a: 0 dB chain_b: 14 dB chain_c: 14 dB mimo2: 11 dB mimo3: 0 dB
ieee80211 phy2: U iwlcore_init_geos Channel 1 Freq=2412[2.4GHz] valid flag=0x20
ieee80211 phy2: U iwlcore_init_geos Channel 2 Freq=2417[2.4GHz] valid flag=0x20
ieee80211 phy2: U iwlcore_init_geos Channel 3 Freq=2422[2.4GHz] valid flag=0x20
ieee80211 phy2: U iwlcore_init_geos Channel 4 Freq=2427[2.4GHz] valid flag=0x20
ieee80211 phy2: U iwlcore_init_geos Channel 5 Freq=2432[2.4GHz] valid flag=0x0
ieee80211 phy2: U iwlcore_init_geos Channel 6 Freq=2437[2.4GHz] valid flag=0x0
ieee80211 phy2: U iwlcore_init_geos Channel 7 Freq=2442[2.4GHz] valid flag=0x0
ieee80211 phy2: U iwlcore_init_geos Channel 8 Freq=2447[2.4GHz] valid flag=0x10
ieee80211 phy2: U iwlcore_init_geos Channel 9 Freq=2452[2.4GHz] valid flag=0x10
ieee80211 phy2: U iwlcore_init_geos Channel 10 Freq=2457[2.4GHz] valid flag=0x10
ieee80211 phy2: U iwlcore_init_geos Channel 11 Freq=2462[2.4GHz] valid flag=0x10
ieee80211 phy2: U iwlcore_init_geos Channel 12 Freq=2467[2.4GHz] valid flag=0x36
ieee80211 phy2: U iwlcore_init_geos Channel 13 Freq=2472[2.4GHz] valid flag=0x36
ieee80211 phy2: U iwlcore_init_geos Channel 36 Freq=5180[5.2GHz] valid flag=0x26
ieee80211 phy2: U iwlcore_init_geos Channel 40 Freq=5200[5.2GHz] valid flag=0x16
ieee80211 phy2: U iwlcore_init_geos Channel 44 Freq=5220[5.2GHz] valid flag=0x26
ieee80211 phy2: U iwlcore_init_geos Channel 48 Freq=5240[5.2GHz] valid flag=0x16
ieee80211 phy2: U iwlcore_init_geos Channel 52 Freq=5260[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 56 Freq=5280[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 60 Freq=5300[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 64 Freq=5320[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 100 Freq=5500[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 104 Freq=5520[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 108 Freq=5540[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 112 Freq=5560[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 116 Freq=5580[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 120 Freq=5600[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 124 Freq=5620[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 128 Freq=5640[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 132 Freq=5660[5.2GHz] valid flag=0x2E
ieee80211 phy2: U iwlcore_init_geos Channel 136 Freq=5680[5.2GHz] valid flag=0x1E
ieee80211 phy2: U iwlcore_init_geos Channel 140 Freq=5700[5.2GHz] valid flag=0x3E
ieee80211 phy2: U iwlcore_init_geos Channel 149 Freq=5745[5.2GHz] valid flag=0x26
ieee80211 phy2: U iwlcore_init_geos Channel 153 Freq=5765[5.2GHz] valid flag=0x16
ieee80211 phy2: U iwlcore_init_geos Channel 157 Freq=5785[5.2GHz] valid flag=0x26
ieee80211 phy2: U iwlcore_init_geos Channel 161 Freq=5805[5.2GHz] valid flag=0x16
ieee80211 phy2: U iwlcore_init_geos Channel 165 Freq=5825[5.2GHz] valid flag=0x36
iwlagn 0000:02:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
iwlagn 0000:02:00.0: irq 44 for MSI/MSI-X
ieee80211 phy2: U iwl_request_firmware attempting to load firmware 'iwlwifi-6000-4.ucode'
ieee80211 phy2: U iwl_ucode_callback Loaded firmware file 'iwlwifi-6000-4.ucode' (454608 bytes).
iwlagn 0000:02:00.0: loaded firmware version 9.221.4.1 build 25532
ieee80211 phy2: U iwl_ucode_callback f/w package hdr ucode version raw = 0x9dd0401
ieee80211 phy2: U iwl_ucode_callback f/w package hdr runtime inst size = 145616
ieee80211 phy2: U iwl_ucode_callback f/w package hdr runtime data size = 81920
ieee80211 phy2: U iwl_ucode_callback f/w package hdr init inst size = 145124
ieee80211 phy2: U iwl_ucode_callback f/w package hdr init data size = 81920
ieee80211 phy2: U iwl_ucode_callback f/w package hdr boot inst size = 0
ieee80211 phy2: U iwl_ucode_callback Copying (but not loading) uCode instr len 145616
ieee80211 phy2: U iwl_ucode_callback uCode instr buf vaddr = 0xffff8800c91c0000, paddr = 0xc91c0000
ieee80211 phy2: U iwl_ucode_callback Copying (but not loading) uCode data len 81920
ieee80211 phy2: U iwl_ucode_callback Copying (but not loading) init instr len 145124
ieee80211 phy2: U iwl_ucode_callback Copying (but not loading) init data len 81920
ieee80211 phy2: U iwl_ucode_callback Copying (but not loading) boot instr len 0
ieee80211 phy2: Selected rate control algorithm 'iwl-agn-rs'
4: phy2: Wireless LAN
	Soft blocked: no
	Hard blocked: yes

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lspci

00:00.0 Host bridge: Intel Corporation Core Processor DRAM Controller (rev 02)
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>

00:02.0 VGA compatible controller: Intel Corporation Core Processor Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Dell Device 0410
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f0000000 (64-bit, non-prefetchable)
	Region 2: Memory at e0000000 (64-bit, prefetchable)
	Region 4: I/O ports at 60b0
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0500c  Data: 4169
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a4] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel modules: i915

00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 05)
	Subsystem: Dell Device 0410
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 5
	Region 0: Memory at f5400000 (32-bit, non-prefetchable)
	Region 1: Memory at f5480000 (32-bit, non-prefetchable)
	Region 2: I/O ports at 6040
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0400c  Data: 41a1
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel modules: e1000e

00:1a.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 05) (prog-if 20 [EHCI])
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f5470000 (32-bit, non-prefetchable)
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-

00:1b.0 Audio device: Intel Corporation Device 3b57 (rev 05)
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 3
	Region 0: Memory at f5460000 (64-bit, non-prefetchable)
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0500c  Data: 4189
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 1 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: f4000000-f53fffff
	Prefetchable memory behind bridge: 00000000fe900000-00000000feafffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Dell Device 0410
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel modules: shpchp

00:1c.1 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 2 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: f2c00000-f3ffffff
	Prefetchable memory behind bridge: 00000000fe700000-00000000fe8fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #1, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Dell Device 0410
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel modules: shpchp

00:1c.2 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 3 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f1800000-f2bfffff
	Prefetchable memory behind bridge: 00000000fe500000-00000000fe6fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #2, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Dell Device 0410
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel modules: shpchp

00:1c.3 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 4 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=09, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0400000-f17fffff
	Prefetchable memory behind bridge: 00000000fe300000-00000000fe4fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Dell Device 0410
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel modules: shpchp

00:1d.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 05) (prog-if 20 [EHCI])
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f5450000 (32-bit, non-prefetchable)
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev a5) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=0a, subordinate=0a, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Dell Device 0410

00:1f.0 ISA bridge: Intel Corporation 5 Series/3400 Series Chipset LPC Interface Controller (rev 05)
	Subsystem: Dell Device 0410
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=10 <?>
	Kernel modules: iTCO_wdt

00:1f.2 SATA controller: Intel Corporation 5 Series/3400 Series Chipset 6 port SATA AHCI Controller (rev 05) (prog-if 01 [AHCI 1.0])
	Subsystem: Dell Device 0410
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 10
	Region 0: I/O ports at 6090
	Region 1: I/O ports at 6080
	Region 2: I/O ports at 6070
	Region 3: I/O ports at 6060
	Region 4: I/O ports at 6020
	Region 5: Memory at f5440000 (32-bit, non-prefetchable)
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0500c  Data: 4161
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-

00:1f.3 SMBus: Intel Corporation 5 Series/3400 Series Chipset SMBus Controller (rev 05)
	Subsystem: Dell Device 0410
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin C routed to IRQ 10
	Region 0: Memory at f5430000 (64-bit, non-prefetchable)
	Region 4: I/O ports at 6000
	Kernel modules: i2c-i801

00:1f.6 Signal processing controller: Intel Corporation 5 Series/3400 Series Chipset Thermal Subsystem (rev 05)
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 10
	Region 0: Memory at f5420000 (64-bit, non-prefetchable)
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000

02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6200 (rev 35)
	Subsystem: Intel Corporation Centrino Advanced-N 6200 2x2 AGN
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f2c00000 (64-bit, non-prefetchable)
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 41b1
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <32us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel modules: iwlagn

03:00.0 SD Host controller: Ricoh Co Ltd Device e822 (rev 01)
	Subsystem: Dell Device 0410
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f1830000 (32-bit, non-prefetchable)
	Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [78] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [80] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <4us, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel modules: sdhci-pci


--vtzGhvizbBRQ85DL--
