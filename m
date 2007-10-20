From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: PROBLEM: oops, Linus tree: 2.6.23-g4fa4d23f, BUG: unable to
 handle kernel NULL pointer dereference at virtual address 00000004
Date: Sat, 20 Oct 2007 12:54:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710201246540.18815@twin.jikos.cz>
References: <4719B727.7090908@oak.selfip.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>
To: Dave Haywood <tla@oak.selfip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:50244 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757171AbXJTKzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 06:55:05 -0400
In-Reply-To: <4719B727.7090908@oak.selfip.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

added some relevant CCs

On Sat, 20 Oct 2007, Dave Haywood wrote:

> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
> 
> Linux s1 2.6.23-g4fa4d23f #4 Fri Oct 19 10:15:50 BST 2007 i686 Pentium III (Coppermine) GenuineIntel GNU/Linux
> 
> Gnu C                  4.2.0
> Gnu make               3.81
> binutils               2.18
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.2.2
> e2fsprogs              1.40.2
> PPP                    2.4.4
> Linux C Library        2.6.1
> Dynamic linker (ldd)   2.6.1
> Procps                 3.2.7
> Net-tools              1.60
> Kbd                    1.13
> Sh-utils               6.9
> udev                   115
> 
> Linux version 2.6.23-g4fa4d23f (tla@s1) (gcc version 4.2.0 (Gentoo 4.2.0 p1.4)) #4 Fri Oct 19 10:15:50 BST 2007
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
>  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 000000000fed0000 (usable)
>  BIOS-e820: 000000000fed0000 - 000000000fef0000 (ACPI NVS)
>  BIOS-e820: 000000000fef0000 - 000000000ff00000 (usable)
>  BIOS-e820: 00000000feea0000 - 0000000100000000 (reserved)
> 0MB HIGHMEM available.
> 255MB LOWMEM available.
> found SMP MP-table at 000f9bf0
> Entering add_active_range(0, 0, 65280) 0 entries of 256 used
> Zone PFN ranges:
>   DMA             0 ->     4096
>   Normal       4096 ->    65280
>   HighMem     65280 ->    65280
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0:        0 ->    65280
> On node 0 totalpages: 65280
>   DMA zone: 32 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 4064 pages, LIFO batch:0
>   Normal zone: 478 pages used for memmap
>   Normal zone: 60706 pages, LIFO batch:15
>   HighMem zone: 0 pages used for memmap
>   Movable zone: 0 pages used for memmap
> DMI 2.3 present.
> Using APIC driver default
> ACPI: RSDP 000E0010, 0014 (r0 COMPAQ)
> ACPI: RSDT 000E0080, 0054 (r1 COMPAQ CPQ0014  20010612             0)
> ACPI: FACP 000E0130, 0074 (r1 COMPAQ SOLANO          1             0)
> ACPI: DSDT 000E0204, 0CE6 (r1 COMPAQ     DSDT        1 MSFT  100000D)
> ACPI: FACS 000E0040, 0040
> ACPI: SSDT 000E0EEA, 0174 (r1 COMPAQ CORE_UTL        1 MSFT  100000D)
> ACPI: SSDT 000E105E, 0D3D (r1 COMPAQ VILLTBL1        1 MSFT  100000D)
> ACPI: APIC 000E01A4, 0060 (r1 COMPAQ SOLANO          1             0)
> ACPI: SSDT 000E2D4F, 0076 (r1 COMPAQ     APIC        1 MSFT  100000D)
> ACPI: SSDT 000E1D9B, 06AD (r1 COMPAQ PNP_PRSS        1 MSFT  100000D)
> ACPI: SSDT 000E24A6, 01A4 (r1 COMPAQ       S3        1 MSFT  100000D)
> ACPI: SSDT 000E264A, 0158 (r1 COMPAQ   PIDETM        1 MSFT  100000D)
> ACPI: SSDT 000E28FF, 010B (r1 COMPAQ     GTF0        1 MSFT  100000D)
> ACPI: SSDT 000E27A2, 015D (r1 COMPAQ   SIDETM        1 MSFT  100000D)
> ACPI: SSDT 000E2B21, 0117 (r1 COMPAQ     GTF2        1 MSFT  100000D)
> ACPI: SSDT 000E2EAD, 004E (r1 COMPAQ    FINIS        1 MSFT  100000D)
> ACPI: PM-Timer IO Port: 0xf808
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> Processor #0 6:8 APIC version 17
> ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
> ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Enabling APIC mode:  Flat.  Using 1 I/O APICs
> Using ACPI (MADT) for SMP configuration information
> Allocating PCI resources starting at 10000000 (gap: 0ff00000:eefa0000)
> swsusp: Registered nosave memory region: 000000000009f000 - 00000000000a0000
> swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000e0000
> swsusp: Registered nosave memory region: 00000000000e0000 - 0000000000100000
> swsusp: Registered nosave memory region: 000000000fed0000 - 000000000fef0000
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64770
> Kernel command line: root=/dev/md4
> mapped APIC to ffffb000 (fee00000)
> mapped IOAPIC to ffffa000 (fec00000)
> Enabling fast FPU save and restore... done.
> Enabling unmasked SIMD FPU exception support... done.
> Initializing CPU#0
> PID hash table entries: 1024 (order: 10, 4096 bytes)
> Detected 930.368 MHz processor.
> Console: colour VGA+ 80x25
> console [tty0] enabled
> Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
> Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
> Memory: 252820k/261120k available (3213k kernel code, 7612k reserved, 1274k data, 264k init, 0k highmem)
> virtual kernel memory layout:
>     fixmap  : 0xfffa7000 - 0xfffff000   ( 352 kB)
>     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
>     vmalloc : 0xd0800000 - 0xff7fe000   ( 751 MB)
>     lowmem  : 0xc0000000 - 0xcff00000   ( 255 MB)
>       .init : 0xc0564000 - 0xc05a6000   ( 264 kB)
>       .data : 0xc04236bc - 0xc0561f08   (1274 kB)
>       .text : 0xc0100000 - 0xc04236bc   (3213 kB)
> Checking if this processor honours the WP bit even in supervisor mode... Ok.
> SLUB: Genslabs=11, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
> Calibrating delay using timer specific routine.. 1862.06 BogoMIPS (lpj=3724128)
> Mount-cache hash table entries: 512
> CPU: After generic identify, caps: 0383fbff 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> CPU: L1 I cache: 16K, L1 D cache: 16K
> CPU: L2 cache: 256K
> CPU: After all inits, caps: 0383fbff 00000000 00000000 00000040 00000000 00000000 00000000 00000000
> Intel machine check architecture supported.
> Intel machine check reporting enabled on CPU#0.
> Compat vDSO mapped to ffffe000.
> CPU: Intel Pentium III (Coppermine) stepping 06
> Checking 'hlt' instruction... OK.
> Freeing SMP alternatives: 0k freed
> ACPI: Core revision 20070126
> Parsing all Control Methods:
> Table [DSDT](id 0001) - 147 Objects with 18 Devices 32 Methods 2 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0002) - 3 Objects with 0 Devices 3 Methods 0 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0003) - 100 Objects with 9 Devices 23 Methods 5 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0004) - 4 Objects with 1 Devices 1 Methods 0 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0005) - 21 Objects with 0 Devices 10 Methods 1 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0006) - 11 Objects with 0 Devices 8 Methods 0 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0007) - 19 Objects with 1 Devices 5 Methods 2 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0008) - 5 Objects with 1 Devices 3 Methods 0 Regions
> Parsing all Control Methods:
> Table [SSDT](id 0009) - 19 Objects with 1 Devices 5 Methods 2 Regions
> Parsing all Control Methods:
> Table [SSDT](id 000A) - 5 Objects with 1 Devices 3 Methods 0 Regions
> Parsing all Control Methods:
> Table [SSDT](id 000B) - 2 Objects with 0 Devices 2 Methods 0 Regions
>  tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
> evxfevnt-0091 [00] enable                : Transition to ACPI mode successful
> ENABLING IO-APIC IRQs
> ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
> net_namespace: 64 bytes
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> PCI: PCI BIOS revision 2.10 entry at 0xe8316, last bus=2
> PCI: Using configuration type 1
> Setting up standard PCI resources
> evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 0F [_GPE] 2 regs on int 0x9
> evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 4 Wake, Enabled 0 Runtime GPEs in this block
> ACPI: EC: Look up EC in DSDT
> Completing Region/Field/Buffer/Package initialization:............................................
> Initialized 8/12 Regions 0/0 Fields 31/31 Buffers 5/12 Packages (345 nodes)
> Initializing Device/Processor/Thermal objects by executing _INI methods:.
> Executed 1 _INI methods requiring 0 _STA executions (examined 35 objects)
> ACPI: Interpreter enabled
> ACPI: (supports S0 S1 S3 S4 S5)
> ACPI: Using IOAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> PCI quirk: region f800-f87f claimed by ICH4 ACPI/GPIO/TCO
> PCI quirk: region fa00-fa3f claimed by ICH4 GPIO
> PCI: Transparent bridge - 0000:00:1e.0
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB_._PRT]
> ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 14 15)
> ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11 14 15) *9
> ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 14 15)
> ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11 14 15)
> Linux Plug and Play Support v0.97 (c) Adam Belay
> pnp: PnP ACPI init
> ACPI: bus type pnp registered
> pnp: PnP ACPI: found 15 devices
> ACPI: ACPI bus type pnp unregistered
> SCSI subsystem initialized
> libata version 3.00 loaded.
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> PCI: Using ACPI for IRQ routing
> PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
> Time: tsc clocksource has been installed.
> system 00:0c: ioport range 0x4d0-0x4d1 has been reserved
> system 00:0d: ioport range 0x400-0x41f has been reserved
> system 00:0d: ioport range 0x420-0x43f has been reserved
> system 00:0d: ioport range 0x440-0x45f has been reserved
> system 00:0d: ioport range 0x460-0x47f has been reserved
> system 00:0d: ioport range 0xf800-0xf81f has been reserved
> system 00:0d: ioport range 0xf820-0xf83f has been reserved
> system 00:0d: ioport range 0xf840-0xf85f has been reserved
> system 00:0d: ioport range 0xf860-0xf87f has been reserved
> system 00:0e: iomem range 0x0-0x9ffff could not be reserved
> system 00:0e: iomem range 0xe0000-0xfffff could not be reserved
> system 00:0e: iomem range 0x100000-0xfefffff could not be reserved
> system 00:0e: iomem range 0xfff80000-0xffffffff could not be reserved
> PCI: Bridge: 0000:00:1e.0
>   IO window: 1000-1fff
>   MEM window: 40000000-407fffff
>   PREFETCH window: disabled.
> PCI: Setting latency timer of device 0000:00:1e.0 to 64
> NET: Registered protocol family 2
> IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
> TCP established hash table entries: 8192 (order: 4, 65536 bytes)
> TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
> TCP: Hash tables configured (established 8192 bind 8192)
> TCP reno registered
> Machine check exception polling timer started.
> IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
> Total HugeTLB memory allocated, 0
> io scheduler noop registered
> io scheduler cfq registered (default)
> Boot video device is 0000:00:02.0
> input: Power Button (FF) as /devices/virtual/input/input0
> ACPI: Power Button (FF) [PWRF]
> input: Power Button (CM) as /devices/virtual/input/input1
> ACPI: Power Button (CM) [PBTN]
> ACPI: Processor [CPU0] (supports 8 throttling states)
> Real Time Clock Driver v1.12ac
> intel_rng: FWH not detected
> Linux agpgart interface v0.102
> agpgart: Detected an Intel i815 Chipset.
> agpgart: AGP aperture is 64M @ 0x44000000
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
> serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> 00:09: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> FDC 0 is a post-1991 82077
> RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
> loop: module loaded
> Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
> Copyright (c) 1999-2006 Intel Corporation.
> e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> e100: Copyright(c) 1999-2006 Intel Corporation
> 8139too Fast Ethernet driver 0.9.28
> ACPI: PCI Interrupt 0000:02:09.0[A] -> GSI 17 (level, low) -> IRQ 16
> eth0: RealTek RTL8139 at 0xd0816000, 00:05:5d:49:eb:21, IRQ 16
> eth0:  Identified 8139 chip type 'RTL-8139C'
> ACPI: PCI Interrupt 0000:02:0a.0[A] -> GSI 18 (level, low) -> IRQ 17
> eth1: RealTek RTL8139 at 0xd0818000, 00:10:b5:ac:ea:7d, IRQ 17
> eth1:  Identified 8139 chip type 'RTL-8139B'
> console [netcon0] enabled
> netconsole: network logging started
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> ICH: IDE controller at PCI slot 0000:00:1f.1
> ICH: chipset revision 2
> ICH: not 100% native mode: will probe irqs later
>     ide0: BM-DMA at 0x2460-0x2467, BIOS settings: hda:DMA, hdb:pio
>     ide1: BM-DMA at 0x2468-0x246f, BIOS settings: hdc:DMA, hdd:pio
> Probing IDE interface ide0...
> Switched to high resolution mode on CPU 0
> hda: Maxtor 6G160P0, ATA DISK drive
> hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
> hda: selected mode 0x44
> ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> Probing IDE interface ide1...
> hdc: Maxtor 6G160P0, ATA DISK drive
> hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO4
> hdc: selected mode 0x44
> ide1 at 0x170-0x177,0x376 on irq 15
> hda: max request size: 512KiB
> hda: 312581808 sectors (160041 MB) w/8192KiB Cache, CHS=19457/255/63, UDMA(66)
> hda: cache flushes supported
>  hda: hda1 hda2 hda3 hda4
> hdc: max request size: 512KiB
> hdc: 312581808 sectors (160041 MB) w/8192KiB Cache, CHS=19457/255/63, UDMA(66)
> hdc: cache flushes supported
>  hdc: hdc1 hdc2 hdc3 hdc4
> Fusion MPT base driver 3.04.06
> Copyright (c) 1999-2007 LSI Corporation
> Fusion MPT SPI Host driver 3.04.06
> ieee1394: raw1394: /dev/raw1394 device initialized
> usbmon: debugfs is not available
> ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
> USB Universal Host Controller Interface driver v3.0
> ACPI: PCI Interrupt 0000:00:1f.2[D] -> GSI 19 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:00:1f.2 to 64
> uhci_hcd 0000:00:1f.2: UHCI Host Controller
> uhci_hcd 0000:00:1f.2: new USB bus registered, assigned bus number 1
> uhci_hcd 0000:00:1f.2: irq 18, io base 0x00002440
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 2 ports detected
> usbcore: registered new interface driver usblp
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> PNP: PS/2 Controller [PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mice: PS/2 mouse device common for all mice
> input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
> md: raid1 personality registered for level 1
> usbcore: registered new interface driver usbhid
> drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
> Netfilter messages via NETLINK v0.30.
> nf_conntrack version 0.5.0 (4096 buckets, 16384 max)
> ctnetlink v0.93: registering with nfnetlink.
> ip_tables: (C) 2000-2006 Netfilter Core Team
> ClusterIP Version 0.8 loaded successfully
> arp_tables: (C) 2002 David S. Miller
> TCP cubic registered
> NET: Registered protocol family 1
> NET: Registered protocol family 10
> ip6_tables: (C) 2000-2006 Netfilter Core Team
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> Using IPI Shortcut mode
> input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input3
> md: Autodetecting RAID arrays.
> md: Scanned 8 and added 8 devices.
> md: autorun ...
> md: considering hdc4 ...
> md:  adding hdc4 ...
> md: hdc3 has different UUID to hdc4
> md: hdc2 has different UUID to hdc4
> md: hdc1 has different UUID to hdc4
> md:  adding hda4 ...
> md: hda3 has different UUID to hdc4
> md: hda2 has different UUID to hdc4
> md: hda1 has different UUID to hdc4
> md: created md4
> md: bind<hda4>
> md: bind<hdc4>
> md: running: <hdc4><hda4>
> raid1: raid set md4 active with 2 out of 2 mirrors
> md4: bitmap initialized from disk: read 11/11 pages, set 6 bits
> created bitmap (169 pages) for device md4
> md: considering hdc3 ...
> md:  adding hdc3 ...
> md: hdc2 has different UUID to hdc3
> md: hdc1 has different UUID to hdc3
> md:  adding hda3 ...
> md: hda2 has different UUID to hdc3
> md: hda1 has different UUID to hdc3
> md: created md3
> md: bind<hda3>
> md: bind<hdc3>
> md: running: <hdc3><hda3>
> raid1: raid set md3 active with 2 out of 2 mirrors
> md3: bitmap initialized from disk: read 15/15 pages, set 0 bits
> created bitmap (233 pages) for device md3
> md: considering hdc2 ...
> md:  adding hdc2 ...
> md: hdc1 has different UUID to hdc2
> md:  adding hda2 ...
> md: hda1 has different UUID to hdc2
> md: created md2
> md: bind<hda2>
> md: bind<hdc2>
> md: running: <hdc2><hda2>
> raid1: raid set md2 active with 2 out of 2 mirrors
> md2: bitmap initialized from disk: read 8/8 pages, set 0 bits
> created bitmap (123 pages) for device md2
> md: considering hdc1 ...
> md:  adding hdc1 ...
> md:  adding hda1 ...
> md: created md1
> md: bind<hda1>
> md: bind<hdc1>
> md: running: <hdc1><hda1>
> raid1: raid set md1 active with 2 out of 2 mirrors
> md1: bitmap initialized from disk: read 10/10 pages, set 0 bits
> created bitmap (153 pages) for device md1
> md: ... autorun DONE.
> EXT3-fs: INFO: recovery required on readonly filesystem.
> EXT3-fs: write access will be enabled during recovery.
> kjournald starting.  Commit interval 5 seconds
> EXT3-fs: recovery complete.
> EXT3-fs: mounted filesystem with ordered data mode.
> VFS: Mounted root (ext3 filesystem) readonly.
> Freeing unused kernel memory: 264k freed
> EXT3 FS on md4, internal journal
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on md3, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> Adding 1999992k swap on /dev/md2.  Priority:-1 extents:1 across:1999992k
> eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
> eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> eth0: no IPv6 routers present
> eth1: no IPv6 routers present
> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
> printing eip: c0383fa0 *pde = 00000000 
> Oops: 0000 [#1] 
> CPU:    0
> EIP:    0060:[<c0383fa0>]    Not tainted VLI
> EFLAGS: 00010282   (2.6.23-g4fa4d23f #4)
> EIP is at sk_filter_delayed_uncharge+0x0/0x20
> eax: c5dfb600   ebx: 00000000   ecx: 00000000   edx: 00000000
> esi: c5dfb600   edi: 00000000   ebp: c170d300   esp: c5dcbef8
> ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> Process dhcpd (pid: 5380, ti=c5dca000 task=c47f0520 task.ti=c5dca000)
> Stack: c038410f 00000068 00000058 c5dcbf34 b7fd000b c1b75000 c5dfb600 c0371d19 
>        c1b70fd8 c180d300 c1b70f80 00000007 00000001 b7fd000b c170d900 b7fd000b 
>        080c9fa0 0000000e 00000000 c5dcbf6c c036dbc2 0000000e c1b75000 00000008 
> Call Trace:
>  [<c038410f>] sk_attach_filter+0xdf/0x100
>  [<c0371d19>] sock_setsockopt+0x509/0x590
>  [<c036dbc2>] sockfd_lookup_light+0x32/0x60
>  [<c036dd8b>] sys_setsockopt+0x9b/0xb0
>  [<c036f705>] sys_socketcall+0xd5/0x280
>  [<c010503e>] sysenter_past_esp+0x5f/0x85
>  =======================
> Code: cb 04 76 c7 83 c1 01 83 ee 01 39 d1 75 8d eb d7 83 7c cb 04 0f 77 b4 83 c1 01 83 ee 01 39 d1 0f 85 76 ff ff ff eb c0 8d 74 26 00 <8b> 4a 04 8d 0c cd 10 00 00 00 29 48 5c 8d 42 08 ba 10 40 38 c0 
> EIP: [<c0383fa0>] sk_filter_delayed_uncharge+0x0/0x20 SS:ESP 0068:c5dcbef8
> 
> 
> 

-- 
Jiri Kosina
