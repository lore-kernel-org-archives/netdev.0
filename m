From: Han Boetes <han@mijncomputer.nl>
Subject: Re: [Fwd: rtl8169 driver from realtek]
Date: Sat, 4 Sep 2004 23:18:40 +0159
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040904211902.GK2387@boetes.org>
References: <4139ED5B.2030002@pobox.com> <20040904182404.GB16875@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040904182404.GB16875@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here we go again. This is with the normal kernel-driver. It works
fine. Obviously I did something else wrong and drew the wrong
conclusion. Excuse me for that.

Heavy stress-tests work fine with this driver!

Francois Romieu wrote:
> - the complete dmesg after boot once the r8169 is ifconfig'ed up

Linux version 2.6.9-rc1 (han@marsupilami) (gcc version 3.3.3 (CRUX)) #1 Sat Sep 4 22:43:12 CEST 2004
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000002fff0000 (usable)
 BIOS-e820: 000000002fff0000 - 000000002fff8000 (ACPI data)
 BIOS-e820: 000000002fff8000 - 0000000030000000 (ACPI NVS)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
767MB LOWMEM available.
On node 0 totalpages: 196592
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 192496 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
Built 1 zonelists
Kernel command line: BOOT_IMAGE=269rc1 ro root=305 acpi=off hdc=ide-cd hdd=ide-cd
ide_setup: hdc=ide-cd
ide_setup: hdd=ide-cd
Initializing CPU#0
PID hash table entries: 4096 (order 12: 32768 bytes)
Detected 1467.420 MHz processor.
Using tsc for high-res timesource
Console: colour dummy device 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 774912k/786368k available (2324k kernel code, 10704k reserved, 714k data, 396k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 2891.77 BogoMIPS
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: 0383fbff c1c3fbff 00000000 00000000
CPU: After vendor identify, caps:  0383fbff c1c3fbff 00000000 00000000
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
CPU: After all inits, caps:        0383fbff c1c3fbff 00000000 00000020
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU: AMD Athlon(tm) XP 1700+ stepping 02
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
ACPI: IRQ9 SCI: Edge set to Level Trigger.
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfdaf1, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040715
ACPI: Interpreter disabled.
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Using IRQ router default [1106/3147] at 0000:00:11.0
PCI: IRQ 0 for device 0000:00:11.1 doesn't match PIRQ mask - try pci=usepirqmask
PCI: Hardcoded IRQ 14 for device 0000:00:11.1
get_random_bytes called before random driver initialization
vesafb: framebuffer at 0xd0000000, mapped to 0xf0807000, size 3072k
vesafb: mode is 1024x768x16, linelength=2048, pages=1
vesafb: protected mode interface info at c000:e4d0
vesafb: scrolling: redraw
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
fb0: VESA VGA frame buffer device
Machine check exception polling timer started.
apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
apm: driver version: No APM present
Console: switching to colour frame buffer device 128x48
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected VIA KT266/KY266x/KT333 chipset
agpgart: Maximum main memory to use for agp memory: 690M
agpgart: AGP aperture is 128M @ 0xe0000000
Serial: 8250/16550 driver $Revision: 1.90 $ 8 ports, IRQ sharing disabled
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
8139too Fast Ethernet driver 0.9.27
eth0: RealTek RTL8139 at 0xf0b88f00, 00:e0:4c:67:52:80, IRQ 10
eth0:  Identified 8139 chip type 'RTL-8139B'
Universal TUN/TAP device driver 1.5 (C)1999-2002 Maxim Krasnyansky
r8169 Gigabit Ethernet driver 1.2 loaded
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: RTL8169 at 0xf0b8ae00, 00:08:a1:3c:34:7a, IRQ 12
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:11.1
PCI: Hardcoded IRQ 14 for device 0000:00:11.1
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt8233a (rev 00) IDE UDMA133 controller on pci0000:00:11.1
    ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:DMA, hdd:pio
hda: ST340823A, ATA DISK drive
hdb: BDV 108A DVDROM, ATAPI CD/DVD-ROM drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hdc: LITE-ON LTR-40125S, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 78165360 sectors (40020 MB) w/512KiB Cache, CHS=65535/16/63, UDMA(100)
hda: cache flushes supported
 hda: hda1 hda2 < hda5 hda6 hda7 hda8 hda9 hda10 >
hdb: ATAPI DVD-ROM drive, 512kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
hdc: ATAPI 48X CD-ROM CD-R/RW drive, 2048kB Cache, UDMA(33)
ide-floppy driver 0.99.newide
USB Universal Host Controller Interface driver v2.2
uhci_hcd 0000:00:11.2: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
uhci_hcd 0000:00:11.2: irq 5, io base 0000d800
uhci_hcd 0000:00:11.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
uhci_hcd 0000:00:11.3: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (#2)
uhci_hcd 0000:00:11.3: irq 5, io base 0000dc00
uhci_hcd 0000:00:11.3: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
input: AT Translated Set 2 keyboard on isa0060/serio0
Advanced Linux Sound Architecture Driver Version 1.0.4 (Mon May 17 14:31:44 2004 UTC).
ALSA device list:
  #0: Sound Blaster Live! (rev.7) at 0xe000, irq 10
NET: Registered protocol family 2
IP: routing cache hash table of 8192 buckets, 64Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET: Registered protocol family 1
NET: Registered protocol family 17
usb 1-1: new low speed USB device using address 2
UDF-fs: No VRS found
VFS: Mounted root (jfs filesystem) readonly.
Freeing unused kernel memory: 396k freed
HID Mouse 0xc024 forced to 2 ms polling
input: USB HID v1.10 Mouse [B16_b_02 USB-PS/2 Optical Mouse] on usb-0000:00:11.2-1
Adding 257000k swap on /dev/hda6.  Priority:-1 extents:1


> - the content of the /proc/interrupts file once the r8169 is ifconfig'ed up

           CPU0
  0:    1012596          XT-PIC  timer
  1:       2271          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  5:      35354          XT-PIC  uhci_hcd, uhci_hcd
  8:          1          XT-PIC  rtc
 10:       8922          XT-PIC  EMU10K1
 11:      68450          XT-PIC  nvidia
 12:     203034          XT-PIC  eth1
 14:       7347          XT-PIC  ide0
 15:         20          XT-PIC  ide1
NMI:          0
ERR:          0

> If you can stay with us until an in kernel, modified, r8169 driver
> works with your setup, it should be possible to get the best of both
> worlds.

Please let me know if you want to test new patches based on stuff you
found in the realtek driver.



# Han
--
A random bookmark:                              http://crypto.yashy.com/nmap.php
