From: TommyDrum <mycooc@yahoo.it>
Subject: [Fwd: Re: r8169 native module problems on 2.6.11]
Date: Sun, 10 Apr 2005 20:11:10 +0200
Message-ID: <42596C3E.5020506@yahoo.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000905000008070802080408"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000905000008070802080408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j3AI5Q7P002593

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1



Forwarded because I forgot to Cc: it... (sorry)

O/H Francois Romieu =CE=AD=CE=B3=CF?=CE=B1=CF=C6=CE=B5:

|>ACPI: PCI interrupt 0000:00:09.0[A] -> GSI 11 (level, low) -> IRQ 11
|>eth0: Identified chip type is 'RTL8169s/8110s'.
|>eth0: U.S. Robotics 10/100/1000 PCI NIC driver version 2.0 at
|
| ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
|
|>0xe08ee000, 00:c0:49:f2:86:1e, IRQ 11
|>eth0: Auto-negotiation Enabled.
|
|
| Can you check that the message above is _really_ the output of your
| native kernel ? I have not checked gentoo's sources but the real vanill=
a
| kernel can not issue this string.
|

Sorry, my mistake... the output above was from a modprobe of the same
external module. I was confused because the kernel doesn't show like its
native module is present anyway, even when modprobed (as you can see
from the info you requested).

| You can send for both working/non-working after module insertion (wait
| for a few seconds):
| - complete dmesg (the beginning of it could be in /var/log/dmesg or suc=
h)

dmesg_native is the kernel's native r8169 module dmesg, while
dmesg_external is the external module dmesg provided by usr cd.

| - lspci -vx
| - lsmod
| - ifconfig -a
| - ethtool eth0
| - cat /proc/interrupts

All follow the same naming scheme as you can see from attached messages.
I noticed that the kernel totally ignores native module r8169, even if
it shows it as modprobed in lsmod. All logs were taken in two separate
reboots.

| - source code

Did you mean the source code of the external module? It's the
r8169_external.tar.gz file. Modinfo says it's GPL'ed, but I didn't find
any notice of it in the cdrom.

| - brand name of the motherboard

It's a Supermicro 370SDA which accepts pentium celeron and pentium III's
up to 1GHz (socket 370). There's a pIII 933 mounted on it.

| - the name given by USR to the adapter (check the box)

It's referred to as "High-Performance 10/100/1000Mbps Desktop/Server
Networking Model 7902". The part number is USR997902 "PCI NIC ASSEMBLED
IN CHINA IN 2004".

| I do not mind if the info is mailed, available on some web site or stuf=
fed
| at bugzilla.kernel.org. Please Cc: netdev@oss.sgi.com on further messag=
es.

Ehmm.... I'm not sure if I have to Cc: this message to
netdev@oss.sgi.com together with attached files... please say so if
needed. Oh, mind that I'm not subscribed to the linux-kernel mailing
list. Ciao!

TIA,
Tommy

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCWWw4gpUvhTIUBAERAhFsAJ9VJRmWH0IwnbYZ52n7rBnJwNm46ACeJl6d
GiunYz3TC3+eUx/gi7T2Rmg=3D
=3DjGck
-----END PGP SIGNATURE-----

--------------000905000008070802080408
Content-Type: text/plain;
 name="dmesg_external"
Content-Disposition: inline;
 filename="dmesg_external"
Content-Transfer-Encoding: 7bit

Linux version 2.6.11-gentoo-r5 (root@Pitagora) (gcc version 3.3.5 (Gentoo Linux 3.3.5-r1, ssp-3.3.2-3, pie-8.7.7.1)) #1 Wed Apr 6 05:09:01 CEST 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
 BIOS-e820: 000000001fff0000 - 000000001fff3000 (ACPI NVS)
 BIOS-e820: 000000001fff3000 - 0000000020000000 (ACPI data)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
