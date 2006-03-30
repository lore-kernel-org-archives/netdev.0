From: "JaniD++" <djani22@dynamicweb.hu>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 14:53:02 +0200
Message-ID: <014201c653f8$e5394b90$1600a8c0@dcccs>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408> <20060329.204409.109404254.davem@davemloft.net> <20060330095245.GA2385@gondor.apana.org.au> <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <jesse.brandeburg@intel.com>,
	<nipsy@bitgnome.net>, <jrlundgren@gmail.com>, <cat@zip.com.au>,
	<djani22@dynamicweb.hu>, <yoseph.basri@gmail.com>,
	<mykleb@no.ibm.com>, <olel@ans.pl>, <michal@feix.cz>,
	<chris@scorpion.nl>, <netdev@vger.kernel.org>,
	<jesse.brandeburg@gmail.com>, <E1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hello,

>Motherboard?

Intel SE7520AF2 (Dual Xeon)

>Are you all using iptables?

YES

>Are you all routing?

NO


>From the reports I assume none of you are using an 82571/2/3 (pci expres=
s)?

08:04.0 Ethernet controller: Intel Corp.: Unknown device 1079 (rev 03)
        Subsystem: Intel Corp.: Unknown device 341a
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParEr=
r+
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (63750ns min), cache line size 10
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at fe9c0000 (64-bit, non-prefetchable) [size=3D1=
28K]
        Region 4: I/O ports at c800 [size=3D64]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=3D0 OST=3D0
                Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-=
,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-      Capabi
lities: [f0] Message Signalled Interrupts: 64bit+ Queue=3D0/0 Enable-
                Address: 0000000000000000  Data: 0000

08:04.1 Ethernet controller: Intel Corp.: Unknown device 1079 (rev 03)
        Subsystem: Intel Corp.: Unknown device 341a
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParEr=
r+
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (63750ns min), cache line size 10
        Interrupt: pin B routed to IRQ 22
        Region 0: Memory at fe9e0000 (64-bit, non-prefetchable) [size=3D1=
28K]
        Region 4: I/O ports at cc00 [size=3D64]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=3D0 OST=3D0
                Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-=
,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-      Capabi
lities: [f0] Message Signalled Interrupts: 64bit+ Queue=3D0/0 Enable-
                Address: 0000000000000000  Data: 0000

And, i can see, all testers using the E1000 card to serving web (or web
proxy) directly to internet. (or not?)


My dmesg:  (kernel 2.6.15.7 + nbd-fix + E1000 driver from 2.6.16.1 versio=
n
6.3.9-k4)

Linux version 2.6.15.7-NBDFIX (root@dy-xeon-1) (gcc version 4.0.0 2005051=
9
(Red Hat 4.0.0-8)) #2 SMP Wed Mar 29 15:05:41 CEST 2006
BIOS-provided physical RAM map:

BIOS-e820: 0000000000000000 - 000000000009f800 (usable)

BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)

BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)

BIOS-e820: 0000000000100000 - 00000000dffe0000 (usable)

BIOS-e820: 00000000dffe0000 - 00000000dffef000 (ACPI data)

BIOS-e820: 00000000dffef000 - 00000000dfffdc00 (ACPI NVS)

BIOS-e820: 00000000dfffdc00 - 00000000e0000000 (reserved)

BIOS-e820: 00000000fec00000 - 00000000fec86000 (reserved)

BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)

BIOS-e820: 00000000ffc00000 - 0000000100000000 (reserved)

BIOS-e820: 0000000100000000 - 0000000120000000 (usable)

3712MB HIGHMEM available.

896MB LOWMEM available.

found SMP MP-table at 000ff780

On node 0 totalpages: 1179648

DMA zone: 4096 pages, LIFO batch:0

DMA32 zone: 0 pages, LIFO batch:0

Normal zone: 225280 pages, LIFO batch:31

HighMem zone: 950272 pages, LIFO batch:31

DMI 2.3 present.

ACPI: RSDP (v000 ACPIAM ) @ 0x000f7f80

ACPI: RSDT (v001 A M I OEMRSDT 0x10000408 MSFT 0x00000097) @ 0xdffe0000

