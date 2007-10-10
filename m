From: "Denys" <denys@visp.net.lb>
Subject: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 15:32:22 +0300
Message-ID: <20071010123222.M71635@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:47132 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbXJJMdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 08:33:19 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id B11ECBDDCF
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 15:32:22 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

P.S.
dmesg
Linux version 2.6.23-insat1 (root@visp-1) (gcc version 4.1.1 (Gentoo 4.1.1-
r3)) #1 SMP Wed Oct 10 01:41:17 EEST 2007
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000100 - 00000000000a0000 (usable)
 BIOS-e820: 0000000000100000 - 000000003ffa8000 (usable)
 BIOS-e820: 000000003ffa8000 - 000000003ffb7c00 (ACPI data)
 BIOS-e820: 000000003ffb7c00 - 0000000040000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fe000000 - 0000000100000000 (reserved)
127MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000fe710
Entering add_active_range(0, 0, 262056) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->   262056
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->   262056
On node 0 totalpages: 262056
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 1760 pages used for memmap
  Normal zone: 223520 pages, LIFO batch:31
  HighMem zone: 255 pages used for memmap
  HighMem zone: 32425 pages, LIFO batch:7
  Movable zone: 0 pages used for memmap
DMI 2.4 present.
Using APIC driver default
ACPI: RSDP 000F2620, 0024 (r2 DELL  )
ACPI: XSDT 000F26A0, 004C (r1 DELL   PE_SC3          1 DELL        1)
ACPI: FACP 000F27A8, 00F4 (r3 DELL   PE_SC3          1 DELL        1)
ACPI: DSDT 3FFA8000, 3C53 (r1 DELL   PE_SC3          1 MSFT  100000E)
ACPI: FACS 3FFB7C00, 0040
ACPI: APIC 000F289C, 00E0 (r1 DELL   PE_SC3          1 DELL        1)
ACPI: SPCR 000F297D, 0050 (r1 DELL   PE_SC3          1 DELL        1)
ACPI: HPET 000F29CD, 0038 (r1 DELL   PE_SC3          1 DELL        1)
ACPI: MCFG 000F2A05, 003C (r1 DELL   PE_SC3          1 DELL        1)
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:6 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
Processor #2 15:6 APIC version 20
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
Processor #1 15:6 APIC version 20
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
Processor #3 15:6 APIC version 20
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x15] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x16] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x17] disabled)
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x05] address[0xfec80000] gsi_base[32])
IOAPIC[1]: apic_id 5, version 32, address 0xfec80000, GSI 32-55
ACPI: IOAPIC (id[0x06] address[0xfec81000] gsi_base[64])
IOAPIC[2]: apic_id 6, version 32, address 0xfec81000, GSI 64-87
ACPI: IOAPIC (id[0x07] address[0xfec82000] gsi_base[96])
IOAPIC[3]: apic_id 7, version 32, address 0xfec82000, GSI 96-119
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 4 I/O APICs
ACPI: HPET id: 0x8086a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
Built 1 zonelists in Zone order.  Total pages: 260009
Kernel command line: root=/dev/sda3 panic=10 nmi_watchdog=1
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
mapped IOAPIC to ffff9000 (fec80000)
mapped IOAPIC to ffff8000 (fec81000)
mapped IOAPIC to ffff7000 (fec82000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c050e000 soft=c04ee000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 3192.148 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1033564k/1048224k available (2453k kernel code, 14048k reserved, 
1305k data, 232k init, 130720k highmem)
virtual kernel memory layout:
    fixmap  : 0xffe14000 - 0xfffff000   (1964 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc04b1000 - 0xc04eb000   ( 232 kB)
      .data : 0xc036544c - 0xc04ab97c   (1305 kB)
      .text : 0xc0100000 - 0xc036544c   (2453 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
SLUB: Genslabs=22, HWalign=64, Order=0-1, MinObjects=4, CPUs=4, Nodes=1
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
hpet0: 3 64-bit timers, 14318180 Hz
Calibrating delay using timer specific routine.. 6388.11 BogoMIPS 
(lpj=3194056)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
monitor/mwait feature present.
using mwait in idle threads.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (24) available
CPU0: Thermal monitoring enabled
Compat vDSO mapped to ffffe000.
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 15k freed
ACPI: Core revision 20070126
Parsing all Control Methods:
Table [DSDT](id 0001) - 295 Objects with 44 Devices 111 Methods 8 Regions
 tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
evxfevnt-0079 [00] enable                : System is already in ACPI mode
CPU0: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
Booting processor 1/1 eip 2000
CPU 1 irqstacks, hard=c050f000 soft=c04ef000
Initializing CPU#1
Calibrating delay using timer specific routine.. 6383.75 BogoMIPS 
(lpj=3191875)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (24) available
CPU1: Thermal monitoring enabled
CPU1: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
Booting processor 2/2 eip 2000
CPU 2 irqstacks, hard=c0510000 soft=c04f0000
Initializing CPU#2
Calibrating delay using timer specific routine.. 6383.77 BogoMIPS 
(lpj=3191888)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#2.
CPU2: Intel P4/Xeon Extended MCE MSRs (24) available
CPU2: Thermal monitoring enabled
CPU2: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
Booting processor 3/3 eip 2000
CPU 3 irqstacks, hard=c0511000 soft=c04f1000
Initializing CPU#3
Calibrating delay using timer specific routine.. 6383.75 BogoMIPS 
(lpj=3191876)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 
0000e43d 00000000 00000001 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: After all inits, caps: bfebfbff 20100000 00000000 0000b180 0000e43d 
00000000 00000001 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#3.
CPU3: Intel P4/Xeon Extended MCE MSRs (24) available
CPU3: Thermal monitoring enabled
CPU3: Intel(R) Xeon(TM) CPU 3.20GHz stepping 04
Total of 4 processors activated (25539.39 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
APIC timer registered as dummy, due to nmi_watchdog=1!
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
checking TSC synchronization [CPU#0 -> CPU#2]:
Measured 1056 cycles TSC warp between CPUs, turning off TSC clock.
Marking TSC unstable due to: check_tsc_sync_source failed.
Brought up 4 CPUs
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG
Setting up standard PCI resources
evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 
0x9
evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 1 Wake, Enabled 0 Runtime 
GPEs in this block
ACPI: EC: Look up EC in DSDT
Completing Region/Field/Buffer/Package initialization:.................
Initialized 5/8 Regions 0/0 Fields 9/9 Buffers 3/4 Packages (304 nodes)
Initializing Device/Processor/Thermal objects by executing _INI methods:.
Executed 1 _INI methods requiring 0 _STA executions (examined 54 objects)
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST.DWN1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST.DWN2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.PE2X._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3.PE2P._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4.PE2P._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.SBEX._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.COMP._PRT]
ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
Time: hpet clocksource has been installed.
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 0
Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode: lapic is not functional.
 lapic is not functional.
Could not switch to high resolution mode on CPU 2
Could not switch to high resolution mode on CPU 3
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 1
pnp: 00:08: ioport range 0x800-0x87f has been reserved
pnp: 00:08: ioport range 0x880-0x8bf has been reserved
pnp: 00:08: ioport range 0x8c0-0x8df has been reserved
pnp: 00:08: ioport range 0x8e0-0x8e3 has been reserved
pnp: 00:08: ioport range 0xc00-0xc7f has been reserved
pnp: 00:08: ioport range 0xca0-0xca7 has been reserved
pnp: 00:08: ioport range 0xca9-0xcab has been reserved
pnp: 00:08: ioport range 0xcad-0xcaf has been reserved
pnp: 00:09: ioport range 0xca8-0xca8 has been reserved
pnp: 00:09: ioport range 0xcac-0xcac has been reserved
pnp: 00:0a: iomem range 0xe0000000-0xefffffff could not be reserved
PCI: Bridge: 0000:07:00.0
  IO window: disabled.
  MEM window: f4000000-f7ffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:06:00.0
  IO window: disabled.
  MEM window: f4000000-f7ffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:06:01.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:05:00.0
  IO window: disabled.
  MEM window: f4000000-f7ffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:05:00.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: disabled.
  MEM window: f2000000-f7ffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:01:00.0
  IO window: e000-efff
  MEM window: fc500000-fc6fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:03.0
  IO window: e000-efff
  MEM window: fc400000-fc6fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:0b:00.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:04.0
  IO window: disabled.
  MEM window: fc300000-fc3fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:05.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:06.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:07.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:03:00.0
  IO window: disabled.
  MEM window: f8000000-fbffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: disabled.
  MEM window: f8000000-fbffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: d000-dfff
  MEM window: fc100000-fc2fffff
  PREFETCH window: d8000000-dfffffff
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:02.0 to 64
ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:05:00.0 to 64
ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:06:00.0 to 64
PCI: Setting latency timer of device 0000:07:00.0 to 64
ACPI: PCI Interrupt 0000:06:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:06:01.0 to 64
PCI: Setting latency timer of device 0000:05:00.3 to 64
ACPI: PCI Interrupt 0000:00:03.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:03.0 to 64
PCI: Setting latency timer of device 0000:01:00.0 to 64
ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:04.0 to 64
PCI: Setting latency timer of device 0000:0b:00.0 to 64
ACPI: PCI Interrupt 0000:00:05.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:05.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:06.0 to 64
PCI: Setting latency timer of device 0000:00:07.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.0 to 64
PCI: Setting latency timer of device 0000:03:00.0 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1572864 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
Machine check exception polling timer started.
IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
io scheduler noop registered
io scheduler cfq registered (default)
Boot video device is 0000:10:0d.0
PCI: Setting latency timer of device 0000:00:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:02.0:pcie00]
Allocate Port Service[0000:00:02.0:pcie01]
PCI: Setting latency timer of device 0000:00:03.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.0:pcie00]
Allocate Port Service[0000:00:03.0:pcie01]
PCI: Setting latency timer of device 0000:00:04.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:04.0:pcie00]
Allocate Port Service[0000:00:04.0:pcie01]
PCI: Setting latency timer of device 0000:00:05.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:05.0:pcie00]
Allocate Port Service[0000:00:05.0:pcie01]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie01]
PCI: Setting latency timer of device 0000:00:07.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:07.0:pcie00]
Allocate Port Service[0000:00:07.0:pcie01]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:05:00.0 to 64
Allocate Port Service[0000:05:00.0:pcie10]
Allocate Port Service[0000:05:00.0:pcie11]
PCI: Setting latency timer of device 0000:06:00.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:06:00.0:pcie20]
Allocate Port Service[0000:06:00.0:pcie21]
PCI: Setting latency timer of device 0000:06:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:06:01.0:pcie20]
Allocate Port Service[0000:06:01.0:pcie21]
AER service couldn't init device 0000:00:02.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:03.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:04.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:05.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:06.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:07.0:pcie01 - no _OSC support
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
Real Time Clock Driver v1.12ac
hpet_resources: 0xfed00000 is busy
intel_rng: FWH not detected
Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 
seconds).
Hangcheck: Using get_cycles().
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode:<6>Clockevents: could not switch to one-shot mode: 
lapic is not functional.
 lapic is not functional.
