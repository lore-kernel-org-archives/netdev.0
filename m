From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: r8169 in 2.6.7: transfer stops after few seconds
Date: Wed, 21 Jul 2004 15:47:51 +0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040721114750.GA7668@tentacle.sectorb.msk.ru>
References: <20040721083406.GA5785@usr.lcm.msu.ru> <20040721125622.A31273@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Return-path: <linux-net-owner@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040721125622.A31273@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Wed, Jul 21, 2004 at 12:56:22PM +0200, Francois Romieu wrote:
> Vladimir B. Savkin <master@sectorb.msk.ru> :
> > My realtek-8169 based NIC doesn't work with 2.6.
> > Kernel versions tried: 2.6.7, 2.6.7-mm7.
> > Works OK with 2.4.26.
> [...]
> > Is there any other info I can supply you with to debug this problem?
> 
> - dmesg once the card is up/stopped (please provide complete dmesg from
>   boot as it usually gets truncated and misses the compiler info)

Attached as dmesg.boot.
No additional messages after card is stopped.
(I use vlans, but can reproduce the problem without them).

> - ifconfig output once the card is stopped

Attached as ifconfig.eth1
Look, seems like the card stops after 64 packets transmitted -
I checked this several times!

> - lspci -vx

Attached as lspci-vx.
> 
> Did you try 2.6.6 or previous kernel in the 2.6.x serie ?

Just checked - 2.6.6 couldn't boot on this machine - 
hda: lost interrupt

> 
> Please redirect traffic to netdev@oss.sgi.com.
> 
> --
> Ueimor
> 
~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="dmesg.boot"

Linux version 2.6.7-mm7 (vsavkin@abyss) (gcc version 2.95.4 20011002 (Debian prerelease)) #2 Wed Jul 21 00:18:02 MSD 2004
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000fff0000 (usable)
 BIOS-e820: 000000000fff0000 - 000000000fff8000 (ACPI data)
 BIOS-e820: 000000000fff8000 - 0000000010000000 (ACPI NVS)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
