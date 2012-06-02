From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: Network hangs on current git kernel
Date: Sat, 2 Jun 2012 13:27:18 +0200
Message-ID: <20120602112718.GB10145@x4>
References: <20120602082503.GC329@x4>
 <1338630610.2760.1695.camel@edumazet-glaptop>
 <20120602105747.GB28769@electric-eye.fr.zoreil.com>
 <1338635703.2760.1696.camel@edumazet-glaptop>
 <20120602112334.GA10145@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:37256 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab2FBL1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 07:27:20 -0400
Content-Disposition: inline
In-Reply-To: <20120602112334.GA10145@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012.06.02 at 13:23 +0200, Markus Trippelsdorf wrote:
> On 2012.06.02 at 13:15 +0200, Eric Dumazet wrote:
> > On Sat, 2012-06-02 at 12:57 +0200, Francois Romieu wrote:
> > > Eric Dumazet <eric.dumazet@gmail.com> :
> > > > On Sat, 2012-06-02 at 10:25 +0200, Markus Trippelsdorf wrote:
> > > [hang]
> > > > Maybe tell us what NIC it is, that sort of things...
> > > 
> > > As well as 'ip -s link' and complete dmesg from boot.

Oops, forget to include dmesg:

Linux version 3.4.0-09820-g86c47b7-dirty (markus@x4) (gcc version 4.7.1 20120423 (prerelease) (GCC) ) #50 SMP Fri Jun 1 22:25:38 CEST 2012
Command line: BOOT_IMAGE=/usr/src/linux/arch/x86/boot/bzImage root=PARTUUID=1E3384D0-CAE6-41BB-8CD6-4F640164EFD7 rootflags=logbsize=256k init=/sbin/minit fbcon=rotate:3 drm_kms_helper.poll=0 quiet
KERNEL supported cpus:
  AMD AuthenticAMD
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000e6000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x00000000dfe8ffff] usable
BIOS-e820: [mem 0x00000000dfe90000-0x00000000dfea7fff] ACPI data
BIOS-e820: [mem 0x00000000dfea8000-0x00000000dfecffff] ACPI NVS
BIOS-e820: [mem 0x00000000dfed0000-0x00000000dfefffff] reserved
BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
BIOS-e820: [mem 0x0000000100000000-0x000000021fffffff] usable
NX (Execute Disable) protection: active
DMI present.
DMI: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
e820: remove [mem 0x000a0000-0x000fffff] usable
e820: last_pfn = 0x220000 max_arch_pfn = 0x400000000
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
e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
e820: last_pfn = 0xdfe90 max_arch_pfn = 0x400000000
initial memory mapped: [mem 0x00000000-0x1fffffff]
Base memory trampoline at [ffff880000099000] 99000 size 24576
Using GB pages for direct mapping
init_memory_mapping: [mem 0x00000000-0xdfe8ffff]
 [mem 0x00000000-0xbfffffff] page 1G
 [mem 0xc0000000-0xdfdfffff] page 2M
 [mem 0xdfe00000-0xdfe8ffff] page 4k
kernel direct mapping tables up to 0xdfe8ffff @ [mem 0x1f9fd000-0x1fffffff]
init_memory_mapping: [mem 0x100000000-0x21fffffff]
 [mem 0x100000000-0x1ffffffff] page 1G
 [mem 0x200000000-0x21fffffff] page 2M
kernel direct mapping tables up to 0x21fffffff @ [mem 0xdf68e000-0xdfe8ffff]
ACPI: RSDP 00000000000fb880 00024 (v02 ACPIAM)
ACPI: XSDT 00000000dfe90100 0005C (v01 041311 XSDT1656 20110413 MSFT 00000097)
ACPI: FACP 00000000dfe90290 000F4 (v03 041311 FACP1656 20110413 MSFT 00000097)
ACPI Warning: Optional field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20120320/tbfadt-579)
ACPI: DSDT 00000000dfe90450 0E6FE (v01  A1152 A1152000 00000000 INTL 20060113)
ACPI: FACS 00000000dfea8000 00040
ACPI: APIC 00000000dfe90390 0007C (v01 041311 APIC1656 20110413 MSFT 00000097)
ACPI: MCFG 00000000dfe90410 0003C (v01 041311 OEMMCFG  20110413 MSFT 00000097)
ACPI: OEMB 00000000dfea8040 00072 (v01 041311 OEMB1656 20110413 MSFT 00000097)
ACPI: SRAT 00000000dfe9f450 000E8 (v01 AMD    FAM_F_10 00000002 AMD  00000001)
ACPI: HPET 00000000dfe9f540 00038 (v01 041311 OEMHPET  20110413 MSFT 00000097)
ACPI: SSDT 00000000dfe9f580 0088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00087fffff] PMD -> [ffff880217600000-ffff88021f5fffff] on node 0
Zone ranges:
  DMA      [mem 0x00010000-0x00ffffff]
  DMA32    [mem 0x01000000-0xffffffff]
  Normal   [mem 0x100000000-0x21fffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00010000-0x0009efff]
  node   0: [mem 0x00100000-0xdfe8ffff]
  node   0: [mem 0x100000000-0x21fffffff]
