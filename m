From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14350] New: Network driver for mpc8313erdb
 board does not work
Date: Tue, 13 Oct 2009 12:08:31 -0700
Message-ID: <20091013120831.9db03876.akpm@linux-foundation.org>
References: <bug-14350-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: janegu12@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60595 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933986AbZJMTJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 15:09:43 -0400
In-Reply-To: <bug-14350-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 8 Oct 2009 22:14:38 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14350
> 
>            Summary: Network driver for mpc8313erdb board does not work

All right, I give up.  Which net device driver does a "mpc8313erdb board" use?

I'm seeing gianfar in the dmesg.  Is it that?

>            Product: Drivers
>            Version: 2.5
>     Kernel Version: linux2.6.31.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: janegu12@gmail.com
>         Regression: No
> 
> 
> I am working on mpc8313erdb board. I want to update current linux2.6.23 from
> freescale to latest version.there are 3 scenarios as below:
> 
> 1: when I set up uboot as NFS boot, it hang on after IP-config:
> 
> ## Booting image at 00200000 ...
>    Image Name:   Linux-2.6.31.1
>    Created:      2009-10-08  21:19:37 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    1987293 Bytes =  1.9 MB
>    Load Address: 02000000
>    Entry Point:  02000000
>    Verifying Checksum ... OK
>    Uncompressing Kernel Image ... OK
>    Booting using the fdt at 0x400000
> Using MPC831x RDB machine description
> Linux version 2.6.31.1 (root@dtl-lap-desi2.dtlab.moriseiki.co.jp) (gcc version
> 4.1.2) #15 Thu Oct 8 14:19:30 PDT 2009
> Found legacy serial port 0 for /soc8313@e0000000/serial@4500
>   mem=e0004500, taddr=e0004500, irq=0, clk=166666665, speed=0
> Found legacy serial port 1 for /soc8313@e0000000/serial@4600
>   mem=e0004600, taddr=e0004600, irq=0, clk=166666665, speed=0
> console [udbg0] enabled
> setup_arch: bootmem
> mpc831x_rdb_setup_arch()
> arch: exit
> Top of RAM: 0x8000000, Total RAM: 0x8000000
> Memory hole size: 0MB
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00008000
>   Normal   0x00008000 -> 0x00008000
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0: 0x00000000 -> 0x00008000
> On node 0 totalpages: 32768
> free_area_init_node: node 0, pgdat c23f856c, node_mem_map c0010000
>   DMA zone: 256 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 32512 pages, LIFO batch:7
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: root=/dev/nfs rw nfsroot=10.10.8.167:/tftpboot/rootfs8313
> ip=10.10.8.239:10.10.8.167:10.10.8.1:255.255.255.0:mpc8313eio:eth1:off consol0
> PID hash table entries: 512 (order: 9, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 125252k/131072k available (3896k kernel code, 5668k reserved, 180k
> data, 347k bss, 148k init)
> Kernel virtual memory layout:
>   * 0xffffe000..0xfffff000  : fixmap
>   * 0xfdffc000..0xfe000000  : early ioremap
>   * 0xc9000000..0xfdffc000  : vmalloc & ioremap
> Hierarchical RCU implementation.
> NR_IRQS:512
> IPIC (128 IRQ sources) at c9000700
> time_init: decrementer frequency = 41.666666 MHz
> time_init: processor frequency   = 333.333330 MHz
> clocksource: timebase mult[6000002] shift[22] registered
> clockevent: decrementer mult[aaaaaa7] shift[32] cpu[0]
> Mount-cache hash table entries: 512
> khelper used greatest stack depth: 7248 bytes left
> NET: Registered protocol family 16
> 
> irq: irq 38 on host /soc8313@e0000000/pic@700 mapped to virtual irq 38
> khelper used greatest stack depth: 7216 bytes left
> Registering ipic with sysfs...
> khelper used greatest stack depth: 7200 bytes left
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> Generic PHY: Registered new driver
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Freescale Elo / Elo Plus DMA driver
> Switched to high resolution mode on CPU 0
> khelper used greatest stack depth: 7104 bytes left
> NET: Registered protocol family 2
> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
> TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP reno registered
> NET: Registered protocol family 1
> irq: irq 9 on host /soc8313@e0000000/pic@700 mapped to virtual irq 16
> irq: irq 10 on host /soc8313@e0000000/pic@700 mapped to virtual irq 17
> khelper used greatest stack depth: 6880 bytes left
> WDT driver for MPC8xxx initialized. mode:reset timeout=65535 (25 seconds)
> fsl-elo-dma e00082a8.dma: Probe the Freescale DMA driver for fsl,elo-dma
> controller at 0xe00082a8...
> irq: irq 71 on host /soc8313@e0000000/pic@700 mapped to virtual irq 71
> fsl-elo-dma e00082a8.dma: #0 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #1 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #2 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #3 (fsl,elo-dma-channel), irq 71
> JFFS2 version 2.2. (NAND) .. 2001-2006 Red Hat, Inc.
> msgmni has been set to 244
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> khelper used greatest stack depth: 6752 bytes left
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
> console handover: boot [udbg0] -> real [ttyS0]
> serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
> brd: module loaded
> loop: module loaded
> irq: irq 37 on host /soc8313@e0000000/pic@700 mapped to virtual irq 37
> irq: irq 36 on host /soc8313@e0000000/pic@700 mapped to virtual irq 36
> irq: irq 35 on host /soc8313@e0000000/pic@700 mapped to virtual irq 35
> eth0: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:01
> eth0: Running with NAPI enabled
> eth0: 256/256 RX/TX BD ring size
> irq: irq 34 on host /soc8313@e0000000/pic@700 mapped to virtual irq 34
> irq: irq 33 on host /soc8313@e0000000/pic@700 mapped to virtual irq 33
> irq: irq 32 on host /soc8313@e0000000/pic@700 mapped to virtual irq 32
> eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:02
> eth1: Running with NAPI enabled
> eth1: 256/256 RX/TX BD ring size
> Freescale PowerQUICC MII Bus: probed
> irq: irq 20 on host /soc8313@e0000000/pic@700 mapped to virtual irq 20
> Freescale PowerQUICC MII Bus: probed
> Marvell 88E1101: Registered new driver
> Marvell 88E1112: Registered new driver
> Marvell 88E1111: Registered new driver
> Marvell 88E1118: Registered new driver
> Marvell 88E1121R: Registered new driver
> Marvell 88E1145: Registered new driver
> Marvell 88E1240: Registered new driver
> Fixed MDIO Bus: probed
> fe000000.flash: Found 1 x16 devices at 0x0 in 16-bit bank
>  Amd/Fujitsu Extended Query Table at 0x0040
> fe000000.flash: Swapping erase regions for broken CFI table.
> number of CFI chips: 1
> cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
> RedBoot partition parsing not available
> irq: irq 16 on host /soc8313@e0000000/pic@700 mapped to virtual irq 18
> e0007000.spi: MPC8xxx SPI Controller driver at 0xc9090000 (irq = 18)
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 38, io base 0xe0023000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i2c /dev entries driver
> irq: irq 14 on host /soc8313@e0000000/pic@700 mapped to virtual irq 19
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> irq: irq 15 on host /soc8313@e0000000/pic@700 mapped to virtual irq 21
> TCP cubic registered
> NET: Registered protocol family 17
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> rtc-ds1307 0-0068: setting system clock to 2001-04-09 16:02:33 UTC (986832153)
> IP-Config: Complete:
>      device=eth1, addr=10.10.8.239, mask=255.255.255.0, gw=10.10.8.1,
>      host=mpc8313eio, domain=, nis-domain=(none),
>      bootserver=10.10.8.167, rootserver=10.10.8.167, rootpath=
> VFS: Cannot open root device "nfs" or unknown-block(0,255)
> Please append a correct "root=" boot option; here are the available partitions:
> 1f00            8192 mtdblock0 (driver?)
> Kernel panic - not syncing: VFS: Unable to mount root fs on
> unknown-block(0,255)
> Call Trace:
> [c7825ee0] [c2008768] show_stack+0x3c/0x160 (unreliable)
> [c7825f10] [c20240f4] panic+0x8c/0x164
> [c7825f60] [c23a9c5c] mount_block_root+0x124/0x2bc
> [c7825fb0] [c23a9fdc] prepare_namespace+0x180/0x210
> [c7825fd0] [c23a9210] kernel_init+0xfc/0x128
> [c7825ff0] [c2011128] kernel_thread+0x4c/0x68
> Rebooting in 180 seconds..
> 
> 2:if I setup uboot as ramdisk boot and only setup eth1 interface, I can boot
> the linux. when I try to ping other PC, it hang on and get exception.
> 
> ## Booting image at 00200000 ...
>    Image Name:   Linux-2.6.31.1
>    Created:      2009-10-08  21:59:21 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    1984750 Bytes =  1.9 MB
>    Load Address: 02000000
>    Entry Point:  02000000
>    Verifying Checksum ... OK
>    Uncompressing Kernel Image ... OK
> ## Loading RAMDisk Image at 01000000 ...
>    Image Name:   uboot ext2 ramdisk rootfs
>    Created:      2009-10-08  22:01:18 UTC
>    Image Type:   PowerPC Linux RAMDisk Image (gzip compressed)
>    Data Size:    3811695 Bytes =  3.6 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
>    Booting using the fdt at 0x400000
>    Loading Ramdisk to 07ba4000, end 07f4696f ... OK
> Using MPC831x RDB machine description
> Linux version 2.6.31.1 (root@dtl-lap-desi2.dtlab.moriseiki.co.jp) (gcc version
> 4.1.2) #16 Thu Oct 8 14:59:14 PDT 2009
> Found initrd at 0xc7ba4000:0xc7f4696f
> Found legacy serial port 0 for /soc8313@e0000000/serial@4500
>   mem=e0004500, taddr=e0004500, irq=0, clk=166666665, speed=0
> Found legacy serial port 1 for /soc8313@e0000000/serial@4600
>   mem=e0004600, taddr=e0004600, irq=0, clk=166666665, speed=0
> console [udbg0] enabled
> setup_arch: bootmem
> mpc831x_rdb_setup_arch()
> arch: exit
> Top of RAM: 0x8000000, Total RAM: 0x8000000
> Memory hole size: 0MB
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00008000
>   Normal   0x00008000 -> 0x00008000
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0: 0x00000000 -> 0x00008000
> On node 0 totalpages: 32768
> free_area_init_node: node 0, pgdat c23f756c, node_mem_map c0010000
>   DMA zone: 256 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 32512 pages, LIFO batch:7
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: root=/dev/ram rw console=ttyS0,115200
> PID hash table entries: 512 (order: 9, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 121524k/131072k available (3892k kernel code, 9384k reserved, 180k
> data, 347k bss, 148k init)
> Kernel virtual memory layout:
>   * 0xffffe000..0xfffff000  : fixmap
>   * 0xfdffc000..0xfe000000  : early ioremap
>   * 0xc9000000..0xfdffc000  : vmalloc & ioremap
> Hierarchical RCU implementation.
> NR_IRQS:512
> IPIC (128 IRQ sources) at c9000700
> time_init: decrementer frequency = 41.666666 MHz
> time_init: processor frequency   = 333.333330 MHz
> clocksource: timebase mult[6000002] shift[22] registered
> clockevent: decrementer mult[aaaaaa7] shift[32] cpu[0]
> Mount-cache hash table entries: 512
> khelper used greatest stack depth: 7248 bytes left
> NET: Registered protocol family 16
> 
> irq: irq 38 on host /soc8313@e0000000/pic@700 mapped to virtual irq 38
> khelper used greatest stack depth: 7216 bytes left
> Registering ipic with sysfs...
> khelper used greatest stack depth: 6736 bytes left
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> Generic PHY: Registered new driver
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Freescale Elo / Elo Plus DMA driver
> Switched to high resolution mode on CPU 0
> NET: Registered protocol family 2
> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
> TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP reno registered
> NET: Registered protocol family 1
> Trying to unpack rootfs image as initramfs...
> rootfs image is not initramfs (no cpio magic); looks like an initrd
> Freeing initrd memory: 3722k freed
> irq: irq 9 on host /soc8313@e0000000/pic@700 mapped to virtual irq 16
> irq: irq 10 on host /soc8313@e0000000/pic@700 mapped to virtual irq 17
> WDT driver for MPC8xxx initialized. mode:reset timeout=65535 (25 seconds)
> fsl-elo-dma e00082a8.dma: Probe the Freescale DMA driver for fsl,elo-dma
> controller at 0xe00082a8...
> irq: irq 71 on host /soc8313@e0000000/pic@700 mapped to virtual irq 71
> fsl-elo-dma e00082a8.dma: #0 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #1 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #2 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #3 (fsl,elo-dma-channel), irq 71
> khelper used greatest stack depth: 6624 bytes left
> JFFS2 version 2.2. (NAND) .. 2001-2006 Red Hat, Inc.
> msgmni has been set to 244
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
> console handover: boot [udbg0] -> real [ttyS0]
> serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
> brd: module loaded
> loop: module loaded
> irq: irq 37 on host /soc8313@e0000000/pic@700 mapped to virtual irq 37
> irq: irq 36 on host /soc8313@e0000000/pic@700 mapped to virtual irq 36
> irq: irq 35 on host /soc8313@e0000000/pic@700 mapped to virtual irq 35
> eth0: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:01
> eth0: Running with NAPI enabled
> eth0: 256/256 RX/TX BD ring size
> irq: irq 34 on host /soc8313@e0000000/pic@700 mapped to virtual irq 34
> irq: irq 33 on host /soc8313@e0000000/pic@700 mapped to virtual irq 33
> irq: irq 32 on host /soc8313@e0000000/pic@700 mapped to virtual irq 32
> eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:02
> eth1: Running with NAPI enabled
> eth1: 256/256 RX/TX BD ring size
> Freescale PowerQUICC MII Bus: probed
> irq: irq 20 on host /soc8313@e0000000/pic@700 mapped to virtual irq 20
> Freescale PowerQUICC MII Bus: probed
> Marvell 88E1101: Registered new driver
> Marvell 88E1112: Registered new driver
> Marvell 88E1111: Registered new driver
> Marvell 88E1118: Registered new driver
> Marvell 88E1121R: Registered new driver
> Marvell 88E1145: Registered new driver
> Marvell 88E1240: Registered new driver
> Fixed MDIO Bus: probed
> fe000000.flash: Found 1 x16 devices at 0x0 in 16-bit bank
>  Amd/Fujitsu Extended Query Table at 0x0040
> fe000000.flash: Swapping erase regions for broken CFI table.
> number of CFI chips: 1
> cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
> RedBoot partition parsing not available
> irq: irq 16 on host /soc8313@e0000000/pic@700 mapped to virtual irq 18
> e0007000.spi: MPC8xxx SPI Controller driver at 0xc9090000 (irq = 18)
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 38, io base 0xe0023000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i2c /dev entries driver
> irq: irq 14 on host /soc8313@e0000000/pic@700 mapped to virtual irq 19
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> irq: irq 15 on host /soc8313@e0000000/pic@700 mapped to virtual irq 21
> TCP cubic registered
> NET: Registered protocol family 17
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> rtc-ds1307 0-0068: setting system clock to 2001-04-09 16:29:22 UTC (986833762)
> RAMDISK: gzip image found at block 0
> VFS: Mounted root (ext2 filesystem) on device 1:0.
> Freeing unused kernel memory: 148k init
> Setting the hostname to mpc8313erdb
> hostname used greatest stack depth: 6544 bytes left
> hostname used greatest stack depth: 6272 bytes left
> Mounting filesystems
> Running sysctl
> Setting up networking on loopback device: 
> 
> Warning: no IPADDR is set, please set this from the ltib
> config screen, or directly in /etc/rc.d/rc.conf.
> IP address setup bypassed
> 
> Setting up networking on eth1: 
> Adding static route for default gateway to 10.10.8.1: 
> Setting nameserver to 10.10.1.15 in /etc/resolv.conf: 
> Starting inetd: 
> inetd used greatest stack depth: 6224 bytes left
> 
> 
>         Welcome to Freescale Semiconductor Embedded Linux Environment
> 
> !!!!! WARNING !!!!!!!
> 
> The default password for the root account is: root
> please change this password using the 'passwd' command
> and then edit this message (/etc/issue) to remove this message
> 
> mpc8313erdb login: PHY: mdio@e0024520:04 - Link is Up - 100/Full
> 
> 
>         Welcome to Freescale Semiconductor Embedded Linux Environment
> 
> !!!!! WARNING !!!!!!!
> 
> The default password for the root account is: root
> please change this password using the 'passwd' command
> and then edit this message (/etc/issue) to remove this message
> 
> mpc8313erdb login: root
> Password: 
> login[862]: root login  on `console'
> 
> ~ # ping 10.10.8.167
> PING 10.10.8.167 (10.10.8.167): 56 data bytes
> NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue 0 timed out
> ------------[ cut here ]------------
> Badness at net/sched/sch_generic.c:246
> NIP: c2254834 LR: c2254834 CTR: c21bc7f8
> REGS: c23fbcf0 TRAP: 0700   Not tainted  (2.6.31.1)
> MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24000022  XER: 20000000
> TASK = c23cf3e8[0] 'swapper' THREAD: c23fa000
> GPR00: c2254834 c23fbda0 c23cf3e8 00000046 00001d01 ffffffff c21b9dc0 00020000 
> GPR08: 00000036 c23f97f4 00001d01 c2400ea0 44000082 00000000 07ffd000 00000001 
> GPR16: c23d1ae8 c2350000 c23f8060 c23d1968 c23f8080 c2420000 c2420000 0000000a 
> GPR24: c23fa000 00000000 c23d0000 c6dc11c0 c2400000 c23d0000 00000000 c6dc1000 
> NIP [c2254834] dev_watchdog+0x298/0x2a8
> LR [c2254834] dev_watchdog+0x298/0x2a8
> Call Trace:
> [c23fbda0] [c2254834] dev_watchdog+0x298/0x2a8 (unreliable)
> [c23fbe00] [c20300cc] run_timer_softirq+0x158/0x1c8
> [c23fbe40] [c202ae90] __do_softirq+0xcc/0x1d4
> [c23fbe90] [c2006678] do_softirq+0x58/0x5c
> [c23fbea0] [c202acb4] irq_exit+0x48/0x58
> [c23fbeb0] [c200ea2c] timer_interrupt+0x12c/0x188
> [c23fbed0] [c201199c] ret_from_except+0x0/0x14
> --- Exception: 901 at cpu_idle+0x9c/0xe0
>     LR = cpu_idle+0x9c/0xe0
> [c23fbf90] [c2009964] cpu_idle+0xd0/0xe0 (unreliable)
> [c23fbfb0] [c2003e58] rest_init+0x5c/0x84
> [c23fbfc0] [c23a883c] start_kernel+0x234/0x2bc
> [c23fbff0] [02003438] 0x2003438
> Instruction dump:
> 7c0903a6 4bfffe48 38810008 7fe3fb78 38a00040 4bfebe19 7fc6f378 7fe4fb78 
> 7c651b78 3c60c238 3863101c 4bdd08f1 <0fe00000> 38000001 901c0b78 4bffff8c 
> 
> 
> 
> 
> 
> 
> 3: if I setup uboot as ramdisk bott and setup both eth0 and eht1 interface, it
> will hang on just after login info was print out:
> 
> ## Booting image at 00200000 ...
>    Image Name:   Linux-2.6.31.1
>    Created:      2009-10-08  21:19:37 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    1987293 Bytes =  1.9 MB
>    Load Address: 02000000
>    Entry Point:  02000000
>    Verifying Checksum ... OK
>    Uncompressing Kernel Image ... OK
> ## Loading RAMDisk Image at 01000000 ...
>    Image Name:   uboot ext2 ramdisk rootfs
>    Created:      2009-10-08  21:48:06 UTC
>    Image Type:   PowerPC Linux RAMDisk Image (gzip compressed)
>    Data Size:    3811870 Bytes =  3.6 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
>    Booting using the fdt at 0x400000
>    Loading Ramdisk to 07ba4000, end 07f46a1e ... OK
> Using MPC831x RDB machine description
> Linux version 2.6.31.1 (root@dtl-lap-desi2.dtlab.moriseiki.co.jp) (gcc version
> 4.1.2) #15 Thu Oct 8 14:19:30 PDT 2009
> Found initrd at 0xc7ba4000:0xc7f46a1e
> Found legacy serial port 0 for /soc8313@e0000000/serial@4500
>   mem=e0004500, taddr=e0004500, irq=0, clk=166666665, speed=0
> Found legacy serial port 1 for /soc8313@e0000000/serial@4600
>   mem=e0004600, taddr=e0004600, irq=0, clk=166666665, speed=0
> console [udbg0] enabled
> setup_arch: bootmem
> mpc831x_rdb_setup_arch()
> arch: exit
> Top of RAM: 0x8000000, Total RAM: 0x8000000
> Memory hole size: 0MB
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00008000
>   Normal   0x00008000 -> 0x00008000
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0: 0x00000000 -> 0x00008000
> On node 0 totalpages: 32768
> free_area_init_node: node 0, pgdat c23f856c, node_mem_map c0010000
>   DMA zone: 256 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 32512 pages, LIFO batch:7
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: root=/dev/ram rw console=ttyS0,115200
> PID hash table entries: 512 (order: 9, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 121524k/131072k available (3896k kernel code, 9392k reserved, 180k
> data, 347k bss, 148k init)
> Kernel virtual memory layout:
>   * 0xffffe000..0xfffff000  : fixmap
>   * 0xfdffc000..0xfe000000  : early ioremap
>   * 0xc9000000..0xfdffc000  : vmalloc & ioremap
> Hierarchical RCU implementation.
> NR_IRQS:512
> IPIC (128 IRQ sources) at c9000700
> time_init: decrementer frequency = 41.666666 MHz
> time_init: processor frequency   = 333.333330 MHz
> clocksource: timebase mult[6000002] shift[22] registered
> clockevent: decrementer mult[aaaaaa7] shift[32] cpu[0]
> Mount-cache hash table entries: 512
> khelper used greatest stack depth: 7248 bytes left
> NET: Registered protocol family 16
> 
> irq: irq 38 on host /soc8313@e0000000/pic@700 mapped to virtual irq 38
> khelper used greatest stack depth: 7216 bytes left
> Registering ipic with sysfs...
> khelper used greatest stack depth: 7072 bytes left
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> Generic PHY: Registered new driver
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Freescale Elo / Elo Plus DMA driver
> Switched to high resolution mode on CPU 0
> NET: Registered protocol family 2
> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
> TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP reno registered
> NET: Registered protocol family 1
> Trying to unpack rootfs image as initramfs...
> rootfs image is not initramfs (no cpio magic); looks like an initrd
> Freeing initrd memory: 3722k freed
> irq: irq 9 on host /soc8313@e0000000/pic@700 mapped to virtual irq 16
> irq: irq 10 on host /soc8313@e0000000/pic@700 mapped to virtual irq 17
> WDT driver for MPC8xxx initialized. mode:reset timeout=65535 (25 seconds)
> khelper used greatest stack depth: 6752 bytes left
> khelper used greatest stack depth: 6688 bytes left
> fsl-elo-dma e00082a8.dma: Probe the Freescale DMA driver for fsl,elo-dma
> controller at 0xe00082a8...
> irq: irq 71 on host /soc8313@e0000000/pic@700 mapped to virtual irq 71
> fsl-elo-dma e00082a8.dma: #0 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #1 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #2 (fsl,elo-dma-channel), irq 71
> fsl-elo-dma e00082a8.dma: #3 (fsl,elo-dma-channel), irq 71
> JFFS2 version 2.2. (NAND) .. 2001-2006 Red Hat, Inc.
> msgmni has been set to 244
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> khelper used greatest stack depth: 6640 bytes left
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
> console handover: boot [udbg0] -> real [ttyS0]
> serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
> brd: module loaded
> loop: module loaded
> irq: irq 37 on host /soc8313@e0000000/pic@700 mapped to virtual irq 37
> irq: irq 36 on host /soc8313@e0000000/pic@700 mapped to virtual irq 36
> irq: irq 35 on host /soc8313@e0000000/pic@700 mapped to virtual irq 35
> eth0: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:01
> eth0: Running with NAPI enabled
> eth0: 256/256 RX/TX BD ring size
> irq: irq 34 on host /soc8313@e0000000/pic@700 mapped to virtual irq 34
> irq: irq 33 on host /soc8313@e0000000/pic@700 mapped to virtual irq 33
> irq: irq 32 on host /soc8313@e0000000/pic@700 mapped to virtual irq 32
> eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:95:02
> eth1: Running with NAPI enabled
> eth1: 256/256 RX/TX BD ring size
> Freescale PowerQUICC MII Bus: probed
> irq: irq 20 on host /soc8313@e0000000/pic@700 mapped to virtual irq 20
> Freescale PowerQUICC MII Bus: probed
> Marvell 88E1101: Registered new driver
> Marvell 88E1112: Registered new driver
> Marvell 88E1111: Registered new driver
> Marvell 88E1118: Registered new driver
> Marvell 88E1121R: Registered new driver
> Marvell 88E1145: Registered new driver
> Marvell 88E1240: Registered new driver
> Fixed MDIO Bus: probed
> fe000000.flash: Found 1 x16 devices at 0x0 in 16-bit bank
>  Amd/Fujitsu Extended Query Table at 0x0040
> fe000000.flash: Swapping erase regions for broken CFI table.
> number of CFI chips: 1
> cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
> RedBoot partition parsing not available
> irq: irq 16 on host /soc8313@e0000000/pic@700 mapped to virtual irq 18
> e0007000.spi: MPC8xxx SPI Controller driver at 0xc9090000 (irq = 18)
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 38, io base 0xe0023000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i2c /dev entries driver
> irq: irq 14 on host /soc8313@e0000000/pic@700 mapped to virtual irq 19
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> irq: irq 15 on host /soc8313@e0000000/pic@700 mapped to virtual irq 21
> TCP cubic registered
> NET: Registered protocol family 17
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> rtc-ds1307 0-0068: setting system clock to 2001-04-09 16:17:27 UTC (986833047)
> RAMDISK: gzip image found at block 0
> VFS: Mounted root (ext2 filesystem) on device 1:0.
> Freeing unused kernel memory: 148k init
> Setting the hostname to mpc8313erdb
> hostname used greatest stack depth: 6544 bytes left
> [ used greatest stack depth: 6416 bytes left
> Mounting filesystems
> [ used greatest stack depth: 6304 bytes left
> Running sysctl
> Setting up networking on loopback device: 
> ifconfig used greatest stack depth: 6000 bytes left
> Setting up networking on eth0: 
> Adding static route for default gateway to 10.10.8.1: 
> Setting nameserver to 10.10.1.15 in /etc/resolv.conf: 
> Setting up networking on eth1: 
> Adding static route for default gateway to 10.10.8.1: 
> Setting nameserver to 10.10.1.15 in /etc/resolv.conf: 
> Starting inetd: 
> 
> 
>         Welcome to Freescale Semiconductor Embedded Linux Environment
> 
> !!!!! WARNING !!!!!!!
> 
> The default password for the root account is: root
> please change this password using the 'passwd' command
> and then edit this message (/etc/issue) to remove this message
> 
> mpc8313erdb login: PHY: 0:01 - Link is Up - 1000/Full
> PHY: mdio@e0024520:04 - Link is Up - 100/Full
> BUG: soft lockup - CPU#0 stuck for 61s! [swapper:0]
> Modules linked in:
> NIP: c20551b8 LR: c2057520 CTR: c2015b20
> REGS: c23fdb50 TRAP: 0901   Not tainted  (2.6.31.1)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 24000048  XER: 20000000
> TASK = c23d03e8[0] 'swapper' THREAD: c23fc000
> GPR00: 00009032 c23fdc00 c23d03e8 00000025 c7549520 00001032 c7401700 00000020 
> GPR08: c22d4be6 c2400000 f2000087 c2428574 00000000 
> NIP [c20551b8] handle_IRQ_event+0x34/0x1d0
> LR [c2057520] handle_level_irq+0x80/0x10c
> Call Trace:
> [c23fdc00] [c2055208] handle_IRQ_event+0x84/0x1d0 (unreliable)
> [c23fdc30] [c2057520] handle_level_irq+0x80/0x10c
> [c23fdc40] [c200672c] do_IRQ+0xb0/0xd8
> --- Exception: c20551b8 at gfar_schedule_cleanup+0x74/0xb0
>     LR = gfar_receive+0x14/0x28
> [c23fdc60] [c201199c] ret_from_except+0x0/0x14 (unreliable)
> --- Exception: 501 at handle_IRQ_event+0x34/0x1d0
>     LR = handle_level_irq+0x80/0x10c
> [c23fdd20] [c2055208] handle_IRQ_event+0x84/0x1d0 (unreliable)
> [c23fdd50] [c2057520] handle_level_irq+0x80/0x10c
> [c23fdd60] [c200672c] do_IRQ+0xb0/0xd8
> [c23fdd80] [c201199c] ret_from_except+0x0/0x14
> --- Exception: 501 at __do_softirq+0x70/0x1d4
>     LR = do_softirq+0x58/0x5c
> [c23fde40] [c22410c4] __napi_schedule+0x30/0x58 (unreliable)
> [c23fde90] [c2006678] do_softirq+0x58/0x5c
> [c23fdea0] [c202acb4] irq_exit+0x48/0x58
> [c23fdeb0] [c2006730] do_IRQ+0xb4/0xd8
> [c23fded0] [c201199c] ret_from_except+0x0/0x14
> --- Exception: 501 at cpu_idle+0x9c/0xe0
>     LR = cpu_idle+0x9c/0xe0
> [c23fdf90] [c2009964] cpu_idle+0xd0/0xe0 (unreliable)
> [c23fdfb0] [c2003e58] rest_init+0x5c/0x84
> [c23fdfc0] [c23a983c] start_kernel+0x234/0x2bc
> [c23fdff0] [02003438] 0x2003438
> Instruction dump:
> 7c0802a6 bf010010 7c9e2378 7c7d1b78 90010034 80040004 70090020 40820010 
> 7c0000a6 60008000 7c000124 3d20c240 <3d60c240> 3b099020 3b2b9040 3b400000 
> BUG: soft lockup - CPU#0 stuck for 61s! [swapper:0]
> 