ACPI: FADT (v002 A M I OEMFACP 0x10000408 MSFT 0x00000097) @ 0xdffe0200

ACPI: MADT (v001 A M I OEMAPIC 0x10000408 MSFT 0x00000097) @ 0xdffe0390

ACPI: MCFG (v001 A M I OEMMCFG 0x10000408 MSFT 0x00000097) @ 0xdffe04a0

ACPI: OEMB (v001 A M I AMI_OEM 0x10000408 MSFT 0x00000097) @ 0xdffef040

ACPI: DSDT (v001 ALIEF ALIEF086 0x00000086 INTL 0x02002026) @ 0x00000000

ACPI: PM-Timer IO Port: 0x408

ACPI: Local APIC address 0xfee00000

ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)

Processor #0 15:4 APIC version 20

ACPI: LAPIC (acpi_id[0x02] lapic_id[0x06] enabled)

Processor #6 15:4 APIC version 20

ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)

Processor #1 15:4 APIC version 20

ACPI: LAPIC (acpi_id[0x04] lapic_id[0x07] enabled)

Processor #7 15:4 APIC version 20

ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])

ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])

ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])

ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])

ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])

IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23

ACPI: IOAPIC (id[0x09] address[0xfec80000] gsi_base[24])

IOAPIC[1]: apic_id 9, version 32, address 0xfec80000, GSI 24-47

ACPI: IOAPIC (id[0x0a] address[0xfec80400] gsi_base[48])

IOAPIC[2]: apic_id 10, version 32, address 0xfec80400, GSI 48-71

ACPI: IOAPIC (id[0x0b] address[0xfec85000] gsi_base[72])

IOAPIC[3]: apic_id 11, version 32, address 0xfec85000, GSI 72-95

ACPI: IOAPIC (id[0x0c] address[0xfec85400] gsi_base[96])

IOAPIC[4]: apic_id 12, version 32, address 0xfec85400, GSI 96-119

ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)

ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)

ACPI: IRQ0 used by override.

ACPI: IRQ2 used by override.

ACPI: IRQ9 used by override.

Enabling APIC mode: Flat. Using 5 I/O APICs

Using ACPI (MADT) for SMP configuration information

Allocating PCI resources starting at e2000000 (gap: e0000000:1ec00000)

Built 1 zonelists

Kernel command line: root=3D/dev/nfs,rw nfsroot=3D192.168.2.1://NFS/ROOT-=
XEON1/
ip=3D:::::eth0:autoconf pci=3Drouteirq vga=3D0x0f05 notsc
BOOT_IMAGE=3D20060329_XEON_2.6.15.7-NBDFIX-NEWe1000

notsc: Kernel compiled with CONFIG_X86_TSC, cannot disable TSC.

mapped APIC to ffffd000 (fee00000)

mapped IOAPIC to ffffc000 (fec00000)

mapped IOAPIC to ffffb000 (fec80000)

mapped IOAPIC to ffffa000 (fec80400)

mapped IOAPIC to ffff9000 (fec85000)

mapped IOAPIC to ffff8000 (fec85400)

Initializing CPU#0

PID hash table entries: 4096 (order: 12, 65536 bytes)

Detected 2992.695 MHz processor.

Using pmtmr for high-res timesource

Console: colour VGA+ 80x30

Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)

Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)

Memory: 4149096k/4718592k available (3675k kernel code, 43856k reserved,
1225k data, 248k init, 3276672k highmem)

Checking if this processor honours the WP bit even in supervisor mode... =
Ok.

Calibrating delay using timer specific routine.. 5989.80 BogoMIPS
(lpj=3D29949038)

Security Framework v1.0.0 initialized

Capability LSM initialized

Mount-cache hash table entries: 512

CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

monitor/mwait feature present.

using mwait in idle threads.

CPU: Trace cache: 12K uops, L1 D cache: 16K

CPU: L2 cache: 1024K

CPU: Physical Processor ID: 0

CPU: After all inits, caps: bfebfbff 20000000 00000000 00000080 0000641d
00000000 00000000

Intel machine check architecture supported.

Intel machine check reporting enabled on CPU#0.

CPU0: Intel P4/Xeon Extended MCE MSRs (24) available

CPU0: Thermal monitoring enabled

