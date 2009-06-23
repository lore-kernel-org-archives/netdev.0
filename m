From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: bnx2 firmware problem with 2.6.30
Date: Tue, 23 Jun 2009 17:31:18 +0200
Message-ID: <BAY103-DAV109D9C8B5604B2AF4A84EB2360@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s5.bay0.hotmail.com ([65.54.246.205]:30106 "EHLO
	bay0-omc3-s5.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761012AbZFWPct convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 11:32:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I have a pretty strange problem with the bnx2
driver on Slackware 12.2 linux 2.6.30 (32-bit).
When I modprobe the bnx2 I get this kind of
messages:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
bnx2: Firmware file "bnx2/bnx2-rv2p-06-4.6.16.fw" is invalid
bnx2 0000:03:00.0: PCI INT A disabled
bnx2: probe of 0000:03:00.0 failed with error -22

so, I remove the driver with rmmod bnx2 and I
retry, till it works:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
firmware 0000:03:00.0: firmware_loading_store: unexpected value (0)
bnx2: Firmware file "bnx2/bnx2-rv2p-06-4.6.16.fw" is invalid
bnx2 0000:03:00.0: PCI INT A disabled
bnx2: probe of 0000:03:00.0 failed with error -22
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
firmware 0000:03:00.0: firmware_loading_store: unexpected value (0)
bnx2: Firmware file "bnx2/bnx2-rv2p-06-4.6.16.fw" is invalid
bnx2 0000:03:00.0: PCI INT A disabled
bnx2: probe of 0000:03:00.0 failed with error -22
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
firmware 0000:03:00.0: firmware_loading_store: unexpected value (0)
firmware 0000:03:00.0: firmware_loading_store: unexpected value (0)
bnx2: Can't load firmware file "bnx2/bnx2-rv2p-06-4.6.16.fw"
bnx2 0000:03:00.0: PCI INT A disabled
bnx2: probe of 0000:03:00.0 failed with error -2
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz=
 found at mem fa000000, IRQ 16, node addr 00:24:81:aa:43:6e
bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex

Any feedback are welcome.
TIA


Here is dmesg and .config

Linux version 2.6.30 (root@Imhotep) (gcc version 4.2.4) #1 SMP Tue Jun =
23 18:34:11 CEST 2009
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  NSC Geode by NSC
  Cyrix CyrixInstead
  Centaur CentaurHauls
  Transmeta GenuineTMx86
  Transmeta TransmetaCPU
  UMC UMC UMC UMC
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
 BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dfe54000 (usable)
 BIOS-e820: 00000000dfe54000 - 00000000dfe5c000 (ACPI data)
 BIOS-e820: 00000000dfe5c000 - 00000000dfe5d000 (usable)
 BIOS-e820: 00000000dfe5d000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
 BIOS-e820: 00000000ffc00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 000000025ffff000 (usable)
DMI 2.4 present.
last_pfn =3D 0x25ffff max_arch_pfn =3D 0x1000000
init_memory_mapping: 0000000000000000-00000000379fe000
 0000000000 - 0000200000 page 4k
 0000200000 - 0037800000 page 2M
 0037800000 - 00379fe000 page 4k
kernel direct mapping tables up to 379fe000 @ 7000-d000
ACPI: RSDP 000f4f00 00024 (v02 HP    )
ACPI: XSDT dfe547c0 0007C (v01 HP     ProLiant 00000002   =D2=04 000016=
2E)
ACPI: FACP dfe54840 000F4 (v03 HP     ProLiant 00000002   =D2=04 000016=
2E)
ACPI Warning (tbfadt-0612): Invalid length for Pm1aControlBlock: 32, us=
ing default 16 [20090320]
ACPI Warning (tbfadt-0612): Invalid length for Pm2ControlBlock: 32, usi=
ng default 8 [20090320]
ACPI: DSDT dfe54940 02A24 (v01 HP         DSDT 00000001 INTL 20061109)
ACPI: FACS dfe54100 00040
ACPI: SPCR dfe54140 00050 (v01 HP     SPCRRBSU 00000001   =D2=04 000016=
2E)
ACPI: MCFG dfe541c0 0003C (v01 HP     ProLiant 00000001      00000000)
ACPI: HPET dfe54200 00038 (v01 HP     ProLiant 00000002   =D2=04 000016=
2E)
ACPI: SPMI dfe54240 00040 (v05 HP     ProLiant 00000001   =D2=04 000016=
2E)
ACPI: ERST dfe54280 001D0 (v01 HP     ProLiant 00000001   =D2=04 000016=
2E)
ACPI: APIC dfe54480 0009E (v01 HP     ProLiant 00000002      00000000)
ACPI: FFFF dfe54540 00176 (v01 HP     ProLiant 00000001   =D2=04 000016=
2E)
ACPI: BERT dfe546c0 00030 (v01 HP     ProLiant 00000001   =D2=04 000016=
2E)
ACPI: HEST dfe54700 000BC (v01 HP     ProLiant 00000001   =D2=04 000016=
2E)
ACPI: SSDT dfe59000 00CC5 (v01 HP        SSDTP 00000001 INTL 20061109)
ACPI: Local APIC address 0xfee00000
8838MB HIGHMEM available.
889MB LOWMEM available.
  mapped low ram: 0 - 379fe000
  low ram: 0 - 379fe000
  node 0 low ram: 00000000 - 379fe000
  node 0 bootmap 00009000 - 0000ff40
(8 early reservations) =3D=3D> bootmem [0000000000 - 00379fe000]
  #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0000000000 - 0=
000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE =3D=3D> [0000001000 - 0=
000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE =3D=3D> [0000006000 - 0=
000007000]
  #3 [0000200000 - 00004cb0c4]    TEXT DATA BSS =3D=3D> [0000200000 - 0=
0004cb0c4]
  #4 [000009f400 - 0000100000]    BIOS reserved =3D=3D> [000009f400 - 0=
000100000]
  #5 [00004cc000 - 00004d00e8]              BRK =3D=3D> [00004cc000 - 0=
