From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e100 REGRESSION in 2.6.32
Date: Wed, 16 Dec 2009 10:21:31 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0912160938450.5316@jbrandeb-desk1.amr.corp.intel.com>
References: <Pine.LNX.4.44L0.0912151712560.2643-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, "Allan, Bruce W" <bruce.w.allan@intel.com>,
	Kernel development list <linux-kernel@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alan Stern <stern@rowland.harvard.edu>,
	Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44L0.0912151712560.2643-100000@iolanthe.rowland.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


copied the netdev mailing list.  Alan thanks for the report, I wonder if =

you can revert 98468efddb101f8a29af974101c17ba513b07be1 and see if that =

fixes it?

Roger on the To: line made that change, which may have broken e100 for =

your system.

On Tue, 15 Dec 2009, Alan Stern wrote:

> Below is a dmesg log showing bootup, followed by Alt-SysRq-9 (at
> timestamp 83.426209), and immediately thereafter "ifconfig eth0 down".
> As you can see, the ifconfig ran for a full minute and provoked a bunch
> of slab errors.
> =

> Alan Stern
> =

> =

> =

> [    0.000000] Linux version 2.6.32 (stern@iolanthe.rowland.org) (gcc ver=
sion 4.3.2 20081105 (Red Hat 4.3.2-7) (GCC) ) #1 SMP PREEMPT Mon Dec 7 11:5=
3:37 EST 2009
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   Intel GenuineIntel
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   NSC Geode by NSC
> [    0.000000]   Cyrix CyrixInstead
> [    0.000000]   Centaur CentaurHauls
> [    0.000000]   Transmeta GenuineTMx86
> [    0.000000]   Transmeta TransmetaCPU
> [    0.000000]   UMC UMC UMC UMC
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
> [    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000002fe40000 (usable)
> [    0.000000]  BIOS-e820: 000000002fe40000 - 000000002fe50000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000002fe50000 - 000000002ff00000 (ACPI NVS)
> [    0.000000] DMI 2.3 present.
> [    0.000000] last_pfn =3D 0x2fe40 max_arch_pfn =3D 0x100000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-DFFFF uncachable
> [    0.000000]   E0000-FFFFF write-back
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 000000000 mask FE0000000 write-back
> [    0.000000]   1 base 020000000 mask FF0000000 write-back
> [    0.000000]   2 base 02FF00000 mask FFFF00000 uncachable
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] initial memory mapped : 0 - 01c00000
> [    0.000000] init_memory_mapping: 0000000000000000-000000002fe40000
> [    0.000000]  0000000000 - 0000400000 page 4k
> [    0.000000]  0000400000 - 002fc00000 page 2M
> [    0.000000]  002fc00000 - 002fe40000 page 4k
> [    0.000000] kernel direct mapping tables up to 2fe40000 @ 7000-c000
> [    0.000000] RAMDISK: 2fb31000 - 2fe2fafc
> [    0.000000] ACPI: RSDP 000f7300 00014 (v00 ACPIAM)
> [    0.000000] ACPI: RSDT 2fe40000 00030 (v01 INTEL  D845GBV2 20030714 MS=
FT 00000097)
> [    0.000000] ACPI: FACP 2fe40200 00081 (v02 INTEL  D845GBV2 20030714 MS=
FT 00000097)
> [    0.000000] ACPI: DSDT 2fe40370 03FD7 (v01 INTEL  D845GBV2 0000010A MS=
FT 0100000D)
> [    0.000000] ACPI: FACS 2fe50000 00040
> [    0.000000] ACPI: APIC 2fe40300 00068 (v01 INTEL  D845GBV2 20030714 MS=
FT 00000097)
> [    0.000000] ACPI: ASF! 2fe44350 00084 (v16 AMIASF I845GASF 00000001 MS=
FT 0100000D)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] 766MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 2fe40000
> [    0.000000]   low ram: 0 - 2fe40000
> [    0.000000]   node 0 low ram: 00000000 - 2fe40000
> [    0.000000]   node 0 bootmap 00008000 - 0000dfc8
> [    0.000000] (9 early reservations) =3D=3D> bootmem [0000000000 - 002fe=
40000]
> [    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0=
000000000 - 0000001000]
> [    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE =3D=3D> [0=
000001000 - 0000002000]
> [    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE =3D=3D> [0=
000006000 - 0000007000]
> [    0.000000]   #3 [0001000000 - 000187119c]    TEXT DATA BSS =3D=3D> [0=
001000000 - 000187119c]
> [    0.000000]   #4 [002fb31000 - 002fe2fafc]          RAMDISK =3D=3D> [0=
02fb31000 - 002fe2fafc]
> [    0.000000]   #5 [000009fc00 - 0000100000]    BIOS reserved =3D=3D> [0=
00009fc00 - 0000100000]
> [    0.000000]   #6 [0001872000 - 0001879178]              BRK =3D=3D> [0=
001872000 - 0001879178]
> [    0.000000]   #7 [0000007000 - 0000008000]          PGTABLE =3D=3D> [0=
000007000 - 0000008000]
> [    0.000000]   #8 [0000008000 - 000000e000]          BOOTMAP =3D=3D> [0=
000008000 - 000000e000]
> [    0.000000] found SMP MP-table at [c00ff780] ff780
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000000 -> 0x00001000
> [    0.000000]   Normal   0x00001000 -> 0x0002fe40
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[2] active PFN ranges
> [    0.000000]     0: 0x00000000 -> 0x0000009f
> [    0.000000]     0: 0x00000100 -> 0x0002fe40
> [    0.000000] On node 0 totalpages: 196063
> [    0.000000] free_area_init_node: node 0, pgdat c12ef820, node_mem_map =
c187a000
> [    0.000000]   DMA zone: 52 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3947 pages, LIFO batch:0
> [    0.000000]   Normal zone: 2439 pages used for memmap
> [    0.000000]   Normal zone: 189625 pages, LIFO batch:31
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x408
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x81] disabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI =
0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] SMP: Allowing 2 CPUs, 1 hotplug CPUs
> [    0.000000] nr_irqs_gsi: 24
> [    0.000000] PM: Registered nosave memory: 000000000009f000 - 000000000=
00a0000
> [    0.000000] PM: Registered nosave memory: 00000000000a0000 - 000000000=
00e0000
> [    0.000000] PM: Registered nosave memory: 00000000000e0000 - 000000000=
0100000
> [    0.000000] Allocating PCI resources starting at 2ff00000 (gap: 2ff000=
00:d0100000)
> [    0.000000] NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 13 pages/cpu @c2400000 s30936 r0 d22312 u=
2097152
> [    0.000000] pcpu-alloc: s30936 r0 d22312 u2097152 alloc=3D1*4194304
> [    0.000000] pcpu-alloc: [0] 0 1
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 193572
> [    0.000000] Kernel command line: ro root=3DUUID=3D38b19631-670b-4ec8-b=
e1a-a65458d523ae resume=3D/dev/hda7 no_console_suspend
> [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
> [    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 =
bytes)
> [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 by=
tes)
> [    0.000000] Enabling fast FPU save and restore... done.
> [    0.000000] Enabling unmasked SIMD FPU exception support... done.
> [    0.000000] Initializing CPU#0
> [    0.000000] Memory: 761180k/784640k available (1848k kernel code, 2270=
0k reserved, 1171k data, 284k init, 0k highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xfff1f000 - 0xfffff000   ( 896 kB)
> [    0.000000]     vmalloc : 0xf0640000 - 0xfff1d000   ( 248 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xefe40000   ( 766 MB)
> [    0.000000]       .init : 0xc12f4000 - 0xc133b000   ( 284 kB)
> [    0.000000]       .data : 0xc11ce2b2 - 0xc12f3208   (1171 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc11ce2b2   (1848 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supe=
rvisor mode...Ok.
> [    0.000000] SLUB: Genslabs=3D13, HWalign=3D128, Order=3D0-3, MinObject=
s=3D0, CPUs=3D2, Nodes=3D1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] NR_IRQS:512
> [    0.000000] CPU 0 irqstacks, hard=3Dc2400000 soft=3Dc2401000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc=
., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
> [    0.000000] ... CHAINHASH_SIZE:          16384
> [    0.000000]  memory used by lock dependency info: 3567 kB
> [    0.000000]  per task-struct memory footprint: 1152 bytes
> [    0.000000] Fast TSC calibration failed
> [    0.000000] TSC: PIT calibration matches PMTIMER. 1 loops
> [    0.000000] Detected 1799.793 MHz processor.
> [    0.008070] Calibrating delay loop (skipped), value calculated using t=
imer frequency.. 3599.58 BogoMIPS (lpj=3D7199172)
> [    0.008562] Mount-cache hash table entries: 512
> [    0.014269] CPU: Trace cache: 12K uops, L1 D cache: 8K
> [    0.014401] CPU: L2 cache: 512K
> [    0.014487] CPU: Hyper-Threading is disabled
> [    0.014578] mce: CPU supports 4 MCE banks
> [    0.014724] Checking 'hlt' instruction... OK.
> [    0.028543] lockdep: fixing up alternatives.
> [    0.028634] SMP alternatives: switching to UP code
> [    0.033810] ACPI: Core revision 20090903
> [    0.066817] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=
=3D-1
> [    0.106613] CPU0: Intel(R) Pentium(R) 4 CPU 1.80GHz stepping 07
> [    0.108001] Brought up 1 CPUs
> [    0.108001] Total of 1 processors activated (3599.58 BogoMIPS).
> [    0.110100] NET: Registered protocol family 16
> [    0.112778] ACPI: bus type pci registered
> [    0.113776] PCI: PCI BIOS revision 2.10 entry at 0xf0031, last bus=3D1
> [    0.113874] PCI: Using configuration type 1 for base access
> [    0.128183] bio: create slab <bio-0> at 0
> [    0.136432] ACPI: EC: Look up EC in DSDT
> [    0.149864] ACPI: Executed 2 blocks of module-level executable AML code
> [    0.184177] ACPI: Interpreter enabled
> [    0.184281] ACPI: (supports S0 S1 S3 S4 S5)
> [    0.184862] ACPI: Using IOAPIC for interrupt routing
> [    0.239819] ACPI: Power Resource [URP1] (off)
> [    0.240281] ACPI: Power Resource [FDDP] (off)
> [    0.240551] ACPI: Power Resource [LPTP] (off)
> [    0.241864] ACPI: PCI Root Bridge [PCI0] (0000:00)
> [    0.242662] pci 0000:00:00.0: reg 10 32bit mmio pref: [0xf8000000-0xfb=
ffffff]
> [    0.242899] pci 0000:00:02.0: reg 10 32bit mmio pref: [0xf0000000-0xf7=
ffffff]
> [    0.242916] pci 0000:00:02.0: reg 14 32bit mmio: [0xffa80000-0xffaffff=
f]
> [    0.243179] pci 0000:00:1d.0: reg 20 io port: [0xe800-0xe81f]
> [    0.243306] pci 0000:00:1d.1: reg 20 io port: [0xe880-0xe89f]
> [    0.243430] pci 0000:00:1d.2: reg 20 io port: [0xec00-0xec1f]
> [    0.243590] pci 0000:00:1d.7: reg 10 32bit mmio: [0xffa7fc00-0xffa7fff=
f]
> [    0.243711] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
> [    0.243812] pci 0000:00:1d.7: PME# disabled
> [    0.244179] * The chipset may have PM-Timer Bug. Due to workarounds fo=
r a bug,
> [    0.244182] * this clock source is slow. If you are sure your timer do=
es not have
> [    0.244184] * this bug, please use "acpi_pm_good" to disable the worka=
round
> [    0.244628] pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH4 =
ACPI/GPIO/TCO
> [    0.244768] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH4 =
GPIO
> [    0.244948] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
> [    0.244965] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
> [    0.244980] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
> [    0.244995] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
> [    0.245011] pci 0000:00:1f.1: reg 20 io port: [0xffa0-0xffaf]
> [    0.245026] pci 0000:00:1f.1: reg 24 32bit mmio: [0x000000-0x0003ff]
> [    0.245148] pci 0000:00:1f.3: reg 20 io port: [0xe000-0xe01f]
> [    0.245258] pci 0000:00:1f.5: reg 10 io port: [0xe400-0xe4ff]
> [    0.245273] pci 0000:00:1f.5: reg 14 io port: [0xe080-0xe0bf]
> [    0.245289] pci 0000:00:1f.5: reg 18 32bit mmio: [0xffa7f800-0xffa7f9f=
f]
> [    0.245304] pci 0000:00:1f.5: reg 1c 32bit mmio: [0xffa7f400-0xffa7f4f=
f]
> [    0.245374] pci 0000:00:1f.5: PME# supported from D0 D3hot D3cold
> [    0.245471] pci 0000:00:1f.5: PME# disabled
> [    0.245655] pci 0000:01:00.0: reg 10 32bit mmio: [0xff8fd000-0xff8fdff=
f]
> [    0.245756] pci 0000:01:00.0: supports D1 D2
> [    0.245761] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot
> [    0.245857] pci 0000:01:00.0: PME# disabled
> [    0.246018] pci 0000:01:00.1: reg 10 32bit mmio: [0xff8fe000-0xff8feff=
f]
> [    0.246117] pci 0000:01:00.1: supports D1 D2
> [    0.246122] pci 0000:01:00.1: PME# supported from D0 D1 D2 D3hot
> [    0.246219] pci 0000:01:00.1: PME# disabled
> [    0.246379] pci 0000:01:00.2: reg 10 32bit mmio: [0xff8ffc00-0xff8ffcf=
f]
> [    0.246478] pci 0000:01:00.2: supports D1 D2
> [    0.246483] pci 0000:01:00.2: PME# supported from D0 D1 D2 D3hot
> [    0.246580] pci 0000:01:00.2: PME# disabled
> [    0.246793] pci 0000:01:01.0: reg 20 io port: [0xd880-0xd89f]
> [    0.246965] pci 0000:01:01.1: reg 20 io port: [0xdc00-0xdc1f]
> [    0.247099] pci 0000:01:01.2: reg 10 32bit mmio: [0xff8ff800-0xff8ff8f=
f]
> [    0.247200] pci 0000:01:01.2: PME# supported from D0 D3hot
> [    0.247297] pci 0000:01:01.2: PME# disabled
> [    0.247451] pci 0000:01:02.0: reg 10 32bit mmio: [0xff8e0000-0xff8efff=
f]
> [    0.247467] pci 0000:01:02.0: reg 14 32bit mmio pref: [0xe6af0000-0xe6=
afffff]
> [    0.247483] pci 0000:01:02.0: reg 18 32bit mmio: [0xff8d0000-0xff8dfff=
f]
> [    0.247622] pci 0000:01:08.0: reg 10 32bit mmio: [0xff8fc000-0xff8fcff=
f]
> [    0.247639] pci 0000:01:08.0: reg 14 io port: [0xd800-0xd83f]
> [    0.247729] pci 0000:01:08.0: supports D1 D2
> [    0.247733] pci 0000:01:08.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.247831] pci 0000:01:08.0: PME# disabled
> [    0.248022] pci 0000:00:1e.0: transparent bridge
> [    0.248118] pci 0000:00:1e.0: bridge io port: [0xd000-0xdfff]
> [    0.248129] pci 0000:00:1e.0: bridge 32bit mmio: [0xff800000-0xff8ffff=
f]
> [    0.248140] pci 0000:00:1e.0: bridge 32bit mmio pref: [0xe6a00000-0xe6=
afffff]
> [    0.248162] pci_bus 0000:00: on NUMA node 0
> [    0.248185] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> [    0.249208] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
> [    0.274286] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 1=
2 14 15)
> [    0.275611] ACPI: PCI Interrupt Link [LNKB] (IRQs *3 4 5 6 7 9 10 11 1=
2 14 15)
> [    0.277147] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 1=
2 14 15)
> [    0.278456] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 1=
2 14 15)
> [    0.279761] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11 1=
2 14 15)
> [    0.281193] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 1=
2 14 15)
> [    0.282501] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11 1=
2 14 15)
> [    0.283807] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11 1=
2 14 15)
> [    0.286614] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,ow=
ns=3Dio+mem,locks=3Dnone
> [    0.286876] vgaarb: loaded
> [    0.287914] PCI: Using ACPI for IRQ routing
> [    0.290136] Switching to clocksource tsc
> [    0.293345] pnp: PnP ACPI init
> [    0.293510] ACPI: bus type pnp registered
> [    0.316258] pnp: PnP ACPI: found 14 devices
> [    0.316355] ACPI: ACPI bus type pnp unregistered
> [    0.316502] system 00:05: ioport range 0x4d0-0x4d1 has been reserved
> [    0.316649] system 00:0c: ioport range 0x400-0x47f has been reserved
> [    0.316748] system 00:0c: ioport range 0x680-0x6ff has been reserved
> [    0.316846] system 00:0c: ioport range 0x480-0x4bf has been reserved
> [    0.316951] system 00:0c: iomem range 0xfec00000-0xfec00fff could not =
be reserved
> [    0.317091] system 00:0c: iomem range 0xfee00000-0xfee00fff has been r=
eserved
> [    0.317218] system 00:0d: iomem range 0x0-0x9ffff could not be reserved
> [    0.317322] system 00:0d: iomem range 0xc0000-0xdffff could not be res=
erved
> [    0.317424] system 00:0d: iomem range 0xe0000-0xfffff could not be res=
erved
> [    0.317527] system 00:0d: iomem range 0x100000-0x2fefffff could not be=
 reserved
