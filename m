From: Olaf Hering <olh@suse.de>
Subject: Re: Linux v2.6.17-rc4
Date: Fri, 12 May 2006 13:23:18 +0200
Message-ID: <20060512112318.GA2115@suse.de>
References: <Pine.LNX.4.64.0605111640010.3866@g5.osdl.org> <20060512102422.GA30285@harddisk-recovery.com> <200605121244.22511.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Mouw <erik@harddisk-recovery.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:25321 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751217AbWELLXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 07:23:23 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200605121244.22511.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 On Fri, May 12, Michael Buesch wrote:

> On Friday 12 May 2006 12:24, you wrote:
> > On Thu, May 11, 2006 at 04:44:03PM -0700, Linus Torvalds wrote:
> > > Ok, I've let the release time between -rc's slide a bit too much again, 
> > > but -rc4 is out there, and this is the time to hunker down for 2.6.17.
> > > 
> > > If you know of any regressions, please holler now, so that we don't miss 
> > > them. 
> > 
> > I got assertion failures in the bcm43xx driver:
> > 
> > bcm43xx: Chip ID 0x4318, rev 0x2
> 
> That is expected an non-fatal.

Is this one in the same category?
[   79.087115] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)


[    0.000000] Using PowerMac machine description
[    0.000000] Total memory = 768MB; using 2048kB for hash table (at cfe00000)
[    0.000000] Linux version 2.6.17-rc4-airport (olaf@pomegranate) (gcc version 4.1.0 (SUSE Linux)) #3 Fri May 12 13:12:42 CEST 2006
[    0.000000] Found initrd at 0xc4100000:0xc445d000
[    0.000000] Found UniNorth memory controller & host bridge @ 0xf8000000 revision: 0xd2
[    0.000000] Mapped at 0xfdfc0000
[    0.000000] Found a Intrepid mac-io controller, rev: 0, mapped at 0xfdf40000
[    0.000000] Processor NAP mode on idle enabled.
[    0.000000] PowerMac motherboard: iBook G4
[    0.000000] via-pmu: Server Mode is disabled
[    0.000000] PMU driver v2 initialized for Core99, firmware: 0c
[    0.000000] Found UniNorth PCI host bridge at 0xf0000000. Firmware bus number: 0->0
[    0.000000] Found UniNorth PCI host bridge at 0xf2000000. Firmware bus number: 0->0
[    0.000000] Found UniNorth PCI host bridge at 0xf4000000. Firmware bus number: 0->0
[    0.000000] Top of RAM: 0x30000000, Total RAM: 0x30000000
[    0.000000] Memory hole size: 0MB
[    0.000000] On node 0 totalpages: 196608
[    0.000000]   DMA zone: 196608 pages, LIFO batch:31
[    0.000000] Built 1 zonelists
[    0.000000] Kernel command line: root=/dev/hda2  quiet time sysrq=1 
[    0.000000] mpic: Setting up MPIC " MPIC 1   " version 1.2 at 80040000, max 4 CPUs
[    0.000000] mpic: ISU size: 64, shift: 6, mask: 3f
[    0.000000] mpic: Initializing for 64 sources
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] time_init: decrementer frequency = 18.432000 MHz
[    0.000000] time_init: processor frequency   = 1333.333330 MHz
[   23.809911] Console: colour dummy device 80x25
[   23.810822] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[   23.812165] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[   23.854228] Memory: 767232k/786432k available (3160k kernel code, 18664k reserved, 448k data, 2177k bss, 160k init)
[   23.854480] Calibrating delay loop... 36.76 BogoMIPS (lpj=183808)
[   24.039729] Mount-cache hash table entries: 512
[   24.040130] device-tree: Duplicate name in /cpus/PowerPC,G4@0, renamed to "l2-cache#1"
[   24.043262] checking if image is initramfs... it is
[   24.734182] Freeing initrd memory: 3444k freed
[   24.735401] NET: Registered protocol family 16
[   24.736061] KeyWest i2c @0xf8001003 irq 42 /uni-n@f8000000/i2c@f8001000
[   24.736074]  channel 1 bus /uni-n@f8000000/i2c@f8001000/i2c-bus@1
[   24.736123] KeyWest i2c @0x80018000 irq 26 /pci@f2000000/mac-io@17/i2c@18000
[   24.736134]  channel 0 bus /pci@f2000000/mac-io@17/i2c@18000/i2c-bus@0
[   24.736161] PMU i2c /pci@f2000000/mac-io@17/via-pmu@16000/pmu-i2c
[   24.736169]  channel 1 bus <multibus>
[   24.736176]  channel 2 bus <multibus>
[   24.736706] PCI: Probing PCI hardware
[   24.739527] PCI: Cannot allocate resource region 0 of device 0001:10:18.0
[   24.739549] PCI: Cannot allocate resource region 0 of device 0001:10:19.0
[   24.739583] Apple USB OHCI 0001:10:18.0 disabled by firmware
[   24.739596] Apple USB OHCI 0001:10:19.0 disabled by firmware
[   24.740556] usbcore: registered new driver usbfs
[   24.740655] usbcore: registered new driver hub
[   24.740917] TC classifier action (bugs to netdev@vger.kernel.org cc hadi@cyberus.ca)
[   24.741608] NET: Registered protocol family 2
[   24.829781] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[   24.830282] TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
[   24.839978] TCP bind hash table entries: 65536 (order: 8, 1310720 bytes)
[   24.846243] TCP: Hash tables configured (established 131072 bind 65536)
[   24.846253] TCP reno registered
[   24.846361] Thermal assist unit not available
[   24.848508] VFS: Disk quotas dquot_6.5.1
[   24.848561] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[   24.848760] Initializing Cryptographic API
[   24.848777] io scheduler noop registered
[   24.848792] io scheduler anticipatory registered
[   24.848806] io scheduler deadline registered
[   24.848833] io scheduler cfq registered (default)
[   24.849393] PCI: Enabling device 0000:00:10.0 (0006 -> 0007)
[   25.045487] radeonfb (0000:00:10.0): Invalid ROM signature 0 should be 0xaa55
[   25.045502] radeonfb: Retrieved PLL infos from Open Firmware
[   25.045513] radeonfb: Reference=27.00 MHz (RefDiv=12) Memory=183.00 Mhz, System=210.00 MHz
[   25.045522] radeonfb: PLL min 12000 max 35000
[   26.090640] radeonfb: Monitor 1 type LCD found
[   26.090648] radeonfb: EDID probed
[   26.090654] radeonfb: Monitor 2 type no found
[   26.090672] radeonfb: Using Firmware dividers 0x00020074 from PPLL 0
[   26.090750] radeonfb: Dynamic Clock Power Management enabled
[   26.143184] Console: switching to colour frame buffer device 128x48
[   26.143276] Registered "mnca" backlight controller,level: 15/15
[   26.143283] radeonfb (0000:00:10.0): ATI Radeon NV 
[   26.148372] Generic RTC Driver v1.07
[   26.150099] RAMDISK driver initialized: 16 RAM disks of 123456K size 1024 blocksize
[   26.150201] sungem.c:v0.98 8/24/03 David S. Miller (davem@redhat.com)
[   26.230004] PHY ID: 4061e4, addr: 0
[   26.230765] eth0: Sun GEM (PCI) 10/100/1000BaseT Ethernet 00:11:24:e3:f0:1e 
[   26.230785] eth0: Found BCM5221 PHY
[   26.231143] MacIO PCI driver attached to Intrepid chipset
[   26.232921] input: Macintosh mouse button emulation as /class/input/input0
[   26.233164] apm_emu: APM Emulation 0.5 initialized.
[   26.233299] adt746x: version 1 (supported)
[   26.233311] adt746x: Thermostat bus: 1, address: 0x2e, limit_adjust: 0, fan_speed: -1
[   26.233322] sensor 0: PWR/MEMORY BOTTOMSIDE
[   26.233330] sensor 1: CPU BOTTOMSIDE
[   26.233336] sensor 2: GPU BOTTOMSIDE
[   26.233404] adb: starting probe task...
[   26.234766] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[   26.234779] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[   26.234975] PCI: Enabling device 0002:20:0d.0 (0000 -> 0002)
[   26.259143] adb devices: [2]: 2 c4 [7]: 7 1f
[   26.264488] ADB keyboard at 2, handler 1
[   26.264503] Detected ADB keyboard, type ISO, swapping keys.
[   26.264666] input: ADB keyboard as /class/input/input1
[   26.264820] input: ADB Powerbook buttons as /class/input/input2
[   26.264833] adb: finished probe task...
[   27.259660] ide0: Found Apple UniNorth ATA-6 controller, bus ID 3, irq 39
[   27.259682] Probing IDE interface ide0...
[   27.559841] hda: FUJITSU MHV2060AT, ATA DISK drive
[   28.279667] hda: Enabling Ultra DMA 5
[   28.283665] ide0 at 0xf1012000-0xf1012007,0xf1012160 on irq 39
[   28.629816] eth0: Link is up at 100 Mbps, full-duplex.
[   29.309658] ide1: Found Apple KeyLargo ATA-3 controller, bus ID 0, irq 24
[   29.309676] Probing IDE interface ide1...
[   29.729843] hdc: MATSHITACD-RW CW-8124, ATAPI CD/DVD-ROM drive
[   30.089675] hdc: Enabling MultiWord DMA 2
[   30.090716] ide1 at 0xf1006000-0xf1006007,0xf1006160 on irq 24
[   30.091002] hda: max request size: 512KiB
[   30.162948] hda: 117210240 sectors (60011 MB) w/8192KiB Cache, CHS=16383/255/63, UDMA(100)
[   30.167677] hda: cache flushes supported
[   30.167772]  hda: [mac] hda1 hda2 hda3 hda4 hda5 hda6 hda7 hda8
[   30.175449] PCI: Enabling device 0001:10:1b.2 (0004 -> 0006)
[   30.175471] ehci_hcd 0001:10:1b.2: EHCI Host Controller
[   30.175627] ehci_hcd 0001:10:1b.2: new USB bus registered, assigned bus number 1
[   30.199693] ehci_hcd 0001:10:1b.2: irq 63, io mem 0x80080000
[   30.199707] ehci_hcd 0001:10:1b.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   30.199952] usb usb1: configuration #1 chosen from 1 choice
[   30.200063] hub 1-0:1.0: USB hub found
[   30.200094] hub 1-0:1.0: 5 ports detected
[   30.309822] ohci_hcd: 2005 April 22 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
[   30.309942] Apple USB OHCI 0001:10:18.0 disabled by firmware
[   30.309959] Apple USB OHCI 0001:10:19.0 disabled by firmware
[   30.309976] PCI: Enabling device 0001:10:1a.0 (0000 -> 0002)
[   30.309997] ohci_hcd 0001:10:1a.0: OHCI Host Controller
[   30.310125] ohci_hcd 0001:10:1a.0: new USB bus registered, assigned bus number 2
[   30.310158] ohci_hcd 0001:10:1a.0: irq 29, io mem 0x80083000
[   30.389370] usb usb2: configuration #1 chosen from 1 choice
[   30.389471] hub 2-0:1.0: USB hub found
[   30.389495] hub 2-0:1.0: 2 ports detected
[   30.489827] PCI: Enabling device 0001:10:1b.0 (0000 -> 0002)
[   30.489846] ohci_hcd 0001:10:1b.0: OHCI Host Controller
[   30.489981] ohci_hcd 0001:10:1b.0: new USB bus registered, assigned bus number 3
[   30.490009] ohci_hcd 0001:10:1b.0: irq 63, io mem 0x80082000
[   30.569361] usb usb3: configuration #1 chosen from 1 choice
[   30.569461] hub 3-0:1.0: USB hub found
[   30.569483] hub 3-0:1.0: 3 ports detected
[   30.669823] PCI: Enabling device 0001:10:1b.1 (0000 -> 0002)
[   30.669841] ohci_hcd 0001:10:1b.1: OHCI Host Controller
[   30.669940] ohci_hcd 0001:10:1b.1: new USB bus registered, assigned bus number 4
[   30.669966] ohci_hcd 0001:10:1b.1: irq 63, io mem 0x80081000
[   30.749372] usb usb4: configuration #1 chosen from 1 choice
[   30.749469] hub 4-0:1.0: USB hub found
[   30.749492] hub 4-0:1.0: 2 ports detected
[   30.789662] usb 2-1: new full speed USB device using ohci_hcd and address 2
[   31.004679] usb 2-1: configuration #1 chosen from 1 choice
[   31.299660] usb 2-2: new full speed USB device using ohci_hcd and address 3
[   31.488678] usb 2-2: configuration #1 chosen from 1 choice
[   31.492824] usbcore: registered new driver hiddev
[   31.524884] input: HID 05ac:1000 as /class/input/input3
[   31.524917] input: USB HID v1.11 Keyboard [HID 05ac:1000] on usb-0001:10:1a.0-1
[   31.565847] input: HID 05ac:1000 as /class/input/input4
[   31.565861] input: USB HID v1.11 Mouse [HID 05ac:1000] on usb-0001:10:1a.0-1
[   31.572679] HID device not claimed by input or hiddev
[   31.572711] usbcore: registered new driver usbhid
[   31.572720] /home/olaf/kernel/olh/airport/linux-2.6.17-rc4/drivers/usb/input/hid-core.c: v2.6:USB HID core driver
[   31.572966] mice: PS/2 mouse device common for all mice
[   31.573542] PowerMac i2c bus pmu 2 registered
[   31.573649] PowerMac i2c bus pmu 1 registered
[   31.573781] PowerMac i2c bus mac-io 0 registered
[   31.574329] adt746x: ADT7467 initializing
[   31.576521] adt746x: Lowering max temperatures from 69, 92, 101 to 70, 50, 70
[   31.577694] PowerMac i2c bus uni-n 1 registered
[   31.577715] md: md driver 0.90.3 MAX_MD_DEVS=256, MD_SB_DISKS=27
[   31.577723] md: bitmap version 4.39
[   31.577931] NET: Registered protocol family 1
[   31.577948] NET: Registered protocol family 17
[   31.577963] NET: Registered protocol family 15
[   31.578044] Freeing unused kernel memory: 160k init
[   35.655774] ReiserFS: hda2: found reiserfs format "3.6" with standard journal
[   36.937288] ReiserFS: hda2: using ordered data mode
[   36.937791] ReiserFS: hda2: journal params: device hda2, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
[   36.940521] ReiserFS: hda2: checking transaction log (hda2)
[   37.033930] ReiserFS: hda2: Using r5 hash to sort names
[   38.939608] Adding 530136k swap on /dev/hda6.  Priority:-1 extents:1 across:530136k
[   42.013907] input: PowerMac Beep as /class/input/input5
[   43.484073] input: appletouch as /class/input/input6
[   43.484182] usbcore: registered new driver appletouch
[   45.043454] Linux agpgart interface v0.101 (c) Dave Jones
[   45.186632] hdc: ATAPI 24X DVD-ROM CD-R/RW drive, 2048kB Cache, (U)DMA
[   45.186659] Uniform CD-ROM driver Revision: 3.20
[   45.191243] agpgart: Detected Apple UniNorth 2 chipset
[   45.191366] agpgart: configuring for size idx: 4
[   45.191431] agpgart: AGP aperture is 16M @ 0x0
[   45.666918] ieee1394: Initialized config rom entry `ip1394'
[   45.694136] ieee80211_crypt: registered algorithm 'NULL'
[   46.148147] PCI: Enabling device 0002:20:0e.0 (0000 -> 0002)
[   46.219702] ieee80211: 802.11 data/management/control stack, git-1.1.7
[   46.219716] ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   46.241574] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[40]  MMIO=[f5000000-f50007ff]  Max Packet=[2048]  IR/IT contexts=[8/8]
[   47.354898] bcm43xx driver
[   47.355496] PCI: Enabling device 0001:10:12.0 (0004 -> 0006)
[   47.361435] bcm43xx: Chip ID 0x4318, rev 0x2
[   47.361442] bcm43xx: Number of cores: 4
[   47.361452] bcm43xx: Core 0: ID 0x800, rev 0xd, vendor 0x4243, enabled
[   47.361467] bcm43xx: Core 1: ID 0x812, rev 0x9, vendor 0x4243, disabled
[   47.361482] bcm43xx: Core 2: ID 0x804, rev 0xc, vendor 0x4243, enabled
[   47.361497] bcm43xx: Core 3: ID 0x80d, rev 0x7, vendor 0x4243, enabled
[   47.364759] bcm43xx: PHY connected
[   47.364778] bcm43xx: Detected PHY: Version: 3, Type 2, Revision 7
[   47.364806] bcm43xx: Detected Radio: ID: 8205017f (Manuf: 17f Ver: 2050 Rev: 8)
[   47.364835] bcm43xx: Radio turned off
[   47.364857] bcm43xx: Radio turned off
[   47.728792] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[001124fffee3f01e]
[   48.944822] device-mapper: 4.6.0-ioctl (2006-02-17) initialised: dm-devel@redhat.com
[   50.220481] loop: loaded (max 8 devices)
[   50.240129] kjournald starting.  Commit interval 5 seconds
[   50.259939] EXT3 FS on hda5, internal journal
[   50.259957] EXT3-fs: mounted filesystem with ordered data mode.
[   55.277144] NET: Registered protocol family 10
[   55.283176] lo: Disabled Privacy Extensions
[   55.289024] IPv6 over IPv4 tunneling driver
[   55.543587] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   56.192479] ip_tables: (C) 2000-2006 Netfilter Core Team
[   56.314463] Netfilter messages via NETLINK v0.30.
[   56.638288] ip_conntrack version 2.4 (6144 buckets, 49152 max) - 208 bytes per conntrack
[   71.626052] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   72.532956] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   72.537269] NFSD: starting 90-second grace period
[   77.766307] bcm43xx: PHY connected
[   79.071344] bcm43xx: Radio turned on
[   79.087099] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: /home/olaf/kernel/olh/airport/linux-2.6.17-rc4/drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
[   79.087115] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)
[   79.087123] Call Trace:
[   79.087129] [EC571960] [C0007D98] show_stack+0x50/0x184 (unreliable)
[   79.087155] [EC571980] [F24F12B8] bcm43xx_phy_lo_adjust+0x2e8/0x30c [bcm43xx]
[   79.087231] [EC5719A0] [F24ECFAC] bcm43xx_radio_set_txpower_bg+0x284/0x298 [bcm43xx]
[   79.087260] [EC5719C0] [F24F0AC0] bcm43xx_phy_initb6+0x758/0x8b4 [bcm43xx]
[   79.087289] [EC5719E0] [F24F1F28] bcm43xx_phy_initg+0x130/0xe54 [bcm43xx]
[   79.087317] [EC571A50] [F24F4344] bcm43xx_phy_init+0x6f8/0x730 [bcm43xx]
[   79.087346] [EC571A70] [F24E3140] bcm43xx_wireless_core_init+0x8a0/0x10b4 [bcm43xx]
[   79.087375] [EC571B00] [F24E52E0] bcm43xx_init_board+0x2f8/0x624 [bcm43xx]
[   79.087402] [EC571B30] [C020D9E4] dev_open+0x60/0xc8
[   79.087423] [EC571B50] [C020B910] dev_change_flags+0x70/0x148
[   79.087438] [EC571B70] [C0216DD0] do_setlink+0x78/0x390
[   79.087453] [EC571BB0] [C0216944] rtnetlink_rcv_msg+0x204/0x230
[   79.087466] [EC571BE0] [C0222C68] netlink_run_queue+0x80/0x188
[   79.087481] [EC571C20] [C02166B8] rtnetlink_rcv+0x40/0x6c
[   79.087494] [EC571C50] [C0223284] netlink_data_ready+0x28/0x84
[   79.087507] [EC571C60] [C0221C2C] netlink_sendskb+0x34/0x70
[   79.087520] [EC571C80] [C0223240] netlink_sendmsg+0x260/0x27c
[   79.087533] [EC571CD0] [C0200B00] sock_sendmsg+0xac/0xdc
[   79.087552] [EC571DC0] [C020182C] sys_sendmsg+0x1c8/0x254
[   79.087567] [EC571F00] [C02029A4] sys_socketcall+0x1ac/0x1e4
[   79.087582] [EC571F40] [C000F300] ret_from_syscall+0x0/0x38
[   79.087598] --- Exception: c01 at 0xff05d48
[   79.087619]     LR = 0xff66798
[   79.240869] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: /home/olaf/kernel/olh/airport/linux-2.6.17-rc4/drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
[   79.240884] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)
[   79.240892] Call Trace:
[   79.240898] [EC5719A0] [C0007D98] show_stack+0x50/0x184 (unreliable)
[   79.240913] [EC5719C0] [F24F12B8] bcm43xx_phy_lo_adjust+0x2e8/0x30c [bcm43xx]
[   79.240943] [EC5719E0] [F24F2AE8] bcm43xx_phy_initg+0xcf0/0xe54 [bcm43xx]
[   79.240971] [EC571A50] [F24F4344] bcm43xx_phy_init+0x6f8/0x730 [bcm43xx]
[   79.240999] [EC571A70] [F24E3140] bcm43xx_wireless_core_init+0x8a0/0x10b4 [bcm43xx]
[   79.241028] [EC571B00] [F24E52E0] bcm43xx_init_board+0x2f8/0x624 [bcm43xx]
[   79.241055] [EC571B30] [C020D9E4] dev_open+0x60/0xc8
[   79.241069] [EC571B50] [C020B910] dev_change_flags+0x70/0x148
[   79.241083] [EC571B70] [C0216DD0] do_setlink+0x78/0x390
[   79.241095] [EC571BB0] [C0216944] rtnetlink_rcv_msg+0x204/0x230
[   79.241108] [EC571BE0] [C0222C68] netlink_run_queue+0x80/0x188
[   79.241121] [EC571C20] [C02166B8] rtnetlink_rcv+0x40/0x6c
[   79.241133] [EC571C50] [C0223284] netlink_data_ready+0x28/0x84
[   79.241146] [EC571C60] [C0221C2C] netlink_sendskb+0x34/0x70
[   79.241158] [EC571C80] [C0223240] netlink_sendmsg+0x260/0x27c
[   79.241171] [EC571CD0] [C0200B00] sock_sendmsg+0xac/0xdc
[   79.241186] [EC571DC0] [C020182C] sys_sendmsg+0x1c8/0x254
[   79.241199] [EC571F00] [C02029A4] sys_socketcall+0x1ac/0x1e4
[   79.241214] [EC571F40] [C000F300] ret_from_syscall+0x0/0x38
[   79.241226] --- Exception: c01 at 0xff05d48
[   79.241239]     LR = 0xff66798
[   79.242938] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: /home/olaf/kernel/olh/airport/linux-2.6.17-rc4/drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
[   79.242953] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)
[   79.242960] Call Trace:
[   79.242966] [EC571960] [C0007D98] show_stack+0x50/0x184 (unreliable)
[   79.242981] [EC571980] [F24F12B8] bcm43xx_phy_lo_adjust+0x2e8/0x30c [bcm43xx]
[   79.243010] [EC5719A0] [F24ECFAC] bcm43xx_radio_set_txpower_bg+0x284/0x298 [bcm43xx]
[   79.243039] [EC5719C0] [F24EFC40] bcm43xx_phy_init_pctl+0x284/0x2a0 [bcm43xx]
[   79.243068] [EC5719E0] [F24F2BD8] bcm43xx_phy_initg+0xde0/0xe54 [bcm43xx]
[   79.243096] [EC571A50] [F24F4344] bcm43xx_phy_init+0x6f8/0x730 [bcm43xx]
[   79.243124] [EC571A70] [F24E3140] bcm43xx_wireless_core_init+0x8a0/0x10b4 [bcm43xx]
[   79.243153] [EC571B00] [F24E52E0] bcm43xx_init_board+0x2f8/0x624 [bcm43xx]
[   79.243180] [EC571B30] [C020D9E4] dev_open+0x60/0xc8
[   79.243193] [EC571B50] [C020B910] dev_change_flags+0x70/0x148
[   79.243207] [EC571B70] [C0216DD0] do_setlink+0x78/0x390
[   79.243220] [EC571BB0] [C0216944] rtnetlink_rcv_msg+0x204/0x230
[   79.243232] [EC571BE0] [C0222C68] netlink_run_queue+0x80/0x188
[   79.243246] [EC571C20] [C02166B8] rtnetlink_rcv+0x40/0x6c
[   79.243258] [EC571C50] [C0223284] netlink_data_ready+0x28/0x84
[   79.243271] [EC571C60] [C0221C2C] netlink_sendskb+0x34/0x70
[   79.243283] [EC571C80] [C0223240] netlink_sendmsg+0x260/0x27c
[   79.243296] [EC571CD0] [C0200B00] sock_sendmsg+0xac/0xdc
[   79.243310] [EC571DC0] [C020182C] sys_sendmsg+0x1c8/0x254
[   79.243324] [EC571F00] [C02029A4] sys_socketcall+0x1ac/0x1e4
[   79.243338] [EC571F40] [C000F300] ret_from_syscall+0x0/0x38
[   79.243350] --- Exception: c01 at 0xff05d48
[   79.243361]     LR = 0xff66798
[   79.243921] bcm43xx: Chip initialized
[   79.249384] bcm43xx: DMA initialized
[   79.249408] bcm43xx: 80211 cores initialized
[   79.249627] bcm43xx: Keys cleared
[   79.257753] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: /home/olaf/kernel/olh/airport/linux-2.6.17-rc4/drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
[   79.257769] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)
[   79.257778] Call Trace:
[   79.257784] [EC571810] [C0007D98] show_stack+0x50/0x184 (unreliable)
[   79.257808] [EC571830] [F24F12B8] bcm43xx_phy_lo_adjust+0x2e8/0x30c [bcm43xx]
[   79.257875] [EC571850] [F24F1A64] bcm43xx_phy_lo_g_measure+0x788/0xb1c [bcm43xx]
[   79.257904] [EC5718D0] [F24E2234] bcm43xx_periodic_task_handler+0x104/0x344 [bcm43xx]
[   79.257932] [EC5718F0] [C0035284] run_timer_softirq+0x144/0x1bc
[   79.257953] [EC571920] [C0030978] __do_softirq+0x64/0xe4
[   79.257966] [EC571940] [C0005A94] do_softirq+0x50/0x74
[   79.257979] [EC571950] [C0030904] irq_exit+0x38/0x48
[   79.257992] [EC571960] [C000C120] timer_interrupt+0x508/0x51c
[   79.258007] [EC5719C0] [C000F9A8] ret_from_except+0x0/0x14
[   79.258022] --- Exception: 901 at mutex_lock+0x2c/0x6c
[   79.258036]     LR = mutex_lock+0x28/0x6c
[   79.258043] [EC571AA0] [C00B6B08] sysfs_add_file+0x34/0x8c
[   79.258061] [EC571AC0] [C019C51C] device_create_file+0x34/0x58
[   79.258081] [EC571AE0] [F24F7D54] bcm43xx_sysfs_register+0x60/0xcc [bcm43xx]
[   79.258115] [EC571B00] [F24E5578] bcm43xx_init_board+0x590/0x624 [bcm43xx]
[   79.258143] [EC571B30] [C020D9E4] dev_open+0x60/0xc8
[   79.258162] [EC571B50] [C020B910] dev_change_flags+0x70/0x148
[   79.258176] [EC571B70] [C0216DD0] do_setlink+0x78/0x390
[   79.258189] [EC571BB0] [C0216944] rtnetlink_rcv_msg+0x204/0x230
[   79.258203] [EC571BE0] [C0222C68] netlink_run_queue+0x80/0x188
[   79.258218] [EC571C20] [C02166B8] rtnetlink_rcv+0x40/0x6c
[   79.258230] [EC571C50] [C0223284] netlink_data_ready+0x28/0x84
[   79.258243] [EC571C60] [C0221C2C] netlink_sendskb+0x34/0x70
[   79.258256] [EC571C80] [C0223240] netlink_sendmsg+0x260/0x27c
[   79.258269] [EC571CD0] [C0200B00] sock_sendmsg+0xac/0xdc
[   79.258288] [EC571DC0] [C020182C] sys_sendmsg+0x1c8/0x254
[   79.258302] [EC571F00] [C02029A4] sys_socketcall+0x1ac/0x1e4
[   79.258317] [EC571F40] [C000F300] ret_from_syscall+0x0/0x38
[   79.258329] --- Exception: c01 at 0xff05d48
[   79.258349]     LR = 0xff66798
[   79.268404] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   79.525350] SoftMAC: Start scanning with channel: 1
[   79.525362] SoftMAC: Scanning 14 channels
[   79.839760] SoftMAC: Scanning finished
[   82.000532] SoftMAC: Associate: Scanning for networks first.
[   82.000551] SoftMAC: Start scanning with channel: 1
[   82.000558] SoftMAC: Scanning 14 channels
[   82.279679] SoftMAC: Scanning finished
[   82.279727] SoftMAC: Associate: Scanning for networks first.
[   82.279740] SoftMAC: Start scanning with channel: 1
[   82.279747] SoftMAC: Scanning 14 channels
[   82.559728] SoftMAC: Scanning finished
[   82.559783] SoftMAC: Associate: Scanning for networks first.
[   82.559798] SoftMAC: Start scanning with channel: 1
[   82.559805] SoftMAC: Scanning 14 channels
[   82.849676] SoftMAC: Scanning finished
[   82.849730] SoftMAC: Unable to find matching network after scan!
[   84.009832] bcm43xx: set security called
[   84.009844] bcm43xx:    .level = 0
[   84.009850] bcm43xx:    .enabled = 0
[   84.009856] bcm43xx:    .encrypt = 0
[   84.045918] eth0: Link is up at 100 Mbps, full-duplex.
[   84.045931] eth0: Pause is disabled
[   96.400807] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[   96.559913] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[   96.652764] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[   96.819857] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[   96.904775] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[   97.069829] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[   97.319893] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=109 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=89 
[   98.319959] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=109 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=89 
[   99.909871] SoftMAC: Start scanning with channel: 1
[   99.909885] SoftMAC: Scanning 14 channels
[  100.189696] SoftMAC: Scanning finished
[  105.864700] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:02:3f:14:43:68:08:00 SRC=10.10.1.91 DST=224.0.0.251 LEN=105 TOS=0x00 PREC=0x00 TTL=255 ID=4 DF PROTO=UDP SPT=5353 DPT=5353 LEN=85 
[  106.484935] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[  106.736931] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[  106.988938] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=72 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=52 
[  107.240956] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:13:77:04:15:b7:08:00 SRC=10.10.103.184 DST=224.0.0.251 LEN=106 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=86 
[  108.230064] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=109 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=89 
[  116.232421] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=109 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=89 
[  120.289923] SoftMAC: Start scanning with channel: 1
[  120.289939] SoftMAC: Scanning 14 channels
[  120.569731] SoftMAC: Scanning finished
[  121.000248] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[  121.259856] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[  121.519876] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=76 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=56 
[  126.067233] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC=01:00:5e:00:00:fb:00:02:3f:14:43:68:08:00 SRC=10.10.1.91 DST=224.0.0.251 LEN=105 TOS=0x00 PREC=0x00 TTL=255 ID=4 DF PROTO=UDP SPT=5353 DPT=5353 LEN=85 
[  128.780029] SFW2-INext-DROP-DEFLT IN=eth0 OUT= MAC= SRC=10.10.100.46 DST=224.0.0.251 LEN=109 TOS=0x00 PREC=0x00 TTL=255 ID=0 DF PROTO=UDP SPT=5353 DPT=5353 LEN=89 
[  140.669817] SoftMAC: Start scanning with channel: 1
[  140.669832] SoftMAC: Scanning 14 channels
[  140.949681] SoftMAC: Scanning finished