On node 0 totalpages: 2096671
  DMA zone: 64 pages used for memmap
  DMA zone: 6 pages reserved
  DMA zone: 3913 pages, LIFO batch:0
  DMA32 zone: 16320 pages used for memmap
  DMA32 zone: 896720 pages, LIFO batch:31
  Normal zone: 18432 pages used for memmap
  Normal zone: 1161216 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x84] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x85] disabled)
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
e820: [mem 0xdff00000-0xffefffff] available for PCI devices
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 23 pages/cpu @ffff88021fc00000 s72512 r0 d21696 u524288
pcpu-alloc: s72512 r0 d21696 u524288 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2061849
Kernel command line: BOOT_IMAGE=/usr/src/linux/arch/x86/boot/bzImage root=PARTUUID=1E3384D0-CAE6-41BB-8CD6-4F640164EFD7 rootflags=logbsize=256k init=/sbin/minit fbcon=rotate:3 drm_kms_helper.poll=0 quiet
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
__ex_table already sorted, skipping sort
Memory: 8167068k/8912896k available (5523k kernel code, 526212k absent, 219616k reserved, 3065k data, 440k init)
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Hierarchical RCU implementation.
NR_IRQS:4352 nr_irqs:712 16
Extended CMOS year: 2000
spurious 8259A interrupt: IRQ7.
Console: colour VGA+ 80x25
console [tty0] enabled
hpet clockevent registered
Fast TSC calibration using PIT
Detected 3211.072 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 6424.73 BogoMIPS (lpj=10703573)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
LVT offset 0 assigned for vector 0xf9
using AMD E400 aware idle routine
Freeing SMP alternatives: 20k freed
ACPI: Core revision 20120320
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Phenom(tm) II X4 955 Processor stepping 02
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
MCE: In-kernel MCE decoding enabled.
System has AMD C1E enabled
Switch to broadcast mode on CPU1
Switch to broadcast mode on CPU2
Booting Node   0, Processors  #1 #2 #3 Ok.
Brought up 4 CPUs
Total of 4 processors activated (25698.93 BogoMIPS).
Switch to broadcast mode on CPU3
Switch to broadcast mode on CPU0
devtmpfs: initialized
initlevel:0=early, 4 registered initcalls
initlevel:1=core, 19 registered initcalls
NET: Registered protocol family 16
initlevel:2=postcore, 10 registered initcalls
node 0 link 0: io port [1000, ffffff]
TOM: 00000000e0000000 aka 3584M
Fam 10h mmconf [mem 0xe0000000-0xefffffff]
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [e0000000, efffffff] ==> none
node 0 link 0: mmio [f0000000, fbcfffff]
node 0 link 0: mmio [fbd00000, fbefffff]
node 0 link 0: mmio [fbf00000, ffefffff]
TOM2: 0000000220000000 aka 8704M
bus: [00, 07] on node 0 link 0
bus: 00 [io  0x0000-0xffff]
bus: 00 [mem 0x000a0000-0x000bffff]
bus: 00 [mem 0xf0000000-0xffffffff]
bus: 00 [mem 0x220000000-0xfcffffffff]
initlevel:3=arch, 6 registered initcalls
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
PCI: Using configuration type 1 for extended access
initlevel:4=subsys, 36 registered initcalls
mtrr: your CPUs had inconsistent fixed MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
bio: create slab <bio-0> at 0
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: EC: Look up EC in DSDT
ACPI: Executed 3 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A03:00: host bridge window [mem 0x000d0000-0x000dffff]
pci_root PNP0A03:00: host bridge window [mem 0xdff00000-0xdfffffff]
pci_root PNP0A03:00: host bridge window [mem 0xf0000000-0xfebfffff]
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: root bus resource [mem 0xdff00000-0xdfffffff]
pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff]
pci 0000:00:00.0: [1022:9600] type 00 class 0x060000
pci 0000:00:01.0: [1022:9602] type 01 class 0x060400
pci 0000:00:06.0: [1022:9606] type 01 class 0x060400
pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
pci 0000:00:11.0: [1002:4391] type 00 class 0x010601
pci 0000:00:11.0: reg 10: [io  0xc000-0xc007]
pci 0000:00:11.0: reg 14: [io  0xb000-0xb003]
pci 0000:00:11.0: reg 18: [io  0xa000-0xa007]
pci 0000:00:11.0: reg 1c: [io  0x9000-0x9003]
pci 0000:00:11.0: reg 20: [io  0x8000-0x800f]
pci 0000:00:11.0: reg 24: [mem 0xfbcffc00-0xfbcfffff]
pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
pci 0000:00:12.0: reg 10: [mem 0xfbcfd000-0xfbcfdfff]
pci 0000:00:12.1: [1002:4398] type 00 class 0x0c0310
pci 0000:00:12.1: reg 10: [mem 0xfbcfe000-0xfbcfefff]
pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
pci 0000:00:12.2: reg 10: [mem 0xfbcff800-0xfbcff8ff]
pci 0000:00:12.2: supports D1 D2
pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
pci 0000:00:13.0: reg 10: [mem 0xfbcfb000-0xfbcfbfff]
pci 0000:00:13.1: [1002:4398] type 00 class 0x0c0310
pci 0000:00:13.1: reg 10: [mem 0xfbcfc000-0xfbcfcfff]
pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
pci 0000:00:13.2: reg 10: [mem 0xfbcff400-0xfbcff4ff]
pci 0000:00:13.2: supports D1 D2
pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
pci 0000:00:14.1: [1002:439c] type 00 class 0x01018a
pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 20: [io  0xff00-0xff0f]
pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
pci 0000:00:14.5: reg 10: [mem 0xfbcfa000-0xfbcfafff]
pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
pci 0000:01:05.0: [1002:9614] type 00 class 0x030000
pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff pref]
pci 0000:01:05.0: reg 14: [io  0xd000-0xd0ff]
pci 0000:01:05.0: reg 18: [mem 0xfbee0000-0xfbeeffff]
pci 0000:01:05.0: reg 24: [mem 0xfbd00000-0xfbdfffff]
pci 0000:01:05.0: supports D1 D2
pci 0000:01:05.1: [1002:960f] type 00 class 0x040300
pci 0000:01:05.1: reg 10: [mem 0xfbefc000-0xfbefffff]
pci 0000:01:05.1: supports D1 D2
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
pci 0000:02:00.0: [1969:1026] type 00 class 0x020000
pci 0000:02:00.0: reg 10: [mem 0xfbfc0000-0xfbffffff 64bit]
pci 0000:02:00.0: reg 18: [io  0xec00-0xec7f]
pci 0000:02:00.0: PME# supported from D3hot D3cold
pci 0000:00:06.0: PCI bridge to [bus 02-02]
pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4: PCI bridge to [bus 03-03] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xdff00000-0xdfffffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
 pci0000:00: Unable to request _OSC control (_OSC support mask: 0x19)