Could not switch to high resolution mode on CPU 3
Could not switch to high resolution mode on CPU 2
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 0
 lapic is not functional.
Could not switch to high resolution mode on CPU 1
floppy0: no floppy controllers found
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: module loaded
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.6.5 (September 20, 2007)
ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found 
at mem f4000000, IRQ 16, node addr 001372f873ae
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found 
at mem f8000000, IRQ 16, node addr 001372f873ac
Loading iSCSI transport class v2.0-724.
Fusion MPT base driver 3.04.05
Copyright (c) 1999-2007 LSI Logic Corporation
Fusion MPT SPI Host driver 3.04.05
Fusion MPT FC Host driver 3.04.05
Fusion MPT SAS Host driver 3.04.05
PCI: Enabling device 0000:02:08.0 (0156 -> 0157)
ACPI: PCI Interrupt 0000:02:08.0[A] -> GSI 64 (level, low) -> IRQ 17
mptbase: Initiating ioc0 bringup
ioc0: LSISAS1068 B0: Capabilities={Initiator}
scsi0 : ioc0: LSISAS1068 B0, FwRev=00062800h, Ports=1, MaxQ=511, IRQ=17
scsi 0:0:0:0: Direct-Access     ATA      WDC WD800JD-75MS 1E04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 156250000 512-byte hardware sectors (80000 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 67 00 00 08
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support 
DPO or FUA
sd 0:0:0:0: [sda] 156250000 512-byte hardware sectors (80000 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 67 00 00 08
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support 
DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
Fusion MPT misc device (ioctl) driver 3.04.05
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=10,220)
usbmon: debugfs is not available
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 21 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 128 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 18, io mem 0xfc700000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 21 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: irq 18, io base 0x0000cce0
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 20 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000ccc0
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 21 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000cca0
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 1-5: new high speed USB device using ehci_hcd and address 3
usb 1-5: configuration #1 chosen from 1 choice
hub 1-5:1.0: USB hub found
hub 1-5:1.0: 4 ports detected
usbcore: registered new interface driver usblp
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
EDAC MC: Ver: 2.1.0 Oct 10 2007
EDAC MC0: Giving out device to 'i5000_edac.c' 'I5000': DEV 0000:00:10.0
EDAC PCI0: Giving out device to module 'i5000_edac' controller 'EDAC PCI 
controller': DEV '0000:00:10.0' (POLLED)
usb 3-2: new low speed USB device using uhci_hcd and address 2
usb 3-2: configuration #1 chosen from 1 choice
input: DELL DELL USB Keyboard as /class/input/input1
input: USB HID v1.10 Keyboard [DELL DELL USB Keyboard] on usb-0000:00:1d.1-2
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Testing NMI watchdog ... OK.
Using IPI Shortcut mode
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 232k freed
net eth0_rename: device_rename: sysfs_create_symlink failed (-17)
net eth0: device_rename: sysfs_create_symlink failed (-17)
net eth1: device_rename: sysfs_create_symlink failed (-17)
libata version 2.21 loaded.
ata_piix 0000:00:1f.1: version 2.12
ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1f.1 to 64
scsi1 : ata_piix
scsi2 : ata_piix
ata1: PATA max UDMA/100 cmd 0x000101f0 ctl 0x000103f6 bmdma 0x0001fc00 irq 14
ata2: PATA max UDMA/100 cmd 0x00010170 ctl 0x00010376 bmdma 0x0001fc08 irq 15
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x0860)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
ata1.00: ATAPI: TEAC CD-ROM CD-224E-N, 3.AB, max UDMA/33
ata1.00: configured for UDMA/33
ata2: port disabled. ignoring.
scsi 1:0:0:0: CD-ROM            TEAC     CD-ROM CD-224E-N 3.AB PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sr 1:0:0:0: Attached scsi generic sg1 type 5
EXT3 FS on sda3, internal journal
ipmi message handler version 39.1
IPMI System Interface driver.
ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xca8, 
slave address 0x20, irq 0
ipmi: Found new BMC (man_id: 0x0002a2,  prod_id: 0x0100, dev_id: 0x20)
IPMI kcs interface initialized
ipmi device interface
IPMI Watchdog: Unable to register misc device
IPMI Watchdog: driver initialized
Unable to find swap-space signature
bnx2: eth1: using MSI
bnx2: eth0: using MSI
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex
device eth0.2022 entered promiscuous mode
device eth0 entered promiscuous mode
device eth0.2022 left promiscuous mode
device eth0 left promiscuous mode
device eth0.2022 entered promiscuous mode
device eth0 entered promiscuous mode
device eth0.2022 left promiscuous mode
device eth0 left promiscuous mode
device eth0.2022 entered promiscuous mode
device eth0 entered promiscuous mode
device eth0.2022 left promiscuous mode
device eth0 left promiscuous mode
device eth0.2022 entered promiscuous mode
device eth0 entered promiscuous mode
device eth0.2022 left promiscuous mode
device eth0 left promiscuous mode
u32 classifier
    Performance counters on
    input device check on
    Actions configured
