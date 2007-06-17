From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: high ping times with wireless-dev
Date: Sun, 17 Jun 2007 14:03:30 +0200
Message-ID: <200706171403.34299.maxi@daemonizer.de>
References: <200706162327.47413.maxi@daemonizer.de> <200706171255.40155.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7581689.RO0QYX5Hdk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200706171255.40155.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart7581689.RO0QYX5Hdk
Content-Type: multipart/mixed;
  boundary="Boundary-01=_TMSdGFcBDtYoDGe"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_TMSdGFcBDtYoDGe
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 17 June 2007, Michael Buesch wrote:
> On Saturday 16 June 2007 23:27:43 Maximilian Engelhardt wrote:
> > [...]
> > ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
> > ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, lo=
w)
> > -> IRQ 10
> > ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
> > b44.c:v2.0
> > eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
> > [...]
>
> Ok, I prepared two debugging patches.
>
> Please enable SonicsSiliconBackplane Debugging in the kernel kconfig,
> so I can get more detail information about your card.
> Device Drivers/Sonics Silicon Backplane/SSB debugging
> (Must disable "No SSB kernel messages")
>
> Please apply and test the attached debugging patches in a row.
> So apply patch 1 and test if it works again. If not, apply
> patch 2 and test if it works.
> Always save complete dmesg log on each test run and send it to me.
>
> Thanks for testing.
> (This time it seems we are actually getting somewhere, when
> dealing with sane people. :D )

I did the tests with my kernel where only the card is on interrupt 10. dmes=
g=20
is attached.
With the first patch applied networking does work again. I also additionall=
y=20
tried patch2 and it also does work.

Maxi

--Boundary-01=_TMSdGFcBDtYoDGe
Content-Type: text/plain;
  charset="utf-8";
  name="dmesg_patch1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="dmesg_patch1"

Linux version 2.6.22-rc4-wireless-dev-20070616-test1 (root@koala) (gcc vers=
ion 4.1.3 20070601 (prerelease) (Debian 4.1.2-12)) #6 PREEMPT Sun Jun 17 13=
:24:13 CEST 2007
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000ce000 - 00000000000d0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000004dee0000 (usable)
 BIOS-e820: 000000004dee0000 - 000000004deec000 (ACPI data)
 BIOS-e820: 000000004deec000 - 000000004df00000 (ACPI NVS)
 BIOS-e820: 000000004df00000 - 0000000050000000 (reserved)
 BIOS-e820: 00000000fec10000 - 00000000fec20000 (reserved)
 BIOS-e820: 00000000ff800000 - 00000000ffc00000 (reserved)
 BIOS-e820: 00000000fffffc00 - 0000000100000000 (reserved)
350MB HIGHMEM available.
896MB LOWMEM available.
Entering add_active_range(0, 0, 319200) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->   319200
early_node_map[1] active PFN ranges
    0:        0 ->   319200
On node 0 totalpages: 319200
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 1760 pages used for memmap
  Normal zone: 223520 pages, LIFO batch:31
  HighMem zone: 701 pages used for memmap
  HighMem zone: 89123 pages, LIFO batch:15