> [    0.355623] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:01
> [    0.355725] pci 0000:00:1e.0:   IO window: 0xd000-0xdfff
> [    0.355825] pci 0000:00:1e.0:   MEM window: 0xff800000-0xff8fffff
> [    0.355924] pci 0000:00:1e.0:   PREFETCH window: 0xe6a00000-0xe6afffff
> [    0.356043] pci 0000:00:1e.0: setting latency timer to 64
> [    0.356056] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
> [    0.356062] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
> [    0.356068] pci_bus 0000:01: resource 0 io:  [0xd000-0xdfff]
> [    0.356074] pci_bus 0000:01: resource 1 mem: [0xff800000-0xff8fffff]
> [    0.356080] pci_bus 0000:01: resource 2 pref mem [0xe6a00000-0xe6affff=
f]
> [    0.356085] pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
> [    0.356091] pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffff]
> [    0.356250] NET: Registered protocol family 2
> [    0.356889] IP route cache hash table entries: 32768 (order: 5, 131072=
 bytes)
> [    0.358880] TCP established hash table entries: 131072 (order: 8, 1048=
576 bytes)
> [    0.360659] TCP bind hash table entries: 65536 (order: 9, 2097152 byte=
s)
> [    0.372656] TCP: Hash tables configured (established 131072 bind 65536)
> [    0.372867] TCP reno registered
> [    0.373478] NET: Registered protocol family 1
> [    0.373651] pci 0000:00:02.0: Boot video device
> [    0.373672] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup =3D 0x0f=
30
> [    0.373678] pci 0000:00:1d.0: Performing full reset
> [    0.373711] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup =3D 0x00=
30
> [    0.373716] pci 0000:00:1d.1: Performing full reset
> [    0.373746] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup =3D 0x00=
30
> [    0.373751] pci 0000:00:1d.2: Performing full reset
> [    0.373808] pci 0000:00:1d.7: EHCI: BIOS handoff
> [    1.972030] pci 0000:00:1d.7: EHCI: BIOS handoff failed (BIOS bug?) 01=
010001
> [    1.972372] pci 0000:01:01.0: uhci_check_and_reset_hc: legsup =3D 0x20=
00
> [    1.972377] pci 0000:01:01.0: Performing full reset
> [    1.972407] pci 0000:01:01.1: uhci_check_and_reset_hc: legsup =3D 0x20=
00
> [    1.972412] pci 0000:01:01.1: Performing full reset
> [    1.972486] pci 0000:01:08.0: Firmware left e100 interrupts enabled; d=
isabling
> [    1.973509] Trying to unpack rootfs image as initramfs...
> [    2.206913] Freeing initrd memory: 3066k freed
> [    2.260579] msgmni has been set to 1493
> [    2.264602] alg: No test for stdrng (krng)
> [    2.264916] io scheduler noop registered
> [    2.265006] io scheduler anticipatory registered
> [    2.265094] io scheduler deadline registered
> [    2.266020] io scheduler cfq registered (default)
> [    2.305288] Real Time Clock Driver v1.12b
> [    2.306075] Linux agpgart interface v0.103
> [    2.306314] agpgart-intel 0000:00:00.0: Intel 830M Chipset
> [    2.306620] agpgart-intel 0000:00:00.0: detected 892K stolen memory
> [    2.310132] agpgart-intel 0000:00:00.0: AGP aperture is 128M @ 0xf0000=
000
> [    2.310947] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> [    2.311726] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> [    2.316356] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> [    2.331899] brd: module loaded
> [    2.332288] Uniform Multi-Platform E-IDE driver
> [    2.333055] piix 0000:00:1f.1: IDE controller (0x8086:0x24cb rev 0x02)
> [    2.333171] PIIX_IDE 0000:00:1f.1: enabling device (0005 -> 0007)
> [    2.333291] PIIX_IDE 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) ->=
 IRQ 18
