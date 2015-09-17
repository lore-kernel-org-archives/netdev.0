From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/3] net: Add FIB table id to rtable
Date: Thu, 17 Sep 2015 15:43:33 +0900
Message-ID: <20150917064333.GA3128@verge.net.au>
References: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
 <1441227516-39692-2-git-send-email-dsa@cumulusnetworks.com>
 <20150915.120159.1078660839581843586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org, tgraf@suug.ch,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150915.120159.1078660839581843586.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cc: linux-sh@vger.kernel.org]

On Tue, Sep 15, 2015 at 12:01:59PM -0700, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed,  2 Sep 2015 13:58:35 -0700
> 
> > Add the FIB table id to rtable to make the information available for
> > IPv4 as it is for IPv6.
> > 
> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Applied.

Unfortunately I have observed the following when booting the koelsch board
which is based on the Renesas ARM r8a7791 SoC. The kernel was complied
using the shmobile_defconfig.

I also see this problem in net-next (37d2dbcdcca8) and next-20150917.

Booting Linux on physical CPU 0x0
Linux version 4.2.0-11171-gb7503e0cdb5d (horms@ayumi.isobedori.kobe.vergenet.net) (gcc version 4.6.3 (GCC) ) #6130 SMP Thu Sep 17 15:33:06 JST 2015
CPU: ARMv7 Processor [413fc0f2] revision 2 (ARMv7), cr=10c5307d
CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
Machine model: Koelsch
Ignoring memory block 0x200000000 - 0x240000000
debug: ignoring loglevel setting.
Memory policy: Data cache writealloc
On node 0 totalpages: 262144
free_area_init_node: node 0, pgdat c06b5a40, node_mem_map eeff9000
  Normal zone: 1520 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 194560 pages, LIFO batch:31
  HighMem zone: 67584 pages, LIFO batch:15
PERCPU: Embedded 10 pages/cpu @eefc0000 s17984 r0 d22976 u40960
pcpu-alloc: s17984 r0 d22976 u40960 alloc=10*4096
pcpu-alloc: [0] 0 [0] 1 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 260624
Kernel command line: ignore_loglevel rw root=/dev/nfs ip=dhcp
PID hash table entries: 4096 (order: 2, 16384 bytes)
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1032232K/1048576K available (4935K kernel code, 244K rwdata, 1356K rodata, 304K init, 204K bss, 16344K reserved, 0K cma-reserved, 270336K highmem)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
    vmalloc : 0xf0000000 - 0xff000000   ( 240 MB)
    lowmem  : 0xc0000000 - 0xef800000   ( 760 MB)
    pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
      .text : 0xc0008000 - 0xc062dfec   (6296 kB)
      .init : 0xc062e000 - 0xc067a000   ( 304 kB)
      .data : 0xc067a000 - 0xc06b7340   ( 245 kB)
       .bss : 0xc06ba000 - 0xc06ed314   ( 205 kB)
Hierarchical RCU implementation.
        Build-time adjustment of leaf fanout to 32.
        RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=2.