mtrr: v2.0 (20020519)

Enabling fast FPU save and restore... done.

Enabling unmasked SIMD FPU exception support... done.

Checking 'hlt' instruction... OK.

CPU0: Intel(R) Xeon(TM) CPU 3.00GHz stepping 01

Booting processor 1/1 eip 2000

Initializing CPU#1

Calibrating delay using timer specific routine.. 5985.20 BogoMIPS
(lpj=3D29926009)

CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

monitor/mwait feature present.

CPU: Trace cache: 12K uops, L1 D cache: 16K

CPU: L2 cache: 1024K

CPU: Physical Processor ID: 0

CPU: After all inits, caps: bfebfbff 20000000 00000000 00000080 0000641d
00000000 00000000

Intel machine check architecture supported.

Intel machine check reporting enabled on CPU#1.

CPU1: Intel P4/Xeon Extended MCE MSRs (24) available

CPU1: Thermal monitoring enabled

CPU1: Intel(R) Xeon(TM) CPU 3.00GHz stepping 01

Booting processor 2/6 eip 2000

Initializing CPU#2

Calibrating delay using timer specific routine.. 5985.22 BogoMIPS
(lpj=3D29926134)

CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

monitor/mwait feature present.

CPU: Trace cache: 12K uops, L1 D cache: 16K

CPU: L2 cache: 1024K

CPU: Physical Processor ID: 3

CPU: After all inits, caps: bfebfbff 20000000 00000000 00000080 0000641d
00000000 00000000

Intel machine check architecture supported.

Intel machine check reporting enabled on CPU#2.

CPU2: Intel P4/Xeon Extended MCE MSRs (24) available

CPU2: Thermal monitoring enabled

CPU2: Intel(R) Xeon(TM) CPU 3.00GHz stepping 01

Booting processor 3/7 eip 2000

Initializing CPU#3

Calibrating delay using timer specific routine.. 5985.23 BogoMIPS
(lpj=3D29926183)

CPU: After generic identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

CPU: After vendor identify, caps: bfebfbff 20000000 00000000 00000000
0000641d 00000000 00000000

monitor/mwait feature present.

CPU: Trace cache: 12K uops, L1 D cache: 16K

CPU: L2 cache: 1024K

CPU: Physical Processor ID: 3

CPU: After all inits, caps: bfebfbff 20000000 00000000 00000080 0000641d
00000000 00000000

Intel machine check architecture supported.

Intel machine check reporting enabled on CPU#3.

CPU3: Intel P4/Xeon Extended MCE MSRs (24) available

CPU3: Thermal monitoring enabled

CPU3: Intel(R) Xeon(TM) CPU 3.00GHz stepping 01

Total of 4 processors activated (23945.47 BogoMIPS).

ENABLING IO-APIC IRQs

..TIMER: vector=3D0x31 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1

checking TSC synchronization across 4 CPUs: passed.

Brought up 4 CPUs

NET: Registered protocol family 16

ACPI: bus type pci registered

PCI: PCI BIOS revision 2.10 entry at 0xf0031, last bus=3D9

PCI: Using MMCONFIG

ACPI: Subsystem revision 20050902

ACPI: Interpreter enabled

ACPI: Using IOAPIC for interrupt routing

ACPI: PCI Root Bridge [PCI0] (0000:00)

PCI: Probing PCI hardware (bus 00)

PCI quirk: region 0400-047f claimed by ICH4 ACPI/GPIO/TCO

PCI quirk: region 0500-053f claimed by ICH4 GPIO

PCI: PXH quirk detected, disabling MSI for SHPC device

PCI: PXH quirk detected, disabling MSI for SHPC device

Boot video device is 0000:01:0c.0

PCI: Transparent bridge - 0000:00:1e.0

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPA0.PXHA._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPA0.PXHB._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPB0._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPC0._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPC1.DBSA._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EPC1.DBSB._PRT]

ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]

ACPI: PCI Interrupt Link [LNKA] (IRQs *7)

ACPI: PCI Interrupt Link [LNKB] (IRQs *7)

ACPI: PCI Interrupt Link [LNKC] (IRQs *7)