DMI present.
ACPI: RSDP 000F6050, 0014 (r0 ACER  )
ACPI: RSDT 4DEE5A39, 0030 (r1 ACER   Wagtail  20020114  LTP        0)
ACPI: FACP 4DEEBF2C, 0074 (r1 ACER   Wagtail  20020114 PTL        50)
ACPI: DSDT 4DEE5A69, 64C3 (r1 ACER   Wagtail  20020114 MSFT  100000E)
ACPI: FACS 4DEFCFC0, 0040
ACPI: HPET 4DEEBFA0, 0038 (r1 ACER   Wagtail  20020114 PTL         0)
ACPI: BOOT 4DEEBFD8, 0028 (r1 ACER   Wagtail  20020114  LTP        1)
ACPI: PM-Timer IO Port: 0x1008
ACPI: HPET id: 0x8086a201 base: 0x0
Allocating PCI resources starting at 60000000 (gap: 50000000:aec10000)
Built 1 zonelists.  Total pages: 316707
Kernel command line: root=3D/dev/sda1 ro vga=3D0x31b resume=3D/dev/sda2
Local APIC disabled by BIOS -- you can enable it with "lapic"
mapped APIC to ffffd000 (019c4000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 1395.565 MHz processor.
Console: colour dummy device 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1259844k/1276800k available (3572k kernel code, 16168k reserved, 11=
52k data, 220k init, 359296k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffaa000 - 0xfffff000   ( 340 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc05a0000 - 0xc05d7000   ( 220 kB)
      .data : 0xc047d05d - 0xc059d0b0   (1152 kB)
      .text : 0xc0100000 - 0xc047d05d   (3572 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
SLUB: Genslabs=3D23, HWalign=3D64, Order=3D0-1, MinObjects=3D4, Processors=
=3D1, Nodes=3D1
Calibrating delay using timer specific routine.. 2793.34 BogoMIPS (lpj=3D46=
53358)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: a7e9f9bf 00000000 00000000 00000000 0000=
0180 00000000 00000000
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 1024K
CPU: After all inits, caps: a7e9f9bf 00000000 00000000 00002040 00000180 00=
000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
Compat vDSO mapped to ffffe000.
CPU: Intel(R) Pentium(R) M processor 1400MHz stepping 05
Checking 'hlt' instruction... OK.
ACPI: Core revision 20070126
ACPI: setting ELCR to 0200 (from 0c00)
NET: Registered protocol family 16
No dock devices found.
ACPI: \_SB_.PCI0.IDE0.SECN.BAY1: found ejectable bay
ACPI: \_SB_.PCI0.IDE0.SECN.BAY1: Adding notify handler
ACPI: Bay [\_SB_.PCI0.IDE0.SECN.BAY1] Added
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfd742, last bus=3D2
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI quirk: region 1000-107f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 1180-11bf claimed by ICH4 GPIO
PCI: Transparent bridge - 0000:00:1e.0
PCI: Bus #03 (-#06) is hidden behind transparent bridge #02 (-#02) (try 'pc=
i=3Dassign-busses')
Please report the result to linux-kernel to fix this permanently
PCI: Bus #07 (-#0a) is hidden behind transparent bridge #02 (-#02) (try 'pc=
i=3Dassign-busses')
Please report the result to linux-kernel to fix this permanently
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs *11)
ACPI: PCI Interrupt Link [LNKB] (IRQs *10)
ACPI: PCI Interrupt Link [LNKC] (IRQs *10)
ACPI: PCI Interrupt Link [LNKD] (IRQs 10) *11
ACPI: PCI Interrupt Link [LNKE] (IRQs 10) *11
ACPI: PCI Interrupt Link [LNKF] (IRQs 10) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs *10)
ACPI: Power Resource [PFN0] (off)
ACPI: Power Resource [PFN1] (off)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 2.21 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=3Drouteirq".  If it helps, post a r=
eport
pnp: 00:04: iomem range 0xfec10000-0xfec1ffff could not be reserved
pnp: 00:04: iomem range 0xff800000-0xffbfffff could not be reserved
pnp: 00:04: iomem range 0xfff00000-0xffffffff could not be reserved
pnp: 00:04: iomem range 0x0-0x9ffff could not be reserved
Time: tsc clocksource has been installed.
PCI: Bus 3, cardbus bridge: 0000:02:06.0
  IO window: 00003000-000030ff
  IO window: 00003400-000034ff
  PREFETCH window: 60000000-63ffffff
  MEM window: 6c000000-6fffffff
PCI: Bus 7, cardbus bridge: 0000:02:06.1
  IO window: 00003800-000038ff
  IO window: 00003c00-00003cff
  PREFETCH window: 64000000-67ffffff
  MEM window: 70000000-73ffffff
PCI: Bridge: 0000:00:1e.0
  IO window: 3000-3fff
  MEM window: e0200000-e07fffff
  PREFETCH window: 60000000-67ffffff
PCI: Setting latency timer of device 0000:00:1e.0 to 64
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:02:06.0[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
ACPI: PCI Interrupt 0000:02:06.1[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
Simple Boot Flag at 0x37 set to 0x1
Machine check exception polling timer started.
highmem bounce pool size: 64 pages
NTFS driver 2.1.28 [Flags: R/W].
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:00:02.0
ACPI: AC Adapter [ACAD] (on-line)
ACPI: Battery Slot [BAT1] (battery present)
ACPI: Battery Slot [BAT2] (battery absent)
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Lid Switch as /class/input/input1
ACPI: Lid Switch [LID]
input: Sleep Button (CM) as /class/input/input2
ACPI: Sleep Button (CM) [SLPB]
ACPI: Transitioning device [FAN0] to D3
ACPI: Transitioning device [FAN0] to D3
ACPI: Fan [FAN0] (off)
ACPI: Transitioning device [FAN1] to D3
ACPI: Transitioning device [FAN1] to D3
ACPI: Fan [FAN1] (off)
ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
ACPI: Thermal Zone [THRM] (54 C)
lp: driver loaded but no devices found
Real Time Clock Driver v1.12ac
intel_rng: FWH not detected
ppdev: user-space parallel port driver
Linux agpgart interface v0.102 (c) Dave Jones
agpgart: Detected an Intel 855 Chipset.
agpgart: Detected 32636K stolen memory.
agpgart: AGP aperture is 128M @ 0xe8000000
[drm] Initialized drm 1.1.0 20060810
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LNKA] -> GSI 11 (level, low) -=
> IRQ 11
[drm] Initialized i915 1.6.0 20060119 on minor 0
[drm] Initialized i915 1.6.0 20060119 on minor 1
intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/91=
5GM/945G/945GM chipsets
intelfb: Version 0.9.4
intelfb: 00:02.0: Intel(R) 855GM, aperture size 128MB, stolen memory 32636kB
intelfb: Non-CRT device is enabled ( LVDS port ).  Disabling mode switching.
intelfb: Initial video mode is 1280x1024-32@60.
intelfb: Changing the video mode is not supported.
Console: switching to colour frame buffer device 160x64
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
ACPI: PCI Interrupt 0000:00:1f.6[B] -> Link [LNKB] -> GSI 10 (level, low) -=
> IRQ 10
ACPI: PCI interrupt for device 0000:00:1f.6 disabled
parport_pc 00:08: reported by Plug and Play ACPI
parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,EP=
P,ECP,DMA]
Marking TSC unstable due to: possible TSC halt in C2.
Time: acpi_pm clocksource has been installed.
Switched to high resolution mode on CPU 0
lp0: using parport0 (interrupt-driven).
loop: module loaded
nbd: registered device at major 43
Ethernet Channel Bonding Driver: v3.1.2 (January 20, 2007)
bonding: Warning: either miimon or arp_interval and arp_ip_target module pa=
rameters must be specified, otherwise bonding will not detect link failures=
! see bonding.txt for details.
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low) -=
> IRQ 10
ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x04, vendor 0x4243)
ssb: Core 1 found: V90 (cc 0x807, rev 0x01, vendor 0x4243)
ssb: Core 2 found: PCI (cc 0x804, rev 0x02, vendor 0x4243)
ssb: Switching to PCI core, index 2
ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
b44.c:v2.0
ssb: Switching to Fast Ethernet core, index 0
Enabling IRQ vectors
ssb: Switching to PCI core, index 2
ssb: Switching to Fast Ethernet core, index 0
Writing INTVEC. TPSFLAG is 0x00000041
ssb: Switching to PCI core, index 2
ssb: Switching to Fast Ethernet core, index 0
eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
ata_piix 0000:00:1f.1: version 2.11
PCI: Enabling device 0000:00:1f.1 (0005 -> 0007)
ACPI: PCI Interrupt 0000:00:1f.1[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
PCI: Setting latency timer of device 0000:00:1f.1 to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max UDMA/100 cmd 0x000101f0 ctl 0x000103f6 bmdma 0x00011810 irq =
14
ata2: PATA max UDMA/100 cmd 0x00010170 ctl 0x00010376 bmdma 0x00011818 irq =
15
ata1.00: ata_hpa_resize 1: sectors =3D 156301488, hpa_sectors =3D 156301488
ata1.00: ATA-6: TOSHIBA MK8026GAX, PA001G, max UDMA/100
ata1.00: 156301488 sectors, multi 16: LBA=20
ata1.00: ata_hpa_resize 1: sectors =3D 156301488, hpa_sectors =3D 156301488
ata1.00: configured for UDMA/100
ata2.00: ATAPI, max UDMA/33
ata2.00: configured for UDMA/33
scsi 0:0:0:0: Direct-Access     ATA      TOSHIBA MK8026GA PA00 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
 sda:<4>Clocksource tsc unstable (delta =3D -413804920 ns)
 sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:0:0: CD-ROM            Optiarc  DVD RW AD-7543A  1-00 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sr 1:0:0:0: Attached scsi generic sg1 type 5
usbmon: debugfs is not available
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:MOU2] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input3
input: PC Speaker as /class/input/input4
Synaptics Touchpad, model: 1, fw: 5.8, id: 0x9d48b1, caps: 0x904713/0x4006
input: SynPS/2 Synaptics TouchPad as /class/input/input5
i2c /dev entries driver
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
Advanced Linux Sound Architecture Driver Version 1.0.14 (Thu May 31 09:03:2=
5 2007 UTC).
ALSA device list:
  No soundcards found.
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (8192 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
IPv4 over IPv4 tunneling driver
GRE over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
ClusterIP Version 0.8 loaded successfully
arp_tables: (C) 2002 David S. Miller
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Mobile IPv6
ip6_tables: (C) 2000-2006 Netfilter Core Team
IPv6 over IPv4 tunneling driver
sit0: Disabled Privacy Extensions
NET: Registered protocol family 17
NET: Registered protocol family 15
Using IPI Shortcut mode
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
=46reeing unused kernel memory: 220k freed
ACPI: PCI Interrupt Link [LNKE] enabled at IRQ 10
ACPI: PCI Interrupt 0000:02:04.0[A] -> Link [LNKE] -> GSI 10 (level, low) -=
> IRQ 10
p54: LM86 firmware
wmaster0: Selected rate control algorithm 'simple'
phy0: hwaddr 00:60:b3:91:45:5b, isl3890
Adding 2001880k swap on /dev/sda2.  Priority:-1 extents:1 across:2001880k
EXT3 FS on sda1, internal journal
fuse init (API version 7.8)
ADDRCONF(NETDEV_UP): eth0: link is not ready
b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

--Boundary-01=_TMSdGFcBDtYoDGe
Content-Type: text/plain;
  charset="utf-8";
  name="dmesg_patch2"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="dmesg_patch2"

Linux version 2.6.22-rc4-wireless-dev-20070616-test1 (root@koala) (gcc vers=
ion 4.1.3 20070601 (prerelease) (Debian 4.1.2-12)) #7 PREEMPT Sun Jun 17 13=
:47:38 CEST 2007
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000ce000 - 00000000000d0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000004dee0000 (usable)
 BIOS-e820: 000000004dee0000 - 000000004deec000 (ACPI data)
 BIOS-e820: 000000004deec000 - 000000004df00000 (ACPI NVS)
 BIOS-e820: 000000004df00000 - 0000000050000000 (reserved)
 BIOS-e820: 00000000fec10000 - 00000000fec20000 (reserved)
 BIOS-e820: 00000000ff800000 - 00000000ffc00000 (reserved)
 BIOS-e820: 00000000fffffc00 - 0000000100000000 (reserved)
350MB HIGHMEM available.
896MB LOWMEM available.
Entering add_active_range(0, 0, 319200) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->   319200
early_node_map[1] active PFN ranges
    0:        0 ->   319200
On node 0 totalpages: 319200
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 1760 pages used for memmap
  Normal zone: 223520 pages, LIFO batch:31
  HighMem zone: 701 pages used for memmap
  HighMem zone: 89123 pages, LIFO batch:15
DMI present.
ACPI: RSDP 000F6050, 0014 (r0 ACER  )
ACPI: RSDT 4DEE5A39, 0030 (r1 ACER   Wagtail  20020114  LTP        0)
ACPI: FACP 4DEEBF2C, 0074 (r1 ACER   Wagtail  20020114 PTL        50)
ACPI: DSDT 4DEE5A69, 64C3 (r1 ACER   Wagtail  20020114 MSFT  100000E)
ACPI: FACS 4DEFCFC0, 0040
ACPI: HPET 4DEEBFA0, 0038 (r1 ACER   Wagtail  20020114 PTL         0)
ACPI: BOOT 4DEEBFD8, 0028 (r1 ACER   Wagtail  20020114  LTP        1)
ACPI: PM-Timer IO Port: 0x1008
ACPI: HPET id: 0x8086a201 base: 0x0
Allocating PCI resources starting at 60000000 (gap: 50000000:aec10000)
Built 1 zonelists.  Total pages: 316707
Kernel command line: root=3D/dev/sda1 ro vga=3D0x31b resume=3D/dev/sda2
Local APIC disabled by BIOS -- you can enable it with "lapic"
mapped APIC to ffffd000 (019c4000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 1395.554 MHz processor.
Console: colour dummy device 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1259844k/1276800k available (3571k kernel code, 16168k reserved, 11=
48k data, 220k init, 359296k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffaa000 - 0xfffff000   ( 340 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc05a0000 - 0xc05d7000   ( 220 kB)
      .data : 0xc047cf7d - 0xc059c0b0   (1148 kB)
      .text : 0xc0100000 - 0xc047cf7d   (3571 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
SLUB: Genslabs=3D23, HWalign=3D64, Order=3D0-1, MinObjects=3D4, Processors=
=3D1, Nodes=3D1
Calibrating delay using timer specific routine.. 2793.33 BogoMIPS (lpj=3D46=
53334)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: a7e9f9bf 00000000 00000000 00000000 0000=
0180 00000000 00000000
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 1024K
CPU: After all inits, caps: a7e9f9bf 00000000 00000000 00002040 00000180 00=
000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
Compat vDSO mapped to ffffe000.
CPU: Intel(R) Pentium(R) M processor 1400MHz stepping 05
Checking 'hlt' instruction... OK.
ACPI: Core revision 20070126
ACPI: setting ELCR to 0200 (from 0c00)
NET: Registered protocol family 16
No dock devices found.
ACPI: \_SB_.PCI0.IDE0.SECN.BAY1: found ejectable bay
ACPI: \_SB_.PCI0.IDE0.SECN.BAY1: Adding notify handler
ACPI: Bay [\_SB_.PCI0.IDE0.SECN.BAY1] Added
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfd742, last bus=3D2
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI quirk: region 1000-107f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 1180-11bf claimed by ICH4 GPIO
PCI: Transparent bridge - 0000:00:1e.0
PCI: Bus #03 (-#06) is hidden behind transparent bridge #02 (-#02) (try 'pc=
i=3Dassign-busses')
Please report the result to linux-kernel to fix this permanently
PCI: Bus #07 (-#0a) is hidden behind transparent bridge #02 (-#02) (try 'pc=
i=3Dassign-busses')
Please report the result to linux-kernel to fix this permanently
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs *11)
ACPI: PCI Interrupt Link [LNKB] (IRQs *10)
ACPI: PCI Interrupt Link [LNKC] (IRQs *10)
ACPI: PCI Interrupt Link [LNKD] (IRQs 10) *11
ACPI: PCI Interrupt Link [LNKE] (IRQs 10) *11
ACPI: PCI Interrupt Link [LNKF] (IRQs 10) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs *10)
ACPI: Power Resource [PFN0] (off)
ACPI: Power Resource [PFN1] (off)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 2.21 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=3Drouteirq".  If it helps, post a r=
eport
pnp: 00:04: iomem range 0xfec10000-0xfec1ffff could not be reserved
pnp: 00:04: iomem range 0xff800000-0xffbfffff could not be reserved
pnp: 00:04: iomem range 0xfff00000-0xffffffff could not be reserved
pnp: 00:04: iomem range 0x0-0x9ffff could not be reserved
Time: tsc clocksource has been installed.
PCI: Bus 3, cardbus bridge: 0000:02:06.0
  IO window: 00003000-000030ff
  IO window: 00003400-000034ff
  PREFETCH window: 60000000-63ffffff
  MEM window: 6c000000-6fffffff
PCI: Bus 7, cardbus bridge: 0000:02:06.1
  IO window: 00003800-000038ff
  IO window: 00003c00-00003cff
  PREFETCH window: 64000000-67ffffff
  MEM window: 70000000-73ffffff
PCI: Bridge: 0000:00:1e.0
  IO window: 3000-3fff
  MEM window: e0200000-e07fffff
  PREFETCH window: 60000000-67ffffff
PCI: Setting latency timer of device 0000:00:1e.0 to 64
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI Interrupt 0000:02:06.0[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
ACPI: PCI Interrupt 0000:02:06.1[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
Simple Boot Flag at 0x37 set to 0x1
Machine check exception polling timer started.
highmem bounce pool size: 64 pages
NTFS driver 2.1.28 [Flags: R/W].
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:00:02.0
ACPI: AC Adapter [ACAD] (on-line)
ACPI: Battery Slot [BAT1] (battery present)
ACPI: Battery Slot [BAT2] (battery absent)
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Lid Switch as /class/input/input1
ACPI: Lid Switch [LID]
input: Sleep Button (CM) as /class/input/input2
ACPI: Sleep Button (CM) [SLPB]
ACPI: Transitioning device [FAN0] to D3
ACPI: Transitioning device [FAN0] to D3
ACPI: Fan [FAN0] (off)
ACPI: Transitioning device [FAN1] to D3
ACPI: Transitioning device [FAN1] to D3
ACPI: Fan [FAN1] (off)
ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
ACPI: Thermal Zone [THRM] (49 C)
lp: driver loaded but no devices found
Real Time Clock Driver v1.12ac
intel_rng: FWH not detected
ppdev: user-space parallel port driver
Linux agpgart interface v0.102 (c) Dave Jones
agpgart: Detected an Intel 855 Chipset.
agpgart: Detected 32636K stolen memory.
agpgart: AGP aperture is 128M @ 0xe8000000
[drm] Initialized drm 1.1.0 20060810
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LNKA] -> GSI 11 (level, low) -=
> IRQ 11
[drm] Initialized i915 1.6.0 20060119 on minor 0
[drm] Initialized i915 1.6.0 20060119 on minor 1
intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/91=
5GM/945G/945GM chipsets
intelfb: Version 0.9.4
intelfb: 00:02.0: Intel(R) 855GM, aperture size 128MB, stolen memory 32636kB
intelfb: Non-CRT device is enabled ( LVDS port ).  Disabling mode switching.
intelfb: Initial video mode is 1280x1024-32@60.
intelfb: Changing the video mode is not supported.
Console: switching to colour frame buffer device 160x64
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
ACPI: PCI Interrupt 0000:00:1f.6[B] -> Link [LNKB] -> GSI 10 (level, low) -=
> IRQ 10
ACPI: PCI interrupt for device 0000:00:1f.6 disabled
parport_pc 00:08: reported by Plug and Play ACPI
parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,EP=
P,ECP,DMA]
Marking TSC unstable due to: possible TSC halt in C2.
Time: acpi_pm clocksource has been installed.
Switched to high resolution mode on CPU 0
lp0: using parport0 (interrupt-driven).
loop: module loaded
nbd: registered device at major 43
Ethernet Channel Bonding Driver: v3.1.2 (January 20, 2007)
bonding: Warning: either miimon or arp_interval and arp_ip_target module pa=
rameters must be specified, otherwise bonding will not detect link failures=
! see bonding.txt for details.
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low) -=
> IRQ 10
ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x04, vendor 0x4243)
ssb: Core 1 found: V90 (cc 0x807, rev 0x01, vendor 0x4243)
ssb: Core 2 found: PCI (cc 0x804, rev 0x02, vendor 0x4243)
ssb: Switching to PCI core, index 2
ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
b44.c:v2.0
ssb: Switching to Fast Ethernet core, index 0
Enabling IRQ vectors
ssb: Switching to PCI core, index 2
ssb: Switching to Fast Ethernet core, index 0
Writing INTVEC. TPSFLAG is 0x00000041
ssb: Switching to PCI core, index 2
Wrote translation
ssb: Switching to Fast Ethernet core, index 0
eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
ata_piix 0000:00:1f.1: version 2.11
PCI: Enabling device 0000:00:1f.1 (0005 -> 0007)
ACPI: PCI Interrupt 0000:00:1f.1[A] -> Link [LNKC] -> GSI 10 (level, low) -=
> IRQ 10
PCI: Setting latency timer of device 0000:00:1f.1 to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max UDMA/100 cmd 0x000101f0 ctl 0x000103f6 bmdma 0x00011810 irq =
14
ata2: PATA max UDMA/100 cmd 0x00010170 ctl 0x00010376 bmdma 0x00011818 irq =
15
ata1.00: ata_hpa_resize 1: sectors =3D 156301488, hpa_sectors =3D 156301488
ata1.00: ATA-6: TOSHIBA MK8026GAX, PA001G, max UDMA/100
ata1.00: 156301488 sectors, multi 16: LBA=20
ata1.00: ata_hpa_resize 1: sectors =3D 156301488, hpa_sectors =3D 156301488
ata1.00: configured for UDMA/100
ata2.00: ATAPI, max UDMA/33
ata2.00: configured for UDMA/33
scsi 0:0:0:0: Direct-Access     ATA      TOSHIBA MK8026GA PA00 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
 sda:<4>Clocksource tsc unstable (delta =3D -417033865 ns)
 sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:0:0: CD-ROM            Optiarc  DVD RW AD-7543A  1-00 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sr 1:0:0:0: Attached scsi generic sg1 type 5
usbmon: debugfs is not available
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:MOU2] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input3
input: PC Speaker as /class/input/input4
Synaptics Touchpad, model: 1, fw: 5.8, id: 0x9d48b1, caps: 0x904713/0x4006
input: SynPS/2 Synaptics TouchPad as /class/input/input5
i2c /dev entries driver
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
Advanced Linux Sound Architecture Driver Version 1.0.14 (Thu May 31 09:03:2=
5 2007 UTC).
ALSA device list:
  No soundcards found.
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (8192 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
IPv4 over IPv4 tunneling driver
GRE over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
ClusterIP Version 0.8 loaded successfully
arp_tables: (C) 2002 David S. Miller
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Mobile IPv6
ip6_tables: (C) 2000-2006 Netfilter Core Team
IPv6 over IPv4 tunneling driver
sit0: Disabled Privacy Extensions
NET: Registered protocol family 17
NET: Registered protocol family 15
Using IPI Shortcut mode
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
=46reeing unused kernel memory: 220k freed
ACPI: PCI Interrupt Link [LNKE] enabled at IRQ 10
ACPI: PCI Interrupt 0000:02:04.0[A] -> Link [LNKE] -> GSI 10 (level, low) -=
> IRQ 10
p54: LM86 firmware
wmaster0: Selected rate control algorithm 'simple'
phy0: hwaddr 00:60:b3:91:45:5b, isl3890
Adding 2001880k swap on /dev/sda2.  Priority:-1 extents:1 across:2001880k
EXT3 FS on sda1, internal journal
fuse init (API version 7.8)
ADDRCONF(NETDEV_UP): eth0: link is not ready
b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

--Boundary-01=_TMSdGFcBDtYoDGe--

--nextPart7581689.RO0QYX5Hdk
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGdSMWOimwv528XGERAv8VAKDHAtiPp84Y8bT9tQWh3UOx9t04gwCfQ1Bi
UclnTmCa3ajSEN1FW1Wsj1M=
=/Kxu
-----END PGP SIGNATURE-----

--nextPart7581689.RO0QYX5Hdk--
