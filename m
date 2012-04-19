From: Marco Berizzi <pupilla@hotmail.com>
Subject: rx_dropped packets stop with tcpdump running
Date: Thu, 19 Apr 2012 15:12:22 +0200
Message-ID: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s2.dub0.hotmail.com ([157.55.0.201]:5107 "EHLO
	dub0-omc1-s2.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892Ab2DSNSu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Folks,

I'm running linux 3.3.2 on slackware64
13.1 as a firewall and ipsec gateway.
I'm experimenting a problem on one of
the nics: I see the rx_dropped packets
counter increasing. Running tcpdump on
that nic (eth2) 'fix' the problem: the
counter doesn't increase anymore.
The only remarkable running daemon is
openswan 2.4.15

Same problem happens with linux 2.6.37

The connection is at 1000Mbit/s copper,
full duplex.

Any feedback are welcome
TIA

This is the output from lspci -vv about the nic:

10:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network C=
onnection
=A0=A0=A0=A0=A0=A0=A0 Subsystem: Fujitsu Technology Solutions Device 11=
92
=A0=A0=A0=A0=A0=A0=A0 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-=
 VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
=A0=A0=A0=A0=A0=A0=A0 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3D=
fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
=A0=A0=A0=A0=A0=A0=A0 Latency: 0, Cache Line Size: 64 bytes
=A0=A0=A0=A0=A0=A0=A0 Interrupt: pin A routed to IRQ 18
=A0=A0=A0=A0=A0=A0=A0 Region 0: Memory at ce420000 (32-bit, non-prefetc=
hable) [size=3D128K]
=A0=A0=A0=A0=A0=A0=A0 Region 2: I/O ports at 5000 [size=3D32]
=A0=A0=A0=A0=A0=A0=A0 Region 3: Memory at ce400000 (32-bit, non-prefetc=
hable) [size=3D16K]
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [c8] Power Management version 2
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Flags: PMEClk- DSI+ D1- D=
2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Status: D0 NoSoftRst- PME=
-Enable- DSel=3D0 DScale=3D1 PME-
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [d0] MSI: Enable- Count=3D1/1 Maska=
ble- 64bit+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Address: 0000000000000000=
=A0 Data: 0000
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [e0] Express (v1) Endpoint, MSI 00
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCap: MaxPayload 256 by=
tes, PhantFunc 0, Latency L0s <512ns, L1 <64us
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 E=
xtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCtl: Report errors: Co=
rrectable- Non-Fatal+ Fatal+ Unsupported-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 R=
lxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 M=
axPayload 128 bytes, MaxReadReq 512 bytes
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevSta: CorrErr+ UncorrEr=
r- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkCap: Port #0, Speed 2.=
5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 C=
lockPM- Surprise- LLActRep- BwNot-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkCtl: ASPM Disabled; RC=
B 64 bytes Disabled- Retrain- CommClk+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 E=
xtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkSta: Speed 2.5GT/s, Wi=
dth x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [a0] MSI-X: Enable+ Count=3D5 Maske=
d-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Vector table: BAR=3D3 off=
set=3D00000000
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 PBA: BAR=3D3 offset=3D000=
02000
=A0=A0=A0=A0=A0=A0=A0 Kernel driver in use: e1000e
=A0=A0=A0=A0=A0=A0=A0 Kernel modules: e1000e

output from dmesg and .config

Linux version 3.3.2 (root@Teti) (gcc version 4.4.4 (GCC) ) #1 SMP Wed A=
pr 18 17:08:15 CEST 2012
Command line: auto BOOT_IMAGE=3DLinux ro root=3D801 vt.default_utf8=3D0
BIOS-provided physical RAM map:
=A0BIOS-e820: 0000000000000000 - 000000000009c000 (usable)
=A0BIOS-e820: 000000000009c000 - 00000000000a0000 (reserved)
=A0BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
=A0BIOS-e820: 0000000000100000 - 000000007d7a0000 (usable)
=A0BIOS-e820: 000000007d7a0000 - 000000007f7b0000 (reserved)
=A0BIOS-e820: 000000007f7b0000 - 000000007f7bc000 (ACPI data)
=A0BIOS-e820: 000000007f7bc000 - 000000007f7bd000 (ACPI NVS)
=A0BIOS-e820: 000000007f7bd000 - 0000000080000000 (reserved)
=A0BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
=A0BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
=A0BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
=A0BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
NX (Execute Disable) protection: active
DMI present.
DMI: FUJITSU=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 PRIMERGY TX150 S7=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /=
D2759, BIOS 6.00 Rev. 1.17.2759.A1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 12/08/=
2010
e820 update range: 0000000000000000 - 0000000000010000 (usable) =3D=3D>=
 (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn =3D 0x7d7a0 max_arch_pfn =3D 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
=A0 00000-9FFFF write-back
=A0 A0000-BFFFF uncachable
=A0 C0000-C7FFF write-protect
=A0 C8000-DFFFF uncachable
=A0 E0000-FFFFF write-protect
MTRR variable ranges enabled:
=A0 0 base 000000000 mask F80000000 write-back
=A0 1 disabled
=A0 2 disabled
=A0 3 disabled
=A0 4 disabled
=A0 5 disabled
=A0 6 disabled
=A0 7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
initial memory mapped : 0 - 20000000
Base memory trampoline at [ffff88000009a000] 9a000 size 8192
init_memory_mapping: 0000000000000000-000000007d7a0000
=A00000000000 - 007d600000 page 2M
=A0007d600000 - 007d7a0000 page 4k
kernel direct mapping tables up to 7d7a0000 @ 1fffc000-20000000
ACPI: RSDP 00000000000f9790 00024 (v02 PTLTD )
ACPI: XSDT 000000007f7b55ba 000CC (v01 FSC=A0=A0=A0 PC=A0=A0=A0=A0=A0=A0=
 00060000=A0 LTP 00000000)
ACPI: FACP 000000007f7ba765 000F4 (v03 FSC=A0=A0=A0 PC=A0=A0=A0=A0=A0=A0=
 00060000 FTS=A0 000F4240)
ACPI: DSDT 000000007f7b5686 0506B (v01 FTS=A0=A0=A0 D2759=A0=A0=A0 0006=
0000 MSFT 03000001)
ACPI: FACS 000000007f7bcfc0 00040
ACPI: TCPA 000000007f7ba859 00032 (v01 Phoeni=A0 x=A0=A0=A0=A0=A0=A0 00=
060000=A0 TL=A0 00000000)
ACPI: EINJ 000000007f7ba88b 001B0 (v01 PTL=A0=A0=A0 WHEAPTL=A0 00060000=
 PTL=A0 00000001)
ACPI: HEST 000000007f7baa3b 00268 (v01 PTL=A0=A0=A0 WHEAPTL=A0 00060000=
 PTL=A0 00000001)
ACPI: BERT 000000007f7baca3 00030 (v01 PTL=A0=A0=A0 WHEAPTL=A0 00060000=
 PTL=A0 00000001)
ACPI: SSDT 000000007f7bacd3 000EB (v01 wheaos=A0 wheaosc 00060000 MSFT =
03000001)
ACPI: ERST 000000007f7badbe 00270 (v01 PTL=A0=A0=A0 WHEAPTL=A0 00060000=
 PTL=A0 00000001)
ACPI: SSDT 000000007f7bb02e 000D8 (v01 FSC=A0=A0=A0 CST_PR00 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb106 000D8 (v01 FSC=A0=A0=A0 CST_PR01 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb1de 000D8 (v01 FSC=A0=A0=A0 CST_PR04 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb2b6 000D8 (v01 FSC=A0=A0=A0 CST_PR05 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb38e 00263 (v01 FSC=A0=A0=A0 PST_PR00 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb5f1 00263 (v01 FSC=A0=A0=A0 PST_PR01 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bb854 00263 (v01 FSC=A0=A0=A0 PST_PR04 00060000=A0=
 CSF 00000001)
ACPI: SSDT 000000007f7bbab7 00263 (v01 FSC=A0=A0=A0 PST_PR05 00060000=A0=
 CSF 00000001)
ACPI: SPCR 000000007f7bbd1a 00050 (v01 PTLTD=A0 $UCRTBL$ 00060000 PTL=A0=
 00000001)
ACPI: SLIC 000000007f7bbd6a 00176 (v01 FSC=A0=A0=A0 PC=A0=A0=A0=A0=A0=A0=
 00060000=A0 LTP 00000000)
ACPI: MCFG 000000007f7bbee0 0003C (v01 PTLTD=A0=A0=A0 MCFG=A0=A0 000600=
00=A0 LTP 00000000)
ACPI: HPET 000000007f7bbf1c 00038 (v01 PTLTD=A0 HPETTBL=A0 00060000=A0 =
LTP 00000001)
ACPI: APIC 000000007f7bbf54 00084 (v01 PTLTD=A0 ? APIC=A0=A0 00060000=A0=
 LTP 00000000)
ACPI: BOOT 000000007f7bbfd8 00028 (v01 PTLTD=A0 $SBFTBL$ 00060000=A0 LT=
P 00000001)
ACPI: Local APIC address 0xfee00000
=A0[ffffea0000000000-ffffea0001ffffff] PMD -> [ffff88007ae00000-ffff880=
07cdfffff] on node 0
Zone PFN ranges:
=A0 DMA=A0=A0=A0=A0=A0 0x00000010 -> 0x00001000
=A0 DMA32=A0=A0=A0 0x00001000 -> 0x00100000
=A0 Normal=A0=A0 empty
Movable zone start PFN for each node
Early memory PFN ranges
=A0=A0=A0 0: 0x00000010 -> 0x0000009c
=A0=A0=A0 0: 0x00000100 -> 0x0007d7a0
On node 0 totalpages: 513836
=A0 DMA zone: 64 pages used for memmap
=A0 DMA zone: 2 pages reserved
=A0 DMA zone: 3914 pages, LIFO batch:0
=A0 DMA32 zone: 7967 pages used for memmap
=A0 DMA32 zone: 501889 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x05] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a701 base: 0xfed00000
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 40
Allocating PCI resources starting at 80000000 (gap: 80000000:60000000)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 25 pages/cpu @ffff88007d400000 s69696 r8192 d24512 u52=
4288
pcpu-alloc: s69696 r8192 d24512 u524288 alloc=3D1*2097152
pcpu-alloc: [0] 0 1 2 3=20
Built 1 zonelists in Zone order, mobility grouping on.=A0 Total pages: =
505803
Kernel command line: auto BOOT_IMAGE=3DLinux ro root=3D801 vt.default_u=
tf8=3D0
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Checking aperture...
No AGP bridge found
Memory: 2014828k/2055808k available (2292k kernel code, 464k absent, 40=
516k reserved, 939k data, 372k init)
SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
4, Nodes=3D1
Hierarchical RCU implementation.
NR_IRQS:4352 nr_irqs:712 16
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
hpet clockevent registered
=46ast TSC calibration using PIT
Detected 3058.766 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. 6117.53 BogoMIPS (lpj=3D3058766)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
using mwait in idle threads.
=46reeing SMP alternatives: 12k freed
ACPI: Core revision 20120111
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Intel(R) Core(TM) i3 CPU=A0=A0=A0=A0=A0=A0=A0=A0 540=A0 @ 3.07GHz=
 stepping 02
Performance Events: PEBS fmt1+, Westmere events, Intel PMU driver.
CPUID marked event: 'bus cycles' unavailable
=2E.. version:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 3
=2E.. bit width:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 48
=2E.. generic registers:=A0=A0=A0=A0=A0 4
=2E.. value mask:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0000ffffffffffff
=2E.. max period:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 000000007fffffff
=2E.. fixed-purpose events:=A0=A0 3
=2E.. event mask:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 000000070000000f
Booting Node=A0=A0 0, Processors=A0 #1
smpboot cpu 1: start_ip =3D 9a000
=A0#2
smpboot cpu 2: start_ip =3D 9a000
=A0#3 Ok.
smpboot cpu 3: start_ip =3D 9a000
Brought up 4 CPUs
Total of 4 processors activated (24470.12 BogoMIPS).
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: Using host bridge windows from ACPI; if necessary, use "pci=3Dnocr=
s" and report a bug
ACPI: PCI Root Bridge [CPU0] (domain 0000 [bus ff])
PCI: root bus ff: using default resources
PCI host bridge to bus 0000:ff
pci_bus 0000:ff: root bus resource [io=A0 0x0000-0xffff]
pci_bus 0000:ff: root bus resource [mem 0x00000000-0xfffffffff]
pci 0000:ff:00.0: [8086:2c61] type 0 class 0x000600
pci 0000:ff:00.1: [8086:2d01] type 0 class 0x000600
pci 0000:ff:02.0: [8086:2d10] type 0 class 0x000600
pci 0000:ff:02.1: [8086:2d11] type 0 class 0x000600
pci 0000:ff:02.2: [8086:2d12] type 0 class 0x000600
pci 0000:ff:02.3: [8086:2d13] type 0 class 0x000600
pci_bus 0000:ff: on NUMA node 0
=A0pci0000:ff: Unable to request _OSC control (_OSC support mask: 0x1e)
ACPI: PCI Root Bridge [CPU1] (domain 0000 [bus fe])
PCI: root bus fe: using default resources
PCI host bridge to bus 0000:fe
pci_bus 0000:fe: root bus resource [io=A0 0x0000-0xffff]
pci_bus 0000:fe: root bus resource [mem 0x00000000-0xfffffffff]
pci_bus 0000:fe: on NUMA node 0
=A0pci0000:fe: Unable to request _OSC control (_OSC support mask: 0x1e)
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3d])
pci_root PNP0A08:00: host bridge window [io=A0 0x0000-0x0cf7]
pci_root PNP0A08:00: host bridge window [io=A0 0x0d00-0xffff]
pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A08:00: host bridge window [mem 0x000c8000-0x000dffff]
pci_root PNP0A08:00: host bridge window [mem 0x80100000-0xdfffffff]
pci_root PNP0A08:00: host bridge window [mem 0xf0000000-0xfebfffff]
pci_root PNP0A08:00: host bridge window [mem 0xfed00000-0xfedfffff]
pci_root PNP0A08:00: host bridge window [mem 0xfef00000-0xffbfffff]
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io=A0 0x0000-0x0cf7]
pci_bus 0000:00: root bus resource [io=A0 0x0d00-0xffff]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000dffff]
pci_bus 0000:00: root bus resource [mem 0x80100000-0xdfffffff]
pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff]
pci_bus 0000:00: root bus resource [mem 0xfed00000-0xfedfffff]
pci_bus 0000:00: root bus resource [mem 0xfef00000-0xffbfffff]
pci 0000:00:00.0: [8086:0048] type 0 class 0x000600
pci 0000:00:01.0: [8086:0049] type 1 class 0x000604
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: [8086:3b3c] type 0 class 0x000c03
pci 0000:00:1a.0: reg 10: [mem 0xce002000-0xce0023ff]
pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: [8086:3b42] type 1 class 0x000604
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: [8086:3b4c] type 1 class 0x000604
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.6: [8086:3b4e] type 1 class 0x000604
pci 0000:00:1c.6: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.7: [8086:3b50] type 1 class 0x000604
pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.0: [8086:3b34] type 0 class 0x000c03
pci 0000:00:1d.0: reg 10: [mem 0xce003000-0xce0033ff]
pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1e.0: [8086:244e] type 1 class 0x000604
pci 0000:00:1f.0: [8086:3b14] type 0 class 0x000601
pci 0000:00:1f.2: [8086:3b20] type 0 class 0x000101
pci 0000:00:1f.2: reg 10: [io=A0 0x1890-0x1897]
pci 0000:00:1f.2: reg 14: [io=A0 0x1884-0x1887]
pci 0000:00:1f.2: reg 18: [io=A0 0x1888-0x188f]
pci 0000:00:1f.2: reg 1c: [io=A0 0x1880-0x1883]
pci 0000:00:1f.2: reg 20: [io=A0 0x1850-0x185f]
pci 0000:00:1f.2: reg 24: [io=A0 0x1840-0x184f]
pci 0000:00:1f.3: [8086:3b30] type 0 class 0x000c05
pci 0000:00:1f.3: reg 10: [mem 0xce004000-0xce0040ff 64bit]
pci 0000:00:1f.3: reg 20: [io=A0 0x1820-0x183f]
pci 0000:00:1f.5: [8086:3b26] type 0 class 0x000101
pci 0000:00:1f.5: reg 10: [io=A0 0x18a8-0x18af]
pci 0000:00:1f.5: reg 14: [io=A0 0x189c-0x189f]
pci 0000:00:1f.5: reg 18: [io=A0 0x18a0-0x18a7]
pci 0000:00:1f.5: reg 1c: [io=A0 0x1898-0x189b]
pci 0000:00:1f.5: reg 20: [io=A0 0x1870-0x187f]
pci 0000:00:1f.5: reg 24: [io=A0 0x1860-0x186f]
pci 0000:01:00.0: [1000:0073] type 0 class 0x000104
pci 0000:01:00.0: reg 10: [io=A0 0x2000-0x20ff]
pci 0000:01:00.0: reg 14: [mem 0xce100000-0xce103fff 64bit]
pci 0000:01:00.0: reg 1c: [mem 0xce180000-0xce1bffff 64bit]
pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0003ffff pref]
pci 0000:01:00.0: supports D1 D2
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:=A0=A0 bridge window [io=A0 0x2000-0x2fff]
pci 0000:00:01.0:=A0=A0 bridge window [mem 0xce100000-0xce1fffff]
pci 0000:05:00.0: [8086:107d] type 0 class 0x000200
pci 0000:05:00.0: reg 10: [mem 0xce240000-0xce25ffff]
pci 0000:05:00.0: reg 14: [mem 0xce220000-0xce23ffff]
pci 0000:05:00.0: reg 18: [io=A0 0x3000-0x301f]
pci 0000:05:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.=A0 You can ena=
ble it with 'pcie_aspm=3Dforce'
pci 0000:00:1c.0: PCI bridge to [bus 05-05]
pci 0000:00:1c.0:=A0=A0 bridge window [io=A0 0x3000-0x3fff]
pci 0000:00:1c.0:=A0=A0 bridge window [mem 0xce200000-0xce2fffff]
pci 0000:0f:00.0: [8086:107d] type 0 class 0x000200
pci 0000:0f:00.0: reg 10: [mem 0xce340000-0xce35ffff]
pci 0000:0f:00.0: reg 14: [mem 0xce320000-0xce33ffff]
pci 0000:0f:00.0: reg 18: [io=A0 0x4000-0x401f]
pci 0000:0f:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
pci 0000:0f:00.0: PME# supported from D0 D3hot D3cold
pci 0000:0f:00.0: disabling ASPM on pre-1.1 PCIe device.=A0 You can ena=
ble it with 'pcie_aspm=3Dforce'
pci 0000:00:1c.5: PCI bridge to [bus 0f-0f]
pci 0000:00:1c.5:=A0=A0 bridge window [io=A0 0x4000-0x4fff]
pci 0000:00:1c.5:=A0=A0 bridge window [mem 0xce300000-0xce3fffff]
pci 0000:10:00.0: [8086:10d3] type 0 class 0x000200
pci 0000:10:00.0: reg 10: [mem 0xce420000-0xce43ffff]
pci 0000:10:00.0: reg 18: [io=A0 0x5000-0x501f]
pci 0000:10:00.0: reg 1c: [mem 0xce400000-0xce403fff]
pci 0000:10:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.6: PCI bridge to [bus 10-10]
pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 0x5000-0x5fff]
pci 0000:00:1c.6:=A0=A0 bridge window [mem 0xce400000-0xce4fffff]
pci 0000:11:00.0: [102b:0522] type 0 class 0x000300
pci 0000:11:00.0: reg 10: [mem 0xcf000000-0xcfffffff pref]
pci 0000:11:00.0: reg 14: [mem 0xce500000-0xce503fff]
pci 0000:11:00.0: reg 18: [mem 0xce800000-0xceffffff]
pci 0000:11:00.0: disabling ASPM on pre-1.1 PCIe device.=A0 You can ena=
ble it with 'pcie_aspm=3Dforce'
pci 0000:00:1c.7: PCI bridge to [bus 11-11]
pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xce500000-0xceffffff]
pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xcf000000-0xcfffffff 64bit =
pref]
pci 0000:00:1e.0: PCI bridge to [bus 12-12] (subtractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [io=A0 0x0000-0x0cf7] (subtractiv=
e decode)
pci 0000:00:1e.0:=A0=A0 bridge window [io=A0 0x0d00-0xffff] (subtractiv=
e decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0x000a0000-0x000bffff] (subt=
ractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0x000c8000-0x000dffff] (subt=
ractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0x80100000-0xdfffffff] (subt=
ractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0xf0000000-0xfebfffff] (subt=
ractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0xfed00000-0xfedfffff] (subt=
ractive decode)
pci 0000:00:1e.0:=A0=A0 bridge window [mem 0xfef00000-0xffbfffff] (subt=
ractive decode)
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PE1_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX8._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIH._PRT]
=A0pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
ACPI: PCI Interrupt Link [LNKA] (IRQs 9 10 *11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 9 10 *11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 9 10 *11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 9 10 *11)
ACPI: PCI Interrupt Link [LNKE] (IRQs 9 10 *11)
ACPI: PCI Interrupt Link [LNKF] (IRQs 9 *10 11)
ACPI: PCI Interrupt Link [LNKG] (IRQs *9 10 11)
ACPI: PCI Interrupt Link [LNKH] (IRQs 9 10 11) *5
vgaarb: device added: PCI:0000:11:00.0,decodes=3Dio+mem,owns=3Dio+mem,l=
ocks=3Dnone
vgaarb: loaded
vgaarb: bridge control possible 0000:11:00.0
SCSI subsystem initialized
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
Expanded resource reserved due to conflict with PCI Bus 0000:00
reserve RAM buffer: 000000000009c000 - 000000000009ffff=20
reserve RAM buffer: 000000007d7a0000 - 000000007fffffff=20
Switching to clocksource hpet
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [mem 0xe0000000-0xefffffff window]
system 00:00: [mem 0xe0000000-0xefffffff window] has been reserved
system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:01: [bus ff]
pnp 00:01: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:02: [bus fe]
pnp 00:02: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:03: [bus 00-3d]
pnp 00:03: [io=A0 0x0000-0x0cf7 window]
pnp 00:03: [io=A0 0x0cf8-0x0cff]
pnp 00:03: [io=A0 0x0d00-0xffff window]
pnp 00:03: [mem 0x000a0000-0x000bffff window]
pnp 00:03: [mem 0x000c8000-0x000dffff window]
pnp 00:03: [mem 0x80100000-0xdfffffff window]
pnp 00:03: [mem 0xf0000000-0xfebfffff window]
pnp 00:03: [mem 0xfed00000-0xfedfffff window]
pnp 00:03: [mem 0xfef00000-0xffbfffff window]
pnp 00:03: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
pnp 00:04: [io=A0 0x0010-0x001f]
pnp 00:04: [io=A0 0x0022-0x002d]
pnp 00:04: [io=A0 0x002e-0x002f]
pnp 00:04: [io=A0 0x0030-0x003f]
pnp 00:04: [io=A0 0x004e-0x004f]
pnp 00:04: [io=A0 0x0050-0x0053]
pnp 00:04: [io=A0 0x0060-0x006f]
pnp 00:04: [io=A0 0x0072-0x0073]
pnp 00:04: [io=A0 0x0074-0x007f]
pnp 00:04: [io=A0 0x0090-0x009f]
pnp 00:04: [io=A0 0x00a2-0x00b1]
pnp 00:04: [io=A0 0x00b2-0x00b3]
pnp 00:04: [io=A0 0x00b4-0x00bf]
pnp 00:04: [io=A0 0x00e0-0x00ef]
pnp 00:04: [io=A0 0x0200-0x020f]
pnp 00:04: [io=A0 0x04d0-0x04d1]
pnp 00:04: [io=A0 0x0500-0x057f]
pnp 00:04: [io=A0 0x0800-0x080f]
pnp 00:04: [io=A0 0x0810-0x081f]
pnp 00:04: [io=A0 0x0ca0-0x0ca1]
pnp 00:04: [io=A0 0x0ca4-0x0ca7]
pnp 00:04: [io=A0 0x0ca8-0x0cab]
pnp 00:04: [io=A0 0x0cae-0x0caf]
pnp 00:04: [io=A0 0x0e00-0x0e7f]
pnp 00:04: [io=A0 0x1000-0x107f]
pnp 00:04: [io=A0 0x1100-0x110f]
pnp 00:04: [io=A0 0x1180-0x11ff]
pnp 00:04: [io=A0 0xfe00]
pnp 00:04: [io=A0 0xff00]
pnp 00:04: [mem 0xfe710000-0xfe711fff]
pnp 00:04: [mem 0xfe713000-0xfe713fff]
pnp 00:04: [mem 0xfec00000-0xfecfffff]
pnp 00:04: [mem 0xfee00000-0xfeefffff]
pnp 00:04: [mem 0xfed1c000-0xfed1ffff]
system 00:04: [io=A0 0x0200-0x020f] has been reserved
system 00:04: [io=A0 0x04d0-0x04d1] has been reserved
system 00:04: [io=A0 0x0500-0x057f] has been reserved
system 00:04: [io=A0 0x0800-0x080f] has been reserved
system 00:04: [io=A0 0x0810-0x081f] has been reserved
system 00:04: [io=A0 0x0ca0-0x0ca1] has been reserved
system 00:04: [io=A0 0x0ca4-0x0ca7] has been reserved
system 00:04: [io=A0 0x0ca8-0x0cab] has been reserved
system 00:04: [io=A0 0x0cae-0x0caf] has been reserved
system 00:04: [io=A0 0x0e00-0x0e7f] has been reserved
system 00:04: [io=A0 0x1000-0x107f] has been reserved
system 00:04: [io=A0 0x1100-0x110f] has been reserved
system 00:04: [io=A0 0x1180-0x11ff] has been reserved
system 00:04: [io=A0 0xfe00] has been reserved
system 00:04: [io=A0 0xff00] has been reserved
system 00:04: [mem 0xfe710000-0xfe711fff] has been reserved
system 00:04: [mem 0xfe713000-0xfe713fff] has been reserved
system 00:04: [mem 0xfec00000-0xfecfffff] could not be reserved
system 00:04: [mem 0xfee00000-0xfeefffff] could not be reserved
system 00:04: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:05: [io=A0 0x0000-0x000f]
pnp 00:05: [io=A0 0x0080-0x008f]
pnp 00:05: [io=A0 0x00c0-0x00df]
pnp 00:05: [dma 4]
pnp 00:05: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:06: [io=A0 0x0070-0x0071]
pnp 00:06: [irq 8]
pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:07: [io=A0 0x00f0-0x00fe]
pnp 00:07: [irq 13]
pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:08: [io=A0 0x0061]
pnp 00:08: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:09: [mem 0xfed00000-0xfed003ff]
pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:0a: [io=A0 0x03f8-0x03ff]
pnp 00:0a: [irq 4]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: [io=A0 0x02f8-0x02ff]
pnp 00:0b: [irq 3]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0c: [io=A0 0x0ca2-0x0ca3]
pnp 00:0c: Plug and Play ACPI device, IDs IPI0001 (active)
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
PCI: max bus depth: 1 pci_try_num: 2
pci 0000:00:01.0: BAR 9: assigned [mem 0x80100000-0x801fffff pref]
pci 0000:00:1c.0: BAR 9: assigned [mem 0x80200000-0x802fffff pref]
pci 0000:00:1c.5: BAR 9: assigned [mem 0x80300000-0x803fffff pref]
pci 0000:00:1c.7: BAR 7: assigned [io=A0 0x6000-0x6fff]
pci 0000:00:1c.6: BAR 9: assigned [mem 0x80400000-0x805fffff 64bit pref=
]
pci 0000:00:1c.5: BAR 9: assigned [mem 0x80600000-0x808fffff pref]
pci 0000:00:1c.0: BAR 9: assigned [mem 0x80900000-0x80bfffff pref]
pci 0000:01:00.0: BAR 6: assigned [mem 0x80100000-0x8013ffff pref]
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:=A0=A0 bridge window [io=A0 0x2000-0x2fff]
pci 0000:00:01.0:=A0=A0 bridge window [mem 0xce100000-0xce1fffff]
pci 0000:00:01.0:=A0=A0 bridge window [mem 0x80100000-0x801fffff pref]
pci 0000:05:00.0: BAR 6: assigned [mem 0x80900000-0x8091ffff pref]
pci 0000:00:1c.0: PCI bridge to [bus 05-05]
pci 0000:00:1c.0:=A0=A0 bridge window [io=A0 0x3000-0x3fff]
pci 0000:00:1c.0:=A0=A0 bridge window [mem 0xce200000-0xce2fffff]
pci 0000:00:1c.0:=A0=A0 bridge window [mem 0x80900000-0x80bfffff pref]
pci 0000:0f:00.0: BAR 6: assigned [mem 0x80600000-0x8061ffff pref]
pci 0000:00:1c.5: PCI bridge to [bus 0f-0f]
pci 0000:00:1c.5:=A0=A0 bridge window [io=A0 0x4000-0x4fff]
pci 0000:00:1c.5:=A0=A0 bridge window [mem 0xce300000-0xce3fffff]
pci 0000:00:1c.5:=A0=A0 bridge window [mem 0x80600000-0x808fffff pref]
pci 0000:00:1c.6: PCI bridge to [bus 10-10]
pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 0x5000-0x5fff]
pci 0000:00:1c.6:=A0=A0 bridge window [mem 0xce400000-0xce4fffff]
pci 0000:00:1c.6:=A0=A0 bridge window [mem 0x80400000-0x805fffff 64bit =
pref]
pci 0000:00:1c.7: PCI bridge to [bus 11-11]
pci 0000:00:1c.7:=A0=A0 bridge window [io=A0 0x6000-0x6fff]
pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xce500000-0xceffffff]
pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xcf000000-0xcfffffff 64bit =
pref]
pci 0000:00:1e.0: PCI bridge to [bus 12-12]
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:ff: resource 4 [io=A0 0x0000-0xffff]
pci_bus 0000:ff: resource 5 [mem 0x00000000-0xfffffffff]
pci_bus 0000:fe: resource 4 [io=A0 0x0000-0xffff]
pci_bus 0000:fe: resource 5 [mem 0x00000000-0xfffffffff]
pci_bus 0000:00: resource 4 [io=A0 0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [io=A0 0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0x000c8000-0x000dffff]
pci_bus 0000:00: resource 8 [mem 0x80100000-0xdfffffff]
pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:00: resource 10 [mem 0xfed00000-0xfedfffff]
pci_bus 0000:00: resource 11 [mem 0xfef00000-0xffbfffff]
pci_bus 0000:01: resource 0 [io=A0 0x2000-0x2fff]
pci_bus 0000:01: resource 1 [mem 0xce100000-0xce1fffff]
pci_bus 0000:01: resource 2 [mem 0x80100000-0x801fffff pref]
pci_bus 0000:05: resource 0 [io=A0 0x3000-0x3fff]
pci_bus 0000:05: resource 1 [mem 0xce200000-0xce2fffff]
pci_bus 0000:05: resource 2 [mem 0x80900000-0x80bfffff pref]
pci_bus 0000:0f: resource 0 [io=A0 0x4000-0x4fff]
pci_bus 0000:0f: resource 1 [mem 0xce300000-0xce3fffff]
pci_bus 0000:0f: resource 2 [mem 0x80600000-0x808fffff pref]
pci_bus 0000:10: resource 0 [io=A0 0x5000-0x5fff]
pci_bus 0000:10: resource 1 [mem 0xce400000-0xce4fffff]
pci_bus 0000:10: resource 2 [mem 0x80400000-0x805fffff 64bit pref]
pci_bus 0000:11: resource 0 [io=A0 0x6000-0x6fff]
pci_bus 0000:11: resource 1 [mem 0xce500000-0xceffffff]
pci_bus 0000:11: resource 2 [mem 0xcf000000-0xcfffffff 64bit pref]
pci_bus 0000:12: resource 4 [io=A0 0x0000-0x0cf7]
pci_bus 0000:12: resource 5 [io=A0 0x0d00-0xffff]
pci_bus 0000:12: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:12: resource 7 [mem 0x000c8000-0x000dffff]
pci_bus 0000:12: resource 8 [mem 0x80100000-0xdfffffff]
pci_bus 0000:12: resource 9 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:12: resource 10 [mem 0xfed00000-0xfedfffff]
pci_bus 0000:12: resource 11 [mem 0xfef00000-0xffbfffff]
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 1024 (order: 3, 32768 bytes)
UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
NET: Registered protocol family 1
PCI: CLS mismatch (32 !=3D 64), using 64 bytes
pci 0000:11:00.0: Boot video device
Simple Boot Flag at 0x50 set to 0x80
SGI XFS with security attributes, large block/inode numbers, no debug e=
nabled
msgmni has been set to 3935
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler cfq registered (default)
megasas: 00.00.06.14-rc1 Fri. Jan. 6 17:00:00 PDT 2012
megasas: 0x1000:0x0073:0x1734:0x1177: bus 1:slot 0:func 0
megasas: FW now in Ready state
megaraid_sas 0000:01:00.0: irq 40 for MSI/MSI-X
megasas_init_mfi: fw_support_ieee=3D67108864
megasas: INIT adapter done
scsi0 : LSI SAS based MegaRAID driver
scsi 0:0:4:0: Direct-Access=A0=A0=A0=A0 SEAGATE=A0 ST3146356SS=A0=A0=A0=
=A0=A0 1606 PQ: 0 ANSI: 5
scsi 0:0:5:0: Direct-Access=A0=A0=A0=A0 SEAGATE=A0 ST3146356SS=A0=A0=A0=
=A0=A0 1606 PQ: 0 ANSI: 5
scsi 0:2:0:0: Direct-Access=A0=A0=A0=A0 FTS=A0=A0=A0=A0=A0 RAID SAS 6G =
0/1=A0 2.0. PQ: 0 ANSI: 5
sd 0:2:0:0: [sda] 285671424 512-byte logical blocks: (146 GB/136 GiB)
i8042: PNP: No PS/2 controller found. Probing ports directly.
sd 0:2:0:0: [sda] Write Protect is off
sd 0:2:0:0: [sda] Mode Sense: 1f 00 10 08
sd 0:2:0:0: [sda] Write cache: disabled, read cache: disabled, supports=
 DPO and FUA
=A0sda: sda1 sda2 < sda5 sda6 sda7 sda8 sda9 >
sd 0:2:0:0: [sda] Attached SCSI disk
serio: i8042 KBD port at 0x60,0x64 irq 1
mousedev: PS/2 mouse device common for all mice
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
XFS (sda1): Mounting Filesystem
XFS (sda1): Ending clean mount
VFS: Mounted root (xfs filesystem) readonly on device 8:1.
=46reeing unused kernel memory: 372k freed
Refined TSC clocksource calibration: 3058.980 MHz.
Switching to clocksource tsc
udevd (495): /proc/495/oom_adj is deprecated, please use /proc/495/oom_=
score_adj instead.
ACPI: acpi_idle registered with cpuidle
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.0: setting latency timer to 64
ehci_hcd 0000:00:1a.0: EHCI Host Controller
ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.0: debug port 2
ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1a.0: irq 21, io mem 0xce002000
e1000e 0000:05:00.0: Disabling ASPM=A0 L1
e1000e 0000:05:00.0: irq 41 for MSI/MSI-X
ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ehci_hcd 0000:00:1d.0: setting latency timer to 64
ehci_hcd 0000:00:1d.0: EHCI Host Controller
ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.0: debug port 2
ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1d.0: irq 20, io mem 0xce003000
ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
e1000e 0000:05:00.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:15:17:f9:5=
4:0e
e1000e 0000:05:00.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:05:00.0: eth0: MAC: 1, PHY: 4, PBA No: D50858-006
e1000e 0000:0f:00.0: Disabling ASPM=A0 L1
e1000e 0000:0f:00.0: irq 42 for MSI/MSI-X
usb 1-1: new high-speed USB device number 2 using ehci_hcd
e1000e 0000:0f:00.0: eth1: (PCI Express:2.5GT/s:Width x1) 00:15:17:f9:5=
4:0f
e1000e 0000:0f:00.0: eth1: Intel(R) PRO/1000 Network Connection
e1000e 0000:0f:00.0: eth1: MAC: 1, PHY: 4, PBA No: D50858-006
e1000e 0000:10:00.0: Disabling ASPM L0s=20
e1000e 0000:10:00.0: irq 43 for MSI/MSI-X
e1000e 0000:10:00.0: irq 44 for MSI/MSI-X
e1000e 0000:10:00.0: irq 45 for MSI/MSI-X
hub 1-1:1.0: USB hub found
hub 1-1:1.0: 6 ports detected
e1000e 0000:10:00.0: eth2: (PCI Express:2.5GT/s:Width x1) 00:19:99:ab:2=
e:f6
e1000e 0000:10:00.0: eth2: Intel(R) PRO/1000 Network Connection
e1000e 0000:10:00.0: eth2: MAC: 3, PHY: 8, PBA No: 313132-030
Adding 4273252k swap on /dev/sda9.=A0 Priority:-1 extents:1 across:4273=
252k=20
usb 2-1: new high-speed USB device number 2 using ehci_hcd
hub 2-1:1.0: USB hub found
hub 2-1:1.0: 8 ports detected
usb 1-1.1: new low-speed USB device number 3 using ehci_hcd
input:=A0=A0 USB Keyboard as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/=
1-1.1/1-1.1:1.0/input/input0
generic-usb 0003:1241:1603.0001: input: USB HID v1.10 Keyboard [=A0 USB=
 Keyboard] on usb-0000:00:1a.0-1.1/input0
input:=A0=A0 USB Keyboard as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/=
1-1.1/1-1.1:1.1/input/input1
generic-usb 0003:1241:1603.0002: input: USB HID v1.10 Device [=A0 USB K=
eyboard] on usb-0000:00:1a.0-1.1/input1
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
XFS (sda5): Mounting Filesystem
XFS (sda5): Ending clean mount
XFS (sda6): Mounting Filesystem
XFS (sda6): Ending clean mount
XFS (sda7): Mounting Filesystem
XFS (sda7): Ending clean mount
XFS (sda8): Mounting Filesystem
XFS (sda8): Ending clean mount
e1000e 0000:05:00.0: irq 41 for MSI/MSI-X
e1000e 0000:05:00.0: irq 41 for MSI/MSI-X
e1000e 0000:0f:00.0: irq 42 for MSI/MSI-X
e1000e 0000:0f:00.0: irq 42 for MSI/MSI-X
ip_tables: (C) 2000-2006 Netfilter Core Team
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
e1000e: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
e1000e 0000:0f:00.0: eth1: 10/100 speed: disabling TSO
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
NET: Registered protocol family 15
sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.3.2 Kernel Configuration
#
CONFIG_64BIT=3Dy
CONFIG_X86_64=3Dy
CONFIG_X86=3Dy
CONFIG_INSTRUCTION_DECODER=3Dy
CONFIG_OUTPUT_FORMAT=3D"elf64-x86-64"
CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=3Dy
CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
CONFIG_GENERIC_CLOCKEVENTS=3Dy
CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
CONFIG_MMU=3Dy
CONFIG_NEED_DMA_MAP_STATE=3Dy
CONFIG_NEED_SG_DMA_LENGTH=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_BUG=3Dy
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_GENERIC_TIME_VSYSCALL=3Dy
CONFIG_ARCH_HAS_CPU_RELAX=3Dy
CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_AUDIT_ARCH=3Dy
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
CONFIG_X86_64_SMP=3Dy
CONFIG_X86_HT=3Dy
CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-rdi -fcall-saved-rsi -fcall-=
saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved=
-r10 -fcall-saved-r11"
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=3Dy
CONFIG_IRQ_WORK=3Dy

CONFIG_INIT_ENV_ARG_LIMIT=3D32
CONFIG_CROSS_COMPILE=3D""
CONFIG_LOCALVERSION=3D""
CONFIG_HAVE_KERNEL_GZIP=3Dy
CONFIG_HAVE_KERNEL_BZIP2=3Dy
CONFIG_HAVE_KERNEL_LZMA=3Dy
CONFIG_HAVE_KERNEL_XZ=3Dy
CONFIG_HAVE_KERNEL_LZO=3Dy
CONFIG_KERNEL_GZIP=3Dy
CONFIG_DEFAULT_HOSTNAME=3D"(none)"
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_BSD_PROCESS_ACCT=3Dy
CONFIG_HAVE_GENERIC_HARDIRQS=3Dy

CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_HAVE_SPARSE_IRQ=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_GENERIC_IRQ_SHOW=3Dy
CONFIG_GENERIC_PENDING_IRQ=3Dy
CONFIG_IRQ_FORCED_THREADING=3Dy
CONFIG_SPARSE_IRQ=3Dy

CONFIG_TREE_RCU=3Dy
CONFIG_RCU_FANOUT=3D64
CONFIG_LOG_BUF_SHIFT=3D18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
CONFIG_NAMESPACES=3Dy
CONFIG_UTS_NS=3Dy
CONFIG_IPC_NS=3Dy
CONFIG_PID_NS=3Dy
CONFIG_NET_NS=3Dy
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
CONFIG_ANON_INODES=3Dy
CONFIG_KALLSYMS=3Dy
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_PCSPKR_PLATFORM=3Dy
CONFIG_HAVE_PCSPKR_PLATFORM=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_TIMERFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_SHMEM=3Dy
CONFIG_AIO=3Dy
CONFIG_HAVE_PERF_EVENTS=3Dy

CONFIG_PERF_EVENTS=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_PCI_QUIRKS=3Dy
CONFIG_SLUB_DEBUG=3Dy
CONFIG_SLUB=3Dy
CONFIG_HAVE_OPROFILE=3Dy
CONFIG_OPROFILE_NMI_TIMER=3Dy
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
CONFIG_HAVE_IOREMAP_PROT=3Dy
CONFIG_HAVE_KPROBES=3Dy
CONFIG_HAVE_KRETPROBES=3Dy
CONFIG_HAVE_OPTPROBES=3Dy
CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
CONFIG_HAVE_DMA_ATTRS=3Dy
CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
CONFIG_HAVE_DMA_API_DEBUG=3Dy
CONFIG_HAVE_HW_BREAKPOINT=3Dy
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=3Dy
CONFIG_HAVE_CMPXCHG_LOCAL=3Dy
CONFIG_HAVE_CMPXCHG_DOUBLE=3Dy

CONFIG_SLABINFO=3Dy
CONFIG_RT_MUTEXES=3Dy
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
CONFIG_MODULE_UNLOAD=3Dy
CONFIG_STOP_MACHINE=3Dy
CONFIG_BLOCK=3Dy
CONFIG_BLK_DEV_BSG=3Dy

CONFIG_MSDOS_PARTITION=3Dy

CONFIG_IOSCHED_NOOP=3Dy
CONFIG_IOSCHED_CFQ=3Dy
CONFIG_DEFAULT_CFQ=3Dy
CONFIG_DEFAULT_IOSCHED=3D"cfq"
CONFIG_INLINE_SPIN_UNLOCK=3Dy
CONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy
CONFIG_INLINE_READ_UNLOCK=3Dy
CONFIG_INLINE_READ_UNLOCK_IRQ=3Dy
CONFIG_INLINE_WRITE_UNLOCK=3Dy
CONFIG_INLINE_WRITE_UNLOCK_IRQ=3Dy
CONFIG_MUTEX_SPIN_ON_OWNER=3Dy

CONFIG_ZONE_DMA=3Dy
CONFIG_TICK_ONESHOT=3Dy
CONFIG_NO_HZ=3Dy
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=3Dy
CONFIG_SMP=3Dy
CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
CONFIG_NO_BOOTMEM=3Dy
CONFIG_MCORE2=3Dy
CONFIG_X86_INTERNODE_CACHE_SHIFT=3D6
CONFIG_X86_CMPXCHG=3Dy
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_XADD=3Dy
CONFIG_X86_WP_WORKS_OK=3Dy
CONFIG_X86_INTEL_USERCOPY=3Dy
CONFIG_X86_USE_PPRO_CHECKSUM=3Dy
CONFIG_X86_P6_NOP=3Dy
CONFIG_X86_TSC=3Dy
CONFIG_X86_CMPXCHG64=3Dy
CONFIG_X86_CMOV=3Dy
CONFIG_X86_MINIMUM_CPU_FAMILY=3D64
CONFIG_X86_DEBUGCTLMSR=3Dy
CONFIG_CPU_SUP_INTEL=3Dy
CONFIG_CPU_SUP_AMD=3Dy
CONFIG_CPU_SUP_CENTAUR=3Dy
CONFIG_HPET_TIMER=3Dy
CONFIG_DMI=3Dy
CONFIG_GART_IOMMU=3Dy
CONFIG_SWIOTLB=3Dy
CONFIG_IOMMU_HELPER=3Dy
CONFIG_NR_CPUS=3D4
CONFIG_SCHED_MC=3Dy
CONFIG_PREEMPT_NONE=3Dy
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy
CONFIG_DIRECT_GBPAGES=3Dy
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy
CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
CONFIG_ILLEGAL_POINTER_VALUE=3D0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=3Dy
CONFIG_SPARSEMEM_MANUAL=3Dy
CONFIG_SPARSEMEM=3Dy
CONFIG_HAVE_MEMORY_PRESENT=3Dy
CONFIG_SPARSEMEM_EXTREME=3Dy
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=3Dy
CONFIG_SPARSEMEM_VMEMMAP=3Dy
CONFIG_HAVE_MEMBLOCK=3Dy
CONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy
CONFIG_ARCH_DISCARD_MEMBLOCK=3Dy
CONFIG_PAGEFLAGS_EXTENDED=3Dy
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_PHYS_ADDR_T_64BIT=3Dy
CONFIG_ZONE_DMA_FLAG=3D1
CONFIG_BOUNCE=3Dy
CONFIG_VIRT_TO_BUS=3Dy
CONFIG_DEFAULT_MMAP_MIN_ADDR=3D4096
CONFIG_X86_RESERVE_LOW=3D64
CONFIG_MTRR=3Dy
CONFIG_X86_PAT=3Dy
CONFIG_ARCH_USES_PG_UNCACHED=3Dy
CONFIG_ARCH_RANDOM=3Dy
CONFIG_SECCOMP=3Dy
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000
CONFIG_SCHED_HRTICK=3Dy
CONFIG_PHYSICAL_START=3D0x1000000
CONFIG_PHYSICAL_ALIGN=3D0x1000000
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy

CONFIG_ACPI=3Dy
CONFIG_ACPI_PROCESSOR=3Dm
CONFIG_ACPI_THERMAL=3Dm
CONFIG_ACPI_BLACKLIST_YEAR=3D0
CONFIG_X86_PM_TIMER=3Dy

CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_TABLE=3Dm
CONFIG_CPU_FREQ_STAT=3Dm
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dm
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dm
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dm
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dm

CONFIG_X86_PCC_CPUFREQ=3Dm
CONFIG_X86_ACPI_CPUFREQ=3Dm

CONFIG_CPU_IDLE=3Dy
CONFIG_CPU_IDLE_GOV_LADDER=3Dy
CONFIG_CPU_IDLE_GOV_MENU=3Dy


CONFIG_PCI=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_DOMAINS=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_PCIEASPM=3Dy
CONFIG_ARCH_SUPPORTS_MSI=3Dy
CONFIG_PCI_MSI=3Dy
CONFIG_HT_IRQ=3Dy
CONFIG_PCI_IOAPIC=3Dy
CONFIG_PCI_LABEL=3Dy
CONFIG_ISA_DMA_API=3Dy
CONFIG_AMD_NB=3Dy

CONFIG_BINFMT_ELF=3Dy
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=3Dy
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=3Dy
CONFIG_HAVE_TEXT_POKE_SMP=3Dy
CONFIG_NET=3Dy

CONFIG_PACKET=3Dy
CONFIG_UNIX=3Dy
CONFIG_XFRM=3Dy
CONFIG_XFRM_USER=3Dy
CONFIG_XFRM_IPCOMP=3Dm
CONFIG_NET_KEY=3Dm
CONFIG_INET=3Dy
CONFIG_IP_ADVANCED_ROUTER=3Dy
CONFIG_IP_MULTIPLE_TABLES=3Dy
CONFIG_IP_ROUTE_MULTIPATH=3Dy
CONFIG_IP_ROUTE_VERBOSE=3Dy
CONFIG_IP_ROUTE_CLASSID=3Dy
CONFIG_NET_IPIP=3Dm
CONFIG_SYN_COOKIES=3Dy
CONFIG_INET_ESP=3Dm
CONFIG_INET_IPCOMP=3Dm
CONFIG_INET_XFRM_TUNNEL=3Dm
CONFIG_INET_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_TRANSPORT=3Dm
CONFIG_INET_XFRM_MODE_TUNNEL=3Dm
CONFIG_INET_LRO=3Dy
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
CONFIG_NETFILTER=3Dy
CONFIG_NETFILTER_ADVANCED=3Dy

CONFIG_NETFILTER_NETLINK=3Dm
CONFIG_NETFILTER_NETLINK_QUEUE=3Dm
CONFIG_NETFILTER_NETLINK_LOG=3Dm
CONFIG_NF_CONNTRACK=3Dm
CONFIG_NF_CONNTRACK_MARK=3Dy
CONFIG_NF_CONNTRACK_PROCFS=3Dy
CONFIG_NF_CT_PROTO_GRE=3Dm
CONFIG_NF_CONNTRACK_FTP=3Dm
CONFIG_NF_CONNTRACK_H323=3Dm
CONFIG_NF_CONNTRACK_IRC=3Dm
CONFIG_NF_CONNTRACK_BROADCAST=3Dm
CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dm
CONFIG_NF_CONNTRACK_PPTP=3Dm
CONFIG_NF_CONNTRACK_SIP=3Dm
CONFIG_NF_CONNTRACK_TFTP=3Dm
CONFIG_NF_CT_NETLINK=3Dm
CONFIG_NETFILTER_XTABLES=3Dm

CONFIG_NETFILTER_XT_MARK=3Dm
CONFIG_NETFILTER_XT_CONNMARK=3Dm

CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dm
CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_DSCP=3Dm
CONFIG_NETFILTER_XT_TARGET_HL=3Dm
CONFIG_NETFILTER_XT_TARGET_MARK=3Dm
CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dm
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dm
CONFIG_NETFILTER_XT_TARGET_RATEEST=3Dm
CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm

CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
CONFIG_NETFILTER_XT_MATCH_DCCP=3Dm
CONFIG_NETFILTER_XT_MATCH_DSCP=3Dm
CONFIG_NETFILTER_XT_MATCH_ESP=3Dm
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
CONFIG_NETFILTER_XT_MATCH_HL=3Dm
CONFIG_NETFILTER_XT_MATCH_IPRANGE=3Dm
CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_MARK=3Dm
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dm
CONFIG_NETFILTER_XT_MATCH_POLICY=3Dm
CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
CONFIG_NETFILTER_XT_MATCH_STATE=3Dm
CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dm
CONFIG_NETFILTER_XT_MATCH_TIME=3Dm
CONFIG_NETFILTER_XT_MATCH_U32=3Dm

CONFIG_NF_DEFRAG_IPV4=3Dm
CONFIG_NF_CONNTRACK_IPV4=3Dm
CONFIG_IP_NF_IPTABLES=3Dm
CONFIG_IP_NF_MATCH_TTL=3Dm
CONFIG_IP_NF_FILTER=3Dm
CONFIG_IP_NF_TARGET_REJECT=3Dm
CONFIG_IP_NF_TARGET_LOG=3Dm
CONFIG_IP_NF_TARGET_ULOG=3Dm
CONFIG_NF_NAT=3Dm
CONFIG_NF_NAT_NEEDED=3Dy
CONFIG_IP_NF_TARGET_MASQUERADE=3Dm
CONFIG_IP_NF_TARGET_NETMAP=3Dm
CONFIG_NF_NAT_PROTO_GRE=3Dm
CONFIG_NF_NAT_FTP=3Dm
CONFIG_NF_NAT_IRC=3Dm
CONFIG_NF_NAT_TFTP=3Dm
CONFIG_NF_NAT_PPTP=3Dm
CONFIG_NF_NAT_H323=3Dm
CONFIG_NF_NAT_SIP=3Dm
CONFIG_IP_NF_MANGLE=3Dm
CONFIG_IP_NF_TARGET_ECN=3Dm
CONFIG_IP_NF_TARGET_TTL=3Dm
CONFIG_NET_SCHED=3Dy

CONFIG_NET_SCH_HTB=3Dm
CONFIG_NET_SCH_HFSC=3Dm
CONFIG_NET_SCH_PRIO=3Dm
CONFIG_NET_SCH_RED=3Dm
CONFIG_NET_SCH_SFQ=3Dm
CONFIG_NET_SCH_TEQL=3Dm
CONFIG_NET_SCH_TBF=3Dm
CONFIG_NET_SCH_GRED=3Dm
CONFIG_NET_SCH_DRR=3Dm
CONFIG_NET_SCH_INGRESS=3Dm

CONFIG_NET_CLS=3Dy
CONFIG_NET_CLS_BASIC=3Dm
CONFIG_NET_CLS_TCINDEX=3Dm
CONFIG_NET_CLS_ROUTE4=3Dm
CONFIG_NET_CLS_FW=3Dm
CONFIG_NET_CLS_U32=3Dm
CONFIG_CLS_U32_PERF=3Dy
CONFIG_CLS_U32_MARK=3Dy
CONFIG_NET_CLS_RSVP=3Dm
CONFIG_NET_CLS_FLOW=3Dm
CONFIG_NET_EMATCH=3Dy
CONFIG_NET_EMATCH_STACK=3D32
CONFIG_NET_EMATCH_U32=3Dm
CONFIG_NET_EMATCH_META=3Dm
CONFIG_NET_EMATCH_TEXT=3Dm
CONFIG_NET_CLS_ACT=3Dy
CONFIG_NET_ACT_POLICE=3Dm
CONFIG_NET_ACT_GACT=3Dm
CONFIG_GACT_PROB=3Dy
CONFIG_NET_ACT_MIRRED=3Dm
CONFIG_NET_ACT_IPT=3Dm
CONFIG_NET_ACT_NAT=3Dm
CONFIG_NET_CLS_IND=3Dy
CONFIG_NET_SCH_FIFO=3Dy
CONFIG_RPS=3Dy
CONFIG_RFS_ACCEL=3Dy
CONFIG_XPS=3Dy
CONFIG_BQL=3Dy
CONFIG_HAVE_BPF_JIT=3Dy

CONFIG_FIB_RULES=3Dy


CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
CONFIG_STANDALONE=3Dy
CONFIG_FW_LOADER=3Dy
CONFIG_EXTRA_FIRMWARE=3D""
CONFIG_PNP=3Dy

CONFIG_PNPACPI=3Dy




CONFIG_HAVE_IDE=3Dy

CONFIG_SCSI_MOD=3Dy
CONFIG_SCSI=3Dy
CONFIG_SCSI_DMA=3Dy

CONFIG_BLK_DEV_SD=3Dy
CONFIG_BLK_DEV_SR=3Dm
CONFIG_SCSI_WAIT_SCAN=3Dm

CONFIG_SCSI_LOWLEVEL=3Dy
CONFIG_MEGARAID_SAS=3Dy

CONFIG_NETDEVICES=3Dy
CONFIG_NET_CORE=3Dy

CONFIG_ETHERNET=3Dy
CONFIG_NET_VENDOR_INTEL=3Dy
CONFIG_E1000E=3Dm



CONFIG_INPUT=3Dy

CONFIG_INPUT_MOUSEDEV=3Dy
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768

CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy

CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
CONFIG_SERIO_LIBPS2=3Dy

CONFIG_VT=3Dy
CONFIG_CONSOLE_TRANSLATIONS=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
CONFIG_UNIX98_PTYS=3Dy

CONFIG_FIX_EARLYCON_MEM=3Dy

CONFIG_DEVPORT=3Dy
CONFIG_I2C=3Dm
CONFIG_I2C_BOARDINFO=3Dy
CONFIG_I2C_HELPER_AUTO=3Dy


CONFIG_I2C_I801=3Dm
CONFIG_I2C_ISCH=3Dm








CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
CONFIG_THERMAL=3Dm
CONFIG_SSB_POSSIBLE=3Dy

CONFIG_BCMA_POSSIBLE=3Dy


CONFIG_MFD_CORE=3Dm
CONFIG_LPC_SCH=3Dm

CONFIG_VGA_ARB=3Dy
CONFIG_VGA_ARB_MAX_GPUS=3D16

CONFIG_VGA_CONSOLE=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D64
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_HID_SUPPORT=3Dy
CONFIG_HID=3Dm

CONFIG_USB_HID=3Dm

CONFIG_HID_A4TECH=3Dm
CONFIG_HID_APPLE=3Dm
CONFIG_HID_BELKIN=3Dm
CONFIG_HID_CHERRY=3Dm
CONFIG_HID_CHICONY=3Dm
CONFIG_HID_CYPRESS=3Dm
CONFIG_HID_EZKEY=3Dm
CONFIG_HID_KYE=3Dm
CONFIG_HID_KENSINGTON=3Dm
CONFIG_HID_LOGITECH=3Dm
CONFIG_HID_LOGITECH_DJ=3Dm
CONFIG_HID_MICROSOFT=3Dm
CONFIG_HID_MONTEREY=3Dm
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_COMMON=3Dm
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB_ARCH_HAS_XHCI=3Dy
CONFIG_USB=3Dm

CONFIG_USB_MON=3Dm

CONFIG_USB_EHCI_HCD=3Dm
CONFIG_USB_UHCI_HCD=3Dm



CONFIG_USB_STORAGE=3Dm







CONFIG_CLKEVT_I8253=3Dy
CONFIG_I8253_LOCK=3Dy
CONFIG_CLKBLD_I8253=3Dy

CONFIG_FIRMWARE_MEMMAP=3Dy

CONFIG_EXT2_FS=3Dm
CONFIG_XFS_FS=3Dy
CONFIG_EXPORTFS=3Dy
CONFIG_FILE_LOCKING=3Dy
CONFIG_FSNOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy


CONFIG_ISO9660_FS=3Dm
CONFIG_JOLIET=3Dy
CONFIG_ZISOFS=3Dy

CONFIG_FAT_FS=3Dm
CONFIG_MSDOS_FS=3Dm
CONFIG_VFAT_FS=3Dm
CONFIG_FAT_DEFAULT_CODEPAGE=3D437
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"

CONFIG_PROC_FS=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_PROC_PAGE_MONITOR=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
CONFIG_NLS_CODEPAGE_437=3Dm
CONFIG_NLS_CODEPAGE_850=3Dm
CONFIG_NLS_ASCII=3Dm
CONFIG_NLS_ISO8859_1=3Dm
CONFIG_NLS_ISO8859_15=3Dm
CONFIG_NLS_UTF8=3Dm

CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=3D4
CONFIG_FRAME_WARN=3D2048
CONFIG_DEBUG_BUGVERBOSE=3Dy
CONFIG_DEBUG_MEMORY_INIT=3Dy
CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
CONFIG_RCU_CPU_STALL_TIMEOUT=3D60
CONFIG_USER_STACKTRACE_SUPPORT=3Dy
CONFIG_HAVE_FUNCTION_TRACER=3Dy
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
CONFIG_HAVE_C_RECORDMCOUNT=3Dy
CONFIG_TRACING_SUPPORT=3Dy
CONFIG_HAVE_ARCH_KGDB=3Dy
CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
CONFIG_EARLY_PRINTK=3Dy
CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
CONFIG_IO_DELAY_TYPE_0X80=3D0
CONFIG_IO_DELAY_TYPE_0XED=3D1
CONFIG_IO_DELAY_TYPE_UDELAY=3D2
CONFIG_IO_DELAY_TYPE_NONE=3D3
CONFIG_IO_DELAY_0X80=3Dy
CONFIG_DEFAULT_IO_DELAY_TYPE=3D0

CONFIG_DEFAULT_SECURITY_DAC=3Dy
CONFIG_DEFAULT_SECURITY=3D""
CONFIG_CRYPTO=3Dy

CONFIG_CRYPTO_ALGAPI=3Dm
CONFIG_CRYPTO_ALGAPI2=3Dm
CONFIG_CRYPTO_AEAD=3Dm
CONFIG_CRYPTO_AEAD2=3Dm
CONFIG_CRYPTO_BLKCIPHER=3Dm
CONFIG_CRYPTO_BLKCIPHER2=3Dm
CONFIG_CRYPTO_HASH=3Dm
CONFIG_CRYPTO_HASH2=3Dm
CONFIG_CRYPTO_RNG2=3Dm
CONFIG_CRYPTO_PCOMP=3Dm
CONFIG_CRYPTO_PCOMP2=3Dm
CONFIG_CRYPTO_MANAGER=3Dm
CONFIG_CRYPTO_MANAGER2=3Dm
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=3Dy
CONFIG_CRYPTO_GF128MUL=3Dm
CONFIG_CRYPTO_WORKQUEUE=3Dm
CONFIG_CRYPTO_CRYPTD=3Dm
CONFIG_CRYPTO_AUTHENC=3Dm


CONFIG_CRYPTO_CBC=3Dm
CONFIG_CRYPTO_LRW=3Dm
CONFIG_CRYPTO_XTS=3Dm

CONFIG_CRYPTO_HMAC=3Dm

CONFIG_CRYPTO_MD5=3Dm
CONFIG_CRYPTO_SHA1=3Dm
CONFIG_CRYPTO_SHA1_SSSE3=3Dm
CONFIG_CRYPTO_SHA256=3Dm
CONFIG_CRYPTO_SHA512=3Dm

CONFIG_CRYPTO_AES=3Dm
CONFIG_CRYPTO_AES_X86_64=3Dm
CONFIG_CRYPTO_BLOWFISH=3Dm
CONFIG_CRYPTO_BLOWFISH_COMMON=3Dm
CONFIG_CRYPTO_BLOWFISH_X86_64=3Dm
CONFIG_CRYPTO_DES=3Dm
CONFIG_CRYPTO_SERPENT=3Dm
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=3Dm
CONFIG_CRYPTO_TWOFISH_COMMON=3Dm
CONFIG_CRYPTO_TWOFISH_X86_64=3Dm
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=3Dm

CONFIG_CRYPTO_DEFLATE=3Dm
CONFIG_CRYPTO_ZLIB=3Dm
CONFIG_CRYPTO_LZO=3Dm

CONFIG_HAVE_KVM=3Dy

CONFIG_BITREVERSE=3Dm
CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
CONFIG_GENERIC_PCI_IOMAP=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_CRC32=3Dm
CONFIG_ZLIB_INFLATE=3Dm
CONFIG_ZLIB_DEFLATE=3Dm
CONFIG_LZO_COMPRESS=3Dm
CONFIG_LZO_DECOMPRESS=3Dm
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dm
CONFIG_TEXTSEARCH_BM=3Dm
CONFIG_TEXTSEARCH_FSM=3Dm
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT=3Dy
CONFIG_HAS_DMA=3Dy
CONFIG_CHECK_SIGNATURE=3Dy
CONFIG_CPU_RMAP=3Dy
CONFIG_DQL=3Dy
CONFIG_NLATTR=3Dy

 		 	   		  