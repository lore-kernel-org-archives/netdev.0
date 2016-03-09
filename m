From: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 10:31:24 -0600
Message-ID: <CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
	<56DD7172.4000707@suse.de>
	<2714888.1DdqvJZ8cb@diego>
	<56DD7593.5060003@suse.de>
	<56DD8176.2080603@st.com>
	<56DD8FBE.9010200@suse.de>
	<56DD99A4.5030004@st.com>
	<56DDA26C.3050301@suse.de>
	<56DDA3D5.3090209@st.com>
	<56DDB749.1020808@suse.de>
	<CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
	<56DE7E1D.5070508@st.com>
	<CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
	<CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
	<56DFE55B.2090806@st.com>
	<56DFE64B.8060606@st.com>
	<CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>
	<56DFF253.9050208@st.com>
	<56DFFA9E.7060602@st.com>
	<CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
	<56E033C8.40506@st.com>
	<56E038CE.606@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
	Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	=?UTF-8?Q?Frank_Sch=C3=A4fer?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56E038CE.606-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 9, 2016 at 8:53 AM, Giuseppe CAVALLARO
<peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
> Hi Tomeu, Dinh, Andreas
>
> I need a sum and help from you to go ahead on the
> tx timeout.
>
> The "stmmac: MDIO fixes" seems to be the candidate to
> fix the phy connection and I will send the V2 asap (Andreas' comment).
>
> So, supposing the probe is ok and phy is connected,
> I need your input ...
>
>  Tomeu: after revering the 0e80bdc9a72d (stmmac: first frame
>         prep at the end of xmit routine) the network is
>         not stable and there is a timeout after a while.
>         The box has 3.50 with normal desc settings.
>
>  Dinh: the network is ok, I wonder if you can share a boot
>        log just to understand if the normal or enhanced
>        descriptors are used.
>

Here it is:

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.5.0-rc6-next-20160304-00001-g092eb23
(dinguyen@linux-builds1) (gcc version 4.7.3 2013022
6 (prerelease) (crosstool-NG linaro-1.13.1-4.7-2013.03-20130313 -
Linaro GCC 2013.03) ) #1 SMP Wed Mar 9 10:22:14 CST 2
016
[    0.000000] CPU: ARMv7 Processor [413fc090] revision 0 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing
instruction cache
[    0.000000] Machine model: Altera SOCFPGA Cyclone V SoC Development Kit
[    0.000000] cma: Reserved 64 MiB at 0x3c000000
[    0.000000] Memory policy: Data cache writealloc
[    0.000000] PERCPU: Embedded 13 pages/cpu @ef7cc000 s23808 r8192
d21248 u53248
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 260608
[    0.000000] Kernel command line: console=ttyS0,115200
root=/dev/mmcblk0p2 rw rootwait ip=dhcp
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Memory: 955932K/1048576K available (9522K kernel code,
1142K rwdata, 4124K rodata, 2048K init, 342K bss,
 27108K reserved, 65536K cma-reserved, 196608K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
[    0.000000]     vmalloc : 0xf0800000 - 0xff800000   ( 240 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0208000 - 0xc1053830   (14639 kB)
[    0.000000]       .init : 0xc1100000 - 0xc1300000   (2048 kB)
[    0.000000]       .data : 0xc1300000 - 0xc141da80   (1143 kB)
[    0.000000]        .bss : 0xc141f000 - 0xc1474920   ( 343 kB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  Build-time adjustment of leaf fanout to 32.
[    0.000000]  RCU restricting CPUs from NR_CPUS=16 to nr_cpu_ids=2.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=32, nr_cpu_ids=2
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] L2C-310 erratum 769419 enabled
[    0.000000] L2C-310 enabling early BRESP for Cortex-A9
[    0.000000] L2C-310 full line of zeros enabled for Cortex-A9
[    0.000000] L2C-310 ID prefetch enabled, offset 1 lines
[    0.000000] L2C-310 dynamic clock gating enabled, standby mode enabled
[    0.000000] L2C-310 cache controller enabled, 8 ways, 512 kB
[    0.000000] L2C-310: CACHE_ID 0x410030c9, AUX_CTRL 0x76060001
[    0.000000] clocksource: timer1: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 19112604467 ns
[    0.000005] sched_clock: 32 bits at 100MHz, resolution 10ns, wraps
every 21474836475ns
[    0.000015] Switching to timer-based delay loop, resolution 10ns
[    0.000268] Console: colour dummy device 80x30
[    0.000290] Calibrating delay loop (skipped), value calculated
using timer frequency.. 200.00 BogoMIPS (lpj=500000)
[    0.000301] pid_max: default: 32768 minimum: 301
[    0.000374] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000382] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000879] CPU: Testing write buffer coherency: ok
[    0.001062] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
[    0.001207] Setting up static identity map for 0x300000 - 0x300098
[    0.003872] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
[    0.003946] Brought up 2 CPUs
[    0.003959] SMP: Total of 2 processors activated (400.00 BogoMIPS).
[    0.003965] CPU: All CPU(s) started in SVC mode.
[    0.004672] devtmpfs: initialized
[    0.008193] VFP support v0.3: implementor 41 architecture 3 part 30
variant 9 rev 4
[    0.008609] clocksource: jiffies: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 9556302231375000 ns
[    0.011733] pinctrl core: initialized pinctrl subsystem
[    0.013149] NET: Registered protocol family 16
[    0.014993] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.029850] cpuidle: using governor menu
[    0.035166] No ATAGs?
[    0.035199] hw-breakpoint: found 5 (+1 reserved) breakpoint and 1
watchpoint registers.
[    0.035207] hw-breakpoint: maximum watchpoint size is 4 bytes.
[    0.037795] Serial: AMBA PL011 UART driver
[    0.064193] vgaarb: loaded
[    0.064994] SCSI subsystem initialized
[    0.065377] usbcore: registered new interface driver usbfs
[    0.065427] usbcore: registered new interface driver hub
[    0.065471] usbcore: registered new device driver usb
[    0.065637] soc:usbphy@0 supply vcc not found, using dummy regulator
[    0.066917] pps_core: LinuxPPS API ver. 1 registered
[    0.066925] pps_core: Software ver. 5.3.6 - Copyright 2005-2007
Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
[    0.066948] PTP clock support registered
[    0.067075] EDAC MC: Ver: 3.0.0
[    0.068905] clocksource: Switched to clocksource timer1
[    0.077130] NET: Registered protocol family 2
[    0.077598] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.077675] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
[    0.077789] TCP: Hash tables configured (established 8192 bind 8192)
[    0.077850] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.077892] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.078045] NET: Registered protocol family 1
[    0.078313] RPC: Registered named UNIX socket transport module.
[    0.078322] RPC: Registered udp transport module.
[    0.078327] RPC: Registered tcp transport module.
[    0.078332] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.079971] futex hash table entries: 512 (order: 3, 32768 bytes)
[    0.080491] workingset: timestamp_bits=28 max_order=18 bucket_order=0
[    0.088552] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.089257] NFS: Registering the id_resolver key type
[    0.089295] Key type id_resolver registered
[    0.089302] Key type id_legacy registered
[    0.089357] ntfs: driver 2.1.32 [Flags: R/O].
[    0.090460] bounce: pool size: 64 pages
[    0.090644] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 248)
[    0.090659] io scheduler noop registered
[    0.090670] io scheduler deadline registered
[    0.090702] io scheduler cfq registered (default)
[    0.101187] dma-pl330 ffe01000.pdma: Loaded driver for PL330 DMAC-341330
[    0.101202] dma-pl330 ffe01000.pdma:         DBUFF-512x8bytes
Num_Chans-8 Num_Peri-32 Num_Events-8
[    0.148800] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.150717] console [ttyS0] disabled
[    0.150752] ffc02000.serial0: ttyS0 at MMIO 0xffc02000 (irq = 35,
base_baud = 6250000) is a 16550A
[    0.760760] console [ttyS0] enabled
[    0.764930] ffc03000.serial1: ttyS1 at MMIO 0xffc03000 (irq = 36,
base_baud = 6250000) is a 16550A
[    0.774702] SuperH (H)SCI(F) driver initialized
[    0.779746] msm_serial: driver initialized
[    0.783950] STMicroelectronics ASC driver initialized
[    0.789977] [drm] Initialized drm 1.1.0 20060810
[    0.804439] brd: module loaded
[    0.812215] loop: module loaded
[    0.815664] at24 0-0051: 4096 byte 24c32 EEPROM, writable, 32 bytes/write
[    0.827372] libphy: Fixed MDIO Bus: probed
[    0.832015] CAN device driver interface
[    0.836848] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.0-k
[    0.843792] igb: Copyright (c) 2007-2014 Intel Corporation.
[    0.850523] stmmac - user ID: 0x10, Synopsys ID: 0x37
[    0.855570]  Ring mode enabled
[    0.858611]  DMA HW capability register supported
[    0.863128]  Enhanced/Alternate descriptors
[    0.867482]  Enabled extended descriptors
[    0.871482]  RX Checksum Offload Engine supported (type 2)
[    0.876948]  TX Checksum insertion supported
[    0.881204]  Enable RX Mitigation via HW Watchdog Timer
[    0.886863] socfpga-dwmac ff702000.ethernet eth0: No MDIO subnode found
[    0.899090] libphy: stmmac: probed
[    0.902484] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
[    0.909742] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB
Ethernet driver
[    0.917175] usbcore: registered new interface driver pegasus
[    0.922873] usbcore: registered new interface driver asix
[    0.928300] usbcore: registered new interface driver ax88179_178a
[    0.934422] usbcore: registered new interface driver cdc_ether
[    0.940294] usbcore: registered new interface driver smsc75xx
[    0.946078] usbcore: registered new interface driver smsc95xx
[    0.951848] usbcore: registered new interface driver net1080
[    0.957529] usbcore: registered new interface driver cdc_subset
[    0.963470] usbcore: registered new interface driver zaurus
[    0.969098] usbcore: registered new interface driver cdc_ncm
[    0.975810] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.982335] ehci-pci: EHCI PCI platform driver
[    0.986814] ehci-platform: EHCI generic platform driver
[    0.992147] ehci-omap: OMAP-EHCI Host Controller driver
[    0.997446] ehci-orion: EHCI orion driver
[    1.001534] SPEAr-ehci: EHCI SPEAr driver
[    1.005623] ehci-st: EHCI STMicroelectronics driver
[    1.010577] ehci-exynos: EHCI EXYNOS driver
[    1.014845] ehci-atmel: EHCI Atmel driver
[    1.018930] tegra-ehci: Tegra EHCI driver
[    1.023017] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.029198] ohci-pci: OHCI PCI platform driver
[    1.033671] ohci-platform: OHCI generic platform driver
[    1.038999] ohci-omap3: OHCI OMAP3 driver
[    1.043076] SPEAr-ohci: OHCI SPEAr driver
[    1.047166] ohci-st: OHCI STMicroelectronics driver
[    1.052119] ohci-atmel: OHCI Atmel driver
[    1.056540] usbcore: registered new interface driver usb-storage
[    1.063604] mousedev: PS/2 mouse device common for all mice
[    1.071372] rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
[    1.078720] i2c /dev entries driver
[    1.088558] sdhci: Secure Digital Host Controller Interface driver
[    1.094733] sdhci: Copyright(c) Pierre Ossman
[    1.099926] Synopsys Designware Multimedia Card Interface Driver
[    1.106160] dw_mmc ff704000.dwmmc0: IDMAC supports 32-bit address mode.
[    1.112832] dw_mmc ff704000.dwmmc0: Using internal DMA controller.
[    1.119003] dw_mmc ff704000.dwmmc0: Version ID is 240a
[    1.124161] dw_mmc ff704000.dwmmc0: DW MMC controller at irq 30,32
bit host data width,1024 deep fifo
[    1.133484] dw_mmc ff704000.dwmmc0: Got CD GPIO
[    1.163951] dw_mmc ff704000.dwmmc0: 1 slots initialized
[    1.169801] sdhci-pltfm: SDHCI platform and OF driver helper
[    1.176752] ledtrig-cpu: registered to indicate activity on CPUs
[    1.183123] usbcore: registered new interface driver usbhid
[    1.188689] usbhid: USB HID core driver
[    1.196305] NET: Registered protocol family 10
[    1.201510] sit: IPv6 over IPv4 tunneling driver
[    1.206748] NET: Registered protocol family 17
[    1.211203] can: controller area network core (rev 20120528 abi 9)
[    1.217420] NET: Registered protocol family 29
[    1.221867] can: raw protocol (rev 20120528)
[    1.226139] can: broadcast manager protocol (rev 20120528 t)
[    1.231793] can: netlink gateway (rev 20130117) max_hops=1
[    1.237633] Key type dns_resolver registered
[    1.242056] ThumbEE CPU extension supported.
[    1.246339] Registering SWP/SWPB emulation handler
[    1.252996] rtc-ds1307 0-0068: setting system clock to 2000-01-01
10:28:48 UTC (946722528)
[    1.283660] mmc_host mmc0: Bus speed (slot 0) = 50000000Hz (slot
req 50000000Hz, actual 50000000HZ div = 0)
[    1.293419] mmc0: new high speed SDHC card at address 0007
[    1.299260] mmcblk0: mmc0:0007 SD4GB 3.71 GiB
[    1.305075]  mmcblk0: p1 p2 p3 p4
[    1.336767] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    5.324487] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
1Gbps/Full - flow control rx/tx
[    5.333591] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    5.343917] Sending DHCP requests ., OK
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