> [    2.333618] piix 0000:00:1f.1: not 100% native mode: will probe irqs l=
ater
> [    2.333723]     ide0: BM-DMA at 0xffa0-0xffa7
> [    2.333826]     ide1: BM-DMA at 0xffa8-0xffaf
> [    2.333926] Probing IDE interface ide0...
> [    2.620204] hda: ST380011A, ATA DISK drive
> [    2.956027] hdb: Maxtor 6Y080P0, ATA DISK drive
> [    2.956622] hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
> [    2.956925] hda: UDMA/100 mode selected
> [    2.957279] hdb: host max PIO4 wanted PIO255(auto-tune) selected PIO4
> [    2.957406] hdb: UDMA/100 mode selected
> [    2.957626] Probing IDE interface ide1...
> [    3.692203] hdc: PLEXTOR DVDR PX-740A, ATAPI CD/DVD-ROM drive
> [    4.364386] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO4
> [    4.364849] hdc: UDMA/33 mode selected
> [    4.365363] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> [    4.366013] ide1 at 0x170-0x177,0x376 on irq 15
> [    4.368196] ide_generic: please use "probe_mask=3D0x3f" module paramet=
er for probing all legacy ISA IDE ports
> [    4.368341] ide-gd driver 1.18
> [    4.368641] hda: max request size: 512KiB
> [    4.380342] hda: 156301488 sectors (80026 MB) w/2048KiB Cache, CHS=3D1=
6383/255/63
> [    4.380732] hda: cache flushes supported
> [    4.381251]  hda: hda1 hda2 hda3 < hda5 hda6 hda7 hda8 hda9 hda10 hda1=
1 > hda4
> [    4.467809] hdb: max request size: 128KiB
> [    4.480215] hdb: 160086528 sectors (81964 MB) w/7936KiB Cache, CHS=3D6=
5535/16/63
> [    4.480601] hdb: cache flushes supported
> [    4.480904]  hdb: hdb1 hdb2 hdb3 hdb4 < hdb5 hdb6 hdb7 hdb8 hdb9 >
> [    4.546695] ide-cd driver 5.00
> [    4.549215] ide-cd: hdc: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048kB=
 Cache
> [    4.549532] Uniform CD-ROM driver Revision: 3.20
> [    4.563164] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0=
x64 irq 1,12
> [    4.566848] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    4.567020] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    4.568886] mice: PS/2 mouse device common for all mice
> [    4.570432] cpuidle: using governor ladder
> [    4.570527] cpuidle: using governor menu
> [    4.571905] TCP cubic registered
> [    4.572061] NET: Registered protocol family 17
> [    4.572277] Using IPI No-Shortcut mode
> [    4.573435] PM: Checking image partition /dev/hda7
> [    4.573518] PM: Resume from partition 3:7
> [    4.573522] PM: Checking hibernation image.
> [    4.589764] PM: Error -22 checking image file
> [    4.589770] PM: Resume from disk failed.
> [    4.591056] Freeing unused kernel memory: 284k freed
> [    4.591959] Write protecting the kernel text: 1852k
> [    4.592231] Write protecting the kernel read-only data: 916k
> [    4.600344] input: AT Translated Set 2 keyboard as /devices/platform/i=
8042/serio0/input/input0
> [    4.924261] input: PS2++ Logitech Mouse as /devices/platform/i8042/ser=
io1/input/input1
> [    8.285634] EXT3-fs: mounted filesystem with writeback data mode.
> [    8.287195] kjournald starting.  Commit interval 5 seconds
> [    9.599516] usbcore: registered new interface driver usbfs
> [    9.599837] usbcore: registered new interface driver hub
> [    9.604144] usbcore: registered new device driver usb
> [   10.521350] udevd version 127 started
> [   10.769864] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PN=
P0C0E:00/input/input2
> [   10.769911] ACPI: Sleep Button [SLPB]
> [   10.770312] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input3
> [   10.770331] ACPI: Power Button [PWRF]
> [   10.810255] processor LNXCPU:00: registered as cooling_device0
> [   10.920203] Floppy drive(s): fd0 is 1.44M
> [   10.940449] FDC 0 is a post-1991 82077
> [   11.220993] uhci_hcd: USB Universal Host Controller Interface driver
> [   11.221442] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) ->=
 IRQ 16
> [   11.221475] uhci_hcd 0000:00:1d.0: setting latency timer to 64
> [   11.221484] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> [   11.221903] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bu=
s number 1
> [   11.221925] uhci_hcd 0000:00:1d.0: detected 2 ports
> [   11.221935] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd =3D 0x=
0000
> [   11.221940] uhci_hcd 0000:00:1d.0: Performing full reset
> [   11.221957] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
> [   11.222041] uhci_hcd 0000:00:1d.0: irq 16, io base 0x0000e800
> [   11.222649] usb usb1: default language 0x0409
> [   11.222721] usb usb1: udev 1, busnum 1, minor =3D 0
> [   11.222727] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.222733] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.222738] usb usb1: Product: UHCI Host Controller
> [   11.222743] usb usb1: Manufacturer: Linux 2.6.32 uhci_hcd
> [   11.222747] usb usb1: SerialNumber: 0000:00:1d.0
> [   11.223516] usb usb1: uevent
> [   11.223796] usb usb1: usb_probe_device
> [   11.223803] usb usb1: configuration #1 chosen from 1 choice
> [   11.242538] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [   11.242545] Warning! ehci_hcd should always be loaded before uhci_hcd =
and ohci_hcd, not after
> [   11.242552] ehci_hcd: block sizes: qh 60 qtd 96 itd 160 sitd 96
> [   11.264277] usb usb1: adding 1-0:1.0 (config #1, interface 0)
> [   11.264448] usb 1-0:1.0: uevent
> [   11.264806] hub 1-0:1.0: usb_probe_interface
> [   11.264812] hub 1-0:1.0: usb_probe_interface - got id
> [   11.264820] hub 1-0:1.0: USB hub found
> [   11.265092] hub 1-0:1.0: 2 ports detected
> [   11.265100] hub 1-0:1.0: standalone hub
> [   11.265105] hub 1-0:1.0: no power switching (usb 1.0)
> [   11.265109] hub 1-0:1.0: individual port over-current protection
> [   11.265115] hub 1-0:1.0: power on to power good time: 2ms
> [   11.265612] hub 1-0:1.0: local power source is good
> [   11.265620] hub 1-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.266158] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 23 (level, low) ->=
 IRQ 23
> [   11.266208] ehci_hcd 0000:00:1d.7: setting latency timer to 64
> [   11.266218] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> [   11.266255] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bu=
s number 2
> [   11.266281] ehci_hcd 0000:00:1d.7: reset hcs_params 0x103206 dbg=3D1 c=
c=3D3 pcc=3D2 ordered !ppc ports=3D6
> [   11.266289] ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 ufra=
mes 1024 64 bit addr
> [   11.266387] ehci_hcd 0000:00:1d.7: debug port 1
> [   11.266398] ehci_hcd 0000:00:1d.7: reset command 080012 (park)=3D0 ith=
resh=3D8 Periodic period=3D1024 Reset HALT
> [   11.276298] ehci_hcd 0000:00:1d.7: cache line size of 128 is not suppo=
rted
> [   11.276307] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
> [   11.276396] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xffa7fc00
> [   11.276407] ehci_hcd 0000:00:1d.7: reset command 080002 (park)=3D0 ith=
resh=3D8 period=3D1024 Reset HALT
> [   11.296213] ehci_hcd 0000:00:1d.7: init command 010001 (park)=3D0 ithr=
esh=3D1 period=3D1024 RUN
> [   11.308177] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
> [   11.308412] usb usb2: default language 0x0409
> [   11.308493] usb usb2: udev 1, busnum 2, minor =3D 128
> [   11.308499] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
> [   11.308504] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.308510] usb usb2: Product: EHCI Host Controller
> [   11.308514] usb usb2: Manufacturer: Linux 2.6.32 ehci_hcd
> [   11.308519] usb usb2: SerialNumber: 0000:00:1d.7
> [   11.308823] usb usb2: uevent
> [   11.308902] usb usb2: usb_probe_device
> [   11.308910] usb usb2: configuration #1 chosen from 1 choice
> [   11.309138] usb usb2: adding 2-0:1.0 (config #1, interface 0)
> [   11.309248] usb 2-0:1.0: uevent
> [   11.309315] hub 2-0:1.0: usb_probe_interface
> [   11.309321] hub 2-0:1.0: usb_probe_interface - got id
> [   11.309327] hub 2-0:1.0: USB hub found
> [   11.309369] hub 2-0:1.0: 6 ports detected
> [   11.309377] hub 2-0:1.0: standalone hub
> [   11.309382] hub 2-0:1.0: no power switching (usb 1.0)
> [   11.309386] hub 2-0:1.0: individual port over-current protection
> [   11.309392] hub 2-0:1.0: power on to power good time: 20ms
> [   11.309525] hub 2-0:1.0: local power source is good
> [   11.309533] hub 2-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.309898] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) ->=
 IRQ 19