ACPI: PCI Interrupt Link [LNKD] (IRQs *7)

ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,
disabled.

ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,
disabled.

ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,
disabled.

ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *10 11 12 14 15)

Linux Plug and Play Support v0.97 (c) Adam Belay

pnp: PnP ACPI init

pnp: PnP ACPI: found 12 devices

SCSI subsystem initialized

usbcore: registered new driver usbfs

usbcore: registered new driver hub

PCI: Using ACPI for IRQ routing

PCI: Routing PCI interrupts for all devices because "pci=3Drouteirq" spec=
ified

ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:07.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 16

ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 17

ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18

ACPI: PCI Interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 19

ACPI: PCI Interrupt 0000:00:1f.2[A] -> GSI 18 (level, low) -> IRQ 18

ACPI: PCI Interrupt 0000:00:1f.3[B] -> GSI 17 (level, low) -> IRQ 20

ACPI: PCI Interrupt 0000:08:04.0[A] -> GSI 52 (level, low) -> IRQ 21

ACPI: PCI Interrupt 0000:08:04.1[B] -> GSI 53 (level, low) -> IRQ 22

ACPI: PCI Interrupt 0000:01:0c.0[A] -> GSI 17 (level, low) -> IRQ 20

pnp: 00:09: ioport range 0x680-0x69f has been reserved

pnp: 00:09: ioport range 0x640-0x65f has been reserved

pnp: 00:09: ioport range 0x600-0x60f has been reserved

pnp: 00:09: ioport range 0x6c0-0x6df has been reserved

pnp: 00:09: ioport range 0x700-0x71f has been reserved

pnp: 00:09: ioport range 0x720-0x73f has been reserved

pnp: 00:09: ioport range 0x740-0x74f has been reserved

PCI: Bridge: 0000:07:00.0

IO window: disabled.

MEM window: disabled.

PREFETCH window: disabled.

PCI: Bridge: 0000:07:00.2

IO window: c000-cfff

MEM window: fe900000-fe9fffff

PREFETCH window: disabled.

PCI: Bridge: 0000:00:02.0

IO window: c000-cfff

MEM window: fe900000-feafffff

PREFETCH window: disabled.

PCI: Bridge: 0000:00:04.0

IO window: disabled.

MEM window: disabled.

PREFETCH window: disabled.

PCI: Bridge: 0000:00:06.0

IO window: disabled.

MEM window: disabled.

PREFETCH window: disabled.

PCI: Bridge: 0000:02:00.0

IO window: disabled.

MEM window: disabled.

PREFETCH window: disabled.

PCI: Bridge: 0000:02:00.2

IO window: disabled.

MEM window: disabled.

PREFETCH window: disabled.

PCI: Bridge: 0000:00:07.0

IO window: disabled.

MEM window: fe800000-fe8fffff

PREFETCH window: disabled.

PCI: Bridge: 0000:00:1e.0

IO window: b000-bfff

MEM window: fc700000-fe7fffff

PREFETCH window: e2000000-e20fffff

ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:02.0 to 64

PCI: Setting latency timer of device 0000:07:00.0 to 64

PCI: Setting latency timer of device 0000:07:00.2 to 64

ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:04.0 to 64

ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:06.0 to 64

ACPI: PCI Interrupt 0000:00:07.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:07.0 to 64

PCI: Setting latency timer of device 0000:02:00.0 to 64

PCI: Setting latency timer of device 0000:02:00.2 to 64

PCI: Setting latency timer of device 0000:00:1e.0 to 64

Machine check exception polling timer started.

apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)

apm: disabled - APM is not SMP safe.

audit: initializing netlink socket (disabled)

audit(1143712094.670:1): initialized

highmem bounce pool size: 64 pages

VFS: Disk quotas dquot_6.5.1

Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)

Coda Kernel/Venus communications, v5.3.20, coda@cs.cmu.edu

Installing knfsd (copyright (C) 1996 okir@monad.swb.de).

NTFS driver 2.1.25 [Flags: R/W].

SGI XFS with ACLs, large block numbers, no debug enabled

SGI XFS Quota Management subsystem

Initializing Cryptographic API

io scheduler noop registered

io scheduler anticipatory registered

io scheduler deadline registered

io scheduler cfq registered

ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:02.0 to 64