511MB LOWMEM available.
On node 0 totalpages: 131056
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 126960 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI: RSDP (v000 VIA694                                ) @ 0x000f6bc0
ACPI: RSDT (v001 VIA694 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1fff3000
ACPI: FADT (v001 VIA694 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1fff3040
ACPI: DSDT (v001 VIA694 AWRDACPI 0x00001000 MSFT 0x0100000c) @ 0x00000000
Allocating PCI resources starting at 20000000 (gap: 20000000:dfff0000)
Built 1 zonelists
Kernel command line: BOOT_IMAGE=2.6.11-r5 ro root=341 no-hlt root=/dev/hdb3 init=/linuxrc video=aty128fb:accel,1280x1024@16
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 32768 bytes)
Detected 933.275 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 514228k/524224k available (3067k kernel code, 9440k reserved, 1043k data, 176k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 1839.10 BogoMIPS (lpj=919552)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: 0383f9ff 00000000 00000000 00000000 00000000 00000000 00000000
CPU: After vendor identify, caps: 0383f9ff 00000000 00000000 00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU: After all inits, caps: 0383f9ff 00000000 00000000 00000040 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU: Intel Pentium III (Coppermine) stepping 0a
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... disabled
ACPI: setting ELCR to 0200 (from 1e20)
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfb3b0, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20050211
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Via IRQ fixup
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 11 *12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *10 11 12 14 15)
PCI: Using ACPI for IRQ routing
** PCI interrupts are no longer routed automatically.  If this
** causes a device to stop working, it is probably because the
** driver failed to call pci_enable_device().  As a temporary
** workaround, the "pci=routeirq" argument restores the old
** behavior.  If this argument makes the device work again,
** please email the output of "lspci" to bjorn.helgaas@hp.com
** so I can fix the driver.
inotify device minor=63
NTFS driver 2.1.22 [Flags: R/W].
Initializing Cryptographic API
lp: driver loaded but no devices found
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected VIA Pro 266 chipset
agpgart: Maximum main memory to use for agp memory: 439M
agpgart: AGP aperture is 64M @ 0xf0000000
[drm] Initialized drm 1.0.0 20040925
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 12
PCI: setting IRQ 12 as level-triggered
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 12 (level, low) -> IRQ 12
[drm] Initialized r128 2.5.0 20030725 on minor 0: ATI Technologies Inc Rage 128 Pro Ultra TF
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 12 (level, low) -> IRQ 12
aty128fb: Found Intel x86 BIOS ROM Image
aty128fb: Rage128 BIOS located
aty128fb: Rage128 TF Ultra AGP [chip rev 0x4] 32M 128-bit SDR SGRAM (1:1)
Console: switching to colour frame buffer device 160x64
fb0: ATY Rage128 frame buffer device on Rage128 TF Ultra AGP
aty128fb: Rage128 MTRR set to ON
ACPI: Power Button (FF) [PWRF]
ACPI: CPU0 (power states: C1[C1] C2[C2])
ACPI: Processor [CPU0] (supports 2 throttling states)
ACPI: Thermal Zone [THRM] (0 C)
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 8 ports, IRQ sharing disabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard on isa0060/serio0
input: PC Speaker
parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
parport0: irq 7 detected
lp0: using parport0 (polling).
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:11.1
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt8233 (rev 00) IDE UDMA100 controller on pci0000:00:11.1
    ide0: BM-DMA at 0xd400-0xd407, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xd408-0xd40f, BIOS settings: hdc:DMA, hdd:DMA
Probing IDE interface ide0...
hda: IC35L080AVVA07-0, ATA DISK drive
hdb: ST38410A, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: HL-DT-ST CD-RW GCE-8240B, ATAPI CD/DVD-ROM drive
hdd: JLMS XJ-HD166S, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide2...
Probing IDE interface ide3...
Probing IDE interface ide4...
Probing IDE interface ide5...
hda: max request size: 128KiB
hda: 160836480 sectors (82348 MB) w/1863KiB Cache, CHS=65535/16/63, UDMA(100)
hda: cache flushes supported
 hda: hda1 hda2 < hda5 > hda3 hda4
hdb: max request size: 128KiB
hdb: 16841664 sectors (8622 MB) w/512KiB Cache, CHS=16708/16/63, UDMA(66)
hdb: cache flushes not supported
 hdb: hdb1 hdb2 hdb3
hdc: ATAPI 40X CD-ROM CD-R/RW drive, 8192kB Cache, DMA
Uniform CD-ROM driver Revision: 3.20
hdd: ATAPI 48X DVD-ROM drive, 512kB Cache, UDMA(33)
Advanced Linux Sound Architecture Driver Version 1.0.8 (Thu Jan 13 09:39:32 2005 UTC).
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI interrupt 0000:00:08.0[A] -> GSI 5 (level, low) -> IRQ 5
ALSA device list:
  #0: Sound Fusion CS46xx at 0xfb102000/0xfb000000, irq 5
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP established hash table entries: 32768 (order: 6, 262144 bytes)
TCP bind hash table entries: 32768 (order: 5, 131072 bytes)
TCP: Hash tables configured (established 32768 bind 32768)
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
ACPI wakeup devices: 
PCI0 USB0 USB1 USB2 LAN0 UAR1 ECP1 
ACPI: (supports S0 S1 S4 S5)
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 176k freed
kjournald starting.  Commit interval 5 seconds
Adding 506016k swap on /dev/hdb2.  Priority:1 extents:1
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hdb3, internal journal
usbcore: registered new driver usbfs
usbcore: registered new driver hub
USB Universal Host Controller Interface driver v2.2
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI interrupt 0000:00:11.2[D] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:11.2: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
uhci_hcd 0000:00:11.2: irq 10, io base 0xd800
uhci_hcd 0000:00:11.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:11.3[D] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:11.3: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (#2)
uhci_hcd 0000:00:11.3: irq 10, io base 0xdc00
uhci_hcd 0000:00:11.3: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI interrupt 0000:00:09.0[A] -> GSI 11 (level, low) -> IRQ 11
eth0: Identified chip type is 'RTL8169s/8110s'.
eth0: U.S. Robotics 10/100/1000 PCI NIC driver version 2.0 at 0xe0892000, 00:c0:49:f2:86:1e, IRQ 11
eth0: Auto-negotiation Enabled.
usb 1-2: new low speed USB device using uhci_hcd and address 2
usbcore: registered new driver hiddev
input: USB HID v1.00 Mouse [04b4:0001] on usb-0000:00:11.2-2
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hdb3, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.

--------------000905000008070802080408
Content-Type: text/plain;
 name="dmesg_native"
Content-Disposition: inline;
 filename="dmesg_native"
Content-Transfer-Encoding: 7bit

Linux version 2.6.11-gentoo-r5 (root@Pitagora) (gcc version 3.3.5 (Gentoo Linux 3.3.5-r1, ssp-3.3.2-3, pie-8.7.7.1)) #1 Wed Apr 6 05:09:01 CEST 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
 BIOS-e820: 000000001fff0000 - 000000001fff3000 (ACPI NVS)
 BIOS-e820: 000000001fff3000 - 0000000020000000 (ACPI data)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
511MB LOWMEM available.
On node 0 totalpages: 131056
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 126960 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI: RSDP (v000 VIA694                                ) @ 0x000f6bc0
ACPI: RSDT (v001 VIA694 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1fff3000
ACPI: FADT (v001 VIA694 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x1fff3040
ACPI: DSDT (v001 VIA694 AWRDACPI 0x00001000 MSFT 0x0100000c) @ 0x00000000
Allocating PCI resources starting at 20000000 (gap: 20000000:dfff0000)
Built 1 zonelists
Kernel command line: BOOT_IMAGE=2.6.11-r5 ro root=341 no-hlt root=/dev/hdb3 init=/linuxrc video=aty128fb:accel,1280x1024@16
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 32768 bytes)
Detected 933.275 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 514228k/524224k available (3067k kernel code, 9440k reserved, 1043k data, 176k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 1839.10 BogoMIPS (lpj=919552)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: 0383f9ff 00000000 00000000 00000000 00000000 00000000 00000000
CPU: After vendor identify, caps: 0383f9ff 00000000 00000000 00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU: After all inits, caps: 0383f9ff 00000000 00000000 00000040 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU: Intel Pentium III (Coppermine) stepping 0a
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... disabled
ACPI: setting ELCR to 0200 (from 1e20)
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfb3b0, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20050211
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Via IRQ fixup
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 11 *12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *10 11 12 14 15)
PCI: Using ACPI for IRQ routing
** PCI interrupts are no longer routed automatically.  If this
** causes a device to stop working, it is probably because the
** driver failed to call pci_enable_device().  As a temporary
** workaround, the "pci=routeirq" argument restores the old
** behavior.  If this argument makes the device work again,
** please email the output of "lspci" to bjorn.helgaas@hp.com
** so I can fix the driver.
inotify device minor=63
NTFS driver 2.1.22 [Flags: R/W].
Initializing Cryptographic API
lp: driver loaded but no devices found
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected VIA Pro 266 chipset
agpgart: Maximum main memory to use for agp memory: 439M
agpgart: AGP aperture is 64M @ 0xf0000000
[drm] Initialized drm 1.0.0 20040925
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 12
PCI: setting IRQ 12 as level-triggered
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 12 (level, low) -> IRQ 12
[drm] Initialized r128 2.5.0 20030725 on minor 0: ATI Technologies Inc Rage 128 Pro Ultra TF
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 12 (level, low) -> IRQ 12
aty128fb: Found Intel x86 BIOS ROM Image
aty128fb: Rage128 BIOS located
aty128fb: Rage128 TF Ultra AGP [chip rev 0x4] 32M 128-bit SDR SGRAM (1:1)
Console: switching to colour frame buffer device 160x64
fb0: ATY Rage128 frame buffer device on Rage128 TF Ultra AGP
aty128fb: Rage128 MTRR set to ON
ACPI: Power Button (FF) [PWRF]
ACPI: CPU0 (power states: C1[C1] C2[C2])
ACPI: Processor [CPU0] (supports 2 throttling states)
ACPI: Thermal Zone [THRM] (0 C)
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 8 ports, IRQ sharing disabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard on isa0060/serio0
input: PC Speaker
parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
parport0: irq 7 detected
lp0: using parport0 (polling).
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:11.1
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt8233 (rev 00) IDE UDMA100 controller on pci0000:00:11.1
    ide0: BM-DMA at 0xd400-0xd407, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xd408-0xd40f, BIOS settings: hdc:DMA, hdd:DMA
Probing IDE interface ide0...
hda: IC35L080AVVA07-0, ATA DISK drive
hdb: ST38410A, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: HL-DT-ST CD-RW GCE-8240B, ATAPI CD/DVD-ROM drive
hdd: JLMS XJ-HD166S, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide2...
Probing IDE interface ide3...
Probing IDE interface ide4...
Probing IDE interface ide5...
hda: max request size: 128KiB
hda: 160836480 sectors (82348 MB) w/1863KiB Cache, CHS=65535/16/63, UDMA(100)
hda: cache flushes supported
 hda: hda1 hda2 < hda5 > hda3 hda4
hdb: max request size: 128KiB
hdb: 16841664 sectors (8622 MB) w/512KiB Cache, CHS=16708/16/63, UDMA(66)
hdb: cache flushes not supported
 hdb: hdb1 hdb2 hdb3
hdc: ATAPI 40X CD-ROM CD-R/RW drive, 8192kB Cache, DMA
Uniform CD-ROM driver Revision: 3.20
hdd: ATAPI 48X DVD-ROM drive, 512kB Cache, UDMA(33)
Advanced Linux Sound Architecture Driver Version 1.0.8 (Thu Jan 13 09:39:32 2005 UTC).
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI interrupt 0000:00:08.0[A] -> GSI 5 (level, low) -> IRQ 5
ALSA device list:
  #0: Sound Fusion CS46xx at 0xfb102000/0xfb000000, irq 5
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP established hash table entries: 32768 (order: 6, 262144 bytes)
TCP bind hash table entries: 32768 (order: 5, 131072 bytes)
TCP: Hash tables configured (established 32768 bind 32768)
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
ACPI wakeup devices: 
PCI0 USB0 USB1 USB2 LAN0 UAR1 ECP1 
ACPI: (supports S0 S1 S4 S5)
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 176k freed
kjournald starting.  Commit interval 5 seconds
Adding 506016k swap on /dev/hdb2.  Priority:1 extents:1
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hdb3, internal journal
usbcore: registered new driver usbfs
usbcore: registered new driver hub
USB Universal Host Controller Interface driver v2.2
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI interrupt 0000:00:11.2[D] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:11.2: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
uhci_hcd 0000:00:11.2: irq 10, io base 0xd800
uhci_hcd 0000:00:11.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:11.3[D] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:11.3: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (#2)
uhci_hcd 0000:00:11.3: irq 10, io base 0xdc00
uhci_hcd 0000:00:11.3: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
usb 1-2: new low speed USB device using uhci_hcd and address 2
usbcore: registered new driver hiddev
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
input: USB HID v1.00 Mouse [04b4:0001] on usb-0000:00:11.2-2
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver

--------------000905000008070802080408
Content-Type: text/plain;
 name="ethtool_external"
Content-Disposition: inline;
 filename="ethtool_external"
Content-Transfer-Encoding: 7bit

Settings for eth0:
No data available

--------------000905000008070802080408
Content-Type: text/plain;
 name="ethtool_native"
Content-Disposition: inline;
 filename="ethtool_native"
Content-Transfer-Encoding: 7bit

Settings for eth0:
Cannot get device settings: No such device
Cannot get wake-on-lan settings: No such device
Cannot get message level: No such device
Cannot get link status: No such device
No data available



--------------000905000008070802080408
Content-Type: text/plain;
 name="ifconfig_external"
Content-Disposition: inline;
 filename="ifconfig_external"
Content-Transfer-Encoding: 7bit

eth0      Link encap:Ethernet  HWaddr 00:C0:49:F2:86:1E  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:29 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:7182 (7.0 Kb)
          Interrupt:11 Base address:0x2000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)


--------------000905000008070802080408
Content-Type: text/plain;
 name="ifconfig_native"
Content-Disposition: inline;
 filename="ifconfig_native"
Content-Transfer-Encoding: 7bit

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)


--------------000905000008070802080408
Content-Type: text/plain;
 name="lsmod_external"
Content-Disposition: inline;
 filename="lsmod_external"
Content-Transfer-Encoding: 7bit

Module                  Size  Used by
usbhid                 34464  0 
r8169                  15008  0 
uhci_hcd               33104  0 
usbcore               122200  3 usbhid,uhci_hcd

--------------000905000008070802080408
Content-Type: text/plain;
 name="lsmod_native"
Content-Disposition: inline;
 filename="lsmod_native"
Content-Transfer-Encoding: 7bit

Module                  Size  Used by
usbhid                 34464  0 
r8169                  25516  0 
uhci_hcd               33104  0 
usbcore               122200  3 usbhid,uhci_hcd

--------------000905000008070802080408
Content-Type: text/plain;
 name="lspcivx_external"
Content-Disposition: inline;
 filename="lspcivx_external"
Content-Transfer-Encoding: 7bit

0000:00:00.0 Host bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266] (rev 01)
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, medium devsel, latency 8
	Memory at f0000000 (32-bit, prefetchable)
	Capabilities: [a0] AGP version 2.0
	Capabilities: [c0] Power Management version 2
00: 06 11 91 30 06 00 10 22 01 00 00 06 00 08 00 00
10: 08 00 00 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

0000:00:01.0 PCI bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266 AGP] (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: f8000000-f9ffffff
	Prefetchable memory behind bridge: f4000000-f7ffffff
	Expansion ROM at 0000c000 [disabled] [size=4K]
	Capabilities: [80] Power Management version 2
00: 06 11 91 b0 07 00 30 22 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 c0 c0 00 00
20: 00 f8 f0 f9 00 f4 f0 f7 00 00 00 00 d9 15 66 18
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 0c 00

0000:00:08.0 Multimedia audio controller: Cirrus Logic CS 4614/22/24 [CrystalClear SoundFusion Audio Accelerator] (rev 01)
	Subsystem: Hercules: Unknown device a010
	Flags: bus master, slow devsel, latency 32, IRQ 5
	Memory at fb102000 (32-bit, non-prefetchable)
	Memory at fb000000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [40] Power Management version 2
00: 13 10 03 60 06 00 10 04 01 00 01 04 00 20 00 00
10: 00 20 10 fb 00 00 00 fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 81 16 10 a0
30: 00 00 00 00 40 00 00 00 00 00 00 00 05 01 04 18

0000:00:09.0 Ethernet controller: U.S. Robotics USR997902 10/100/1000 Mbps PCI Network Card (rev 10)
	Subsystem: U.S. Robotics USR997902 10/100/1000 Mbps PCI Network Card
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 11
	I/O ports at d000
	Memory at fb103000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [dc] Power Management version 2
00: ec 16 16 01 07 00 b0 02 10 00 00 02 08 20 00 00
10: 01 d0 00 00 00 30 10 fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 16 16 01
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 20 40

0000:00:0a.0 Network controller: RaLink Ralink RT2500 802.11 Cardbus Reference Card (rev 01)
	Subsystem: Micro-Star International Co., Ltd.: Unknown device 6834
	Flags: bus master, slow devsel, latency 32, IRQ 10
	Memory at fb100000 (32-bit, non-prefetchable)
	Capabilities: [40] Power Management version 2
00: 14 18 01 02 07 00 10 04 01 00 80 02 08 20 00 00
10: 00 00 10 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 01 06 00 00 62 14 34 68
30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 00 00

0000:00:11.0 ISA bridge: VIA Technologies, Inc. VT8233 PCI to ISA Bridge
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, stepping, medium devsel, latency 0
	Capabilities: [c0] Power Management version 2
00: 06 11 74 30 87 00 10 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00

0000:00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, medium devsel, latency 32
	I/O ports at d400 [size=16]
	Capabilities: [c0] Power Management version 2
00: 06 11 71 05 07 00 90 02 06 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d4 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 00 00 00

0000:00:11.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 18) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
	Flags: bus master, medium devsel, latency 32, IRQ 10
	I/O ports at d800 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 18 00 03 0c 08 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d8 00 00 00 00 00 00 00 00 00 00 25 09 34 12
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 04 00 00

0000:00:11.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 18) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
	Flags: bus master, medium devsel, latency 32, IRQ 10
	I/O ports at dc00 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 18 00 03 0c 08 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 dc 00 00 00 00 00 00 00 00 00 00 25 09 34 12
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 04 00 00

0000:01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 Pro Ultra TF (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage Fury Pro/Xpert 2000 Pro
	Flags: bus master, stepping, 66Mhz, medium devsel, latency 32, IRQ 12
	Memory at f4000000 (32-bit, prefetchable)
	I/O ports at c000 [size=256]
	Memory at f9000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [50] AGP version 2.0
	Capabilities: [5c] Power Management version 2
00: 02 10 46 54 87 00 b0 02 00 00 00 03 08 20 00 00
10: 08 00 00 f4 01 c0 00 00 00 00 00 f9 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 18 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 0c 01 08 00


--------------000905000008070802080408
Content-Type: text/plain;
 name="lspcivx_native"
Content-Disposition: inline;
 filename="lspcivx_native"
Content-Transfer-Encoding: 7bit

0000:00:00.0 Host bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266] (rev 01)
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, medium devsel, latency 8
	Memory at f0000000 (32-bit, prefetchable)
	Capabilities: [a0] AGP version 2.0
	Capabilities: [c0] Power Management version 2
00: 06 11 91 30 06 00 10 22 01 00 00 06 00 08 00 00
10: 08 00 00 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

0000:00:01.0 PCI bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266 AGP] (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: f8000000-f9ffffff
	Prefetchable memory behind bridge: f4000000-f7ffffff
	Expansion ROM at 0000c000 [disabled] [size=4K]
	Capabilities: [80] Power Management version 2
00: 06 11 91 b0 07 00 30 22 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 c0 c0 00 00
20: 00 f8 f0 f9 00 f4 f0 f7 00 00 00 00 d9 15 66 18
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 0c 00

0000:00:08.0 Multimedia audio controller: Cirrus Logic CS 4614/22/24 [CrystalClear SoundFusion Audio Accelerator] (rev 01)
	Subsystem: Hercules: Unknown device a010
	Flags: bus master, slow devsel, latency 32, IRQ 5
	Memory at fb102000 (32-bit, non-prefetchable)
	Memory at fb000000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [40] Power Management version 2
00: 13 10 03 60 06 00 10 04 01 00 01 04 00 20 00 00
10: 00 20 10 fb 00 00 00 fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 81 16 10 a0
30: 00 00 00 00 40 00 00 00 00 00 00 00 05 01 04 18

0000:00:09.0 Ethernet controller: U.S. Robotics USR997902 10/100/1000 Mbps PCI Network Card (rev 10)
	Subsystem: U.S. Robotics USR997902 10/100/1000 Mbps PCI Network Card
	Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 11
	I/O ports at d000
	Memory at fb103000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [dc] Power Management version 2
00: ec 16 16 01 07 00 b0 02 10 00 00 02 08 20 00 00
10: 01 d0 00 00 00 30 10 fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 16 16 01
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 20 40

0000:00:0a.0 Network controller: RaLink Ralink RT2500 802.11 Cardbus Reference Card (rev 01)
	Subsystem: Micro-Star International Co., Ltd.: Unknown device 6834
	Flags: bus master, slow devsel, latency 32, IRQ 10
	Memory at fb100000 (32-bit, non-prefetchable)
	Capabilities: [40] Power Management version 2
00: 14 18 01 02 07 00 10 04 01 00 80 02 08 20 00 00
10: 00 00 10 fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 01 06 00 00 62 14 34 68
30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 00 00

0000:00:11.0 ISA bridge: VIA Technologies, Inc. VT8233 PCI to ISA Bridge
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, stepping, medium devsel, latency 0
	Capabilities: [c0] Power Management version 2
00: 06 11 74 30 87 00 10 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00

0000:00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
	Subsystem: Super Micro Computer Inc: Unknown device 1866
	Flags: bus master, medium devsel, latency 32
	I/O ports at d400 [size=16]
	Capabilities: [c0] Power Management version 2
00: 06 11 71 05 07 00 90 02 06 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d4 00 00 00 00 00 00 00 00 00 00 d9 15 66 18
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 00 00 00

0000:00:11.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 18) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
	Flags: bus master, medium devsel, latency 32, IRQ 10
	I/O ports at d800 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 18 00 03 0c 08 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d8 00 00 00 00 00 00 00 00 00 00 25 09 34 12
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 04 00 00

0000:00:11.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 18) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
	Flags: bus master, medium devsel, latency 32, IRQ 10
	I/O ports at dc00 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 18 00 03 0c 08 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 dc 00 00 00 00 00 00 00 00 00 00 25 09 34 12
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 04 00 00

0000:01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 Pro Ultra TF (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage Fury Pro/Xpert 2000 Pro
	Flags: bus master, stepping, 66Mhz, medium devsel, latency 32, IRQ 12
	Memory at f4000000 (32-bit, prefetchable)
	I/O ports at c000 [size=256]
	Memory at f9000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [50] AGP version 2.0
	Capabilities: [5c] Power Management version 2
00: 02 10 46 54 87 00 b0 02 00 00 00 03 08 20 00 00
10: 08 00 00 f4 01 c0 00 00 00 00 00 f9 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 18 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 0c 01 08 00


--------------000905000008070802080408
Content-Type: text/plain;
 name="procinterrupts_external"
Content-Disposition: inline;
 filename="procinterrupts_external"
Content-Transfer-Encoding: 7bit

           CPU0       
  0:     291227          XT-PIC  timer
  1:       1521          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  5:          0          XT-PIC  CS46XX
  8:          2          XT-PIC  rtc
  9:          1          XT-PIC  acpi
 10:         90          XT-PIC  uhci_hcd, uhci_hcd
 11:         16          XT-PIC  eth0
 14:       2511          XT-PIC  ide0
 15:         48          XT-PIC  ide1
NMI:          0 
ERR:          0

--------------000905000008070802080408
Content-Type: text/plain;
 name="procinterrupts_native"
Content-Disposition: inline;
 filename="procinterrupts_native"
Content-Transfer-Encoding: 7bit

           CPU0       
  0:     788943          XT-PIC  timer
  1:       2185          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  5:          0          XT-PIC  CS46XX
  6:         32          XT-PIC  floppy
  8:          2          XT-PIC  rtc
  9:          1          XT-PIC  acpi
 10:       2201          XT-PIC  uhci_hcd, uhci_hcd
 14:      12762          XT-PIC  ide0
 15:         48          XT-PIC  ide1
NMI:          0 
ERR:          0

--------------000905000008070802080408
Content-Type: application/gzip;
 name="r8169_external.tar.gz"
Content-Disposition: inline;
 filename="r8169_external.tar.gz"
Content-Transfer-Encoding: base64

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
gPY+0zVXPEaEufK6WveW76OlPOIcQYGgO+NwWpVamZX8TQmDF+Y7khZKwPOLpS2M1E2/WWv0
961T11Ai6RKVDhnJBzy7E6YM0BSqPXIWHJs6Z/NxEaH/mTryFURMh5POJiq/nbwmy5fpJooK
NbZo/ByhdFx+D6HuC6A17aDWH8ZQTdhgmJYJPQrorVCjn18EtAb80CjNlpSnGVub8p62Pzlm
H45ZJx/+tOWCOSQpT/PWuD2j2YJmEZWwPU4FfL+TrSqsAhhTyuPSH+KbHCE3wpoZEZ1ROeDx
gqOyWA+rE5ElVYNlflqj6Y446RI7L4bRfFMcfRlvM8puXqIRFfR9h6XZepW3/UktHyG3EbR8
00pv08iTrnI9DjyRAIevoLOVmiA3M7vIadTeVRr5jlVqyq0KKN+M5DkDCh6uJhDx2hCSYW++
JaTqfdfSGA2tb7WK0Ma3xLeJd1uv9w5D+UThvQIFR2GRPVnFhDHv+y6OaI4zpSUJhLzzp90F
rQS0DEDc2VztVix7Xo7pZPIrJi+oqfBt2khLbVPmyubwZhoKKj1da0BWI4+aMdgZWhVk9bo2
0QUtoCutT46RkNWlxgE9RzWGIuzq7ZiFt7ES3m7Hoi7PbVykdh1rx5botx6T4BfSCrWwAy08
fdJ5plvYoRYgLbsF12eVbCSOERRQG7KJGP7DIRSSGe8wFKkRDMsf+I6CYqrDJ2DpXWjO27Tk
bbPkLCyXSYXWjLdsVy+Zql/bLVKfN62ul0vvWb3Q+Gv+pteK7Hlwx2J/xxYswNJbnvt02JvO
z9kzEEzcf/8XnFhv/3u9HX//Ianw/neTpzVv/yGp8P7X4h1//yGp8P7Xas+eefsPSf/u+9/+
vP1vF97/bq/m7z8kFd//Xj21/71i9zem8/fTE2//Ianw/vfaqfsPSf/u+3/xeft/8RXvf3r/
kyX2//Pv/8VF6v5fLJj/v8f+9z5v/3v/b+7/RS91/yHp+9j/wlivrs5Yb23Fs6yzbeOavruh
5RB4WX9bY/CFkFKJZf0kTPlbFeuh0AGFyhalXajCsUUMFKtSO0T8/acnT4tXwUBi3YvtpHCV
GGKL3Wy3n3WL9/IM/tZ3duvFq+zi351kiSq/h78/7VzUiq9y7Scc2bPtdvFuEvj77KJ3UXzJ
UCt3dydO7rH/SywAAoNnndoSC6C7MSpqd0Z8+h2wSha7Hn9oLgkIVPvEeF4PWsJjmIE8Y/j1
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
--------------000905000008070802080408--