0004d00e8]
  #6 [0000007000 - 0000009000]          PGTABLE =3D=3D> [0000007000 - 0=
000009000]
  #7 [0000009000 - 0000010000]          BOOTMAP =3D=3D> [0000009000 - 0=
000010000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x000379fe
  HighMem  0x000379fe -> 0x0025ffff
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x000dfe54
    0: 0x000dfe5c -> 0x000dfe5d
    0: 0x00100000 -> 0x0025ffff
On node 0 totalpages: 2358771
free_area_init_node: node 0, pgdat c041b400, node_mem_map c1000000
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3967 pages, LIFO batch:0
  Normal zone: 1748 pages used for memmap
  Normal zone: 221994 pages, LIFO batch:31
  HighMem zone: 17677 pages used for memmap
  HighMem zone: 2113353 pages, LIFO batch:31
Using APIC driver default
ACPI: PM-Timer IO Port: 0x908
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] disabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] disabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] disabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x09] address[0xfec80000] gsi_base[24])
IOAPIC[1]: apic_id 9, version 32, address 0xfec80000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 2 I/O APICs
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a201 base: 0xfed00000
8 Processors exceeds NR_CPUS limit of 4
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 48
Allocating PCI resources starting at f1000000 (gap: f0000000:ec00000)
NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 11 pages at c5c10000, static data 22876 bytes
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 23=
39314
Kernel command line: BOOT_IMAGE=3DLinux ro root=3D6801 vt.default_utf8=3D=
0
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
xsave/xrstor: enabled xstate_bv 0x3, cntxt size 0x240
Experimental hierarchical RCU implementation.
Experimental hierarchical RCU init done.
NR_IRQS:384
PID hash table entries: 4096 (order: 12, 16384 bytes)
Extended CMOS year: 2000
=46ast TSC calibration using PIT
Detected 2500.429 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Initializing HighMem for node 0 (000379fe:0025ffff)
Memory: 9352348k/9961468k available (1619k kernel code, 81764k reserved=
, 613k data, 224k init, 8524120k highmem)
virtual kernel memory layout:
    fixmap  : 0xfff83000 - 0xfffff000   ( 496 kB)
    pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
    vmalloc : 0xf81fe000 - 0xff9fe000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf79fe000   ( 889 MB)
      .init : 0xc0435000 - 0xc046d000   ( 224 kB)
      .data : 0xc0394cbf - 0xc042e1c8   ( 613 kB)
      .text : 0xc0200000 - 0xc0394cbf   (1619 kB)