Allocate Port Service[pcie00]

Allocate Port Service[pcie01]

ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:04.0 to 64

Allocate Port Service[pcie00]

Allocate Port Service[pcie01]

ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:06.0 to 64

Allocate Port Service[pcie00]

Allocate Port Service[pcie01]

ACPI: PCI Interrupt 0000:00:07.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:07.0 to 64

Allocate Port Service[pcie00]

Allocate Port Service[pcie01]

kobject_register failed for radeonfb (-17)

[<c010360c>] dump_stack+0x16/0x1a

[<c02ad2d5>] kobject_register+0x37/0x4f

[<c0319cbb>] bus_add_driver+0x46/0xa6

[<c031a523>] driver_register+0x41/0x46

[<c02b5047>] __pci_register_driver+0x86/0x97

[<c05e01ef>] radeonfb_old_init+0x38/0x41

[<c05cc848>] do_initcalls+0x46/0x96

[<c05cc8cd>] do_basic_setup+0x21/0x23

[<c01003a5>] init+0xa2/0x199

[<c0100ea5>] kernel_thread_helper+0x5/0xb

Real Time Clock Driver v1.12

ipmi message handler version 38.0

PNP: PS/2 Controller [PNP0f03:PS2M] at 0x60,0x64 irq 12

PNP: PS/2 controller doesn't have KBD irq; using default 1

serio: i8042 AUX port at 0x60,0x64 irq 12

serio: i8042 KBD port at 0x60,0x64 irq 1

Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled

serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A

serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A

00:04: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A

00:05: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A

loop: loaded (max 8 devices)

ibmasm: IBM ASM Service Processor Driver version 1.0 loaded

Intel(R) PRO/1000 Network Driver - version 6.3.9-k4

Copyright (c) 1999-2005 Intel Corporation.

ACPI: PCI Interrupt 0000:08:04.0[A] -> GSI 52 (level, low) -> IRQ 21

e1000: 0000:08:04.0: e1000_probe: (PCI-X:100MHz:64-bit) 00:07:e9:32:e6:d8

e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection

ACPI: PCI Interrupt 0000:08:04.1[B] -> GSI 53 (level, low) -> IRQ 22

e1000: 0000:08:04.1: e1000_probe: (PCI-X:100MHz:64-bit) 00:07:e9:32:e6:d9

e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection

Ethernet Channel Bonding Driver: v2.6.5 (November 4, 2005)

bonding: Warning: either miimon or arp_interval and arp_ip_target module
parameters must be specified, otherwise bonding will not detect link
failures! see bonding.txt for details.

e100: Intel(R) PRO/100 Network Driver, 3.4.14-k4-NAPI

e100: Copyright(c) 1999-2005 Intel Corporation

tun: Universal TUN/TAP device driver, 1.6

tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>

Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2

ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=3D=
xx

Probing IDE interface ide0...

Probing IDE interface ide1...

3ware 9000 Storage Controller device driver for Linux v2.26.02.004.

libata version 1.20 loaded.

ata_piix 0000:00:1f.2: version 1.05

ACPI: PCI Interrupt 0000:00:1f.2[A] -> GSI 18 (level, low) -> IRQ 18

PCI: Setting latency timer of device 0000:00:1f.2 to 64

ata1: SATA max UDMA/133 cmd 0xEC00 ctl 0xE802 bmdma 0xDC00 irq 18

ata2: SATA max UDMA/133 cmd 0xE400 ctl 0xE002 bmdma 0xDC08 irq 18

ata1: dev 0 cfg 49:2f00 82:346b 83:7f61 84:4003 85:3469 86:3c41 87:4003
88:407f

ata1: dev 0 ATA-6, max UDMA/133, 390721968 sectors: LBA48

ata1: dev 0 configured for UDMA/133

scsi0 : ata_piix

ata2: dev 0 cfg 49:2f00 82:346b 83:7f61 84:4003 85:3469 86:3c41 87:4003
88:407f

ata2: dev 0 ATA-6, max UDMA/133, 390721968 sectors: LBA48

ata2: dev 0 configured for UDMA/133

scsi1 : ata_piix

Vendor: ATA Model: WDC WD2000JD-19H Rev: 08.0