device eth0.2022 entered promiscuous mode
device eth0 entered promiscuous mode
device eth0.2022 left promiscuous mode
device eth0 left promiscuous mode
trafanal[9729]: segfault at ffffffff eip b6d00030 esp b7645270 error 6
trafanal[9732]: segfault at 076eaa90 eip b7f45a07 esp 076eaa90 error 6
trafanal[9809]: segfault at 00000024 eip 0805220d esp b7db79d0 error 4
trafanal[9812]: segfault at 00000025 eip b7f66ffa esp b7e40c70 error 6
trafanal[9963]: segfault at b6cd9000 eip b7ea91a7 esp b7e3b998 error 6
trafanal[9966]: segfault at 973d037c eip b7f5e9d3 esp b760e114 error 4

>>>>here is try to switch clocksource to acpi_pm

Time: acpi_pm clocksource has been installed.
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 0
Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 3
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 1
 lapic is not functional.
Could not switch to high resolution mode on CPU 2
Time: hpet clocksource has been installed.
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 0
Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 3
Clockevents: could not switch to one-shot mode: lapic is not functional.
Could not switch to high resolution mode on CPU 1
 lapic is not functional.
Could not switch to high resolution mode on CPU 2

Kernel config
http://www.nuclearcat.com/shaper_config.gz


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