> [   11.310002] uhci_hcd 0000:00:1d.1: setting latency timer to 64
> [   11.310013] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> [   11.310048] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bu=
s number 3
> [   11.310067] uhci_hcd 0000:00:1d.1: detected 2 ports
> [   11.310077] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd =3D 0x=
0000
> [   11.310082] uhci_hcd 0000:00:1d.1: Performing full reset
> [   11.310100] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
> [   11.310172] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e880
> [   11.310415] usb usb3: default language 0x0409
> [   11.310483] usb usb3: udev 1, busnum 3, minor =3D 256
> [   11.310489] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.310494] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.310499] usb usb3: Product: UHCI Host Controller
> [   11.310504] usb usb3: Manufacturer: Linux 2.6.32 uhci_hcd
> [   11.310508] usb usb3: SerialNumber: 0000:00:1d.1
> [   11.310782] usb usb3: uevent
> [   11.310848] usb usb3: usb_probe_device
> [   11.310856] usb usb3: configuration #1 chosen from 1 choice
> [   11.310893] usb usb3: adding 3-0:1.0 (config #1, interface 0)
> [   11.310999] usb 3-0:1.0: uevent
> [   11.311074] hub 3-0:1.0: usb_probe_interface
> [   11.311080] hub 3-0:1.0: usb_probe_interface - got id
> [   11.311086] hub 3-0:1.0: USB hub found
> [   11.311127] hub 3-0:1.0: 2 ports detected
> [   11.311134] hub 3-0:1.0: standalone hub
> [   11.311138] hub 3-0:1.0: no power switching (usb 1.0)
> [   11.311142] hub 3-0:1.0: individual port over-current protection
> [   11.311148] hub 3-0:1.0: power on to power good time: 2ms
> [   11.311209] hub 3-0:1.0: local power source is good
> [   11.311216] hub 3-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.311509] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) ->=
 IRQ 18
> [   11.311537] uhci_hcd 0000:00:1d.2: setting latency timer to 64
> [   11.311547] uhci_hcd 0000:00:1d.2: UHCI Host Controller
> [   11.311579] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bu=
s number 4
> [   11.311599] uhci_hcd 0000:00:1d.2: detected 2 ports
> [   11.311609] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd =3D 0x=
0000
> [   11.311614] uhci_hcd 0000:00:1d.2: Performing full reset
> [   11.311631] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
> [   11.311693] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000ec00
> [   11.311952] usb usb4: default language 0x0409
> [   11.312849] usb usb4: udev 1, busnum 4, minor =3D 384
> [   11.312856] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.312862] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.312868] usb usb4: Product: UHCI Host Controller
> [   11.312872] usb usb4: Manufacturer: Linux 2.6.32 uhci_hcd
> [   11.312877] usb usb4: SerialNumber: 0000:00:1d.2
> [   11.316394] usb usb4: uevent
> [   11.316471] usb usb4: usb_probe_device
> [   11.316479] usb usb4: configuration #1 chosen from 1 choice
> [   11.316530] usb usb4: adding 4-0:1.0 (config #1, interface 0)
> [   11.316636] usb 4-0:1.0: uevent
> [   11.316702] hub 4-0:1.0: usb_probe_interface
> [   11.316709] hub 4-0:1.0: usb_probe_interface - got id
> [   11.316715] hub 4-0:1.0: USB hub found
> [   11.316759] hub 4-0:1.0: 2 ports detected
> [   11.316766] hub 4-0:1.0: standalone hub
> [   11.316770] hub 4-0:1.0: no power switching (usb 1.0)
> [   11.316774] hub 4-0:1.0: individual port over-current protection
> [   11.316781] hub 4-0:1.0: power on to power good time: 2ms
> [   11.316820] hub 4-0:1.0: local power source is good
> [   11.316828] hub 4-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.317142] uhci_hcd 0000:01:01.0: PCI INT A -> GSI 22 (level, low) ->=
 IRQ 22
> [   11.317172] uhci_hcd 0000:01:01.0: UHCI Host Controller
> [   11.317206] uhci_hcd 0000:01:01.0: new USB bus registered, assigned bu=
s number 5
> [   11.317227] uhci_hcd 0000:01:01.0: detected 2 ports
> [   11.317238] uhci_hcd 0000:01:01.0: uhci_check_and_reset_hc: cmd =3D 0x=
0000
> [   11.317243] uhci_hcd 0000:01:01.0: Performing full reset
> [   11.317343] uhci_hcd 0000:01:01.0: irq 22, io base 0x0000d880
> [   11.317539] usb usb5: default language 0x0409
> [   11.317614] usb usb5: udev 1, busnum 5, minor =3D 512
> [   11.317620] usb usb5: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.317626] usb usb5: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.317631] usb usb5: Product: UHCI Host Controller
> [   11.317635] usb usb5: Manufacturer: Linux 2.6.32 uhci_hcd
> [   11.317640] usb usb5: SerialNumber: 0000:01:01.0
> [   11.317885] usb usb5: uevent
> [   11.317948] usb usb5: usb_probe_device
> [   11.317956] usb usb5: configuration #1 chosen from 1 choice
> [   11.317994] usb usb5: adding 5-0:1.0 (config #1, interface 0)
> [   11.318117] usb 5-0:1.0: uevent
> [   11.318179] hub 5-0:1.0: usb_probe_interface
> [   11.318184] hub 5-0:1.0: usb_probe_interface - got id
> [   11.318190] hub 5-0:1.0: USB hub found
> [   11.318229] hub 5-0:1.0: 2 ports detected
> [   11.318235] hub 5-0:1.0: standalone hub
> [   11.318239] hub 5-0:1.0: no power switching (usb 1.0)
> [   11.318243] hub 5-0:1.0: individual port over-current protection
> [   11.318248] hub 5-0:1.0: power on to power good time: 2ms
> [   11.318284] hub 5-0:1.0: local power source is good
> [   11.318290] hub 5-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.318547] uhci_hcd 0000:01:01.1: PCI INT B -> GSI 21 (level, low) ->=
 IRQ 21
> [   11.318571] uhci_hcd 0000:01:01.1: UHCI Host Controller
> [   11.318604] uhci_hcd 0000:01:01.1: new USB bus registered, assigned bu=
s number 6
> [   11.318624] uhci_hcd 0000:01:01.1: detected 2 ports
> [   11.318634] uhci_hcd 0000:01:01.1: uhci_check_and_reset_hc: cmd =3D 0x=
0000
> [   11.318638] uhci_hcd 0000:01:01.1: Performing full reset
> [   11.318711] uhci_hcd 0000:01:01.1: irq 21, io base 0x0000dc00
> [   11.318883] usb usb6: default language 0x0409
> [   11.318950] usb usb6: udev 1, busnum 6, minor =3D 640
> [   11.318955] usb usb6: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.318961] usb usb6: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.318966] usb usb6: Product: UHCI Host Controller
> [   11.318971] usb usb6: Manufacturer: Linux 2.6.32 uhci_hcd
> [   11.318975] usb usb6: SerialNumber: 0000:01:01.1
> [   11.319238] usb usb6: uevent
> [   11.319301] usb usb6: usb_probe_device
> [   11.319308] usb usb6: configuration #1 chosen from 1 choice
> [   11.319342] usb usb6: adding 6-0:1.0 (config #1, interface 0)
> [   11.319467] usb 6-0:1.0: uevent
> [   11.319530] hub 6-0:1.0: usb_probe_interface
> [   11.319536] hub 6-0:1.0: usb_probe_interface - got id
> [   11.319542] hub 6-0:1.0: USB hub found
> [   11.319578] hub 6-0:1.0: 2 ports detected
> [   11.319584] hub 6-0:1.0: standalone hub
> [   11.319588] hub 6-0:1.0: no power switching (usb 1.0)
> [   11.319592] hub 6-0:1.0: individual port over-current protection
> [   11.319597] hub 6-0:1.0: power on to power good time: 2ms
> [   11.319668] hub 6-0:1.0: local power source is good
> [   11.319676] hub 6-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.320107] ehci_hcd 0000:01:00.2: PCI INT C -> GSI 23 (level, low) ->=
 IRQ 23
> [   11.320160] ehci_hcd 0000:01:00.2: EHCI Host Controller
> [   11.320206] ehci_hcd 0000:01:00.2: new USB bus registered, assigned bu=
s number 7
> [   11.320227] ehci_hcd 0000:01:00.2: reset hcs_params 0x2395 dbg=3D0 cc=
=3D2 pcc=3D3 ports=3D5
> [   11.320238] ehci_hcd 0000:01:00.2: reset portroute 1 0 1 0 0
> [   11.320245] ehci_hcd 0000:01:00.2: reset hcc_params e806 thresh 0 ufra=
mes 256/512/1024 park
> [   11.320313] ehci_hcd 0000:01:00.2: park 0
> [   11.320335] ehci_hcd 0000:01:00.2: reset command 080b02 park=3D3 ithre=
sh=3D8 period=3D1024 Reset HALT
> [   11.320345] ehci_hcd 0000:01:00.2: ...powerup ports...
> [   11.322909] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
> [   11.322916] e100: Copyright(c) 1999-2006 Intel Corporation
> [   11.322986] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [   11.322992] ohci_hcd: block sizes: ed 64 td 64
> [   11.344100] ehci_hcd 0000:01:00.2: MWI active
> [   11.344109] ehci_hcd 0000:01:00.2: supports USB remote wakeup
> [   11.344146] ehci_hcd 0000:01:00.2: irq 23, io mem 0xff8ffc00
> [   11.344158] ehci_hcd 0000:01:00.2: reset command 080b02 park=3D3 ithre=
sh=3D8 period=3D1024 Reset HALT
> [   11.344170] ehci_hcd 0000:01:00.2: init command 010009 (park)=3D0 ithr=
esh=3D1 period=3D256 RUN
> [   11.356263] ehci_hcd 0000:01:00.2: USB 2.0 started, EHCI 1.00
> [   11.356467] usb usb7: default language 0x0409
> [   11.356547] usb usb7: udev 1, busnum 7, minor =3D 768
> [   11.356553] usb usb7: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
> [   11.356558] usb usb7: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.356564] usb usb7: Product: EHCI Host Controller
> [   11.356568] usb usb7: Manufacturer: Linux 2.6.32 ehci_hcd
> [   11.356573] usb usb7: SerialNumber: 0000:01:00.2
> [   11.356888] usb usb7: uevent
> [   11.356966] usb usb7: usb_probe_device
> [   11.356974] usb usb7: configuration #1 chosen from 1 choice
> [   11.357018] usb usb7: adding 7-0:1.0 (config #1, interface 0)
> [   11.357127] usb 7-0:1.0: uevent
> [   11.357196] hub 7-0:1.0: usb_probe_interface
> [   11.357202] hub 7-0:1.0: usb_probe_interface - got id
> [   11.357208] hub 7-0:1.0: USB hub found
> [   11.357252] hub 7-0:1.0: 5 ports detected
> [   11.357260] hub 7-0:1.0: standalone hub
> [   11.357265] hub 7-0:1.0: individual port power switching
> [   11.357269] hub 7-0:1.0: individual port over-current protection
> [   11.357275] hub 7-0:1.0: power on to power good time: 20ms
> [   11.357314] hub 7-0:1.0: local power source is good
> [   11.357321] hub 7-0:1.0: enabling power on all ports
> [   11.359798] e100 0000:01:08.0: PCI INT A -> GSI 20 (level, low) -> IRQ=
 20
> [   11.364845] hub 1-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   11.408245] hub 2-0:1.0: state 7 ports 6 chg 0000 evt 0000
> [   11.408269] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   11.416182] uhci_hcd 0000:01:01.0: port 1 portsc 008a,00
> [   11.416342] uhci_hcd 0000:01:01.0: port 2 portsc 008a,00
> [   11.416435] uhci_hcd 0000:01:01.1: port 1 portsc 018a,00
> [   11.416488] uhci_hcd 0000:01:01.1: port 2 portsc 008a,00
> [   11.416544] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   11.456194] hub 7-0:1.0: state 7 ports 5 chg 0000 evt 0000
> [   11.516292] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   11.516314] hub 6-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   11.538312] input: PC Speaker as /devices/platform/pcspkr/input/input4
> [   11.545310] e100 0000:01:08.0: PME# disabled
> [   11.546708] e100: eth0: e100_probe: addr 0xff8fc000, irq 20, MAC addr =
00:0c:f1:a8:ee:4a
> [   11.546795] ohci_hcd 0000:01:00.0: PCI INT A -> GSI 21 (level, low) ->=
 IRQ 21