ACPI: PCI Interrupt Link [LNKA] (IRQs *4 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 4 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
SCSI subsystem initialized
libata version 3.00 loaded.
ACPI: bus type usb registered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
Advanced Linux Sound Architecture Driver Version 1.0.25.
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
e820: reserve RAM buffer [mem 0xdfe90000-0xdfffffff]
initlevel:5=fs, 23 registered initcalls
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
pnp 00:00: [mem 0xdff00000-0xdfffffff window]
pnp 00:00: [mem 0xf0000000-0xfebfffff window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:02: [dma 4]
pnp 00:02: [io  0x0000-0x000f]
pnp 00:02: [io  0x0081-0x0083]
pnp 00:02: [io  0x0087]
pnp 00:02: [io  0x0089-0x008b]
pnp 00:02: [io  0x008f]
pnp 00:02: [io  0x00c0-0x00df]
pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:03: [io  0x0070-0x0071]
pnp 00:03: [irq 8]
pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:04: [io  0x0061]
pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:05: [io  0x00f0-0x00ff]
pnp 00:05: [irq 13]
pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:06: [mem 0xfed00000-0xfed003ff]
pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:07: [io  0x0060]
pnp 00:07: [io  0x0064]
pnp 00:07: [mem 0xfec00000-0xfec00fff]
pnp 00:07: [mem 0xfee00000-0xfee00fff]
system 00:07: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:07: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:08: [io  0x0010-0x001f]
pnp 00:08: [io  0x0022-0x003f]
pnp 00:08: [io  0x0062-0x0063]
pnp 00:08: [io  0x0065-0x006f]
pnp 00:08: [io  0x0072-0x007f]
pnp 00:08: [io  0x0080]
pnp 00:08: [io  0x0084-0x0086]
pnp 00:08: [io  0x0088]
pnp 00:08: [io  0x008c-0x008e]
pnp 00:08: [io  0x0090-0x009f]
pnp 00:08: [io  0x00a2-0x00bf]
pnp 00:08: [io  0x00b1]
pnp 00:08: [io  0x00e0-0x00ef]
pnp 00:08: [io  0x04d0-0x04d1]
pnp 00:08: [io  0x040b]
pnp 00:08: [io  0x04d6]
pnp 00:08: [io  0x0c00-0x0c01]
pnp 00:08: [io  0x0c14]
pnp 00:08: [io  0x0c50-0x0c51]
pnp 00:08: [io  0x0c52]
pnp 00:08: [io  0x0c6c]
pnp 00:08: [io  0x0c6f]
pnp 00:08: [io  0x0cd0-0x0cd1]
pnp 00:08: [io  0x0cd2-0x0cd3]
pnp 00:08: [io  0x0cd4-0x0cd5]
pnp 00:08: [io  0x0cd6-0x0cd7]
pnp 00:08: [io  0x0cd8-0x0cdf]
pnp 00:08: [io  0x0b00-0x0b3f]
pnp 00:08: [io  0x0800-0x089f]
pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:08: [io  0x0b00-0x0b0f]
pnp 00:08: [io  0x0b20-0x0b3f]
pnp 00:08: [io  0x0900-0x090f]
pnp 00:08: [io  0x0910-0x091f]
pnp 00:08: [io  0xfe00-0xfefe]
pnp 00:08: [io  0x0060]
pnp 00:08: [io  0x0064]
pnp 00:08: [mem 0xdff00000-0xdfffffff]
pnp 00:08: [mem 0xffb80000-0xffbfffff]
pnp 00:08: [mem 0xfec10000-0xfec1001f]
system 00:08: [io  0x04d0-0x04d1] has been reserved
system 00:08: [io  0x040b] has been reserved
system 00:08: [io  0x04d6] has been reserved
system 00:08: [io  0x0c00-0x0c01] has been reserved
system 00:08: [io  0x0c14] has been reserved
system 00:08: [io  0x0c50-0x0c51] has been reserved
system 00:08: [io  0x0c52] has been reserved
system 00:08: [io  0x0c6c] has been reserved
system 00:08: [io  0x0c6f] has been reserved
system 00:08: [io  0x0cd0-0x0cd1] has been reserved
system 00:08: [io  0x0cd2-0x0cd3] has been reserved
system 00:08: [io  0x0cd4-0x0cd5] has been reserved
system 00:08: [io  0x0cd6-0x0cd7] has been reserved
system 00:08: [io  0x0cd8-0x0cdf] has been reserved
system 00:08: [io  0x0b00-0x0b3f] has been reserved
system 00:08: [io  0x0800-0x089f] has been reserved
system 00:08: [io  0x0b00-0x0b0f] has been reserved
system 00:08: [io  0x0b20-0x0b3f] has been reserved
system 00:08: [io  0x0900-0x090f] has been reserved
system 00:08: [io  0x0910-0x091f] has been reserved
system 00:08: [io  0xfe00-0xfefe] has been reserved
system 00:08: [mem 0xdff00000-0xdfffffff] has been reserved
system 00:08: [mem 0xffb80000-0xffbfffff] has been reserved
system 00:08: [mem 0xfec10000-0xfec1001f] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:09: [io  0x0230-0x023f]
pnp 00:09: [io  0x0290-0x029f]
pnp 00:09: [io  0x0f40-0x0f4f]
pnp 00:09: [io  0x0a30-0x0a3f]
system 00:09: [io  0x0230-0x023f] has been reserved
system 00:09: [io  0x0290-0x029f] has been reserved
system 00:09: [io  0x0f40-0x0f4f] has been reserved
system 00:09: [io  0x0a30-0x0a3f] has been reserved
system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0a: [mem 0xe0000000-0xefffffff]
system 00:0a: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0b: [mem 0x00000000-0x0009ffff]
pnp 00:0b: [mem 0x000c0000-0x000cffff]
pnp 00:0b: [mem 0x000e0000-0x000fffff]
pnp 00:0b: [mem 0x00100000-0xdfefffff]
pnp 00:0b: [mem 0xfec00000-0xffffffff]
system 00:0b: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:0b: [mem 0x000c0000-0x000cffff] could not be reserved
system 00:0b: [mem 0x000e0000-0x000fffff] could not be reserved
system 00:0b: [mem 0x00100000-0xdfefffff] could not be reserved
system 00:0b: [mem 0xfec00000-0xffffffff] could not be reserved
system 00:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
pci 0000:00:06.0: PCI bridge to [bus 02-02]
pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4: PCI bridge to [bus 03-03]
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 8 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:01: resource 1 [mem 0xfbd00000-0xfbefffff]
pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff 64bit pref]
pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
pci_bus 0000:02: resource 1 [mem 0xfbf00000-0xfbffffff]
pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:03: resource 8 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:03: resource 9 [mem 0xf0000000-0xfebfffff]
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP: reno registered
UDP hash table entries: 4096 (order: 5, 131072 bytes)
UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
NET: Registered protocol family 1
pci 0000:00:01.0: MSI quirk detected; subordinate MSI disabled
pci 0000:01:05.0: Boot video device
PCI: CLS 64 bytes, default 64
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
software IO TLB [mem 0xdb68e000-0xdf68dfff] (64MB) mapped at [ffff8800db68e000-ffff8800df68dfff]
initlevel:6=device, 193 registered initcalls
kvm: Nested Virtualization enabled
kvm: Nested Paging enabled
LVT offset 1 assigned for vector 0x400
IBS: LVT offset 1 assigned
perf: AMD IBS detected (0x0000001f)
microcode: CPU0: patch_level=0x010000c6
microcode: CPU1: patch_level=0x010000c6
microcode: CPU2: patch_level=0x010000c6
microcode: CPU3: patch_level=0x010000c6
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
SGI XFS with security attributes, large block/inode numbers, no debug enabled
Btrfs loaded
msgmni has been set to 15951
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered (default)
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: processor limited to max C-state 1
[drm] Initialized drm 1.1.0 20060810
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
[drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
[drm] register mmio base: 0xFBEE0000
[drm] register mmio size: 65536
ATOM BIOS: 113
radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
[drm] Detected VRAM RAM=128M, BAR=128M
[drm] RAM width 32bits DDR
[TTM] Zone  kernel: Available graphics memory: 4083544 kiB
[TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[TTM] Initializing pool allocator
[TTM] Initializing DMA pool allocator
[drm] radeon: 128M of VRAM memory ready
[drm] radeon: 512M of GTT memory ready.
[drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[drm] Driver supports precise vblank timestamp query.
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 131072, num gpu pages 131072
[drm] Loading RS780 Microcode
[drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
radeon 0000:01:05.0: WB enabled
radeon 0000:01:05.0: fence driver on ring 0 use gpu addr 0x00000000a0000c00 and cpu addr 0xffff88021622fc00
radeon 0000:01:05.0: setting latency timer to 64
[drm] ring test on 0 succeeded in 1 usecs
[drm] ib test on ring 0 succeeded in 0 usecs
[drm] Radeon Display Connectors
[drm] Connector 0:
[drm]   VGA-1
[drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[drm]   Encoders:
[drm]     CRT1: INTERNAL_KLDSCP_DAC1
[drm] Connector 1:
[drm]   DVI-D-1
[drm]   HPD3
[drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[drm]   Encoders:
[drm]     DFP3: INTERNAL_KLDSCP_LVTMA
[drm] radeon: power management initialized
[drm] fb mappable at 0xF0142000
[drm] vram apper at 0xF0000000
[drm] size 7299072
[drm] fb depth is 24
[drm]    pitch is 6912
fbcon: radeondrmfb (fb0) is primary device
Console: switching to colour frame buffer device 131x105
fb0: radeondrmfb frame buffer device
drm: registered panic notifier
[drm] Initialized radeon 2.15.0 20080528 for 0000:01:05.0 on minor 0
loop: module loaded
ahci 0000:00:11.0: version 3.0
ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd00 irq 22
ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 22
ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 22
ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 22
ata5: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff00 irq 22
ata6: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff80 irq 22
pata_atiixp 0000:00:14.1: setting latency timer to 64
scsi6 : pata_atiixp
scsi7 : pata_atiixp
ata7: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
ata8: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:12.2: EHCI Host Controller
ehci_hcd 0000:00:12.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
QUIRK: Enable AMD PLL fix
ehci_hcd 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:12.2: debug port 1
ehci_hcd 0000:00:12.2: irq 17, io mem 0xfbcff800
ehci_hcd 0000:00:12.2: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:13.2: EHCI Host Controller
ehci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
ehci_hcd 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:13.2: debug port 1
ehci_hcd 0000:00:13.2: irq 19, io mem 0xfbcff400
ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:12.0: OHCI Host Controller
ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:12.0: irq 16, io mem 0xfbcfd000
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 3 ports detected
ohci_hcd 0000:00:12.1: OHCI Host Controller
ohci_hcd 0000:00:12.1: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:12.1: irq 16, io mem 0xfbcfe000
ata7.00: ATAPI: HL-DT-STDVD-RAM GH22NP20, 1.03, max UDMA/66
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.0: irq 18, io mem 0xfbcfb000
ata7.00: configured for UDMA/66
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.1: irq 18, io mem 0xfbcfc000
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 3 ports detected
ohci_hcd 0000:00:14.5: OHCI Host Controller
ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 7
ohci_hcd 0000:00:14.5: irq 18, io mem 0xfbcfa000
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata1: SATA link down (SStatus 0 SControl 300)
ata3.00: ATA-8: OCZ VERTEX-TURBO, 1.7, max UDMA/133
ata3.00: 62533296 sectors, multi 1: LBA48 NCQ (depth 31/32), AA
ata2.00: ATA-8: ST1500DL003-9VT16L, CC32, max UDMA/133
ata2.00: 2930277168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
scsi 1:0:0:0: Direct-Access     ATA      ST1500DL003-9VT1 CC32 PQ: 0 ANSI: 5
sd 1:0:0:0: Attached scsi generic sg0 type 0
sd 1:0:0:0: [sda] 2930277168 512-byte logical blocks: (1.50 TB/1.36 TiB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
ata3.00: configured for UDMA/133
ata4.00: ATA-7: SAMSUNG HD103UJ, 1AA01118, max UDMA7
ata4.00: 1953525168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
ata4.00: configured for UDMA/133
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
usbcore: registered new interface driver usblp
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
i8042: PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:03: RTC can wake from S4
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
i2c /dev entries driver
EDAC MC: Ver: 2.1.0
AMD64 EDAC driver v3.4.0
EDAC amd64: DRAM ECC enabled.
EDAC amd64: F10h detected (node 0).
EDAC MC: DCT0 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC MC: DCT1 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC amd64: using x4 syndromes.
EDAC amd64: MCT channel count: 2
EDAC amd64: CS0: Unbuffered DDR3 RAM
EDAC amd64: CS1: Unbuffered DDR3 RAM
EDAC amd64: CS2: Unbuffered DDR3 RAM
EDAC amd64: CS3: Unbuffered DDR3 RAM
EDAC MC0: Giving out device to 'amd64_edac' 'F10h': DEV 0000:00:18.2
EDAC PCI0: Giving out device to module 'amd64_edac' controller 'EDAC PCI controller': DEV '0000:00:18.2' (POLLED)
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
usbcore: registered new interface driver snd-usb-audio
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP: cubic registered
NET: Registered protocol family 17
initlevel:7=late, 27 registered initcalls
registered taskstats version 1
 sda: sda1 sda2 sda3
sd 1:0:0:0: [sda] Attached SCSI disk
rtc_cmos 00:03: setting system clock to 2012-06-02 03:15:57 UTC (1338606957)
powernow-k8: Found 1 AMD Phenom(tm) II X4 955 Processor (4 cpu cores) (version 2.20.00)
scsi 2:0:0:0: Direct-Access     ATA      OCZ VERTEX-TURBO 1.7  PQ: 0 ANSI: 5
powernow-k8:    0 : pstate 0 (3200 MHz)
powernow-k8:    1 : pstate 1 (2500 MHz)
powernow-k8:    2 : pstate 2 (2100 MHz)
powernow-k8:    3 : pstate 3 (800 MHz)
sd 2:0:0:0: [sdb] 62533296 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 2:0:0:0: Attached scsi generic sg1 type 0
sd 2:0:0:0: [sdb] Write Protect is off
sd 2:0:0:0: [sdb] Mode Sense: 00 3a 00 00
ALSA device list:
  No soundcards found.
sd 2:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2
sd 2:0:0:0: [sdb] Attached SCSI disk
scsi 3:0:0:0: Direct-Access     ATA      SAMSUNG HD103UJ  1AA0 PQ: 0 ANSI: 5
sd 3:0:0:0: [sdc] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 3:0:0:0: Attached scsi generic sg2 type 0
sd 3:0:0:0: [sdc] Write Protect is off
sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1
sd 3:0:0:0: [sdc] Attached SCSI disk
scsi 6:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GH22NP20 1.03 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 6:0:0:0: Attached scsi CD-ROM sr0
sr 6:0:0:0: Attached scsi generic sg3 type 5
XFS (sdb2): Mounting Filesystem
XFS (sdb2): Ending clean mount
VFS: Mounted root (xfs filesystem) readonly on device 8:18.
devtmpfs: mounted
Freeing unused kernel memory: 440k freed
Write protecting the kernel read-only data: 8192k
Freeing unused kernel memory: 608k freed
Freeing unused kernel memory: 220k freed
device fsid 3f2b2b67-8b3a-4c83-a994-080844e9244d devid 1 transid 27706 /dev/sda1
usb 4-1: new full-speed USB device number 2 using ohci_hcd
device fsid 3f2b2b67-8b3a-4c83-a994-080844e9244d devid 2 transid 27706 /dev/sdc1
Refined TSC clocksource calibration: 3210.827 MHz.
Switching to clocksource tsc
input: C-Media USB Headphone Set   as /devices/pci0000:00/0000:00:12.1/usb4/4-1/4-1:1.3/input/input2
hid-generic 0003:0D8C:000C.0001: input,hidraw0: USB HID v1.00 Device [C-Media USB Headphone Set  ] on usb-0000:00:12.1-1/input3
device fsid 3f2b2b67-8b3a-4c83-a994-080844e9244d devid 1 transid 27706 /dev/sda1
btrfs: use lzo compression
btrfs: disk space caching is enabled
btrfs: bdev /dev/sdc1 errs: wr 0, rd 0, flush 0, corrupt 0, gen 0
btrfs: bdev /dev/sda1 errs: wr 0, rd 0, flush 0, corrupt 0, gen 0
usb 4-2: new full-speed USB device number 3 using ohci_hcd
logitech-djreceiver 0003:046D:C52B.0004: hiddev0,hidraw1: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:12.1-2/input2
input: Logitech Unifying Device. Wireless PID:101b as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.2/0003:046D:C52B.0004/input/input3
logitech-djdevice 0003:046D:C52B.0005: input,hidraw2: USB HID v1.11 Mouse [Logitech Unifying Device. Wireless PID:101b] on usb-0000:00:12.1-2:1
usb 4-3: new low-speed USB device number 4 using ohci_hcd
input: HID 046a:0011 as /devices/pci0000:00/0000:00:12.1/usb4/4-3/4-3:1.0/input/input4
hid-generic 0003:046A:0011.0006: input,hidraw3: USB HID v1.10 Keyboard [HID 046a:0011] on usb-0000:00:12.1-3/input0
ATL1E 0000:02:00.0: irq 40 for MSI/MSI-X
ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
microcode: CPU0: new patch_level=0x010000db
microcode: CPU1: new patch_level=0x010000db
microcode: CPU2: new patch_level=0x010000db
microcode: CPU3: new patch_level=0x010000db
Adding 1953788k swap on /dev/sda2.  Priority:-1 extents:1 across:1953788k 

-- 
Markus