Type: Direct-Access ANSI SCSI revision: 05

Vendor: ATA Model: WDC WD2000JD-19H Rev: 08.0

Type: Direct-Access ANSI SCSI revision: 05

SCSI device sda: 390721968 512-byte hdwr sectors (200050 MB)

SCSI device sda: drive cache: write back

SCSI device sda: 390721968 512-byte hdwr sectors (200050 MB)

SCSI device sda: drive cache: write back

sda: sda1 sda2

sd 0:0:0:0: Attached scsi disk sda

SCSI device sdb: 390721968 512-byte hdwr sectors (200050 MB)

SCSI device sdb: drive cache: write back

SCSI device sdb: 390721968 512-byte hdwr sectors (200050 MB)

SCSI device sdb: drive cache: write back

sdb: sdb1 sdb2

sd 1:0:0:0: Attached scsi disk sdb

sd 0:0:0:0: Attached scsi generic sg0 type 0

sd 1:0:0:0: Attached scsi generic sg1 type 0

aoe: aoe_init: AoE v2.6-14 initialised.

usbmon: debugfs is not available

ACPI: PCI Interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 19

PCI: Setting latency timer of device 0000:00:1d.7 to 64

ehci_hcd 0000:00:1d.7: EHCI Host Controller

ehci_hcd 0000:00:1d.7: debug port 1

PCI: cache line size of 128 is not supported by device 0000:00:1d.7

ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1

ehci_hcd 0000:00:1d.7: irq 19, io mem 0xfebffc00

ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004

hub 1-0:1.0: USB hub found

hub 1-0:1.0: 6 ports detected

ohci_hcd: 2005 April 22 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI=
)

USB Universal Host Controller Interface driver v2.3

ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 16

PCI: Setting latency timer of device 0000:00:1d.0 to 64

uhci_hcd 0000:00:1d.0: UHCI Host Controller

uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2

uhci_hcd 0000:00:1d.0: irq 16, io base 0x0000d000

hub 2-0:1.0: USB hub found

hub 2-0:1.0: 2 ports detected

ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 17

PCI: Setting latency timer of device 0000:00:1d.1 to 64

uhci_hcd 0000:00:1d.1: UHCI Host Controller

uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3

uhci_hcd 0000:00:1d.1: irq 17, io base 0x0000d400

hub 3-0:1.0: USB hub found

hub 3-0:1.0: 2 ports detected

ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18

PCI: Setting latency timer of device 0000:00:1d.2 to 64

uhci_hcd 0000:00:1d.2: UHCI Host Controller

uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4

uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d800

hub 4-0:1.0: USB hub found

hub 4-0:1.0: 2 ports detected

sl811: driver sl811-hcd, 19 May 2005

Initializing USB Mass Storage driver...

usbcore: registered new driver usb-storage

USB Mass Storage support registered.

mice: PS/2 mouse device common for all mice

I2O subsystem v1.288

i2o: max drivers =3D 8

I2O ProcFS OSM v1.145

i2c /dev entries driver

i2c-sis96x version 1.0.0

pc87360: PC8736x not detected, module not inserted.

md: linear personality registered as nr 1

md: raid0 personality registered as nr 2

md: raid1 personality registered as nr 3

md: raid5 personality registered as nr 4

raid5: automatically using best checksumming function: pIII_sse

pIII_sse : 4862.400 MB/sec

raid5: using function: pIII_sse (4862.400 MB/sec)

md: multipath personality registered as nr 7

md: faulty personality registered as nr 10

md: md driver 0.90.3 MAX_MD_DEVS=3D256, MD_SB_DISKS=3D27

md: bitmap version 4.39

device-mapper: 4.4.0-ioctl (2005-01-12) initialised: dm-devel@redhat.com

device-mapper: dm-multipath version 1.0.4 loaded

device-mapper: dm-round-robin version 1.0.0 loaded

device-mapper: dm-emc version 0.0.3 loaded

NET: Registered protocol family 2

IP route cache hash table entries: 262144 (order: 8, 1048576 bytes)

TCP established hash table entries: 524288 (order: 10, 4194304 bytes)

TCP bind hash table entries: 65536 (order: 7, 524288 bytes)