Checking if this processor honours the WP bit even in supervisor mode..=
=2EOk.
SLUB: Genslabs=3D13, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
4, Nodes=3D1
hpet clockevent registered
Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. 5000.85 BogoMIPS (lpj=3D2500429)
Mount-cache hash table entries: 512
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
using mwait in idle threads.
Checking 'hlt' instruction... OK.
=46reeing SMP alternatives: 8k freed
ACPI: Core revision 20090320
=2ETIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 0a
Booting processor 1 APIC 0x2 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5000.00 BogoMIPS (lpj=3D=
2500002)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU1: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 0a
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x1 ip 0x6000
Initializing CPU#2
Calibrating delay using timer specific routine.. 5000.00 BogoMIPS (lpj=3D=
2500003)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU2: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 0a
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x3 ip 0x6000
Initializing CPU#3
Calibrating delay using timer specific routine.. 4999.99 BogoMIPS (lpj=3D=
2499996)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU3: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 0a
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Brought up 4 CPUs
Total of 4 processors activated (20000.86 BogoMIPS).
net_namespace: 304 bytes
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG for extended config space
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:00.0: PME# disabled
pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
pci 0000:00:04.0: PME# disabled
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0x1000-0x101f]
pci 0000:00:1d.1: reg 20 io port: [0x1020-0x103f]
pci 0000:00:1d.2: reg 20 io port: [0x1040-0x105f]
pci 0000:00:1d.3: reg 20 io port: [0x1060-0x107f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xf9df0000-0xf9df03ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.2: reg 10 io port: [0x1f0-0x1f7]
pci 0000:00:1f.2: reg 14 io port: [0x3f4-0x3f7]
pci 0000:00:1f.2: reg 18 io port: [0x170-0x177]
pci 0000:00:1f.2: reg 1c io port: [0x374-0x377]
pci 0000:00:1f.2: reg 20 io port: [0x500-0x50f]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
pci 0000:04:00.0: PME# disabled
pci 0000:04:00.3: PME# supported from D0 D3hot D3cold
pci 0000:04:00.3: PME# disabled
pci 0000:00:02.0: bridge 32bit mmio: [0xfde00000-0xfdefffff]
pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
pci 0000:05:00.0: PME# disabled
pci 0000:05:01.0: PME# supported from D0 D3hot D3cold
pci 0000:05:01.0: PME# disabled
pci 0000:12:00.0: PME# supported from D0 D3hot D3cold
pci 0000:12:00.0: PME# disabled
pci 0000:00:05.0: bridge io port: [0x4000-0x4fff]
pci 0000:00:05.0: bridge 32bit mmio: [0xfdf00000-0xfdffffff]
pci 0000:13:08.0: reg 10 64bit mmio: [0xfdf80000-0xfdffffff]
pci 0000:13:08.0: reg 18 io port: [0x4000-0x40ff]
pci 0000:13:08.0: reg 1c 32bit mmio: [0xfdf70000-0xfdf77fff]
pci 0000:13:08.0: reg 30 32bit mmio: [0x000000-0x003fff]
pci 0000:13:08.0: supports D1
pci 0000:12:00.0: bridge io port: [0x4000-0x4fff]
pci 0000:12:00.0: bridge 32bit mmio: [0xfdf00000-0xfdffffff]
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:00:1c.0: bridge 32bit mmio: [0xfa000000-0xfbffffff]
pci 0000:03:00.0: reg 10 64bit mmio: [0xfa000000-0xfbffffff]
pci 0000:03:00.0: reg 30 32bit mmio: [0x000000-0x0007ff]
pci 0000:03:00.0: PME# supported from D3hot D3cold
pci 0000:03:00.0: PME# disabled
pci 0000:02:00.0: bridge 32bit mmio: [0xfa000000-0xfbffffff]
pci 0000:01:03.0: reg 10 32bit mmio: [0xf0000000-0xf7ffffff]
pci 0000:01:03.0: reg 14 io port: [0x3000-0x30ff]
pci 0000:01:03.0: reg 18 32bit mmio: [0xf9ff0000-0xf9ffffff]
pci 0000:01:03.0: reg 30 32bit mmio: [0x000000-0x01ffff]
pci 0000:01:03.0: supports D1 D2
pci 0000:01:04.0: reg 10 io port: [0x2800-0x28ff]
pci 0000:01:04.0: reg 14 32bit mmio: [0xf9fe0000-0xf9fe01ff]
pci 0000:01:04.0: PME# supported from D0 D3hot D3cold
pci 0000:01:04.0: PME# disabled
pci 0000:01:04.2: reg 10 io port: [0x3400-0x34ff]
pci 0000:01:04.2: reg 14 32bit mmio: [0xf9fd0000-0xf9fd07ff]
pci 0000:01:04.2: reg 18 32bit mmio: [0xf9fc0000-0xf9fc1fff]
pci 0000:01:04.2: reg 1c 32bit mmio: [0xf9f00000-0xf9f7ffff]
pci 0000:01:04.2: reg 30 32bit mmio: [0x000000-0x00ffff]
pci 0000:01:04.2: PME# supported from D0 D3hot D3cold
pci 0000:01:04.2: PME# disabled
pci 0000:01:04.4: reg 20 io port: [0x3800-0x381f]
pci 0000:01:04.4: PME# supported from D0 D3hot D3cold
pci 0000:01:04.4: PME# disabled
pci 0000:01:04.6: reg 10 32bit mmio: [0xf9ef0000-0xf9ef00ff]
pci 0000:01:04.6: PME# supported from D0 D3hot D3cold
pci 0000:01:04.6: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0x2000-0x3fff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xf9e00000-0xf9ffffff]
pci 0000:00:1e.0: bridge 64bit mmio pref: [0xf0000000-0xf7ffffff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IP2P._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IPTA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02._PRT]
ACPI Warning (nspredef-0437): \_SB_.PCI0.PT02._PRT: Return Package has =
no elements (empty) [20090320]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.PEX2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.IPE4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.IPE4.IPE1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.IPE4.IPE2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT04._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT05.EEPB._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT05.EEPB.EPPB._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs *5 7 10 11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *7 10 11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 5 7 *10 11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 5 7 *10 11)
ACPI: PCI Interrupt Link [LNKE] (IRQs 5 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs *5 7 10 11)
ACPI: PCI Interrupt Link [LNKG] (IRQs 5 7 *10 11)
ACPI: PCI Interrupt Link [LNKH] (IRQs 5 *7 10 11)
PCI: Using ACPI for IRQ routing
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: ioport range 0x408-0x40f has been reserved
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x700-0x71f has been reserved
system 00:01: ioport range 0x800-0x83f has been reserved
system 00:01: ioport range 0x900-0x97f has been reserved
system 00:01: ioport range 0xc80-0xc83 has been reserved
system 00:01: ioport range 0xcd4-0xcd7 has been reserved
system 00:01: ioport range 0xf50-0xf58 has been reserved
system 00:01: ioport range 0xca0-0xca1 has been reserved
system 00:01: ioport range 0xca4-0xca5 has been reserved
system 00:01: ioport range 0x2f8-0x2ff has been reserved
system 00:01: iomem range 0xe0000000-0xefffffff has been reserved
system 00:01: iomem range 0xfe000000-0xfebfffff has been reserved
pci 0000:05:00.0: PCI bridge, secondary bus 0000:06
pci 0000:05:00.0:   IO window: disabled
pci 0000:05:00.0:   MEM window: disabled
pci 0000:05:00.0:   PREFETCH window: disabled
pci 0000:05:01.0: PCI bridge, secondary bus 0000:09
pci 0000:05:01.0:   IO window: disabled
pci 0000:05:01.0:   MEM window: disabled
pci 0000:05:01.0:   PREFETCH window: disabled
pci 0000:04:00.0: PCI bridge, secondary bus 0000:05
pci 0000:04:00.0:   IO window: disabled
pci 0000:04:00.0:   MEM window: disabled
pci 0000:04:00.0:   PREFETCH window: disabled
pci 0000:04:00.3: PCI bridge, secondary bus 0000:0c
pci 0000:04:00.3:   IO window: disabled
pci 0000:04:00.3:   MEM window: disabled
pci 0000:04:00.3:   PREFETCH window: disabled
pci 0000:00:02.0: PCI bridge, secondary bus 0000:04
pci 0000:00:02.0:   IO window: disabled
pci 0000:00:02.0:   MEM window: 0xfde00000-0xfdefffff
pci 0000:00:02.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:17
pci 0000:00:03.0:   IO window: disabled
pci 0000:00:03.0:   MEM window: disabled
pci 0000:00:03.0:   PREFETCH window: disabled
pci 0000:00:04.0: PCI bridge, secondary bus 0000:0f
pci 0000:00:04.0:   IO window: disabled
pci 0000:00:04.0:   MEM window: disabled
pci 0000:00:04.0:   PREFETCH window: disabled
pci 0000:13:04.0: PCI bridge, secondary bus 0000:14
pci 0000:13:04.0:   IO window: disabled
pci 0000:13:04.0:   MEM window: disabled
pci 0000:13:04.0:   PREFETCH window: disabled
pci 0000:12:00.0: PCI bridge, secondary bus 0000:13
pci 0000:12:00.0:   IO window: 0x4000-0x4fff
pci 0000:12:00.0:   MEM window: 0xfdf00000-0xfdffffff
pci 0000:12:00.0:   PREFETCH window: 0x000000f8000000-0x000000f80fffff
pci 0000:00:05.0: PCI bridge, secondary bus 0000:12
pci 0000:00:05.0:   IO window: 0x4000-0x4fff
pci 0000:00:05.0:   MEM window: 0xfdf00000-0xfdffffff
pci 0000:00:05.0:   PREFETCH window: 0x000000f8000000-0x000000f80fffff
pci 0000:02:00.0: PCI bridge, secondary bus 0000:03
pci 0000:02:00.0:   IO window: disabled
pci 0000:02:00.0:   MEM window: 0xfa000000-0xfbffffff
pci 0000:02:00.0:   PREFETCH window: 0x000000f8100000-0x000000f81fffff
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.0:   IO window: disabled
pci 0000:00:1c.0:   MEM window: 0xfa000000-0xfbffffff
pci 0000:00:1c.0:   PREFETCH window: 0x000000f8100000-0x000000f81fffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:01
pci 0000:00:1e.0:   IO window: 0x2000-0x3fff
pci 0000:00:1e.0:   MEM window: 0xf9e00000-0xf9ffffff
pci 0000:00:1e.0:   PREFETCH window: 0x000000f0000000-0x000000f7ffffff
pci 0000:00:02.0: setting latency timer to 64
pci 0000:04:00.0: setting latency timer to 64
pci 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:05:00.0: setting latency timer to 64
pci 0000:05:01.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:05:01.0: setting latency timer to 64
pci 0000:04:00.3: setting latency timer to 64
pci 0000:00:03.0: setting latency timer to 64
pci 0000:00:04.0: setting latency timer to 64
pci 0000:00:05.0: setting latency timer to 64
pci 0000:12:00.0: setting latency timer to 64
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:02:00.0: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:04: resource 1 mem: [0xfde00000-0xfdefffff]
pci_bus 0000:12: resource 0 io:  [0x4000-0x4fff]
pci_bus 0000:12: resource 1 mem: [0xfdf00000-0xfdffffff]
pci_bus 0000:12: resource 2 pref mem [0xf8000000-0xf80fffff]
pci_bus 0000:13: resource 0 io:  [0x4000-0x4fff]
pci_bus 0000:13: resource 1 mem: [0xfdf00000-0xfdffffff]
pci_bus 0000:13: resource 2 pref mem [0xf8000000-0xf80fffff]
pci_bus 0000:02: resource 1 mem: [0xfa000000-0xfbffffff]
pci_bus 0000:02: resource 2 pref mem [0xf8100000-0xf81fffff]
pci_bus 0000:03: resource 1 mem: [0xfa000000-0xfbffffff]
pci_bus 0000:03: resource 2 pref mem [0xf8100000-0xf81fffff]
pci_bus 0000:01: resource 0 io:  [0x2000-0x3fff]
pci_bus 0000:01: resource 1 mem: [0xf9e00000-0xf9ffffff]
pci_bus 0000:01: resource 2 pref mem [0xf0000000-0xf7ffffff]
pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
NET: Registered protocol family 1
platform rtc_cmos: registered platform RTC device (no PNP device found)
highmem bounce pool size: 64 pages
SGI XFS with security attributes, large block/inode numbers, no debug e=
nabled
msgmni has been set to 1619
io scheduler noop registered
io scheduler deadline registered (default)
pci 0000:01:03.0: Boot video device
pcieport-driver 0000:00:1c.0: setting latency timer to 64
pcieport-driver 0000:05:00.0: setting latency timer to 64
pcieport-driver 0000:05:01.0: setting latency timer to 64
aer 0000:05:00.0:pcie22: AER service couldn't init device: no _OSC supp=
ort
aer 0000:05:01.0:pcie22: AER service couldn't init device: no _OSC supp=
ort
HP CISS Driver (v 3.6.20)
cciss 0000:13:08.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
IRQ 19/cciss0: IRQF_DISABLED is not guaranteed on shared IRQs
cciss0: <0x3238> at PCI 0000:13:08.0 IRQ 19 using DAC
      blocks=3D 4294967296 block_size=3D 512
      blocks=3D 4395249392 block_size=3D 512
      heads=3D255, sectors=3D32, cylinders=3D538634

      blocks=3D 4395249392 block_size=3D 512
      heads=3D255, sectors=3D32, cylinders=3D538634

 cciss/c0d0: p1 p2 p3 p4 p5 p6 p7 p8 p9