> [   11.546855] ohci_hcd 0000:01:00.0: OHCI Host Controller
> [   11.546897] ohci_hcd 0000:01:00.0: new USB bus registered, assigned bu=
s number 8
> [   11.546917] ohci_hcd 0000:01:00.0: enabled NEC chipset lost interrupt =
quirk
> [   11.547022] ohci_hcd 0000:01:00.0: created debug files
> [   11.547028] ohci_hcd 0000:01:00.0: supports USB remote wakeup
> [   11.547061] ohci_hcd 0000:01:00.0: irq 21, io mem 0xff8fd000
> [   11.883403] ohci_hcd 0000:01:00.0: OHCI controller state
> [   11.883415] ohci_hcd 0000:01:00.0: OHCI 1.0, NO legacy support registe=
rs
> [   11.883423] ohci_hcd 0000:01:00.0: control 0x283 RWC HCFS=3Doperationa=
l CBSR=3D3
> [   11.883431] ohci_hcd 0000:01:00.0: cmdstatus 0x00000 SOC=3D0
> [   11.883438] ohci_hcd 0000:01:00.0: intrstatus 0x00000004 SF
> [   11.883446] ohci_hcd 0000:01:00.0: intrenable 0x8000005a MIE RHSC UE R=
D WDH
> [   11.883456] ohci_hcd 0000:01:00.0: hcca frame #011c
> [   11.883464] ohci_hcd 0000:01:00.0: roothub.a 0f000203 POTPGT=3D15 NPS =
NDP=3D3(3)
> [   11.883471] ohci_hcd 0000:01:00.0: roothub.b 00000000 PPCM=3D0000 DR=
=3D0000
> [   11.883478] ohci_hcd 0000:01:00.0: roothub.status 00008000 DRWE
> [   11.883486] ohci_hcd 0000:01:00.0: roothub.portstatus [0] 0x00000100 P=
PS
> [   11.883494] ohci_hcd 0000:01:00.0: roothub.portstatus [1] 0x00000100 P=
PS
> [   11.907508] ohci_hcd 0000:01:00.0: roothub.portstatus [2] 0x00000100 P=
PS
> [   11.907635] usb usb8: default language 0x0409
> [   11.907715] usb usb8: udev 1, busnum 8, minor =3D 896
> [   11.907721] usb usb8: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
> [   11.907727] usb usb8: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.907733] usb usb8: Product: OHCI Host Controller
> [   11.907737] usb usb8: Manufacturer: Linux 2.6.32 ohci_hcd
> [   11.907742] usb usb8: SerialNumber: 0000:01:00.0
> [   11.908233] usb usb8: uevent
> [   11.908315] usb usb8: usb_probe_device
> [   11.908322] usb usb8: configuration #1 chosen from 1 choice
> [   11.908368] usb usb8: adding 8-0:1.0 (config #1, interface 0)
> [   11.908501] usb 8-0:1.0: uevent
> [   11.908568] hub 8-0:1.0: usb_probe_interface
> [   11.908575] hub 8-0:1.0: usb_probe_interface - got id
> [   11.908581] hub 8-0:1.0: USB hub found
> [   11.908628] hub 8-0:1.0: 3 ports detected
> [   11.908635] hub 8-0:1.0: standalone hub
> [   11.908640] hub 8-0:1.0: no power switching (usb 1.0)
> [   11.908644] hub 8-0:1.0: global over-current protection
> [   11.908650] hub 8-0:1.0: power on to power good time: 30ms
> [   11.908689] hub 8-0:1.0: local power source is good
> [   11.908694] hub 8-0:1.0: no over-current condition exists
> [   11.908701] hub 8-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.909000] ehci_hcd 0000:01:01.2: PCI INT C -> GSI 20 (level, low) ->=
 IRQ 20