255MB LOWMEM available.
On node 0 totalpages: 65520
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 61424 pages, LIFO batch:14
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI disabled because your bios is from 2000 and too old
You can enable it with acpi=force
Built 1 zonelists
Local APIC disabled by BIOS -- reenabling.
Found and enabled local APIC!
Initializing CPU#0
Kernel command line: BOOT_IMAGE=mm7 ro root=303
PID hash table entries: 1024 (order 10: 8192 bytes)
Detected 909.470 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 256288k/262080k available (1480k kernel code, 5096k reserved, 624k data, 336k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 1781.76 BogoMIPS
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: 0183fbff c1c7fbff 00000000 00000000
CPU: After vendor identify, caps:  0183fbff c1c7fbff 00000000 00000000
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
CPU: After all inits, caps:        0183fbff c1c7fbff 00000000 00000020
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU: AMD Athlon(tm) Processor stepping 02
Enabling fast FPU save and restore... done.
Checking 'hlt' instruction... OK.
enabled ExtINT on CPU#0
ESR value before enabling vector: 00000000
ESR value after enabling vector: 00000000
Using local APIC timer interrupts.
calibrating APIC timer ...
..... CPU clock speed is 908.0736 MHz.
..... host bus clock speed is 201.0941 MHz.
NET: Registered protocol family 16
spurious 8259A interrupt: IRQ7.
PCI: PCI BIOS revision 2.10 entry at 0xfdb71, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Using IRQ router AMD756 [1022/740b] at 0000:00:07.3
TC classifier action (bugs to netdev@oss.sgi.com cc hadi@cyberus.ca)
Machine check exception polling timer started.
IA-32 Microcode Update Driver: v1.14 <tigran@veritas.com>
Initializing Cryptographic API
Real Time Clock Driver v1.12
Using anticipatory io scheduler
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
AMD7409: IDE controller at PCI slot 0000:00:07.1
AMD7409: chipset revision 7
AMD7409: not 100% native mode: will probe irqs later
AMD7409: 0000:00:07.1 (rev 07) UDMA66 controller
    ide0: BM-DMA at 0xf000-0xf007, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xf008-0xf00f, BIOS settings: hdc:DMA, hdd:pio
hda: SAMSUNG SP0802N, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hdc: IDE/ATAPI CD-ROM 50XS, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
PDC20269: IDE controller at PCI slot 0000:00:0b.0
AMD756: dev 105a:4d69, router pirq : 4 get irq : 11
PCI: Found IRQ 11 for device 0000:00:0b.0
PDC20269: chipset revision 2
PDC20269: ROM enabled at 0xeffe0000
PDC20269: 100% native mode on irq 11
    ide2: BM-DMA at 0xcc00-0xcc07, BIOS settings: hde:pio, hdf:pio
    ide3: BM-DMA at 0xcc08-0xcc0f, BIOS settings: hdg:pio, hdh:pio
hde: ST380021A, ATA DISK drive
ide2 at 0xdc00-0xdc07,0xd802 on irq 11
hdg: Maxtor 7Y250P0, ATA DISK drive
ide3 at 0xd400-0xd407,0xd002 on irq 11
hda: max request size: 1024KiB
hda: 156368016 sectors (80060 MB) w/2048KiB Cache, CHS=16383/255/63, UDMA(33)
hda: cache flushes supported
 hda: hda1 hda2 hda3 hda4 < hda5 hda6 hda7 hda8 hda9 >
hde: max request size: 128KiB
hde: 156301488 sectors (80026 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(100)
hde: cache flushes supported
 hde: hde1
hdg: max request size: 1024KiB
hdg: 490234752 sectors (251000 MB) w/2048KiB Cache, CHS=30515/255/63, UDMA(133)
hdg: cache flushes supported
 hdg: hdg1
hdc: ATAPI 11X CD-ROM drive, 128kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard on isa0060/serio0
input: PC Speaker
NET: Registered protocol family 2
IP: routing cache hash table of 2048 buckets, 16Kbytes
TCP: Hash tables configured (established 16384 bind 16384)
NET: Registered protocol family 1
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 336k freed
Adding 1228964k swap on /dev/hda2.  Priority:-1 extents:1
8139too Fast Ethernet driver 0.9.27
AMD756: dev 10ec:8139, router pirq : 1 get irq : 12
PCI: Found IRQ 12 for device 0000:00:08.0
eth0: RealTek RTL8139 at 0xd08a2e00, 00:02:44:00:5c:19, IRQ 12
eth0:  Identified 8139 chip type 'RTL-8139C'
r8169 Gigabit Ethernet driver 1.2 loaded
AMD756: dev 10ec:8169, router pirq : 3 get irq : 10
PCI: Found IRQ 10 for device 0000:00:0a.0
r8169: NAPI enabled
eth1: Identified chip type is 'RTL8169'.
eth1: RTL8169 at 0xd08b0f00, 00:50:fc:b8:2a:c4, IRQ 10
ReiserFS: hda5: found reiserfs format "3.6" with standard journal
ReiserFS: hda5: using ordered data mode
ReiserFS: hda5: journal params: device hda5, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: hda5: checking transaction log (hda5)
ReiserFS: hda5: Using r5 hash to sort names
ReiserFS: hda6: found reiserfs format "3.6" with standard journal
ReiserFS: hda6: using ordered data mode
ReiserFS: hda6: journal params: device hda6, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: hda6: checking transaction log (hda6)
ReiserFS: hda6: Using r5 hash to sort names
ReiserFS: hda7: found reiserfs format "3.6" with standard journal
ReiserFS: hda7: using ordered data mode
ReiserFS: hda7: journal params: device hda7, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: hda7: checking transaction log (hda7)
ReiserFS: hda7: Using r5 hash to sort names
vlan0303: add 01:00:5e:00:00:01 mcast address to master interface
r8169: eth1: link up

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=lspci-vx

0000:00:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-751 [Irongate] System Controller (rev 25)
	Flags: bus master, medium devsel, latency 120
	Memory at e8000000 (32-bit, prefetchable) [size=64M]
	Memory at efdff000 (32-bit, prefetchable) [size=4K]
	I/O ports at c000 [disabled] [size=4]
	Capabilities: [a0] AGP version 1.0
00: 22 10 06 70 06 01 10 22 25 00 00 06 00 78 80 00
10: 08 00 00 e8 08 f0 df ef 01 c0 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

0000:00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-751 [Irongate] AGP Bridge (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, 66MHz, medium devsel, latency 120
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	I/O behind bridge: 00008000-00008fff
	Memory behind bridge: efe00000-efefffff
	Prefetchable memory behind bridge: e7c00000-e7cfffff
00: 22 10 07 70 07 01 20 02 01 00 04 06 00 78 81 00
10: 00 00 00 00 00 00 00 00 00 01 01 20 81 81 20 22
20: e0 ef e0 ef c0 e7 c0 e7 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 00

0000:00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-756 [Viper] ISA (rev 01)
	Flags: bus master, medium devsel, latency 0
00: 22 10 08 74 0f 00 00 02 01 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

0000:00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-756 [Viper] IDE (rev 07) (prog-if 8a [Master SecP PriP])
	Flags: bus master, medium devsel, latency 32
	I/O ports at f000 [size=16]
00: 22 10 09 74 05 00 00 02 07 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

0000:00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-756 [Viper] ACPI (rev 03)
	Flags: medium devsel
00: 22 10 0b 74 00 00 80 02 03 00 80 06 00 78 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

0000:00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
	Flags: bus master, medium devsel, latency 64, IRQ 12
	I/O ports at c400 [size=256]
	Memory at efffbe00 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2
00: ec 10 39 81 07 01 90 02 10 00 00 02 00 40 00 00
10: 01 c4 00 00 00 be ff ef 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 39 81
30: 00 00 00 00 50 00 00 00 00 00 00 00 0c 01 20 40

0000:00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 10
	I/O ports at c800 [size=256]
	Memory at efffbf00 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at effd0000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
	Capabilities: [60] Vital Product Data
00: ec 10 69 81 17 01 b0 02 10 00 00 02 08 40 00 00
10: 01 c8 00 00 00 bf ff ef 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 fd ef dc 00 00 00 00 00 00 00 0a 01 20 40

0000:00:0b.0 Unknown mass storage controller: Promise Technology, Inc. 20269 (rev 02) (prog-if 85)
	Subsystem: Promise Technology, Inc. Ultra133TX2
	Flags: bus master, 66MHz, slow devsel, latency 64, IRQ 11
	I/O ports at dc00 [size=8]
	I/O ports at d800 [size=4]
	I/O ports at d400 [size=8]
	I/O ports at d000 [size=4]
	I/O ports at cc00 [size=16]
	Memory at efffc000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at effe0000 [disabled] [size=16K]
	Capabilities: [60] Power Management version 1
00: 5a 10 69 4d 07 00 30 04 02 85 80 01 08 40 00 00
10: 01 dc 00 00 01 d8 00 00 01 d4 00 00 01 d0 00 00
20: 01 cc 00 00 00 c0 ff ef 00 00 00 00 5a 10 68 4d
30: 01 00 fe ef 60 00 00 00 00 00 00 00 0b 01 04 12


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=koi8-r
Content-Description: ifconfig.eth1
Content-Disposition: attachment; filename="ifconfig.eth1.2"

eth1      Link encap:Ethernet  HWaddr 00:50:FC:B8:2A:C4  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5423 errors:0 dropped:0 overruns:0 frame:0
          TX packets:64 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:406122 (396.6 KiB)  TX bytes:59792 (58.3 KiB)
          Interrupt:10 Base address:0xf00 


--0F1p//8PRICkK4MW--
