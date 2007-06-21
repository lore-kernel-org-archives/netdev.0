From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: Via Rhine II Network Card Failure
Date: Thu, 21 Jun 2007 16:11:22 +0530
Message-ID: <a781481a0706210341y21682964s80d42ed6cf9a8b95@mail.gmail.com>
References: <665527d90706210116g412da384p50bb61aef300f511@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Mark Hannessen" <markhannessen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:44104 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbXFUKlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 06:41:24 -0400
Received: by wr-out-0506.google.com with SMTP id q50so418637wrq
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 03:41:23 -0700 (PDT)
In-Reply-To: <665527d90706210116g412da384p50bb61aef300f511@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mark,

Networking stuff generally goes to netdev. [ Added to Cc: ]

On 6/21/07, Mark Hannessen <markhannessen@gmail.com> wrote:
> Hi list,
>
> I have some trouble getting my network card to run.
> when I run dmesg I can clearly see it being detected
>
> eth0: VIA Rhine II at 0xee006000, 00:e0:c5:54:88:a8, IRQ 11.
> eth0: MII PHY found at address 1, status 0x786d advertising 05e1 Link 45e1.
>
> but when I try ifconfig eth0 up it fails with a no device error.
>
> SIOCSIFADDR: No such device eth0:
> ERROR while getting interface flags: No such device
>
> I tried adding pci=routeirq too, but that didn't work either.
>
> I know there is nothing wrong with the card itself because it works on
> the linux distro that came with it.
>
> does anyone have any hints as to what might get it up and running?
>
> Thanks!
> Mark
>
> I attached a complete dmesg output just in case..

00:00.0 Host bridge: VIA Technologies, Inc. VT8623 [Apollo CLE266]
00:01.0 PCI bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266 AGP]
00:09.0 CardBus bridge: Texas Instruments PCI1510 PC card Cardbus Controller
00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 80)
00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 80)
00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 80)
00:10.3 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 82)
00:11.0 ISA bridge: VIA Technologies, Inc. VT8235 ISA Bridge
00:11.1 IDE interface: VIA Technologies, Inc.
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06)
00:11.5 Multimedia audio controller: VIA Technologies, Inc.
VT8233/A/8235/8237 AC97 Audio Controller (rev 50)
00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 74)
01:00.0 VGA compatible controller: VIA Technologies, Inc. VT8623
[Apollo CLE266] integrated CastleRock graphics (rev 03)
Linux version 2.6.20.14 (root@server) (gcc version 4.1.1 (Gentoo
4.1.1-r3)) #2 PREEMPT Thu Jun 21 09:11:50 CEST 2007
BIOS-provided physical RAM map:
sanitize start
sanitize end
copy_e820_map() start: 0000000000000000 size: 000000000009fc00 end:
000000000009fc00 type: 1
copy_e820_map() type is E820_RAM
copy_e820_map() start: 000000000009fc00 size: 0000000000000400 end:
00000000000a0000 type: 2
copy_e820_map() start: 00000000000f0000 size: 0000000000010000 end:
0000000000100000 type: 2
copy_e820_map() start: 0000000000100000 size: 000000001f6f0000 end:
000000001f7f0000 type: 1
copy_e820_map() type is E820_RAM
copy_e820_map() start: 000000001f7f0000 size: 0000000000003000 end:
000000001f7f3000 type: 4
copy_e820_map() start: 000000001f7f3000 size: 000000000000d000 end:
000000001f800000 type: 3
copy_e820_map() start: 00000000ffff0000 size: 0000000000010000 end:
0000000100000000 type: 2
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001f7f0000 (usable)
 BIOS-e820: 000000001f7f0000 - 000000001f7f3000 (ACPI NVS)
 BIOS-e820: 000000001f7f3000 - 000000001f800000 (ACPI data)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
503MB LOWMEM available.
Entering add_active_range(0, 0, 129008) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   129008
early_node_map[1] active PFN ranges
    0:        0 ->   129008
On node 0 totalpages: 129008
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 975 pages used for memmap
  Normal zone: 123937 pages, LIFO batch:31