> [   11.909057] ehci_hcd 0000:01:01.2: EHCI Host Controller
> [   11.909094] ehci_hcd 0000:01:01.2: new USB bus registered, assigned bu=
s number 9
> [   11.909117] ehci_hcd 0000:01:01.2: reset hcs_params 0x2204 dbg=3D0 cc=
=3D2 pcc=3D2 ordered !ppc ports=3D4
> [   11.909125] ehci_hcd 0000:01:01.2: reset hcc_params 0002 thresh 0 ufra=
mes 256/512/1024
> [   11.909214] ehci_hcd 0000:01:01.2: reset command 080002 (park)=3D0 ith=
resh=3D8 period=3D1024 Reset HALT
> [   11.909236] ehci_hcd 0000:01:01.2: MWI active
> [   11.909241] ehci_hcd 0000:01:01.2: supports USB remote wakeup
> [   11.909319] ehci_hcd 0000:01:01.2: irq 20, io mem 0xff8ff800
> [   11.909329] ehci_hcd 0000:01:01.2: reset command 080002 (park)=3D0 ith=
resh=3D8 period=3D1024 Reset HALT
> [   11.909339] ehci_hcd 0000:01:01.2: init command 010009 (park)=3D0 ithr=
esh=3D1 period=3D256 RUN
> [   11.920133] ehci_hcd 0000:01:01.2: USB 2.0 started, EHCI 0.95
> [   11.920332] usb usb9: default language 0x0409
> [   11.920406] usb usb9: udev 1, busnum 9, minor =3D 1024
> [   11.920412] usb usb9: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
> [   11.920418] usb usb9: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
> [   11.920424] usb usb9: Product: EHCI Host Controller
> [   11.920429] usb usb9: Manufacturer: Linux 2.6.32 ehci_hcd
> [   11.920434] usb usb9: SerialNumber: 0000:01:01.2
> [   11.920751] usb usb9: uevent
> [   11.920832] usb usb9: usb_probe_device
> [   11.920840] usb usb9: configuration #1 chosen from 1 choice
> [   11.920881] usb usb9: adding 9-0:1.0 (config #1, interface 0)
> [   11.920989] usb 9-0:1.0: uevent
> [   11.921057] hub 9-0:1.0: usb_probe_interface
> [   11.921063] hub 9-0:1.0: usb_probe_interface - got id
> [   11.921069] hub 9-0:1.0: USB hub found
> [   11.921114] hub 9-0:1.0: 4 ports detected
> [   11.921121] hub 9-0:1.0: standalone hub
> [   11.921126] hub 9-0:1.0: no power switching (usb 1.0)
> [   11.921129] hub 9-0:1.0: individual port over-current protection
> [   11.921136] hub 9-0:1.0: power on to power good time: 20ms
> [   11.921171] hub 9-0:1.0: local power source is good
> [   11.921179] hub 9-0:1.0: trying to enable port power on non-switchable=
 hub
> [   11.927595] ohci_hcd 0000:01:00.1: PCI INT B -> GSI 22 (level, low) ->=
 IRQ 22
> [   11.927665] ohci_hcd 0000:01:00.1: OHCI Host Controller
> [   11.927706] ohci_hcd 0000:01:00.1: new USB bus registered, assigned bu=
s number 10
> [   11.927728] ohci_hcd 0000:01:00.1: enabled NEC chipset lost interrupt =
quirk
> [   11.928588] ohci_hcd 0000:01:00.1: created debug files
> [   11.928595] ohci_hcd 0000:01:00.1: supports USB remote wakeup
> [   11.928630] ohci_hcd 0000:01:00.1: irq 22, io mem 0xff8fe000
> [   12.008183] hub 8-0:1.0: state 7 ports 3 chg 0000 evt 0000
> [   12.020225] hub 9-0:1.0: state 7 ports 4 chg 0000 evt 0000
> [   12.065490] ohci_hcd 0000:01:00.1: OHCI controller state
> [   12.065502] ohci_hcd 0000:01:00.1: OHCI 1.0, NO legacy support registe=
rs
> [   12.065510] ohci_hcd 0000:01:00.1: control 0x283 RWC HCFS=3Doperationa=
l CBSR=3D3
> [   12.065517] ohci_hcd 0000:01:00.1: cmdstatus 0x00000 SOC=3D0
> [   12.065524] ohci_hcd 0000:01:00.1: intrstatus 0x00000004 SF
> [   12.065532] ohci_hcd 0000:01:00.1: intrenable 0x8000005a MIE RHSC UE R=
D WDH
> [   12.065541] ohci_hcd 0000:01:00.1: hcca frame #0052
> [   12.065548] ohci_hcd 0000:01:00.1: roothub.a 0f000202 POTPGT=3D15 NPS =
NDP=3D2(2)
> [   12.065555] ohci_hcd 0000:01:00.1: roothub.b 00000000 PPCM=3D0000 DR=
=3D0000
> [   12.065562] ohci_hcd 0000:01:00.1: roothub.status 00008000 DRWE
> [   12.065570] ohci_hcd 0000:01:00.1: roothub.portstatus [0] 0x00000100 P=
PS
> [   12.065577] ohci_hcd 0000:01:00.1: roothub.portstatus [1] 0x00000100 P=
PS
> [   12.065685] usb usb10: default language 0x0409
> [   12.065757] usb usb10: udev 1, busnum 10, minor =3D 1152
> [   12.065763] usb usb10: New USB device found, idVendor=3D1d6b, idProduc=
t=3D0001
> [   12.065768] usb usb10: New USB device strings: Mfr=3D3, Product=3D2, S=
erialNumber=3D1
> [   12.065773] usb usb10: Product: OHCI Host Controller
> [   12.065778] usb usb10: Manufacturer: Linux 2.6.32 ohci_hcd
> [   12.065782] usb usb10: SerialNumber: 0000:01:00.1
> [   12.066115] usb usb10: uevent
> [   12.066196] usb usb10: usb_probe_device
> [   12.066204] usb usb10: configuration #1 chosen from 1 choice
> [   12.066243] usb usb10: adding 10-0:1.0 (config #1, interface 0)
> [   12.066351] usb 10-0:1.0: uevent
> [   12.066418] hub 10-0:1.0: usb_probe_interface
> [   12.066424] hub 10-0:1.0: usb_probe_interface - got id
> [   12.066430] hub 10-0:1.0: USB hub found
> [   12.066475] hub 10-0:1.0: 2 ports detected
> [   12.066482] hub 10-0:1.0: standalone hub
> [   12.066487] hub 10-0:1.0: no power switching (usb 1.0)
> [   12.066491] hub 10-0:1.0: global over-current protection
> [   12.066497] hub 10-0:1.0: power on to power good time: 30ms
> [   12.066563] hub 10-0:1.0: local power source is good
> [   12.066568] hub 10-0:1.0: no over-current condition exists
> [   12.066576] hub 10-0:1.0: trying to enable port power on non-switchabl=
e hub
> [   12.164395] hub 10-0:1.0: state 7 ports 2 chg 0000 evt 0000
> [   12.304053] usb usb1: suspend_rh (auto-stop)
> [   12.552062] usb usb3: suspend_rh (auto-stop)
> [   12.552091] usb usb4: suspend_rh (auto-stop)
> [   12.552115] usb usb5: suspend_rh (auto-stop)
> [   12.552139] usb usb6: suspend_rh (auto-stop)
> [   13.048056] ohci_hcd 0000:01:00.0: auto-stop root hub
> [   13.296043] ohci_hcd 0000:01:00.1: auto-stop root hub
> [   13.816475] hub 1-0:1.0: hub_suspend
> [   13.816743] usb usb1: bus auto-suspend
> [   13.816780] usb usb1: suspend_rh
> [   13.816902] hub 2-0:1.0: hub_suspend
> [   13.816915] usb usb2: bus auto-suspend
> [   13.816920] ehci_hcd 0000:00:1d.7: suspend root hub
> [   13.817117] hub 3-0:1.0: hub_suspend
> [   13.817128] usb usb3: bus auto-suspend
> [   13.817133] usb usb3: suspend_rh
> [   13.817159] hub 4-0:1.0: hub_suspend
> [   13.817170] usb usb4: bus auto-suspend
> [   13.817175] usb usb4: suspend_rh
> [   13.817201] hub 7-0:1.0: hub_suspend
> [   13.817211] usb usb7: bus auto-suspend
> [   13.817216] ehci_hcd 0000:01:00.2: suspend root hub
> [   13.817254] hub 5-0:1.0: hub_suspend
> [   13.817266] usb usb5: bus auto-suspend
> [   13.817271] usb usb5: suspend_rh
> [   13.817295] hub 6-0:1.0: hub_suspend
> [   13.817305] usb usb6: bus auto-suspend
> [   13.817310] usb usb6: suspend_rh
> [   14.816073] hub 8-0:1.0: hub_suspend
> [   14.816096] usb usb8: bus auto-suspend
> [   14.816151] ohci_hcd 0000:01:00.0: suspend root hub
> [   14.816172] hub 9-0:1.0: hub_suspend
> [   14.816184] usb usb9: bus auto-suspend
> [   14.816190] ehci_hcd 0000:01:01.2: suspend root hub
> [   14.816225] hub 10-0:1.0: hub_suspend
> [   14.816237] usb usb10: bus auto-suspend
> [   14.816243] ohci_hcd 0000:01:00.1: suspend root hub
> [   57.345078] EXT3 FS on hda8, internal journal
> [   57.532662] kjournald starting.  Commit interval 5 seconds
> [   57.532790] EXT3 FS on hda1, internal journal
> [   57.532812] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.563286] kjournald starting.  Commit interval 5 seconds
> [   57.563445] EXT3 FS on hda9, internal journal
> [   57.563465] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.593301] kjournald starting.  Commit interval 5 seconds
> [   57.593450] EXT3 FS on hda10, internal journal
> [   57.593471] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.616376] kjournald starting.  Commit interval 5 seconds
> [   57.616530] EXT3 FS on hda4, internal journal
> [   57.616551] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.633144] kjournald starting.  Commit interval 5 seconds
> [   57.633322] EXT3 FS on hda11, internal journal
> [   57.633343] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.711117] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.712408] kjournald starting.  Commit interval 5 seconds
> [   57.741914] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.743262] kjournald starting.  Commit interval 5 seconds
> [   57.763078] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.764337] kjournald starting.  Commit interval 5 seconds
> [   57.798668] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.800108] kjournald starting.  Commit interval 5 seconds
> [   57.814595] EXT3-fs: mounted filesystem with writeback data mode.
> [   57.819136] kjournald starting.  Commit interval 5 seconds
> [   58.800646] Adding 530104k swap on /dev/hda7.  Priority:-1 extents:1 a=
cross:530104k
> [   59.900385] e100: eth0 NIC Link is Up 100 Mbps Full Duplex
> [   83.426209] SysRq : Changing Loglevel
> [   83.426345] Loglevel set to 9
> [  144.843699] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.843846] BUG skbuff_head_cache: Poison overwritten
> [  144.843935] ----------------------------------------------------------=
-------------------
> [  144.843939]
> [  144.844003] INFO: 0xeef13598-0xeef13598. First byte 0x6c instead of 0x=
6b
> [  144.844003] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D19980 cpu=
=3D0 pid=3D1435
> [  144.844003] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14545 cpu=3D0 p=
id=3D1952
> [  144.844003] INFO: Slab 0xc2202fdc objects=3D16 used=3D0 fp=3D0xeef1300=
0 flags=3D0x40000082
> [  144.844003] INFO: Object 0xeef13500 @offset=3D1280 fp=3D0x(null)
> [  144.844003]
> [  144.844003] Bytes b4 0xeef134f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.844003]   Object 0xeef13500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.844003]   Object 0xeef13590:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.844003]  Redzone 0xeef1359c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.844003]  Padding 0xeef135c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.844003]  Padding 0xeef135d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.844003]  Padding 0xeef135e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.844003]  Padding 0xeef135f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.844003] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.844003] Call Trace:
> [  144.844003]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.844003]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.844003]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.844003]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.844003]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.844003]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.844003]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.844003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.844003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.844003]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.844003]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.844003]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.844003]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.844003]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.844003]  [<c117bc18>] dev_close+0x77/0x98
> [  144.844003]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.844003]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.844003]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.844003]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.844003]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.844003]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.844003]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.844003]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.844003]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.844003]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.844003]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.844003]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.844003]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.844003]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.844003]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.844003] FIX skbuff_head_cache: Restoring 0xeef13598-0xeef13598=3D0=
x6b
> [  144.844003]
> [  144.874758] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.874902] BUG skbuff_head_cache: Poison overwritten
> [  144.874991] ----------------------------------------------------------=
-------------------
> [  144.874994]
> [  144.875209] INFO: 0xef59e098-0xef59e098. First byte 0x6c instead of 0x=
6b
> [  144.875312] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D19319 cpu=
=3D0 pid=3D1579
> [  144.875451] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14553 cpu=3D0 p=
id=3D1952
> [  144.875547] INFO: Slab 0xc2218418 objects=3D16 used=3D0 fp=3D0xef59e80=
0 flags=3D0x40000082
> [  144.875683] INFO: Object 0xef59e000 @offset=3D0 fp=3D0xef59e500
> [  144.875685]
> [  144.875853]   Object 0xef59e000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e090:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.876005]  Redzone 0xef59e09c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.876005]  Padding 0xef59e0c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e0d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e0e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e0f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.876005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.876005] Call Trace:
> [  144.876005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.876005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.876005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.876005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.876005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.876005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.876005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.876005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.876005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.876005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.876005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.876005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.876005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.876005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.876005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.876005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.876005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.876005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.876005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.876005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.876005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.876005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.876005] FIX skbuff_head_cache: Restoring 0xef59e098-0xef59e098=3D0=
x6b
> [  144.876005]
> [  144.876005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.876005] BUG skbuff_head_cache: Poison overwritten
> [  144.876005] ----------------------------------------------------------=
-------------------
> [  144.876005]
> [  144.876005] INFO: 0xef59e598-0xef59e598. First byte 0x6c instead of 0x=
6b
> [  144.876005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D19485 cpu=
=3D0 pid=3D1596
> [  144.876005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14553 cpu=3D0 p=
id=3D1952
> [  144.876005] INFO: Slab 0xc2218418 objects=3D16 used=3D0 fp=3D0xef59e80=
0 flags=3D0x40000082
> [  144.876005] INFO: Object 0xef59e500 @offset=3D1280 fp=3D0x(null)
> [  144.876005]
> [  144.876005] Bytes b4 0xef59e4f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]   Object 0xef59e500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.876005]   Object 0xef59e590:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.876005]  Redzone 0xef59e59c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.876005]  Padding 0xef59e5c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e5d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e5e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.876005]  Padding 0xef59e5f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.876005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.876005] Call Trace:
> [  144.876005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.876005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.876005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.876005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.876005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.876005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.876005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.876005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.876005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.876005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.876005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.876005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.876005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.876005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.876005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.876005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.876005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.876005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.876005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.876005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.876005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.876005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.876005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.876005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.876005] FIX skbuff_head_cache: Restoring 0xef59e598-0xef59e598=3D0=
x6b
> [  144.876005]
> [  144.934382] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.934526] BUG skbuff_head_cache: Poison overwritten
> [  144.934615] ----------------------------------------------------------=
-------------------
> [  144.934618]
> [  144.934833] INFO: 0xef592998-0xef592998. First byte 0x6c instead of 0x=
6b
> [  144.934937] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D19333 cpu=
=3D0 pid=3D0
> [  144.935034] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14568 cpu=3D0 p=
id=3D1952
> [  144.935130] INFO: Slab 0xc22181a8 objects=3D16 used=3D0 fp=3D0xef59200=
0 flags=3D0x40000082
> [  144.935268] INFO: Object 0xef592900 @offset=3D2304 fp=3D0x(null)
> [  144.935270]
> [  144.935439] Bytes b4 0xef5928f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.936005]   Object 0xef592900:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592910:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592920:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592930:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592940:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592950:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592960:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592970:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592980:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.936005]   Object 0xef592990:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.936005]  Redzone 0xef59299c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.936005]  Padding 0xef5929c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.936005]  Padding 0xef5929d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.936005]  Padding 0xef5929e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.936005]  Padding 0xef5929f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.936005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.936005] Call Trace:
> [  144.936005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.936005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.936005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.936005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.936005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.936005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.936005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.936005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.936005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.936005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.936005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.936005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.936005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.936005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.936005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.936005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.936005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.936005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.936005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.936005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.936005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.936005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.936005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.936005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.936005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.936005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.936005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.936005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.936005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.936005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.936005] FIX skbuff_head_cache: Restoring 0xef592998-0xef592998=3D0=
x6b
> [  144.936005]
> [  144.964801] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.964942] BUG skbuff_head_cache: Poison overwritten
> [  144.965031] ----------------------------------------------------------=
-------------------
> [  144.965034]
> [  144.965246] INFO: 0xed40a098-0xed40a098. First byte 0x6c instead of 0x=
6b
> [  144.965348] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17306 cpu=
=3D0 pid=3D1852
> [  144.965484] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.965579] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.965713] INFO: Object 0xed40a000 @offset=3D0 fp=3D0xed40a600
> [  144.965716]
> [  144.965884]   Object 0xed40a000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.966632]   Object 0xed40a010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.967379]   Object 0xed40a020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a090:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40a09c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40a0c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a0d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a0e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a0f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40a098-0xed40a098=3D0=
x6b
> [  144.968005]
> [  144.968005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.968005] BUG skbuff_head_cache: Poison overwritten
> [  144.968005] ----------------------------------------------------------=
-------------------
> [  144.968005]
> [  144.968005] INFO: 0xed40a398-0xed40a398. First byte 0x6c instead of 0x=
6b
> [  144.968005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17304 cpu=
=3D0 pid=3D0
> [  144.968005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.968005] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.968005] INFO: Object 0xed40a300 @offset=3D768 fp=3D0xed40af00
> [  144.968005]
> [  144.968005] Bytes b4 0xed40a2f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]   Object 0xed40a300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a390:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40a39c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40a3c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a3d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a3e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a3f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40a398-0xed40a398=3D0=
x6b
> [  144.968005]
> [  144.968005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.968005] BUG skbuff_head_cache: Poison overwritten
> [  144.968005] ----------------------------------------------------------=
-------------------
> [  144.968005]
> [  144.968005] INFO: 0xed40a598-0xed40a598. First byte 0x6c instead of 0x=
6b
> [  144.968005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17306 cpu=
=3D0 pid=3D1764
> [  144.968005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.968005] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.968005] INFO: Object 0xed40a500 @offset=3D1280 fp=3D0x(null)
> [  144.968005]
> [  144.968005] Bytes b4 0xed40a4f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]   Object 0xed40a500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a590:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40a59c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40a5c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a5d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a5e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a5f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40a598-0xed40a598=3D0=
x6b
> [  144.968005]
> [  144.968005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.968005] BUG skbuff_head_cache: Poison overwritten
> [  144.968005] ----------------------------------------------------------=
-------------------
> [  144.968005]
> [  144.968005] INFO: 0xed40a698-0xed40a698. First byte 0x6c instead of 0x=
6b
> [  144.968005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17307 cpu=
=3D0 pid=3D1852
> [  144.968005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.968005] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.968005] INFO: Object 0xed40a600 @offset=3D1536 fp=3D0xed40a500
> [  144.968005]
> [  144.968005] Bytes b4 0xed40a5f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]   Object 0xed40a600:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a610:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a630:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a660:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a670:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a680:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40a690:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40a69c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40a6c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a6d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a6e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40a6f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40a698-0xed40a698=3D0=
x6b
> [  144.968005]
> [  144.968005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.968005] BUG skbuff_head_cache: Poison overwritten
> [  144.968005] ----------------------------------------------------------=
-------------------
> [  144.968005]
> [  144.968005] INFO: 0xed40ab98-0xed40ab98. First byte 0x6c instead of 0x=
6b
> [  144.968005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17304 cpu=
=3D0 pid=3D0
> [  144.968005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.968005] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.968005] INFO: Object 0xed40ab00 @offset=3D2816 fp=3D0xed40a300
> [  144.968005]
> [  144.968005] Bytes b4 0xed40aaf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]   Object 0xed40ab00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40ab90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40ab9c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40abc4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40abd4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40abe4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40abf4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40ab98-0xed40ab98=3D0=
x6b
> [  144.968005]
> [  144.968005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  144.968005] BUG skbuff_head_cache: Poison overwritten
> [  144.968005] ----------------------------------------------------------=
-------------------
> [  144.968005]
> [  144.968005] INFO: 0xed40af98-0xed40af98. First byte 0x6c instead of 0x=
6b
> [  144.968005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17305 cpu=
=3D0 pid=3D1852
> [  144.968005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14576 cpu=3D0 p=
id=3D1952
> [  144.968005] INFO: Slab 0xc21ab208 objects=3D16 used=3D0 fp=3D0xed40a70=
0 flags=3D0x40000082
> [  144.968005] INFO: Object 0xed40af00 @offset=3D3840 fp=3D0xed40a000
> [  144.968005]
> [  144.968005] Bytes b4 0xed40aef0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]   Object 0xed40af00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  144.968005]   Object 0xed40af90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  144.968005]  Redzone 0xed40af9c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  144.968005]  Padding 0xed40afc4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40afd4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40afe4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  144.968005]  Padding 0xed40aff4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  144.968005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  144.968005] Call Trace:
> [  144.968005]  [<c106edbe>] print_trailer+0xff/0x107
> [  144.968005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  144.968005]  [<c106ef3f>] check_object+0xa5/0x160
> [  144.968005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  144.968005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  144.968005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  144.968005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  144.968005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  144.968005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  144.968005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  144.968005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  144.968005]  [<c117bc18>] dev_close+0x77/0x98
> [  144.968005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  144.968005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  144.968005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  144.968005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  144.968005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  144.968005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  144.968005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  144.968005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  144.968005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  144.968005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  144.968005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  144.968005] FIX skbuff_head_cache: Restoring 0xed40af98-0xed40af98=3D0=
x6b
> [  144.968005]
> [  145.144154] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.144299] BUG skbuff_head_cache: Poison overwritten
> [  145.144388] ----------------------------------------------------------=
-------------------
> [  145.144391]
> [  145.144605] INFO: 0xe2625298-0xe2625298. First byte 0x6c instead of 0x=
6b
> [  145.144709] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17348 cpu=
=3D0 pid=3D1852
> [  145.144847] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14621 cpu=3D0 p=
id=3D1952
> [  145.144945] INFO: Slab 0xc1f75f84 objects=3D16 used=3D0 fp=3D0xe262570=
0 flags=3D0x40000082
> [  145.145082] INFO: Object 0xe2625200 @offset=3D512 fp=3D0xe2625600
> [  145.145084]
> [  145.145252] Bytes b4 0xe26251f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.146005]   Object 0xe2625200:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.146757]   Object 0xe2625210:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.147507]   Object 0xe2625220:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625230:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625290:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.148006]  Redzone 0xe262529c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.148006]  Padding 0xe26252c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26252d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26252e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26252f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.148006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.148006] Call Trace:
> [  145.148006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.148006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.148006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.148006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.148006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.148006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.148006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.148006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.148006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.148006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.148006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.148006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.148006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.148006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.148006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.148006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.148006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.148006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.148006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.148006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.148006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.148006] FIX skbuff_head_cache: Restoring 0xe2625298-0xe2625298=3D0=
x6b
> [  145.148006]
> [  145.148006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.148006] BUG skbuff_head_cache: Poison overwritten
> [  145.148006] ----------------------------------------------------------=
-------------------
> [  145.148006]
> [  145.148006] INFO: 0xe2625698-0xe2625698. First byte 0x6c instead of 0x=
6b
> [  145.148006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17348 cpu=
=3D0 pid=3D1852
> [  145.148006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14621 cpu=3D0 p=
id=3D1952
> [  145.148006] INFO: Slab 0xc1f75f84 objects=3D16 used=3D0 fp=3D0xe262570=
0 flags=3D0x40000082
> [  145.148006] INFO: Object 0xe2625600 @offset=3D1536 fp=3D0x(null)
> [  145.148006]
> [  145.148006] Bytes b4 0xe26255f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]   Object 0xe2625600:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625610:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625630:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625660:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625670:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625680:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625690:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.148006]  Redzone 0xe262569c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.148006]  Padding 0xe26256c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26256d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26256e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe26256f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.148006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.148006] Call Trace:
> [  145.148006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.148006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.148006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.148006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.148006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.148006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.148006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.148006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.148006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.148006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.148006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.148006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.148006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.148006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.148006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.148006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.148006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.148006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.148006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.148006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.148006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.148006] FIX skbuff_head_cache: Restoring 0xe2625698-0xe2625698=3D0=
x6b
> [  145.148006]
> [  145.148006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.148006] BUG skbuff_head_cache: Poison overwritten
> [  145.148006] ----------------------------------------------------------=
-------------------
> [  145.148006]
> [  145.148006] INFO: 0xe2625c98-0xe2625c98. First byte 0x6c instead of 0x=
6b
> [  145.148006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17347 cpu=
=3D0 pid=3D0
> [  145.148006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14621 cpu=3D0 p=
id=3D1952
> [  145.148006] INFO: Slab 0xc1f75f84 objects=3D16 used=3D0 fp=3D0xe262570=
0 flags=3D0x40000082
> [  145.148006] INFO: Object 0xe2625c00 @offset=3D3072 fp=3D0xe2625e00
> [  145.148006]
> [  145.148006] Bytes b4 0xe2625bf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]   Object 0xe2625c00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625c90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.148006]  Redzone 0xe2625c9c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.148006]  Padding 0xe2625cc4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625cd4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625ce4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625cf4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.148006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.148006] Call Trace:
> [  145.148006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.148006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.148006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.148006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.148006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.148006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.148006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.148006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.148006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.148006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.148006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.148006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.148006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.148006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.148006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.148006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.148006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.148006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.148006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.148006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.148006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.148006] FIX skbuff_head_cache: Restoring 0xe2625c98-0xe2625c98=3D0=
x6b
> [  145.148006]
> [  145.148006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.148006] BUG skbuff_head_cache: Poison overwritten
> [  145.148006] ----------------------------------------------------------=
-------------------
> [  145.148006]
> [  145.148006] INFO: 0xe2625e98-0xe2625e98. First byte 0x6c instead of 0x=
6b
> [  145.148006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17348 cpu=
=3D0 pid=3D0
> [  145.148006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14621 cpu=3D0 p=
id=3D1952
> [  145.148006] INFO: Slab 0xc1f75f84 objects=3D16 used=3D0 fp=3D0xe262570=
0 flags=3D0x40000082
> [  145.148006] INFO: Object 0xe2625e00 @offset=3D3584 fp=3D0xe2625200
> [  145.148006]
> [  145.148006] Bytes b4 0xe2625df0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]   Object 0xe2625e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.148006]   Object 0xe2625e90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.148006]  Redzone 0xe2625e9c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.148006]  Padding 0xe2625ec4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625ed4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625ee4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.148006]  Padding 0xe2625ef4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.148006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.148006] Call Trace:
> [  145.148006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.148006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.148006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.148006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.148006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.148006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.148006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.148006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.148006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.148006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.148006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.148006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.148006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.148006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.148006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.148006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.148006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.148006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.148006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.148006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.148006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.148006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.148006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.148006] FIX skbuff_head_cache: Restoring 0xe2625e98-0xe2625e98=3D0=
x6b
> [  145.148006]
> [  145.264575] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.264719] BUG skbuff_head_cache: Poison overwritten
> [  145.264807] ----------------------------------------------------------=
-------------------
> [  145.264810]
> [  145.265021] INFO: 0xee9dc498-0xee9dc498. First byte 0x6c instead of 0x=
6b
> [  145.265123] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D17375 cpu=
=3D0 pid=3D1852
> [  145.265260] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14651 cpu=3D0 p=
id=3D1952
> [  145.265355] INFO: Slab 0xc21f20b0 objects=3D16 used=3D0 fp=3D0xee9dc60=
0 flags=3D0x40000082
> [  145.265491] INFO: Object 0xee9dc400 @offset=3D1024 fp=3D0xee9dc700
> [  145.265494]
> [  145.265661] Bytes b4 0xee9dc3f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.266409]   Object 0xee9dc400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.267156]   Object 0xee9dc410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.267904]   Object 0xee9dc420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc430:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc440:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc450:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc460:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc470:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc480:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc490:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.268006]  Redzone 0xee9dc49c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.268006]  Padding 0xee9dc4c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc4d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc4e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc4f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.268006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.268006] Call Trace:
> [  145.268006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.268006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.268006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.268006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.268006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.268006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.268006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.268006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.268006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.268006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.268006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.268006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.268006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.268006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.268006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.268006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.268006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.268006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.268006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.268006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.268006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.268006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.268006] FIX skbuff_head_cache: Restoring 0xee9dc498-0xee9dc498=3D0=
x6b
> [  145.268006]
> [  145.268006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.268006] BUG skbuff_head_cache: Poison overwritten
> [  145.268006] ----------------------------------------------------------=
-------------------
> [  145.268006]
> [  145.268006] INFO: 0xee9dc798-0xee9dc798. First byte 0x6c instead of 0x=
6b
> [  145.268006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D18166 cpu=
=3D0 pid=3D0
> [  145.268006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14651 cpu=3D0 p=
id=3D1952
> [  145.268006] INFO: Slab 0xc21f20b0 objects=3D16 used=3D0 fp=3D0xee9dc60=
0 flags=3D0x40000082
> [  145.268006] INFO: Object 0xee9dc700 @offset=3D1792 fp=3D0x(null)
> [  145.268006]
> [  145.268006] Bytes b4 0xee9dc6f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]   Object 0xee9dc700:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc710:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc720:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc730:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc740:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc750:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc760:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc770:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc780:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.268006]   Object 0xee9dc790:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.268006]  Redzone 0xee9dc79c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.268006]  Padding 0xee9dc7c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc7d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc7e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.268006]  Padding 0xee9dc7f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.268006] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.268006] Call Trace:
> [  145.268006]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.268006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.268006]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.268006]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.268006]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.268006]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.268006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.268006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.268006]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.268006]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.268006]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.268006]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.268006]  [<c117bc18>] dev_close+0x77/0x98
> [  145.268006]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.268006]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.268006]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.268006]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.268006]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.268006]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.268006]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.268006]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.268006]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.268006]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.268006]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.268006] FIX skbuff_head_cache: Restoring 0xee9dc798-0xee9dc798=3D0=
x6b
> [  145.268006]
> [  145.326841] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.326987] BUG skbuff_head_cache: Poison overwritten
> [  145.327075] ----------------------------------------------------------=
-------------------
> [  145.327078]
> [  145.327292] INFO: 0xef8fd198-0xef8fd198. First byte 0x6c instead of 0x=
6b
> [  145.327394] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D21353 cpu=
=3D0 pid=3D1433
> [  145.327532] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14666 cpu=3D0 p=
id=3D1952
> [  145.327629] INFO: Slab 0xc2223364 objects=3D16 used=3D0 fp=3D0xef8fd00=
0 flags=3D0x40000082
> [  145.327765] INFO: Object 0xef8fd100 @offset=3D256 fp=3D0x(null)
> [  145.327768]
> [  145.327936] Bytes b4 0xef8fd0f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]   Object 0xef8fd100:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd110:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd190:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.328005]  Redzone 0xef8fd19c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.328005]  Padding 0xef8fd1c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd1d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd1e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd1f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.328005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.328005] Call Trace:
> [  145.328005]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.328005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.328005]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.328005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.328005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.328005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.328005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.328005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.328005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.328005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.328005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.328005]  [<c117bc18>] dev_close+0x77/0x98
> [  145.328005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.328005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.328005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.328005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.328005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.328005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.328005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.328005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.328005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.328005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.328005] FIX skbuff_head_cache: Restoring 0xef8fd198-0xef8fd198=3D0=
x6b
> [  145.328005]
> [  145.328005] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [  145.328005] BUG skbuff_head_cache: Poison overwritten
> [  145.328005] ----------------------------------------------------------=
-------------------
> [  145.328005]
> [  145.328005] INFO: 0xef8fd598-0xef8fd598. First byte 0x6c instead of 0x=
6b
> [  145.328005] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D21103 cpu=
=3D0 pid=3D1433
> [  145.328005] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D14666 cpu=3D0 p=
id=3D1952
> [  145.328005] INFO: Slab 0xc2223364 objects=3D16 used=3D0 fp=3D0xef8fd00=
0 flags=3D0x40000082
> [  145.328005] INFO: Object 0xef8fd500 @offset=3D1280 fp=3D0xef8fd100
> [  145.328005]
> [  145.328005] Bytes b4 0xef8fd4f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]   Object 0xef8fd500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [  145.328005]   Object 0xef8fd590:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a3 =
            kkkkkkkklkk=A3