TCP: Hash tables configured (established 524288 bind 65536)

TCP reno registered

ip_conntrack version 2.4 (8192 buckets, 65536 max) - 232 bytes per conntr=
ack

ip_tables: (C) 2000-2002 Netfilter core team

ipt_recent v0.3.1: Stephen Frost <sfrost@snowman.net>.
http://snowman.net/projects/ipt_recent/

arp_tables: (C) 2002 David S. Miller

TCP bic registered

NET: Registered protocol family 1

NET: Registered protocol family 10

lo: Disabled Privacy Extensions

IPv6 over IPv4 tunneling driver

ip6_tables: (C) 2000-2002 Netfilter core team

registering ipv6 mark target

NET: Registered protocol family 17

p4-clockmod: P4/Xeon(TM) CPU On-Demand Clock Modulation available

Using IPI Shortcut mode

ADDRCONF(NETDEV_UP): eth0: link is not ready

e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex

ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Sending DHCP requests ., OK

IP-Config: Got DHCP answer from 192.168.2.1, my address is 192.168.2.50

IP-Config: Complete:

device=3Deth0, addr=3D192.168.2.50, mask=3D255.255.255.0, gw=3D192.168.2.=
100,

host=3Dxeon, domain=3D, nis-domain=3D(none),

bootserver=3D192.168.2.1, rootserver=3D192.168.2.1, rootpath=3D/NFS/ROOT-=
XEON1/

md: Autodetecting RAID arrays.

md: invalid raid superblock magic on sda2

md: sda2 has invalid sb, not importing!

md: invalid raid superblock magic on sdb2

md: sdb2 has invalid sb, not importing!

md: autorun ...

md: considering sdb1 ...

md: adding sdb1 ...

md: adding sda1 ...

md: created md10

md: bind<sda1>

md: bind<sdb1>

md: running: <sdb1><sda1>

md10: bitmap initialized from disk: read 9/9 pages, set 0 bits, status: 0

created bitmap (131 pages) for device md10

raid1: raid set md10 active with 2 out of 2 mirrors

md: ... autorun DONE.

Looking up port of RPC 100003/2 on 192.168.2.1

Looking up port of RPC 100005/1 on 192.168.2.1

VFS: Mounted root (nfs filesystem) readonly.

Freeing unused kernel memory: 248k freed

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

program scsi_unique_id is using a deprecated SCSI ioctl, please convert i=
t
to SG_IO

eth0: no IPv6 routers present


Cheers,
Janos



----- Original Message -----=20
From: "Herbert Xu" <herbert@gondor.apana.org.au>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Cc: "David S. Miller" <davem@davemloft.net>; <jesse.brandeburg@intel.com>=
;
<nipsy@bitgnome.net>; <jrlundgren@gmail.com>; <cat@zip.com.au>;
<djani22@dynamicweb.hu>; <yoseph.basri@gmail.com>; <mykleb@no.ibm.com>;
<olel@ans.pl>; <michal@feix.cz>; <chris@scorpion.nl>;
<netdev@vger.kernel.org>; <jesse.brandeburg@gmail.com>;
<E1000-devel@lists.sourceforge.net>
Sent: Thursday, March 30, 2006 12:12 PM
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed..=
.


> On Thu, Mar 30, 2006 at 10:02:01AM +0000, Boris B. Zhmurov wrote:
> >
> > [zhmurov@builds linux-2.6.16]$ patch -p1 <
> >
../../../SOURCES/linux-2.6.16-e1000-try-to-fix-assertion_sk_forward_alloc=
_fa
iled_by_Herbert_Xu.patch
> >
> > patching file drivers/net/e1000/e1000_main.c
> > Reversed (or previously applied) patch detected!  Assume -R? [n]
> >
> > Herbert, is that patch already included in 2.6.16.1?
>
> Not really.  It's just patch being silly (or too smart :)
>
> Here it is again rediffed against 2.6.16.
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
>
>  _____________ NOD32 1.584 (20031220) Inform=E1ci=F3 _____________
>
> Az =FCzenetet a NOD32 Antivirus System megvizsg=E1lta.
> http://www.nod32.hu
>
>



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