DMI 2.2 present.
ACPI: RSDP (v000 CLE266                                ) @ 0x000f6690
ACPI: RSDT (v001 CLE266 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1f7f3040
ACPI: FADT (v001 CLE266 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1f7f30c0
ACPI: DSDT (v001 CLE266 AWRDACPI 0x00001000 MSFT 0x0100000e) @ 0x00000000
ACPI: PM-Timer IO Port: 0x4008
Allocating PCI resources starting at 20000000 (gap: 1f800000:e07f0000)
Detected 1000.450 MHz processor.
Built 1 zonelists.  Total pages: 128001
Kernel command line: BOOT_IMAGE=(hd0,1)/kernels/vmlinuz-2.6.20
root=/dev/sda2 splash=silent,fadein,tty=tty8,theme:riecom console=tty1
vga=791 pci=routeirq
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 8192 bytes)
Console: colour dummy device 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 500536k/516032k available (2425k kernel code, 14860k reserved,
1369k data, 168k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xffff7000 - 0xfffff000   (  32 kB)
    vmalloc : 0xe0000000 - 0xffff5000   ( 511 MB)
    lowmem  : 0xc0000000 - 0xdf7f0000   ( 503 MB)
      .init : 0xc04b8000 - 0xc04e2000   ( 168 kB)
      .data : 0xc035e41c - 0xc04b4a10   (1369 kB)
      .text : 0xc0100000 - 0xc035e41c   (2425 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 2002.29 BogoMIPS (lpj=1001145)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 0381b03f 00000000 00000000 00000000
00000000 00000000 00000000
CPU: L1 I Cache: 64K (32 bytes/line), D cache 64K (32 bytes/line)
CPU: L2 Cache: 64K (32 bytes/line)
CPU: After all inits, caps: 0381b13f 00000000 00000000 00000000
00000000 000000dd 00000000
Compat vDSO mapped to ffffe000.
CPU: Centaur VIA Nehemiah stepping 08
Checking 'hlt' instruction... OK.
Checking for popad bug... OK.
ACPI: Core revision 20060707
ACPI: setting ELCR to 0200 (from 9a20)
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfb3f0, last bus=2
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
ACPI: Assume root bridge [\_SB_.PCI0] bus is 0
PCI quirk: region 4000-407f claimed by vt8235 PM
PCI quirk: region 5000-500f claimed by vt8235 SMB
Boot video device is 0000:01:00.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 10 11 12) *15
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 6 7 10 11 12) *5
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 *11 12)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 11 *12)
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: Routing PCI interrupts for all devices because "pci=routeirq" specified
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt 0000:00:10.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:00:10.1[B] -> Link [LNKB] -> GSI 10 (level,
low) -> IRQ 10
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
ACPI: PCI Interrupt 0000:00:10.2[C] -> Link [LNKC] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 12
PCI: setting IRQ 12 as level-triggered
ACPI: PCI Interrupt 0000:00:10.3[D] -> Link [LNKD] -> GSI 12 (level,
low) -> IRQ 12
ACPI: PCI Interrupt 0000:00:11.1[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt 0000:00:11.5[C] -> Link [LNKC] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt 0000:00:12.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
ACPI: PCI Interrupt 0000:01:00.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
PCI: Bridge: 0000:00:01.0
  IO window: disabled.
  MEM window: ec000000-edffffff
  PREFETCH window: e8000000-ebffffff
PCI: Bus 2, cardbus bridge: 0000:00:09.0
  IO window: 00001000-000010ff
  IO window: 00001400-000014ff
  PREFETCH window: 20000000-23ffffff
  MEM window: 24000000-27ffffff
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
TCP: Hash tables configured (established 16384 bind 8192)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 6248k freed
audit: initializing netlink socket (disabled)
audit(1182410582.259:1): initialized
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
NTFS driver 2.1.28 [Flags: R/W].
io scheduler noop registered (default)
Real Time Clock Driver v1.12ac
Non-volatile memory driver v1.2
VIA RNG detected
Linux agpgart interface v0.101 (c) Dave Jones
agpgart: Detected VIA CLE266 chipset
agpgart: AGP aperture is 64M @ 0xe4000000
vesafb: framebuffer at 0xe8000000, mapped to 0xe0080000, using 3072k,
total 8192k
vesafb: mode is 1024x768x16, linelength=2048, pages=4
vesafb: protected mode interface info at c000:352c
vesafb: pmi: set display start = c00c357a, set palette = c00c35eb
vesafb: scrolling: redraw
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Console: switching to colour frame buffer device 128x48
fbsplash: console 0 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 0
fb0: VESA VGA frame buffer device
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input1
ACPI: Power Button (CM) [PWRB]
input: Sleep Button (CM) as /class/input/input2
ACPI: Sleep Button (CM) [SLPB]
ACPI: Fan [FAN] (on)
ACPI: CPU0 (power states: C1[C1] C2[C2])
ACPI: Processor [CPU0] (supports 2 throttling states)
ACPI: Thermal Zone [THRM] (29 C)
ibm_acpi: ec object not found
RAMDISK driver initialized: 16 RAM disks of 32000K size 1024 blocksize
loop: loaded (max 8 devices)
via-rhine.c:v1.10-LK1.4.2 Sept-11-2006 Written by Donald Becker
ACPI: PCI Interrupt 0000:00:12.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
PCI: VIA VLink IRQ fixup for 0000:00:12.0, from 15 to 11
eth0: VIA Rhine II at 0xee006000, 00:e0:c5:54:88:a8, IRQ 11.
eth0: MII PHY found at address 1, status 0x786d advertising 05e1 Link 45e1.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:11.1
ACPI: PCI Interrupt 0000:00:11.1[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
PCI: VIA VLink IRQ fixup for 0000:00:11.1, from 255 to 11
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt8235 (rev 00) IDE UDMA133 controller on pci0000:00:11.1
    ide0: BM-DMA at 0xe700-0xe707, BIOS settings: hda:pio, hdb:pio
Probing IDE interface ide0...
Probing IDE interface ide0...
Probing IDE interface ide1...
ide-floppy driver 0.99.newide
SCSI Media Changer driver v0.25
ACPI: PCI Interrupt 0000:00:10.3[D] -> Link [LNKD] -> GSI 12 (level,
low) -> IRQ 12
ehci_hcd 0000:00:10.3: EHCI Host Controller
ehci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:10.3: irq 12, io mem 0xee005000
ehci_hcd 0000:00:10.3: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:10.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
PCI: VIA VLink IRQ fixup for 0000:00:10.0, from 15 to 11
uhci_hcd 0000:00:10.0: UHCI Host Controller
uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:10.0: irq 11, io base 0x0000e400
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
usb 1-6: new high speed USB device using ehci_hcd and address 3
ACPI: PCI Interrupt 0000:00:10.1[B] -> Link [LNKB] -> GSI 10 (level,
low) -> IRQ 10
PCI: VIA VLink IRQ fixup for 0000:00:10.1, from 5 to 10
uhci_hcd 0000:00:10.1: UHCI Host Controller
uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:10.1: irq 10, io base 0x0000e500
usb 1-6: configuration #1 chosen from 1 choice
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:10.2[C] -> Link [LNKC] -> GSI 11 (level,
low) -> IRQ 11
uhci_hcd 0000:00:10.2: UHCI Host Controller
uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:10.2: irq 11, io base 0x0000e600
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
Initializing USB Mass Storage driver...
scsi0 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 3
usb-storage: waiting for device to settle before scanning
usb 4-1: new low speed USB device using uhci_hcd and address 2
usb 4-1: configuration #1 chosen from 1 choice
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usbcore: registered new interface driver libusual
usbcore: registered new interface driver hiddev
input: Logitech Logitech USB Keyboard as /class/input/input3
input: USB HID v1.10 Keyboard [Logitech Logitech USB Keyboard] on
usb-0000:00:10.2-1
input: Logitech Logitech USB Keyboard as /class/input/input4
input: USB HID v1.10 Mouse [Logitech Logitech USB Keyboard] on
usb-0000:00:10.2-1
usbcore: registered new interface driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
device-mapper: multipath round-robin: version 1.0.0 loaded
device-mapper: multipath emc: version 0.0.3 loaded
padlock: No VIA PadLock drivers have been loaded.
padlock: Using VIA PadLock ACE for AES algorithm.
padlock: VIA PadLock Hash Engine not detected.
IPv4 over IPv4 tunneling driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
ieee80211: 802.11 data/management/control stack, git-1.1.13
ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
ieee80211_crypt: registered algorithm 'NULL'
ieee80211_crypt: registered algorithm 'WEP'
ieee80211_crypt: registered algorithm 'CCMP'
Using IPI Shortcut mode
ACPI: (supports S0 S1 S4 S5)
Time: tsc clocksource has been installed.
Freeing unused kernel memory: 168k freed
scsi 0:0:0:0: Direct-Access     BUFFALO  USB Flash Disk   4000 PQ: 0 ANSI: 0 CCS
SCSI device sda: 16056320 512-byte hdwr sectors (8221 MB)
sda: Write Protect is off
sda: Mode Sense: 43 00 00 00
sda: assuming drive cache: write through
SCSI device sda: 16056320 512-byte hdwr sectors (8221 MB)
sda: Write Protect is off
sda: Mode Sense: 43 00 00 00
sda: assuming drive cache: write through
 sda: sda1 sda2
sd 0:0:0:0: Attached scsi removable disk sda
sd 0:0:0:0: Attached scsi generic sg0 type 0
usb-storage: device scan complete
Time: acpi_pm clocksource has been installed.
ACPI: PCI Interrupt 0000:00:11.5[C] -> Link [LNKC] -> GSI 11 (level,
low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:11.5 to 64
ReiserFS: dm-0: found reiserfs format "3.6" with standard journal
ReiserFS: dm-0: using ordered data mode
ReiserFS: dm-0: journal params: device dm-0, size 8192, journal first
block 18, max trans len 1024, max batch 900, max commit age 30, max
trans age 30
ReiserFS: dm-0: checking transaction log (dm-0)
ReiserFS: dm-0: Using r5 hash to sort names
fbsplash: console 1 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 1
fbsplash: console 2 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 2
fbsplash: console 3 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 3
fbsplash: console 4 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 4
fbsplash: console 5 using theme 'riecom'
fbsplash: switched splash state to 'on' on console 5