RCU: Adjusting geometry for rcu_fanout_leaf=32, nr_cpu_ids=2
NR_IRQS:16 nr_irqs:16 16
Architected cp15 timer(s) running at 10.00MHz (virt).
clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x24e6a1710, max_idle_ns: 440795202120 ns
sched_clock: 56 bits at 10MHz, resolution 100ns, wraps every 4398046511100ns
Switching to timer-based delay loop, resolution 100ns
Console: colour dummy device 80x30
console [tty0] enabled
Calibrating delay loop (skipped), value calculated using timer frequency.. 20.00 BogoMIPS (lpj=100000)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
CPU: Testing write buffer coherency: ok
CPU0: update cpu_capacity 1024
CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
Setting up static identity map for 0x40009000 - 0x40009058
Unable to boot CPU1 when MD21 is set
CPU1: failed to boot: -524
Brought up 1 CPUs
SMP: Total of 1 processors activated (20.00 BogoMIPS).
CPU: All CPU(s) started in SVC mode.
devtmpfs: initialized
VFP support v0.3: implementor 41 architecture 4 part 30 variant f rev 0
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
pinctrl core: initialized pinctrl subsystem
NET: Registered protocol family 16
DMA: preallocated 256 KiB pool for atomic coherent allocations
renesas_irqc e61c0000.interrupt-controller: driving 10 irqs
sh-pfc e6060000.pfc: r8a77910_pfc support registered
No ATAGs?
hw-breakpoint: found 5 (+1 reserved) breakpoint and 4 watchpoint registers.
hw-breakpoint: maximum watchpoint size is 8 bytes.
IRQ2 is asserted, installing da9063/da9210 regulator quirk
gpio-regulator regulator@1: Could not obtain regulator setting GPIOs: -517
gpio-regulator regulator@3: Could not obtain regulator setting GPIOs: -517
gpio-regulator regulator@5: Could not obtain regulator setting GPIOs: -517
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
i2c 6-0058: Masking da9063 interrupt sources
i2c 6-0068: Masking da9210 interrupt sources
i2c 6-0068: IRQ2 is not asserted, removing quirk
i2c-sh_mobile e60b0000.i2c: I2C adapter 6, bus speed 100000 Hz
media: Linux media interface: v0.10
Linux video capture interface: v2.00
sh_cmt ffca0000.timer: ch0: used for clock events
sh_cmt ffca0000.timer: ch1: used as clock source
clocksource: ffca0000.timer: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000000 ns
Advanced Linux Sound Architecture Driver Initialized.
clocksource: Switched to clocksource arch_sys_counter
NET: Registered protocol family 2
TCP established hash table entries: 8192 (order: 3, 32768 bytes)
TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
UDP hash table entries: 512 (order: 2, 16384 bytes)
UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
PCI: CLS 0 bytes, default 64
futex hash table entries: 512 (order: 3, 32768 bytes)
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
nfs4filelayout_init: NFSv4 File Layout Driver Registering...
nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
bounce: pool size: 64 pages
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
gpio_rcar e6050000.gpio: driving 32 GPIOs
gpio_rcar e6051000.gpio: driving 32 GPIOs
gpio_rcar e6052000.gpio: driving 32 GPIOs
gpio_rcar e6053000.gpio: driving 32 GPIOs
gpio_rcar e6054000.gpio: driving 32 GPIOs
gpio_rcar e6055000.gpio: driving 32 GPIOs
gpio_rcar e6055400.gpio: driving 32 GPIOs
gpio_rcar e6055800.gpio: driving 26 GPIOs
pci-rcar-gen2 ee090000.pci: PCI: bus0 revision 11
pci-rcar-gen2 ee090000.pci: PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0xee080000-0xee0810ff]
pci_bus 0000:00: root bus resource [mem 0xee080000-0xee0810ff]
pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]
pci 0000:00:00.0: [1033:0000] type 00 class 0x060000
pci 0000:00:00.0: reg 0x10: [mem 0xee090800-0xee090bff]
pci 0000:00:00.0: reg 0x14: [mem 0x40000000-0x7fffffff pref]
pci 0000:00:01.0: [1033:0035] type 00 class 0x0c0310
pci 0000:00:01.0: reg 0x10: [mem 0x00000000-0x00000fff]
pci 0000:00:01.0: supports D1 D2
pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
pci 0000:00:02.0: [1033:00e0] type 00 class 0x0c0320
pci 0000:00:02.0: reg 0x10: [mem 0x00000000-0x000000ff]
pci 0000:00:02.0: supports D1 D2
pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot
PCI: bus0: Fast back to back transfers disabled
pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00
pci 0000:00:01.0: BAR 0: assigned [mem 0xee080000-0xee080fff]
pci 0000:00:02.0: BAR 0: assigned [mem 0xee081000-0xee0810ff]
pci 0000:00:01.0: enabling device (0140 -> 0142)
pci 0000:00:02.0: enabling device (0140 -> 0142)
pci-rcar-gen2 ee0d0000.pci: PCI: bus0 revision 11
pci-rcar-gen2 ee0d0000.pci: PCI host bridge to bus 0001:01
pci_bus 0001:01: root bus resource [io  0xee0c0000-0xee0c10ff]
pci_bus 0001:01: root bus resource [mem 0xee0c0000-0xee0c10ff]
pci_bus 0001:01: No busn resource found for root bus, will use [bus 01-ff]
pci 0001:01:00.0: [1033:0000] type 00 class 0x060000
pci 0001:01:00.0: reg 0x10: [mem 0xee0d0800-0xee0d0bff]
pci 0001:01:00.0: reg 0x14: [mem 0x40000000-0x7fffffff pref]
pci 0001:01:01.0: [1033:0035] type 00 class 0x0c0310
pci 0001:01:01.0: reg 0x10: [mem 0x00000000-0x00000fff]
pci 0001:01:01.0: supports D1 D2
pci 0001:01:01.0: PME# supported from D0 D1 D2 D3hot
pci 0001:01:02.0: [1033:00e0] type 00 class 0x0c0320
pci 0001:01:02.0: reg 0x10: [mem 0x00000000-0x000000ff]
pci 0001:01:02.0: supports D1 D2
pci 0001:01:02.0: PME# supported from D0 D1 D2 D3hot
PCI: bus1: Fast back to back transfers disabled
pci_bus 0001:01: busn_res: [bus 01-ff] end is updated to 01
pci 0001:01:01.0: BAR 0: assigned [mem 0xee0c0000-0xee0c0fff]
pci 0001:01:02.0: BAR 0: assigned [mem 0xee0c1000-0xee0c10ff]
pci 0001:01:01.0: enabling device (0140 -> 0142)
pci 0001:01:02.0: enabling device (0140 -> 0142)
rcar-pcie fe000000.pcie: PCIe link down
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
SuperH (H)SCI(F) driver initialized
e6e60000.serial: ttySC0 at MMIO 0xe6e60000 (irq = 109, base_baud = 0) is a scif
console [ttySC0] enabled
e6e68000.serial: ttySC1 at MMIO 0xe6e68000 (irq = 110, base_baud = 0) is a scif
[drm] Initialized drm 1.1.0 20060810
[drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[drm] No driver support for vblank timestamp query.
rcar-du feb00000.display: failed to initialize encoder /i2c@e6530000/hdmi@39 (-38), skipping
rcar-du feb00000.display: error: no encoder could be initialized
rcar-du feb00000.display: failed to initialize DRM/KMS (-22)
rcar-du: probe of feb00000.display failed with error -22
da9063 6-0058: Device detected (chip-ID: 0x61, var-ID: 0x30)
scsi host0: sata_rcar
ata1: SATA max UDMA/133 irq 112
renesas_spi e6b10000.spi: DMA available
m25p80 spi0.0: unrecognized JEDEC id bytes: 01,  2, 20
renesas_spi e6b10000.spi: probed
spi_sh_msiof e6e20000.spi: DMA available
libphy: sh_mii: probed
sh-eth ee700000.ethernet eth0: Base address at 0xee700000, 2e:09:0a:00:6d:00, IRQ 111.
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci-pci: EHCI PCI platform driver
ehci-pci 0000:00:02.0: EHCI Host Controller
ehci-pci 0000:00:02.0: new USB bus registered, assigned bus number 1
ehci-pci 0000:00:02.0: irq 123, io mem 0xee081000
ehci-pci 0000:00:02.0: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 1 port detected
ehci-pci 0001:01:02.0: EHCI Host Controller
ehci-pci 0001:01:02.0: new USB bus registered, assigned bus number 2
ehci-pci 0001:01:02.0: irq 124, io mem 0xee0c1000
ehci-pci 0001:01:02.0: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 1 port detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci-pci: OHCI PCI platform driver
ohci-pci 0000:00:01.0: OHCI PCI host controller
ohci-pci 0000:00:01.0: new USB bus registered, assigned bus number 3
ohci-pci 0000:00:01.0: irq 123, io mem 0xee080000
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 1 port detected
ohci-pci 0001:01:01.0: OHCI PCI host controller
ohci-pci 0001:01:01.0: new USB bus registered, assigned bus number 4
ohci-pci 0001:01:01.0: irq 124, io mem 0xee0c0000
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 1 port detected
sh-pfc e6060000.pfc: pin GP_7_23 already requested by ee090000.pci; cannot claim for e6590000.usb
sh-pfc e6060000.pfc: pin-247 (e6590000.usb) status -22
sh-pfc e6060000.pfc: could not request pin 247 (GP_7_23) from group usb0  on device sh-pfc
renesas_usbhs e6590000.usb: Error applying setting, reverse things back
renesas_usbhs e6590000.usb: transceiver found
renesas_usbhs e6590000.usb: gadget probed
phy phy-e6590100.usb-phy.1: phy init failed --> -16
renesas_usbhs e6590000.usb: probed
using random self ethernet address
using random host ethernet address
usb0: HOST MAC a2:df:79:f3:9f:12
usb0: MAC 46:bc:ee:5a:92:9c
using random self ethernet address
using random host ethernet address
g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
g_ether gadget: g_ether ready
renesas_usbhs e6590000.usb: fifo select error
mousedev: PS/2 mouse device common for all mice
i2c /dev entries driver
ata1: link resume succeeded after 1 retries
at24 2-0050: 256 byte 24c02 EEPROM, writable, 16 bytes/write
i2c-rcar e6530000.i2c: probed
adv7180 2-0020: chip found @ 0x20 (e6530000.i2c)
soc-camera-pdrv soc-camera-pdrv.0: Probing soc-camera-pdrv.0
rcar_thermal e61f0000.thermal: 1 sensor probed
sh_mobile_sdhi ee100000.sd: Got CD GPIO
sh_mobile_sdhi ee100000.sd: Got WP GPIO
sh_mobile_sdhi ee140000.sd: Got CD GPIO
sh_mobile_sdhi ee140000.sd: Got WP GPIO
sh_mobile_sdhi ee160000.sd: Got CD GPIO
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
ata1: SATA link down (SStatus 0 SControl 300)
rcar_sound ec500000.sound: probed
NET: Registered protocol family 10
sit: IPv6 over IPv4 tunneling driver
NET: Registered protocol family 17
Key type dns_resolver registered
cpufreq: cpufreq_online: CPU0: Running at unlisted freq: 1300000 KHz
cpufreq: cpufreq_online: CPU0: Unlisted initial frequency changed to: 1312500 KHz
Registering SWP/SWPB emulation handler
sh_mobile_sdhi ee100000.sd: Got CD GPIO
sh_mobile_sdhi ee100000.sd: Got WP GPIO
sh_mobile_sdhi ee100000.sd: mmc0 base at 0xee100000 clock rate 97 MHz
sh_mobile_sdhi ee140000.sd: Got CD GPIO
sh_mobile_sdhi ee140000.sd: Got WP GPIO
sh_mobile_sdhi ee140000.sd: mmc1 base at 0xee140000 clock rate 48 MHz
sh_mobile_sdhi ee160000.sd: Got CD GPIO
sh_mobile_sdhi ee160000.sd: mmc2 base at 0xee160000 clock rate 48 MHz
asoc-simple-card sound: ak4642-hifi <-> ec500000.sound mapping ok
input: keyboard as /devices/platform/keyboard/input/input0
hctosys: unable to open rtc device (rtc0)
sh-eth ee700000.ethernet eth0: attached PHY 1 (IRQ 408) to driver Micrel KSZ8041RNLI
IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
Sending DHCP requests .
mmc2: new high speed SDHC card at address b368
mmcblk0: mmc2:b368 SD08G 7.41 GiB 
 mmcblk0: p1
sh-eth ee700000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
.
Unable to handle kernel NULL pointer dereference at virtual address 00000009
pgd = c0004000
[00000009] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.2.0-11171-gb7503e0cdb5d #6130
Hardware name: Generic R8A7791 (Flattened Device Tree)
task: c067f560 ti: c067a000 task.ti: c067a000
PC is at ip_route_input_noref+0x670/0x774
LR is at dst_init+0xfc/0x11c
pc : [<c04192e8>]    lr : [<c03fdd18>]    psr: 20000113
sp : c067bc70  ip : c067bbf8  fp : c067bd04
r10: 9f03030a  r9 : 00000010  r8 : 00000000
r7 : 00000000  r6 : ffffff8f  r5 : ee122900  r4 : eea02dc0
r3 : 00000001  r2 : 00000100  r1 : 00000200  r0 : ee122900
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5307d  Table: 4000406a  DAC: 00000051
Process swapper/0 (pid: 0, stack limit = 0xc067a210)
Stack: (0xc067bc70 to 0xc067c000)
bc60:                                     00000000 00000000 c004c6e8 c01c76f4
bc80: eefc3c40 eea41188 00000000 00000002 00000000 eea30010 eea02e68 eea28164
bca0: 00000000 00000000 0203030a 9f03030a c067bd04 c067bcc0 c0446b0c c0073a90
bcc0: 9f03030a 00000000 00000001 eea28100 00000000 c067bce0 c03e4764 ee23ea8e
bce0: ee23ea40 eea02dc0 eea35800 eea02e68 eea3585c 00000008 c067bd2c c067bd08
bd00: c041b430 c0418c84 eea35800 c066f774 eea02dc0 eea35848 c067e058 eea35800
bd20: c067bd7c c067bd30 c03ef8a0 c041b034 00000008 00000000 00020423 00000000
bd40: 00000000 eea02dc0 00000000 eea3585c 00000610 eea02dc0 c067d144 eea02dc0
bd60: f01ba020 00000002 000001bd 0000ffff c067bd94 c067bd80 c03f0828 c03ef254
bd80: 00000000 eea02dc0 c067bdc4 c067bd98 c03f0a0c c03f07a8 c001bcdc c001b194
bda0: c001f1d4 c00450e8 eea35800 30000000 eea35800 30000000 c067bdd4 c067bdc8
bdc0: c03f4860 c03f0980 c067be34 c067bdd8 c02e5454 c03f4858 00000000 eefc04f8
bde0: 00000200 00000629 00000040 00000040 00040000 c03904f8 eea35d10 0000003f
be00: 00000040 eea35aa8 c067c100 eea35d10 eefc44c0 c06784c0 2e94c000 00000001
be20: 00000040 0000012c c067be7c c067be38 c03f4fbc c02e51a8 ffff8d60 c067be40
be40: c067be40 c067be40 c067be48 c067be48 c0062a14 00000008 c067c080 00000100
be60: 00000003 c067c08c c06bab80 0000000a c067bec4 c067be80 c002978c c03f4edc
be80: c067beac c067be90 00000003 00000004 ffff8d5f 00200000 c068b104 00000000
bea0: 00000000 ee805000 00000001 c0667a30 413fc0f2 ef7fcc80 c067bedc c067bec8
bec0: c0029b70 c00296c8 000001ad 00000000 c067befc c067bee0 c0062320 c0029af0
bee0: f0002000 c068b100 c067bf20 c067c748 c067bf1c c067bf00 c000a3fc c006229c
bf00: c00108d8 60000113 ffffffff c067bf54 c067bf7c c067bf20 c0013d14 c000a3b4
bf20: 00000000 00000d46 c067bf80 c001f800 c0674324 c067c4b8 c04dbe40 c06ba000
bf40: c0667a30 413fc0f2 ef7fcc80 c067bf7c c067bf80 c067bf70 c00108d4 c00108d8
bf60: 60000113 ffffffff 00000051 c006a1fc c067bf8c c067bf80 c0058878 c00108b0
bf80: c067bfa4 c067bf90 c005898c c0058854 00000000 c06ba000 c067bfb4 c067bfa8
bfa0: c04d3e68 c0058888 c067bff4 c067bfb8 c062ec64 c04d3e08 ffffffff ffffffff
bfc0: 00000000 c062e6c0 00000000 c0667a30 c06ba394 c067c440 c0667a2c c068063c
bfe0: 4000406a 00000000 00000000 c067bff8 4000807c c062e920 00000000 00000000
Backtrace: 
[<c0418c78>] (ip_route_input_noref) from [<c041b430>] (ip_rcv+0x408/0x714)
 r10:00000008 r9:eea3585c r8:eea02e68 r7:eea35800 r6:eea02dc0 r5:ee23ea40
 r4:ee23ea8e
[<c041b028>] (ip_rcv) from [<c03ef8a0>] (__netif_receive_skb_core+0x658/0x6b4)
 r7:eea35800 r6:c067e058 r5:eea35848 r4:eea02dc0
[<c03ef248>] (__netif_receive_skb_core) from [<c03f0828>] (__netif_receive_skb+0x8c/0x94)
 r10:0000ffff r9:000001bd r8:00000002 r7:f01ba020 r6:eea02dc0 r5:c067d144
 r4:eea02dc0
[<c03f079c>] (__netif_receive_skb) from [<c03f0a0c>] (netif_receive_skb_internal+0x98/0xa4)
 r4:eea02dc0 r3:00000000
[<c03f0974>] (netif_receive_skb_internal) from [<c03f4860>] (netif_receive_skb_sk+0x14/0x18)
 r5:30000000 r4:eea35800
[<c03f484c>] (netif_receive_skb_sk) from [<c02e5454>] (sh_eth_poll+0x2b8/0x6a4)
[<c02e519c>] (sh_eth_poll) from [<c03f4fbc>] (net_rx_action+0xec/0x2a4)
 r10:0000012c r9:00000040 r8:00000001 r7:2e94c000 r6:c06784c0 r5:eefc44c0
 r4:eea35d10
[<c03f4ed0>] (net_rx_action) from [<c002978c>] (__do_softirq+0xd0/0x230)
 r10:0000000a r9:c06bab80 r8:c067c08c r7:00000003 r6:00000100 r5:c067c080
 r4:00000008
[<c00296bc>] (__do_softirq) from [<c0029b70>] (irq_exit+0x8c/0xfc)
 r10:ef7fcc80 r9:413fc0f2 r8:c0667a30 r7:00000001 r6:ee805000 r5:00000000
 r4:00000000
[<c0029ae4>] (irq_exit) from [<c0062320>] (__handle_domain_irq+0x90/0xb4)
 r4:00000000 r3:000001ad
[<c0062290>] (__handle_domain_irq) from [<c000a3fc>] (gic_handle_irq+0x54/0x90)
 r7:c067c748 r6:c067bf20 r5:c068b100 r4:f0002000
[<c000a3a8>] (gic_handle_irq) from [<c0013d14>] (__irq_svc+0x54/0x70)
Exception stack(0xc067bf20 to 0xc067bf68)
bf20: 00000000 00000d46 c067bf80 c001f800 c0674324 c067c4b8 c04dbe40 c06ba000
bf40: c0667a30 413fc0f2 ef7fcc80 c067bf7c c067bf80 c067bf70 c00108d4 c00108d8
bf60: 60000113 ffffffff
 r7:c067bf54 r6:ffffffff r5:60000113 r4:c00108d8
[<c00108a4>] (arch_cpu_idle) from [<c0058878>] (default_idle_call+0x30/0x34)
[<c0058848>] (default_idle_call) from [<c005898c>] (cpu_startup_entry+0x110/0x194)
[<c005887c>] (cpu_startup_entry) from [<c04d3e68>] (rest_init+0x6c/0x84)
 r7:c06ba000 r3:00000000
[<c04d3dfc>] (rest_init) from [<c062ec64>] (start_kernel+0x350/0x3bc)
[<c062e914>] (start_kernel) from [<4000807c>] (0x4000807c)
 r10:00000000 r8:4000406a r7:c068063c r6:c0667a2c r5:c067c440 r4:c06ba394
Code: e3a03001 e5c5305e e51b303c e3530000 (15933008) 
---[ end trace 5453db8891a6d7c6 ]---
Kernel panic - not syncing: Fatal exception in interrupt
---[ end Kernel panic - not syncing: Fatal exception in interrupt

