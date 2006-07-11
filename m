From: Jar <jar@pcuf.fi>
Subject: RE: oops in current -git
Date: Wed, 12 Jul 2006 01:27:21 +0300
Message-ID: <44B425C9.5010000@pcuf.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox2.netikka.net ([213.250.81.203]:49349 "EHLO
	mbox2.netikka.net") by vger.kernel.org with ESMTP id S932211AbWGKW13
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 18:27:29 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This happen to me with FC4 and 2.6.17-1.2141_FC4. I have eth0=e100, 
eth1=8139too and wlan0=hostap_pci. When ACPI is enabled, all works. If 
acpi=off it hangs for a minute (at stage: Bringing up interface eth1: 
Determinig IP information for eth1...SIOCSIFFLAGS: Device of recource 
busy) and then recovers but only eth0 works. But when I put 'acpi=off 
noapic nolapic' all works again. Strange


Linux version 2.6.17-1.2141_FC4 (bhcompile@hs20-bc1-4.build.redhat.com) 
(gcc version 4.0.2 20051125 (Red Hat 4.0.2-8)) #1 Fri Jun 30 14:53:04 
EDT 2006
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
  BIOS-e820: 00000000000ca000 - 00000000000ce000 (reserved)
  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
  BIOS-e820: 000000001fff0000 - 000000001fff8000 (ACPI data)
  BIOS-e820: 000000001fff8000 - 0000000020000000 (ACPI NVS)
  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
0MB HIGHMEM available.
511MB LOWMEM available.
found SMP MP-table at 000fb6b0
Using x86 segment limits to approximate NX protection
On node 0 totalpages: 131056
   DMA zone: 4096 pages, LIFO batch:0
   Normal zone: 126960 pages, LIFO batch:31
DMI 2.3 present.
Intel MultiProcessor Specification v1.1
     Virtual Wire compatibility mode.
OEM ID: INTEL    Product ID: I845         APIC at: 0xFEE00000
Processor #0 15:1 APIC version 20
I/O APIC #2 Version 32 at 0xFEC00000.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Processors: 1
Allocating PCI resources starting at 30000000 (gap: 20000000:dff00000)
Built 1 zonelists
Kernel command line: ro root=LABEL=/ vga=771 acpi=off
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c077d000 soft=c077e000
PID hash table entries: 2048 (order: 11, 8192 bytes)
Detected 1594.361 MHz processor.
Using tsc for high-res timesource
Console: colour dummy device 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 514048k/524224k available (1977k kernel code, 9552k reserved, 
1358k data, 212k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 3193.59 BogoMIPS 
(lpj=6387188)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 3febfbff 00000000 00000000 00000000 
00000000 00000000 00000000
CPU: After vendor identify, caps: 3febfbff 00000000 00000000 00000000 
00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 256K
CPU: After all inits, caps: 3febf3ff 00000000 00000000 00000080 00000000 
00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU0: Thermal monitoring enabled
CPU: Intel(R) Pentium(R) 4 CPU 1.60GHz stepping 02
Checking 'hlt' instruction... OK.
ExtINT not setup in hardware but reported by MP table
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=0 pin2=0
checking if image is initramfs... it is
Freeing initrd memory: 1070k freed
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfdab1, last bus=2
Setting up standard PCI resources
ACPI: Subsystem revision 20060127
ACPI: Interpreter disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI: disabled
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI quirk: region 0800-087f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 0400-043f claimed by ICH4 GPIO
Boot video device is 0000:01:00.0
PCI: Transparent bridge - 0000:00:1e.0
PCI: Using IRQ router PIIX/ICH [8086/2440] at 0000:00:1f.0
PCI->APIC IRQ transform: 0000:00:1f.2[D] -> IRQ 185
PCI->APIC IRQ transform: 0000:00:1f.3[B] -> IRQ 177
PCI->APIC IRQ transform: 0000:00:1f.4[C] -> IRQ 201
PCI->APIC IRQ transform: 0000:00:1f.5[B] -> IRQ 177
PCI->APIC IRQ transform: 0000:01:00.0[A] -> IRQ 169
PCI->APIC IRQ transform: 0000:02:08.0[A] -> IRQ 193
PCI: Bridge: 0000:00:01.0
   IO window: 9000-9fff
   MEM window: dfd00000-dfdfffff
   PREFETCH window: d7a00000-dfafffff
PCI: Bridge: 0000:00:1e.0
   IO window: a000-afff
   MEM window: dfe00000-dfefffff
   PREFETCH window: dfb00000-dfbfffff
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 6, 262144 bytes)
TCP bind hash table entries: 8192 (order: 5, 163840 bytes)
TCP: Hash tables configured (established 16384 bind 8192)
TCP reno registered
apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
audit: initializing netlink socket (disabled)
audit(1152666513.776:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
Initializing Cryptographic API
ksign: Installing public key data
Loading keyring
- Added public key CECC7E59912DB2CA
- User ID: Red Hat, Inc. (Kernel Module GPG key)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
vesafb: framebuffer at 0xd8000000, mapped to 0xe0880000, using 937k, 
total 16384k
vesafb: mode is 800x600x8, linelength=800, pages=31
vesafb: protected mode interface info at c000:442f
vesafb: scrolling: redraw
vesafb: Pseudocolor: size=8:8:8:8, shift=0:0:0:0
Console: switching to colour frame buffer device 100x37
fb0: VESA VGA frame buffer device
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Real Time Clock Driver v1.12ac
Non-volatile memory driver v1.2
Linux agpgart interface v0.101 (c) Dave Jones
agpgart: Detected an Intel i845 Chipset.
agpgart: AGP aperture is 64M @ 0xe0000000
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH2: IDE controller at PCI slot 0000:00:1f.1
ICH2: chipset revision 18
ICH2: not 100% native mode: will probe irqs later
     ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:DMA
     ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
hda: ST320011A, ATA DISK drive
hdb: Maxtor 6Y080L0, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: OEM CD-ROM F522B, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 39851760 sectors (20404 MB) w/2048KiB Cache, CHS=39535/16/63, UDMA(100)
hda: cache flushes not supported
  hda: hda1 hda2
hdb: max request size: 128KiB
hdb: 156250000 sectors (80000 MB) w/2048KiB Cache, CHS=65535/16/63, 
UDMA(100)
hdb: cache flushes supported
  hdb: hdb1 < hdb5 hdb6 >
hdc: ATAPI 48X CD-ROM drive, 0kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
usbcore: registered new driver libusual
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
md: md driver 0.90.3 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: bitmap version 4.39
TCP bic registered
Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
Using IPI Shortcut mode
Freeing unused kernel memory: 212k freed
Write protecting the kernel read-only data: 924k
input: AT Translated Set 2 keyboard as /class/input/input0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
audit(1152666517.456:2): selinux=0 auid=4294967295
input: ImPS/2 Generic Wheel Mouse as /class/input/input1
Floppy drive(s): fd0 is 1.44M
FDC 0 is a National Semiconductor PC87306
e100: Intel(R) PRO/100 Network Driver, 3.5.10-k2-NAPI
e100: Copyright(c) 1999-2005 Intel Corporation
e100: eth0: e100_probe: addr 0xdfeff000, irq 193, MAC addr 00:04:23:12:F8:19
8139too Fast Ethernet driver 0.9.27
PCI: Enabling device 0000:02:0b.0 (0100 -> 0103)
PCI: No IRQ known for interrupt pin D of device 0000:02:0b.0. Probably 
buggy MP table.
eth1: RealTek RTL8139 at 0xe081af00, 00:30:84:ee:82:6a, IRQ 0
eth1:  Identified 8139 chip type 'RTL-8139C'
ieee80211_crypt: registered algorithm 'NULL'
hostap_pci: 0.4.4-kernel (Jouni Malinen <jkmaline@cc.hut.fi>)
PCI: Enabling device 0000:02:0a.0 (0110 -> 0112)
PCI: No IRQ known for interrupt pin C of device 0000:02:0a.0. Probably 
buggy MP table.
hostap_pci: Registered netdevice wifi0
wifi0: Original COR value: 0x2
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e0875a02> prism2_interrupt+0x0/0x6f7 
[hostap_pci]
  <c043b27e> request_irq+0x6d/0x8b  <e0874ae7> 
prism2_pci_probe+0x8e7/0xa2f [hostap_pci]
  <c05eabfe> wait_for_completion+0x115/0x11d  <c0530cd0> 
__driver_attach+0x0/0x8b
  <c04d72fb> pci_device_probe+0x36/0x55  <c0530c1d> 
driver_probe_device+0x42/0x8b
  <c0530d33> __driver_attach+0x63/0x8b  <c053030b> 
bus_for_each_dev+0x33/0x55
  <c0530b09> driver_attach+0x11/0x13  <c0530cd0> __driver_attach+0x0/0x8b
  <c053057a> bus_add_driver+0x5c/0xdf  <c04d6f12> 
__pci_register_driver+0x5b/0x7d
  <c0431114> sys_init_module+0x1292/0x135f  <c0599da5> 
register_netdevice+0x0/0x316
  <c0402bb3> syscall_call+0x7/0xb
wifi0: request_irq failed
PCI: Setting latency timer of device 0000:00:1f.5 to 64
intel8x0_measure_ac97_clock: measured 54793 usecs
intel8x0: clocking to 48000
hw_random hardware driver 1.0.0 loaded
USB Universal Host Controller Interface driver v3.0
PCI: Setting latency timer of device 0000:00:1f.2 to 64
uhci_hcd 0000:00:1f.2: UHCI Host Controller
uhci_hcd 0000:00:1f.2: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1f.2: irq 185, io base 0x0000d000
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
PCI: Setting latency timer of device 0000:00:1f.4 to 64
uhci_hcd 0000:00:1f.4: UHCI Host Controller
uhci_hcd 0000:00:1f.4: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1f.4: irq 201, io base 0x0000d400
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
input: PC Speaker as /class/input/input2
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
device-mapper: 4.6.0-ioctl (2006-02-17) initialised: dm-devel@redhat.com
EXT3 FS on hda1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdb5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdb6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 1052252k swap on /dev/hda2.  Priority:-1 extents:1 across:1052252k
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e083cab0> rtl8139_interrupt+0x0/0x389 
[8139too]
  <c043b27e> request_irq+0x6d/0x8b  <e083c357> rtl8139_open+0x26/0x1a3 
[8139too]
  <c05993a9> dev_open+0x2b/0x62  <c0598bde> dev_change_flags+0x47/0xe6
  <c05d010d> devinet_ioctl+0x24b/0x54a  <c0590701> sock_ioctl+0x1a8/0x1c5
  <c0590559> sock_ioctl+0x0/0x1c5  <c046784e> do_ioctl+0x16/0x48
  <c0467a72> vfs_ioctl+0x1f2/0x209  <c0467acf> sys_ioctl+0x46/0x5f
  <c0402bb3> syscall_call+0x7/0xb
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e083cab0> rtl8139_interrupt+0x0/0x389 
[8139too]
  <c043b27e> request_irq+0x6d/0x8b  <e083c357> rtl8139_open+0x26/0x1a3 
[8139too]
  <c05993a9> dev_open+0x2b/0x62  <c0598bde> dev_change_flags+0x47/0xe6
  <c05d010d> devinet_ioctl+0x24b/0x54a  <c0590701> sock_ioctl+0x1a8/0x1c5
  <c0590559> sock_ioctl+0x0/0x1c5  <c046784e> do_ioctl+0x16/0x48
  <c0467a72> vfs_ioctl+0x1f2/0x209  <c0467acf> sys_ioctl+0x46/0x5f
  <c0402bb3> syscall_call+0x7/0xb
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e083cab0> rtl8139_interrupt+0x0/0x389 
[8139too]
  <c043b27e> request_irq+0x6d/0x8b  <e083c357> rtl8139_open+0x26/0x1a3 
[8139too]
  <c05993a9> dev_open+0x2b/0x62  <c0598bde> dev_change_flags+0x47/0xe6
  <c05d010d> devinet_ioctl+0x24b/0x54a  <c0590701> sock_ioctl+0x1a8/0x1c5
  <c0590559> sock_ioctl+0x0/0x1c5  <c046784e> do_ioctl+0x16/0x48
  <c0467a72> vfs_ioctl+0x1f2/0x209  <c0467acf> sys_ioctl+0x46/0x5f
  <c0402bb3> syscall_call+0x7/0xb
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e083cab0> rtl8139_interrupt+0x0/0x389 
[8139too]
  <c043b27e> request_irq+0x6d/0x8b  <e083c357> rtl8139_open+0x26/0x1a3 
[8139too]
  <c05993a9> dev_open+0x2b/0x62  <c0598bde> dev_change_flags+0x47/0xe6
  <c05d010d> devinet_ioctl+0x24b/0x54a  <c0590701> sock_ioctl+0x1a8/0x1c5
  <c0590559> sock_ioctl+0x0/0x1c5  <c046784e> do_ioctl+0x16/0x48
  <c0467a72> vfs_ioctl+0x1f2/0x209  <c0467acf> sys_ioctl+0x46/0x5f
  <c0402bb3> syscall_call+0x7/0xb
setup_irq: irq handler mismatch
  <c043b11d> setup_irq+0xef/0xfc  <e083cab0> rtl8139_interrupt+0x0/0x389 
[8139too]
  <c043b27e> request_irq+0x6d/0x8b  <e083c357> rtl8139_open+0x26/0x1a3 
[8139too]
  <c05993a9> dev_open+0x2b/0x62  <c0598bde> dev_change_flags+0x47/0xe6
  <c05d010d> devinet_ioctl+0x24b/0x54a  <c0590701> sock_ioctl+0x1a8/0x1c5
  <c0590559> sock_ioctl+0x0/0x1c5  <c046784e> do_ioctl+0x16/0x48
  <c0467a72> vfs_ioctl+0x1f2/0x209  <c0467acf> sys_ioctl+0x46/0x5f
  <c0402bb3> syscall_call+0x7/0xb
parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
parport0: Printer, Hewlett-Packard hp LaserJet 1320 series
lp0: using parport0 (interrupt-driven).
lp0: console ready
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
device eth0 entered promiscuous mode
audit(1152655847.770:3): dev=eth0 prom=256 old_prom=0 auid=4294967295


00:00.0 Host bridge: Intel Corporation 82845 845 (Brookdale) Chipset 
Host Bridge (rev 03)
         Subsystem: Hewlett-Packard Company: Unknown device 1a30
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR-
         Latency: 0
         Region 0: Memory at e0000000 (32-bit, prefetchable) [size=64M]
         Capabilities: [e4] Vendor Specific Information
         Capabilities: [a0] AGP version 2.0
                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- 
HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- 
FW- Rate=<none>

00:01.0 PCI bridge: Intel Corporation 82845 845 (Brookdale) Chipset AGP 
Bridge (rev 03) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 32
         Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
         I/O behind bridge: 00009000-00009fff
         Memory behind bridge: dfd00000-dfdfffff
         Prefetchable memory behind bridge: d7a00000-dfafffff
         Secondary status: 66Mhz+ FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
         BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 12) (prog-if 
00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
         I/O behind bridge: 0000a000-0000afff
         Memory behind bridge: dfe00000-dfefffff
         Prefetchable memory behind bridge: dfb00000-dfbfffff
         Secondary status: 66Mhz- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
         BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corporation 82801BA ISA Bridge (LPC) (rev 12)
         Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0

00:1f.1 IDE interface: Intel Corporation 82801BA IDE U100 (rev 12) 
(prog-if 80 [Master])
         Subsystem: Hewlett-Packard Company: Unknown device 2440
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Region 4: I/O ports at fc00 [size=16]

00:1f.2 USB Controller: Intel Corporation 82801BA/BAM USB (Hub #1) (rev 
12) (prog-if 00 [UHCI])
         Subsystem: Hewlett-Packard Company: Unknown device 2440
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Interrupt: pin D routed to IRQ 201
         Region 4: I/O ports at d000 [size=32]

00:1f.3 SMBus: Intel Corporation 82801BA/BAM SMBus (rev 12)
         Subsystem: Hewlett-Packard Company: Unknown device 2440
         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin B routed to IRQ 0
         Region 4: I/O ports at 0c00 [size=16]

00:1f.4 USB Controller: Intel Corporation 82801BA/BAM USB (Hub #2) (rev 
12) (prog-if 00 [UHCI])
         Subsystem: Hewlett-Packard Company: Unknown device 2440
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Interrupt: pin C routed to IRQ 209
         Region 4: I/O ports at d400 [size=32]

00:1f.5 Multimedia audio controller: Intel Corporation 82801BA/BAM AC'97 
Audio (rev 12)
         Subsystem: Hewlett-Packard Company: Unknown device 127a
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Interrupt: pin B routed to IRQ 193
         Region 0: I/O ports at dc00 [size=256]
         Region 1: I/O ports at d800 [size=64]

01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 Pro 
Ultra TF (prog-if 00 [VGA])
         Subsystem: ATI Technologies Inc Rage Fury Pro/Xpert 2000 Pro
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping+ SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (2000ns min), Cache Line Size 08
         Interrupt: pin A routed to IRQ 11
         Region 0: Memory at d8000000 (32-bit, prefetchable) [size=64M]
         Region 1: I/O ports at 9800 [size=256]
         Region 2: Memory at dfdfc000 (32-bit, non-prefetchable) [size=16K]
         Expansion ROM at dfdc0000 [disabled] [size=128K]
         Capabilities: [50] AGP version 2.0
                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- 
HTrans- 64bit- FW- AGP3- Rate=x1,x2,x4
                 Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP- GART64- 64bit- 
FW- Rate=<none>
         Capabilities: [5c] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:08.0 Ethernet controller: Intel Corporation 82801BA/BAM/CA/CAM 
Ethernet Controller (rev 03)
         Subsystem: Intel Corporation EtherExpress PRO/100 VE
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (2000ns min, 14000ns max), Cache Line Size 08
         Interrupt: pin A routed to IRQ 169
         Region 0: Memory at dfeff000 (32-bit, non-prefetchable) [size=4K]
         Region 1: I/O ports at ac00 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:0a.0 Network controller: Intersil Corporation Prism 2.5 Wavelan 
chipset (rev 01)
         Subsystem: 3Com Corporation: Unknown device 0001
         Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV+ VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin A routed to IRQ 185
         Region 0: Memory at dfbff000 (32-bit, prefetchable) [size=4K]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8139/8139C/8139C+ (rev 10)
         Subsystem: Allied Telesyn International AT-2500TX/ACPI
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (8000ns min, 16000ns max)
         Interrupt: pin A routed to IRQ 177
         Region 0: I/O ports at a800 [size=256]
         Region 1: Memory at dfefef00 (32-bit, non-prefetchable) [size=256]
         Capabilities: [50] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-


-- 
Best Regards, Jar