PNP: PS/2 Controller [PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
NET: Registered protocol family 17
Using IPI Shortcut mode
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/i=
nput/input0
=46ilesystem "cciss/c0d0p1": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p1
Ending clean XFS mount for filesystem: cciss/c0d0p1
VFS: Mounted root (xfs filesystem) readonly on device 104:1.
=46reeing unused kernel memory: 224k freed
Adding 5241856k swap on /dev/cciss/c0d0p9.  Priority:-1 extents:1 acros=
s:5241856k=20
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
bnx2: Firmware file "bnx2/bnx2-rv2p-06-4.6.16.fw" is invalid
bnx2 0000:03:00.0: PCI INT A disabled
bnx2: probe of 0000:03:00.0 failed with error -22
input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042/serio1/inp=
ut/input1
=46ilesystem "cciss/c0d0p2": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p2
Ending clean XFS mount for filesystem: cciss/c0d0p2
=46ilesystem "cciss/c0d0p3": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p3
Ending clean XFS mount for filesystem: cciss/c0d0p3
=46ilesystem "cciss/c0d0p4": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p4
Ending clean XFS mount for filesystem: cciss/c0d0p4
=46ilesystem "cciss/c0d0p5": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p5
Ending clean XFS mount for filesystem: cciss/c0d0p5
=46ilesystem "cciss/c0d0p6": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p6
Ending clean XFS mount for filesystem: cciss/c0d0p6
=46ilesystem "cciss/c0d0p7": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p7
Ending clean XFS mount for filesystem: cciss/c0d0p7
=46ilesystem "cciss/c0d0p8": Disabling barriers, trial barrier write fa=
iled
XFS mounting filesystem cciss/c0d0p8
Ending clean XFS mount for filesystem: cciss/c0d0p8




#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.30
# Tue Jun 23 18:41:22 2009
#
# CONFIG_64BIT is not set
CONFIG_X86_32=3Dy
# CONFIG_X86_64 is not set
CONFIG_X86=3Dy
CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/i386_defconfig"
CONFIG_GENERIC_TIME=3Dy
CONFIG_GENERIC_CMOS_UPDATE=3Dy
CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
CONFIG_GENERIC_CLOCKEVENTS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
CONFIG_FAST_CMPXCHG_LOCAL=3Dy
CONFIG_MMU=3Dy
CONFIG_ZONE_DMA=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_GENERIC_BUG=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
# CONFIG_GENERIC_TIME_VSYSCALL is not set
CONFIG_ARCH_HAS_CPU_RELAX=3Dy
CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
CONFIG_HAVE_DYNAMIC_PER_CPU_AREA=3Dy
# CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
# CONFIG_ZONE_DMA32 is not set
CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_GENERIC_PENDING_IRQ=3Dy
CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
CONFIG_X86_32_SMP=3Dy
CONFIG_X86_HT=3Dy
CONFIG_X86_TRAMPOLINE=3Dy
CONFIG_X86_32_LAZY_GS=3Dy
CONFIG_KTIME_SCALAR=3Dy
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_LOCK_KERNEL=3Dy
CONFIG_INIT_ENV_ARG_LIMIT=3D32
CONFIG_LOCALVERSION=3D""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=3Dy
CONFIG_HAVE_KERNEL_BZIP2=3Dy
CONFIG_HAVE_KERNEL_LZMA=3Dy
CONFIG_KERNEL_GZIP=3Dy
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_BSD_PROCESS_ACCT=3Dy
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set

#
# RCU Subsystem
#
# CONFIG_CLASSIC_RCU is not set
CONFIG_TREE_RCU=3Dy
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=3D32
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=3D18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
# CONFIG_CGROUPS is not set
# CONFIG_SYSFS_DEPRECATED_V2 is not set
CONFIG_RELAY=3Dy
CONFIG_NAMESPACES=3Dy
CONFIG_UTS_NS=3Dy
CONFIG_IPC_NS=3Dy
# CONFIG_BLK_DEV_INITRD is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
CONFIG_ANON_INODES=3Dy
# CONFIG_EMBEDDED is not set
CONFIG_UID16=3Dy
CONFIG_SYSCTL_SYSCALL=3Dy
CONFIG_KALLSYMS=3Dy
CONFIG_KALLSYMS_EXTRA_PASS=3Dy
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_PCSPKR_PLATFORM=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_TIMERFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_SHMEM=3Dy
CONFIG_AIO=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_PCI_QUIRKS=3Dy
CONFIG_SLUB_DEBUG=3Dy
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=3Dy
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
# CONFIG_MARKERS is not set
CONFIG_HAVE_OPROFILE=3Dy
# CONFIG_KPROBES is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
CONFIG_HAVE_IOREMAP_PROT=3Dy
CONFIG_HAVE_KPROBES=3Dy
CONFIG_HAVE_KRETPROBES=3Dy
CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
CONFIG_HAVE_DMA_API_DEBUG=3Dy
# CONFIG_SLOW_WORK is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=3Dy
CONFIG_SLABINFO=3Dy
CONFIG_RT_MUTEXES=3Dy
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=3Dy
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=3Dy
CONFIG_BLOCK=3Dy
CONFIG_LBD=3Dy
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
# CONFIG_IOSCHED_AS is not set
CONFIG_IOSCHED_DEADLINE=3Dy
# CONFIG_IOSCHED_CFQ is not set
# CONFIG_DEFAULT_AS is not set
CONFIG_DEFAULT_DEADLINE=3Dy
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"deadline"
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=3Dy
CONFIG_NO_HZ=3Dy
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
CONFIG_SMP=3Dy
# CONFIG_SPARSE_IRQ is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_MEMTEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=3Dy
# CONFIG_GENERIC_CPU is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CPU=3Dy
CONFIG_X86_L1_CACHE_BYTES=3D64
CONFIG_X86_INTERNODE_CACHE_BYTES=3D64
CONFIG_X86_CMPXCHG=3Dy
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_XADD=3Dy
CONFIG_X86_WP_WORKS_OK=3Dy
CONFIG_X86_INVLPG=3Dy
CONFIG_X86_BSWAP=3Dy
CONFIG_X86_POPAD_OK=3Dy
CONFIG_X86_INTEL_USERCOPY=3Dy
CONFIG_X86_USE_PPRO_CHECKSUM=3Dy
CONFIG_X86_TSC=3Dy
CONFIG_X86_CMPXCHG64=3Dy
CONFIG_X86_CMOV=3Dy
CONFIG_X86_MINIMUM_CPU_FAMILY=3D4
CONFIG_X86_DEBUGCTLMSR=3Dy
CONFIG_CPU_SUP_INTEL=3Dy
CONFIG_CPU_SUP_CYRIX_32=3Dy
CONFIG_CPU_SUP_AMD=3Dy
CONFIG_CPU_SUP_CENTAUR=3Dy
CONFIG_CPU_SUP_TRANSMETA_32=3Dy
CONFIG_CPU_SUP_UMC_32=3Dy
# CONFIG_X86_DS is not set
CONFIG_HPET_TIMER=3Dy
CONFIG_DMI=3Dy
# CONFIG_IOMMU_HELPER is not set
# CONFIG_IOMMU_API is not set
CONFIG_NR_CPUS=3D4
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=3Dy
CONFIG_PREEMPT_NONE=3Dy
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_X86_IO_APIC=3Dy
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
CONFIG_VM86=3Dy
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_X86_CPU_DEBUG is not set
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=3Dy
CONFIG_PAGE_OFFSET=3D0xC0000000
CONFIG_HIGHMEM=3Dy
CONFIG_X86_PAE=3Dy
CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
CONFIG_FLATMEM=3Dy
CONFIG_FLAT_NODE_MEM_MAP=3Dy
CONFIG_PAGEFLAGS_EXTENDED=3Dy
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_PHYS_ADDR_T_64BIT=3Dy
CONFIG_ZONE_DMA_FLAG=3D1
CONFIG_BOUNCE=3Dy
CONFIG_VIRT_TO_BUS=3Dy
CONFIG_UNEVICTABLE_LRU=3Dy
CONFIG_HAVE_MLOCK=3Dy
CONFIG_HAVE_MLOCKED_PAGE_BIT=3Dy
CONFIG_HIGHPTE=3Dy
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
# CONFIG_X86_RESERVE_LOW_64K is not set
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=3Dy
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000
CONFIG_SCHED_HRTICK=3Dy
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=3D0x100000
CONFIG_PHYSICAL_ALIGN=3D0x200000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy

#
# Power management and ACPI options
#
CONFIG_PM=3Dy
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=3Dy
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_SYSFS_POWER is not set
# CONFIG_ACPI_PROC_EVENT is not set
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
# CONFIG_ACPI_BUTTON is not set
# CONFIG_ACPI_FAN is not set
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=3D0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=3Dy
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=3Dy
CONFIG_CPU_IDLE_GOV_LADDER=3Dy
CONFIG_CPU_IDLE_GOV_MENU=3Dy

#
# Bus options (PCI etc.)
#
CONFIG_PCI=3Dy
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=3Dy
CONFIG_PCI_BIOS=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_MMCONFIG=3Dy
CONFIG_PCI_DOMAINS=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_ARCH_SUPPORTS_MSI=3Dy
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_LEGACY is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=3Dy
# CONFIG_PCI_IOV is not set
CONFIG_ISA_DMA_API=3Dy
# CONFIG_ISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
# CONFIG_OLPC is not set
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=3Dy
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_HAVE_AOUT=3Dy
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_HAVE_ATOMIC_IOMAP=3Dy
CONFIG_NET=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
CONFIG_PACKET_MMAP=3Dy
CONFIG_UNIX=3Dy
# CONFIG_NET_KEY is not set
CONFIG_INET=3Dy
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=3Dy
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
CONFIG_SYN_COOKIES=3Dy
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=3Dy
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_PHONET is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
CONFIG_STANDALONE=3Dy
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=3Dy
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=3D""
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy
CONFIG_BLK_DEV=3Dy
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
CONFIG_BLK_CPQ_CISS_DA=3Dy
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_MISC_DEVICES is not set
CONFIG_HAVE_IDE=3Dy
# CONFIG_IDE is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dm
CONFIG_SCSI_DMA=3Dy
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dm
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=3Dm
# CONFIG_BLK_DEV_SR_VENDOR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=3Dm

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#

#
# A new alternative FireWire stack is available with EXPERIMENTAL=3Dy
#
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=3Dy
# CONFIG_COMPAT_NET_DEV_OPS is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=3Dy
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
CONFIG_BNX2=3Dm
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_JME is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=3Dm
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=3Dy
CONFIG_MOUSE_PS2=3Dm
CONFIG_MOUSE_PS2_ALPS=3Dy
CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
CONFIG_MOUSE_PS2_LIFEBOOK=3Dy
CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=3Dy
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_CONSOLE_TRANSLATIONS=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
# CONFIG_VT_HW_CONSOLE_BINDING is not set
# CONFIG_DEVKMEM is not set
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
# CONFIG_SERIAL_8250 is not set
CONFIG_FIX_EARLYCON_MEM=3Dy

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=3Dy
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_RTC is not set
# CONFIG_GEN_RTC is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_CS5535_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_DEVPORT=3Dy
# CONFIG_I2C is not set
# CONFIG_SPI is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
# CONFIG_POWER_SUPPLY is not set
# CONFIG_HWMON is not set
# CONFIG_THERMAL is not set
# CONFIG_THERMAL_HWMON is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=3Dy

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_REGULATOR is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_VIDEO_MEDIA is not set

#
# Multimedia drivers
#
# CONFIG_DAB is not set

#
# Graphics support
#
# CONFIG_AGP is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=3Dy
# CONFIG_SOUND is not set
# CONFIG_HID_SUPPORT is not set
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB=3Dm
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=3Dy
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
CONFIG_USB_MON=3Dm
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=3Dm
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=3Dm
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# Enable Host or Gadget support to see Inventra options
#

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
# CONFIG_RTC_CLASS is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=3Dy
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=3Dm
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_FS_POSIX_ACL is not set
CONFIG_FILE_LOCKING=3Dy
CONFIG_XFS_FS=3Dy
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# Caches
#

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dm
CONFIG_JOLIET=3Dy
# CONFIG_ZISOFS is not set
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
CONFIG_NTFS_RW=3Dy

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=3Dy
CONFIG_PROC_PAGE_MONITOR=3Dy
CONFIG_SYSFS=3Dy
# CONFIG_TMPFS is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
# CONFIG_CONFIGFS_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_EXPORTFS=3Dy

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=3Dy
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=3Dy
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=3Dy
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=3Dm
CONFIG_NLS_DEFAULT=3D"cp437"
CONFIG_NLS_CODEPAGE_437=3Dm
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=3Dm
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=3Dm
CONFIG_NLS_ISO8859_1=3Dm
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=3Dm
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=3Dm

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
# CONFIG_PRINTK_TIME is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=3D2048
# CONFIG_MAGIC_SYSRQ is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_DEBUG_BUGVERBOSE=3Dy
CONFIG_DEBUG_MEMORY_INIT=3Dy
CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
# CONFIG_FRAME_POINTER is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
CONFIG_USER_STACKTRACE_SUPPORT=3Dy
CONFIG_HAVE_FUNCTION_TRACER=3Dy
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
CONFIG_HAVE_FTRACE_SYSCALLS=3Dy
CONFIG_TRACING_SUPPORT=3Dy

#
# Tracers
#
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SYSPROF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_CONTEXT_SWITCH_TRACER is not set
# CONFIG_EVENT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
# CONFIG_BOOT_TRACER is not set
# CONFIG_TRACE_BRANCH_PROFILING is not set
# CONFIG_POWER_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_KMEMTRACE is not set
# CONFIG_WORKQUEUE_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=3Dy
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=3Dy
CONFIG_EARLY_PRINTK=3Dy
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_4KSTACKS is not set
CONFIG_DOUBLEFAULT=3Dy
CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
CONFIG_IO_DELAY_TYPE_0X80=3D0
CONFIG_IO_DELAY_TYPE_0XED=3D1
CONFIG_IO_DELAY_TYPE_UDELAY=3D2
CONFIG_IO_DELAY_TYPE_NONE=3D3
CONFIG_IO_DELAY_0X80=3Dy
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_IMA is not set
# CONFIG_CRYPTO is not set
CONFIG_HAVE_KVM=3Dy
CONFIG_HAVE_KVM_IRQCHIP=3Dy
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=3Dy
CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
CONFIG_GENERIC_FIND_NEXT_BIT=3Dy
CONFIG_GENERIC_FIND_LAST_BIT=3Dy
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=3Dm
CONFIG_CRC32=3Dy
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT=3Dy
CONFIG_HAS_DMA=3Dy
CONFIG_NLATTR=3Dy