> [  145.328005]  Redzone 0xef8fd59c:  bb bb bb bb                         =
            =BB=BB=BB=BB
> [  145.328005]  Padding 0xef8fd5c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd5d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd5e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  145.328005]  Padding 0xef8fd5f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
            ZZZZZZZZZZZZ
> [  145.328005] Pid: 1952, comm: ifconfig Not tainted 2.6.32 #1
> [  145.328005] Call Trace:
> [  145.328005]  [<c106edbe>] print_trailer+0xff/0x107
> [  145.328005]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
> [  145.328005]  [<c106ef3f>] check_object+0xa5/0x160
> [  145.328005]  [<c106f05e>] __free_slab+0x64/0xf5
> [  145.328005]  [<c106f12a>] discard_slab+0x3b/0x3e
> [  145.328005]  [<c10704cc>] __slab_free+0x115/0x24b
> [  145.328005]  [<c107198f>] kmem_cache_free+0x7b/0xa2
> [  145.328005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744c6>] __kfree_skb+0x6e/0x71
> [  145.328005]  [<c11744f4>] consume_skb+0x2b/0x2d
> [  145.328005]  [<f0838b92>] e100_rx_clean_list+0x46/0x75 [e100]
> [  145.328005]  [<f0838fa3>] e100_down+0x7e/0x82 [e100]
> [  145.328005]  [<f08390ae>] e100_close+0xd/0x11 [e100]
> [  145.328005]  [<c117bc18>] dev_close+0x77/0x98
> [  145.328005]  [<c117b6a3>] dev_change_flags+0xa5/0x158
> [  145.328005]  [<c11af153>] devinet_ioctl+0x21a/0x48f
> [  145.328005]  [<c11b01fe>] inet_ioctl+0x8e/0xa7
> [  145.328005]  [<c116e885>] sock_ioctl+0x1d3/0x1f7
> [  145.328005]  [<c116e6b2>] ? sock_ioctl+0x0/0x1f7
> [  145.328005]  [<c107ee73>] vfs_ioctl+0x22/0x69
> [  145.328005]  [<c107f3e1>] do_vfs_ioctl+0x483/0x4bd
> [  145.328005]  [<c103f373>] ? trace_hardirqs_on_caller+0xff/0x120
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c103f39f>] ? trace_hardirqs_on+0xb/0xd
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c10733f6>] ? do_sys_open+0xdc/0xe7
> [  145.328005]  [<c1002a3b>] ? sysenter_exit+0xf/0x18
> [  145.328005]  [<c107f447>] sys_ioctl+0x2c/0x45
> [  145.328005]  [<c1002a08>] sysenter_do_call+0x12/0x36
> [  145.328005] FIX skbuff_head_cache: Restoring 0xef8fd598-0xef8fd598=3D0=
x6b
> [  145.328005]
> =

> =


---------------------------------------------------------------------------=
---
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev =
