From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: Realtek 8111c weirdness problems, apic/msi, and normal bug
Date: Fri, 11 Apr 2008 03:11:55 +0200
Message-ID: <1207876315.1514.21.camel@localhost>
References: <1207407804.14885.27.camel@localhost>
	 <20080405232354.57ff2fac.akpm@linux-foundation.org>
	 <20080406140624.GA24479@electric-eye.fr.zoreil.com>
	 <1207541340.30698.18.camel@localhost>  <1207829872.1514.3.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-StoVgFg+XVG18R05OnFW"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML Mailinglist <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1207829872.1514.3.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-StoVgFg+XVG18R05OnFW
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Sorry for top posting, but its just easier in this case :)

I may have just gotten some new information to share.

I just built -git8. and the nic didnt work.. by booting with
noapic/nomsi i got it running though. then i did some tests, and
rebooted into the default(has worked mostly for me) noapic/msi boot.
Then it worked.

i did get some interresting information though, which i think may help
to fix the problem..

if its a boot where the nic works, i can usually rmmod/modprobe the
module once without it giving error, however if its a boot where the nic
doesent work, first time i rmmod and modprobe, it gives me an error..

the error is:
PCI: cache line size of 32 is not supported by device 0000:05:00.0
ACPI: PCI interrupt for device 0000:05:00.0 disabled
r8169: probe of 0000:05:00.0 failed with error -22

I have attached some dmesgs(sorry, but my client messes up inlines..)
also.. link detecting isnt working properly, sometimes it will detect a
link as down after a while.. its quite weird..

(oh, and this time its without nvidia just to be 100000% sure)

I hope this can help to get it resolved, alot of people are having
problems with these controllers.. i can however confirm that a similar
controller is working perfectly on a friends gigabyte motherboard, thats
with P35 chipset though, i have X48. He has only 1 of them onboard.

also something which may be of interrest, realtek offers a modified
r8169 driver called "r8168", which supposedly fixes this. I have been
unable to get it to compile though, but i saw it on ubuntu forums.


On Thu, 2008-04-10 at 14:17 +0200, Kasper Sandberg wrote:
> On Mon, 2008-04-07 at 06:09 +0200, Kasper Sandberg wrote:
> > Hello.
> > 
> > I apologize, but it will have to wait a few days, as the fan on the
> > graphics card just broke, and it overheats almost instantly.
> > 
> > I will post as soon as possible, sorry for the inconvenience.

<snip>
> 
> 
> 
> > > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=-StoVgFg+XVG18R05OnFW
Content-Disposition: attachment; filename=noapicmsi_workssemi
Content-Type: text/plain; name=noapicmsi_workssemi; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

und 12 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x290-0x29f has been reserved
system 00:01: ioport range 0x800-0x87f has been reserved
system 00:01: ioport range 0x290-0x294 has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:08: ioport range 0x400-0x4bf could not be reserved
system 00:09: iomem range 0xe0000000-0xe3ffffff could not be reserved
system 00:0a: iomem range 0xd1e00-0xd3fff has been reserved
system 00:0a: iomem range 0xf0000-0xf7fff could not be reserved
system 00:0a: iomem range 0xf8000-0xfbfff could not be reserved
system 00:0a: iomem range 0xfc000-0xfffff could not be reserved
system 00:0a: iomem range 0xcfee0000-0xcfefffff could not be reserved
system 00:0a: iomem range 0x0-0x9ffff could not be reserved
system 00:0a: iomem range 0x100000-0xcfedffff could not be reserved
system 00:0a: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0a: iomem range 0xfed10000-0xfed1dfff could not be reserved
system 00:0a: iomem range 0xfed20000-0xfed8ffff could not be reserved
system 00:0a: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0a: iomem range 0xffb00000-0xffb7ffff could not be reserved
system 00:0a: iomem range 0xfff00000-0xffffffff could not be reserved
system 00:0a: iomem range 0xe0000-0xeffff has been reserved
PCI: Bridge: 0000:00:01.0
  IO window: disabled.
  MEM window: 0xe4000000-0xe6ffffff
  PREFETCH window: 0x00000000d0000000-0x00000000dfffffff
PCI: Bridge: 0000:00:06.0
  IO window: 9000-9fff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: a000-afff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.3
  IO window: b000-bfff
  MEM window: 0xe9100000-0xe91fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: c000-cfff
  MEM window: 0xe7000000-0xe7ffffff
  PREFETCH window: 0x00000000e9000000-0x00000000e90fffff
PCI: Bridge: 0000:00:1c.5
  IO window: d000-dfff
  MEM window: 0xe8000000-0xe8ffffff
  PREFETCH window: 0x00000000e9200000-0x00000000e92fffff
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: 0xe9300000-0xe93fffff
  PREFETCH window: disabled.
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:00:01.0[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:06.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 15
PCI: setting IRQ 15 as level-triggered
ACPI: PCI Interrupt 0000:00:1c.3[D] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1c.3 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1c.4 to 64
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:1c.5[B] -> Link [LNKB] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1c.5 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
highmem bounce pool size: 64 pages
SGI XFS with ACLs, no debug enabled
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.3:pcie00]
Allocate Port Service[0000:00:1c.3:pcie02]
Allocate Port Service[0000:00:1c.3:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
PCI: Setting latency timer of device 0000:00:1c.5 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.5:pcie00]
Allocate Port Service[0000:00:1c.5:pcie02]
Allocate Port Service[0000:00:1c.5:pcie03]
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:1f.2: version 3.0
ACPI: PCI Interrupt 0000:00:1f.2[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
Switched to high resolution mode on CPU 0
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406100 irq 217
ata2: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406180 irq 217
ata3: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406200 irq 217
ata4: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406280 irq 217
ata5: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406300 irq 217
ata6: SATA max UDMA/133 abar m2048@0xe9406000 port 0xe9406380 irq 217
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3
sd 1:0:0:0: [sdb] Attached SCSI disk
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.7[C] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 5, io mem 0xe9405000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ACPI: PCI Interrupt Link [LNK1] enabled at IRQ 7
PCI: setting IRQ 7 as level-triggered
ACPI: PCI Interrupt 0000:00:1d.7[A] -> Link [LNK1] -> GSI 7 (level, low) -> IRQ 7
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 7, io mem 0xe9404000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 10, io base 0x0000e000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 3
PCI: setting IRQ 3 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.1[B] -> Link [LNKF] -> GSI 3 (level, low) -> IRQ 3
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 3, io base 0x0000e100
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1a.2[C] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 5, io base 0x0000e200
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> Link [LNK1] -> GSI 7 (level, low) -> IRQ 7
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 7, io base 0x0000e300
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 15, io base 0x0000e400
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 5, io base 0x0000e500
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
PNP: PS/2 Controller [PNP0f13:PS2M] at 0x60,0x64 irq 12
PNP: PS/2 controller doesn't have KBD irq; using default 1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
md: raid1 personality registered for level 1
cpuidle: using governor ladder
usb 8-2: new low speed USB device using uhci_hcd and address 2
usb 8-2: configuration #1 chosen from 1 choice
input: Logitech Logitech USB Keyboard as /class/input/input0
input: USB HID v1.10 Keyboard [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
input: Logitech Logitech USB Keyboard as /class/input/input1
input: USB HID v1.10 Mouse [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Using IPI Shortcut mode
input: ImPS/2 Generic Wheel Mouse as /class/input/input2
md: Autodetecting RAID arrays.
md: Scanned 6 and added 6 devices.
md: autorun ...
md: considering sdb3 ...
md:  adding sdb3 ...
md: sdb2 has different UUID to sdb3
md: sdb1 has different UUID to sdb3
md:  adding sda3 ...
md: sda2 has different UUID to sdb3
md: sda1 has different UUID to sdb3
md: created md2
md: bind<sda3>
md: bind<sdb3>
md: running: <sdb3><sda3>
raid1: raid set md2 active with 2 out of 2 mirrors
md: considering sdb2 ...
md:  adding sdb2 ...
md: sdb1 has different UUID to sdb2
md:  adding sda2 ...
md: sda1 has different UUID to sdb2
md: created md1
md: bind<sda2>
md: bind<sdb2>
md: running: <sdb2><sda2>
raid1: raid set md1 active with 2 out of 2 mirrors
md: considering sdb1 ...
md:  adding sdb1 ...
md:  adding sda1 ...
md: created md0
md: bind<sda1>
md: bind<sdb1>
md: running: <sdb1><sda1>
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
Filesystem "md1": Disabling barriers, not supported by the underlying device
XFS mounting filesystem md1
Ending clean XFS mount for filesystem: md1
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 204k freed
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: Processor [CPU0] (supports 8 throttling states)
input: Power Button (FF) as /class/input/input3
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input4
ACPI: Power Button (CM) [PWRB]
ACPI: PCI Interrupt Link [LNK0] enabled at IRQ 14
PCI: setting IRQ 14 as level-triggered
ACPI: PCI Interrupt 0000:00:1b.0[A] -> Link [LNK0] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for ALC882, trying auto-probe from BIOS...
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKA] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:05:00.0 to 64
eth0: RTL8168c/8111c at 0xf8878000, 00:1d:7d:06:7b:39, XID 3c2000c0 IRQ 216
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:06:00.0[A] -> Link [LNKB] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:06:00.0 to 64
eth1: RTL8168c/8111c at 0xf88a6000, 00:1d:7d:06:75:d8, XID 3c2000c0 IRQ 215
Filesystem "md1": Disabling barriers, not supported by the underlying device
r8169: eth1: link up
r8169: eth1: link up
r8169: eth1: link up
r8169: eth0: link up
r8169: eth0: link up

--=-StoVgFg+XVG18R05OnFW
Content-Disposition: attachment; filename=noapicnomsi_only1enabled_broken_error
Content-Type: text/plain; name=noapicnomsi_only1enabled_broken_error; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

rrupt Link [LNK1] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x290-0x29f has been reserved
system 00:01: ioport range 0x800-0x87f has been reserved
system 00:01: ioport range 0x290-0x294 has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:08: ioport range 0x400-0x4bf could not be reserved
system 00:09: iomem range 0xe0000000-0xe3ffffff could not be reserved
system 00:0a: iomem range 0xd1e00-0xd3fff has been reserved
system 00:0a: iomem range 0xf0000-0xf7fff could not be reserved
system 00:0a: iomem range 0xf8000-0xfbfff could not be reserved
system 00:0a: iomem range 0xfc000-0xfffff could not be reserved
system 00:0a: iomem range 0xcfee0000-0xcfefffff could not be reserved
system 00:0a: iomem range 0x0-0x9ffff could not be reserved
system 00:0a: iomem range 0x100000-0xcfedffff could not be reserved
system 00:0a: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0a: iomem range 0xfed10000-0xfed1dfff could not be reserved
system 00:0a: iomem range 0xfed20000-0xfed8ffff could not be reserved
system 00:0a: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0a: iomem range 0xffb00000-0xffb7ffff could not be reserved
system 00:0a: iomem range 0xfff00000-0xffffffff could not be reserved
system 00:0a: iomem range 0xe0000-0xeffff has been reserved
PCI: Bridge: 0000:00:01.0
  IO window: disabled.
  MEM window: 0xe4000000-0xe6ffffff
  PREFETCH window: 0x00000000d0000000-0x00000000dfffffff
PCI: Bridge: 0000:00:06.0
  IO window: a000-afff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: c000-cfff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.3
  IO window: b000-bfff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: d000-dfff
  MEM window: 0xe7000000-0xe7ffffff
  PREFETCH window: 0x00000000e8000000-0x00000000e80fffff
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: 0xe8100000-0xe81fffff
  PREFETCH window: disabled.
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:01.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:06.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 15
PCI: setting IRQ 15 as level-triggered
ACPI: PCI Interrupt 0000:00:1c.3[D] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1c.3 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1c.4 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
highmem bounce pool size: 64 pages
SGI XFS with ACLs, no debug enabled
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.3:pcie00]
Allocate Port Service[0000:00:1c.3:pcie02]
Allocate Port Service[0000:00:1c.3:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:1f.2: version 3.0
ACPI: PCI Interrupt 0000:00:1f.2[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
Switched to high resolution mode on CPU 0
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206100 irq 15
ata2: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206180 irq 15
ata3: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206200 irq 15
ata4: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206280 irq 15
ata5: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206300 irq 15
ata6: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206380 irq 15
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3
sd 1:0:0:0: [sdb] Attached SCSI disk
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 14
PCI: setting IRQ 14 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.7[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 14, io mem 0xe8205000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ACPI: PCI Interrupt Link [LNK1] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI Interrupt 0000:00:1d.7[A] -> Link [LNK1] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 5, io mem 0xe8204000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 11, io base 0x0000e200
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 7
PCI: setting IRQ 7 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.1[B] -> Link [LNKF] -> GSI 7 (level, low) -> IRQ 7
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 7, io base 0x0000e000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1a.2[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 14, io base 0x0000e100
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> Link [LNK1] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 5, io base 0x0000e300
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 15, io base 0x0000e400
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 14, io base 0x0000e500
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
PNP: PS/2 Controller [PNP0f13:PS2M] at 0x60,0x64 irq 12
PNP: PS/2 controller doesn't have KBD irq; using default 1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
md: raid1 personality registered for level 1
cpuidle: using governor ladder
usb 8-2: new low speed USB device using uhci_hcd and address 2
usb 8-2: configuration #1 chosen from 1 choice
input: Logitech Logitech USB Keyboard as /class/input/input0
input: USB HID v1.10 Keyboard [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
input: Logitech Logitech USB Keyboard as /class/input/input1
input: USB HID v1.10 Mouse [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Using IPI Shortcut mode
input: ImPS/2 Generic Wheel Mouse as /class/input/input2
md: Autodetecting RAID arrays.
md: Scanned 6 and added 6 devices.
md: autorun ...
md: considering sdb3 ...
md:  adding sdb3 ...
md: sdb2 has different UUID to sdb3
md: sdb1 has different UUID to sdb3
md:  adding sda3 ...
md: sda2 has different UUID to sdb3
md: sda1 has different UUID to sdb3
md: created md2
md: bind<sda3>
md: bind<sdb3>
md: running: <sdb3><sda3>
raid1: raid set md2 active with 2 out of 2 mirrors
md: considering sdb2 ...
md:  adding sdb2 ...
md: sdb1 has different UUID to sdb2
md:  adding sda2 ...
md: sda1 has different UUID to sdb2
md: created md1
md: bind<sda2>
md: bind<sdb2>
md: running: <sdb2><sda2>
raid1: raid set md1 active with 2 out of 2 mirrors
md: considering sdb1 ...
md:  adding sdb1 ...
md:  adding sda1 ...
md: created md0
md: bind<sda1>
md: bind<sdb1>
md: running: <sdb1><sda1>
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
Filesystem "md1": Disabling barriers, not supported by the underlying device
XFS mounting filesystem md1
Ending clean XFS mount for filesystem: md1
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 204k freed
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: Processor [CPU0] (supports 8 throttling states)
input: Power Button (FF) as /class/input/input3
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input4
ACPI: Power Button (CM) [PWRB]
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:05:00.0 to 64
r8169 0000:05:00.0: no MSI. Back to INTx.
eth0: RTL8168c/8111c at 0xf8864000, 00:1d:7d:06:7b:39, XID 3c2000c0 IRQ 11
ACPI: PCI Interrupt Link [LNK0] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:00:1b.0[A] -> Link [LNK0] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for ALC882, trying auto-probe from BIOS...
Filesystem "md1": Disabling barriers, not supported by the underlying device
r8169: eth0: link up
r8169: eth0: link up
ACPI: PCI interrupt for device 0000:05:00.0 disabled
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:05:00.0 to 64
r8169 0000:05:00.0: no MSI. Back to INTx.
eth0: RTL8168c/8111c at 0xf8864000, 00:1d:7d:06:7b:39, XID 3c2000c0 IRQ 11
r8169: eth0: link up
ACPI: PCI interrupt for device 0000:05:00.0 disabled
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: cache line size of 32 is not supported by device 0000:05:00.0
ACPI: PCI interrupt for device 0000:05:00.0 disabled
r8169: probe of 0000:05:00.0 failed with error -22

--=-StoVgFg+XVG18R05OnFW
Content-Disposition: attachment; filename=noapicnomsi_only1enabled_works
Content-Type: text/plain; name=noapicnomsi_only1enabled_works; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 *7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x290-0x29f has been reserved
system 00:01: ioport range 0x800-0x87f has been reserved
system 00:01: ioport range 0x290-0x294 has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:08: ioport range 0x400-0x4bf could not be reserved
system 00:09: iomem range 0xe0000000-0xe3ffffff could not be reserved
system 00:0a: iomem range 0xd1e00-0xd3fff has been reserved
system 00:0a: iomem range 0xf0000-0xf7fff could not be reserved
system 00:0a: iomem range 0xf8000-0xfbfff could not be reserved
system 00:0a: iomem range 0xfc000-0xfffff could not be reserved
system 00:0a: iomem range 0xcfee0000-0xcfefffff could not be reserved
system 00:0a: iomem range 0x0-0x9ffff could not be reserved
system 00:0a: iomem range 0x100000-0xcfedffff could not be reserved
system 00:0a: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0a: iomem range 0xfed10000-0xfed1dfff could not be reserved
system 00:0a: iomem range 0xfed20000-0xfed8ffff could not be reserved
system 00:0a: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0a: iomem range 0xffb00000-0xffb7ffff could not be reserved
system 00:0a: iomem range 0xfff00000-0xffffffff could not be reserved
system 00:0a: iomem range 0xe0000-0xeffff has been reserved
PCI: Bridge: 0000:00:01.0
  IO window: disabled.
  MEM window: 0xe4000000-0xe6ffffff
  PREFETCH window: 0x00000000d0000000-0x00000000dfffffff
PCI: Bridge: 0000:00:06.0
  IO window: a000-afff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: c000-cfff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.3
  IO window: b000-bfff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: d000-dfff
  MEM window: 0xe7000000-0xe7ffffff
  PREFETCH window: 0x00000000e8000000-0x00000000e80fffff
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: 0xe8100000-0xe81fffff
  PREFETCH window: disabled.
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:01.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:06.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 15
PCI: setting IRQ 15 as level-triggered
ACPI: PCI Interrupt 0000:00:1c.3[D] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1c.3 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1c.4 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
highmem bounce pool size: 64 pages
SGI XFS with ACLs, no debug enabled
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.3:pcie00]
Allocate Port Service[0000:00:1c.3:pcie02]
Allocate Port Service[0000:00:1c.3:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:1f.2: version 3.0
ACPI: PCI Interrupt 0000:00:1f.2[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
Switched to high resolution mode on CPU 0
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206100 irq 15
ata2: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206180 irq 15
ata3: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206200 irq 15
ata4: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206280 irq 15
ata5: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206300 irq 15
ata6: SATA max UDMA/133 abar m2048@0xe8206000 port 0xe8206380 irq 15
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3
sd 1:0:0:0: [sdb] Attached SCSI disk
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 14
PCI: setting IRQ 14 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.7[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 14, io mem 0xe8205000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ACPI: PCI Interrupt Link [LNK1] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI Interrupt 0000:00:1d.7[A] -> Link [LNK1] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 5, io mem 0xe8204000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 11, io base 0x0000e200
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 7
PCI: setting IRQ 7 as level-triggered
ACPI: PCI Interrupt 0000:00:1a.1[B] -> Link [LNKF] -> GSI 7 (level, low) -> IRQ 7
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 7, io base 0x0000e000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1a.2[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 14, io base 0x0000e100
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> Link [LNK1] -> GSI 5 (level, low) -> IRQ 5
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 5, io base 0x0000e300
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> Link [LNKD] -> GSI 15 (level, low) -> IRQ 15
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 15, io base 0x0000e400
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> Link [LNKC] -> GSI 14 (level, low) -> IRQ 14
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 14, io base 0x0000e500
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
PNP: PS/2 Controller [PNP0f13:PS2M] at 0x60,0x64 irq 12
PNP: PS/2 controller doesn't have KBD irq; using default 1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
md: raid1 personality registered for level 1
cpuidle: using governor ladder
usb 8-2: new low speed USB device using uhci_hcd and address 2
usb 8-2: configuration #1 chosen from 1 choice
input: Logitech Logitech USB Keyboard as /class/input/input0
input: USB HID v1.10 Keyboard [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
input: Logitech Logitech USB Keyboard as /class/input/input1
input: USB HID v1.10 Mouse [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Using IPI Shortcut mode
input: ImPS/2 Generic Wheel Mouse as /class/input/input2
md: Autodetecting RAID arrays.
md: Scanned 6 and added 6 devices.
md: autorun ...
md: considering sdb3 ...
md:  adding sdb3 ...
md: sdb2 has different UUID to sdb3
md: sdb1 has different UUID to sdb3
md:  adding sda3 ...
md: sda2 has different UUID to sdb3
md: sda1 has different UUID to sdb3
md: created md2
md: bind<sda3>
md: bind<sdb3>
md: running: <sdb3><sda3>
raid1: raid set md2 active with 2 out of 2 mirrors
md: considering sdb2 ...
md:  adding sdb2 ...
md: sdb1 has different UUID to sdb2
md:  adding sda2 ...
md: sda1 has different UUID to sdb2
md: created md1
md: bind<sda2>
md: bind<sdb2>
md: running: <sdb2><sda2>
raid1: raid set md1 active with 2 out of 2 mirrors
md: considering sdb1 ...
md:  adding sdb1 ...
md:  adding sda1 ...
md: created md0
md: bind<sda1>
md: bind<sdb1>
md: running: <sdb1><sda1>
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
Filesystem "md1": Disabling barriers, not supported by the underlying device
XFS mounting filesystem md1
Ending clean XFS mount for filesystem: md1
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 204k freed
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: Processor [CPU0] (supports 8 throttling states)
input: Power Button (FF) as /class/input/input3
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input4
ACPI: Power Button (CM) [PWRB]
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
PCI: Setting latency timer of device 0000:05:00.0 to 64
r8169 0000:05:00.0: no MSI. Back to INTx.
eth0: RTL8168c/8111c at 0xf8864000, 00:1d:7d:06:7b:39, XID 3c2000c0 IRQ 11
ACPI: PCI Interrupt Link [LNK0] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:00:1b.0[A] -> Link [LNK0] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for ALC882, trying auto-probe from BIOS...
Filesystem "md1": Disabling barriers, not supported by the underlying device
r8169: eth0: link up
r8169: eth0: link up

--=-StoVgFg+XVG18R05OnFW--

