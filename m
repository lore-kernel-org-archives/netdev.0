From: Stefan Roese <sr@denx.de>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Fri, 18 Jul 2008 17:44:45 +0200
Message-ID: <200807181744.46058.sr@denx.de>
References: <4866211E.6040704@embedded-sol.com> <200807181655.54760.sr@denx.de> <4880B88A.6060201@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:60671 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbYGRPpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 11:45:06 -0400
In-Reply-To: <4880B88A.6060201@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Felix,

On Friday 18 July 2008, Felix Radensky wrote:
> Are you sure your NFS root is mounted via e1000e ?

Yes!

> I cannot complete the 
> boot
> with 2.6.26 release if e1000e is compiled into the kernel and on-board
> NICs disconnected.
> This is what I get:

## Flattened Device Tree blob at 00800000
   Booting using the fdt blob at 0x800000
   Loading Device Tree to 007fa000, end 007ff70f ... OK
debug: ignoring loglevel setting.
Using Canyonlands machine description
Linux version 2.6.26 (stefan@kubuntu) (gcc version 4.2.2) #2 Fri Jul 18 16:46:00 CEST 
2008
Found legacy serial port 0 for /plb/opb/serial@ef600300
  mem=4ef600300, taddr=4ef600300, irq=0, clk=7407407, speed=0
Found legacy serial port 1 for /plb/opb/serial@ef600400
  mem=4ef600400, taddr=4ef600400, irq=0, clk=7407407, speed=0
Found legacy serial port 2 for /plb/opb/serial@ef600500
  mem=4ef600500, taddr=4ef600500, irq=0, clk=7407407, speed=0
Found legacy serial port 3 for /plb/opb/serial@ef600600
  mem=4ef600600, taddr=4ef600600, irq=0, clk=7407407, speed=0
Entering add_active_range(0, 0, 131072) 0 entries of 256 used
Top of RAM: 0x20000000, Total RAM: 0x20000000
Memory hole size: 0MB
Zone PFN ranges:
  DMA             0 ->   131072
  Normal     131072 ->   131072
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->   131072
On node 0 totalpages: 131072
  DMA zone: 1024 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 130048 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 130048
Kernel command line: root=/dev/nfs rw nfsroot=10.0.0.152:/opt/eldk/ppc_4xxFP 
ip=10.0.0.182:10.0.0.152:::canyonlands:eth0:off panic=1 console=ttyS0,115200 
ignore_loglevel
UIC0 (32 IRQ sources) at DCR 0xc0
UIC1 (32 IRQ sources) at DCR 0xd0
UIC2 (32 IRQ sources) at DCR 0xe0
UIC3 (32 IRQ sources) at DCR 0xf0
PID hash table entries: 2048 (order: 11, 8192 bytes)
time_init: decrementer frequency = 600.000007 MHz
time_init: processor frequency   = 600.000007 MHz
clocksource: timebase mult[6aaaab] shift[22] registered
clockevent: decrementer mult[9999] shift[16] cpu[0]
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 516864k/524288k available (2404k kernel code, 7176k reserved, 100k data, 125k 
bss, 140k init)
SLUB: Genslabs=10, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Calibrating delay loop... 1196.03 BogoMIPS (lpj=2392064)
Mount-cache hash table entries: 512
net_namespace: 192 bytes
NET: Registered protocol family 16
PCIE0: Checking link...
PCIE0: No device detected.
PCI host bridge /plb/pciex@d00000000 (primary) ranges:
 MEM 0x0000000e00000000..0x0000000e7fffffff -> 0x0000000080000000
  IO 0x0000000f80000000..0x0000000f8000ffff -> 0x0000000000000000
4xx PCI DMA offset set to 0x00000000
PCIE0: successfully set as root-complex
PCIE1: Checking link...
PCIE1: Device detected, waiting for link...
PCIE1: link is up !
PCI host bridge /plb/pciex@d20000000 (primary) ranges:
 MEM 0x0000000e80000000..0x0000000effffffff -> 0x0000000080000000
  IO 0x0000000f80010000..0x0000000f8001ffff -> 0x0000000000000000
4xx PCI DMA offset set to 0x00000000
PCIE1: successfully set as root-complex
PCI host bridge /plb/pci@c0ec00000 (primary) ranges:
 MEM 0x0000000d80000000..0x0000000dffffffff -> 0x0000000080000000
  IO 0x0000000c08000000..0x0000000c0800ffff -> 0x0000000000000000
4xx PCI DMA offset set to 0x00000000
PCI: Probing PCI hardware
PCI: Hiding 4xx host bridge resources 0000:40:00.0
PCI: Hiding 4xx host bridge resources 0001:80:00.0
PCI: Bridge: 0000:40:00.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0001:80:00.0
  IO window: 0000-0fff
  MEM window: 0x80000000-0x800fffff
  PREFETCH window: 0x0000000080100000-0x00000000801fffff
NET: Registered protocol family 2
Switched to high resolution mode on CPU 0
IP route cache hash table entries: 16384 (order: 4, 65536 bytes)
TCP established hash table entries: 65536 (order: 7, 524288 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 65536 bind 65536)
TCP reno registered
NET: Registered protocol family 1
msgmni has been set to 1009
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250.0: ttyS0 at MMIO 0x4ef600300 (irq = 19) is a 16550A
console [ttyS0] enabled
serial8250.0: ttyS1 at MMIO 0x4ef600400 (irq = 20) is a 16550A
serial8250.0: ttyS2 at MMIO 0x4ef600500 (irq = 29) is a 16550A
serial8250.0: ttyS3 at MMIO 0x4ef600600 (irq = 21) is a 16550A
4ef600300.serial: ttyS0 at MMIO 0x4ef600300 (irq = 19) is a 16550A
4ef600400.serial: ttyS1 at MMIO 0x4ef600400 (irq = 20) is a 16550A
4ef600500.serial: ttyS2 at MMIO 0x4ef600500 (irq = 29) is a 16550A
4ef600600.serial: ttyS3 at MMIO 0x4ef600600 (irq = 21) is a 16550A
brd: module loaded
e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0001:81:00.0: enabling device (0006 -> 0007)
eth0: (PCI Express:2.5GB/s:Width x1) 00:1b:21:04:a3:47
eth0: Intel(R) PRO/1000 Network Connection
eth0: MAC: 1, PHY: 4, PBA No: d50854-003
PPC 4xx OCP EMAC driver, version 3.54
MAL v2 /plb/mcmal, 2 TX channels, 16 RX channels
ZMII /plb/opb/emac-zmii@ef600d00 initialized
RGMII /plb/opb/emac-rgmii@ef601500 initialized with MDIO support
TAH /plb/opb/emac-tah@ef601350 initialized
TAH /plb/opb/emac-tah@ef601450 initialized
/plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
eth1: EMAC-0 /plb/opb/ethernet@ef600e00, MAC 00:10:ec:00:f9:ed
eth1: found Generic MII PHY (0x00)
/plb/opb/emac-rgmii@ef601500: input 1 in RGMII mode
eth2: EMAC-1 /plb/opb/ethernet@ef600f00, MAC 00:10:ec:00:f9:ee
eth2: found Generic MII PHY (0x01)
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
IP-Config: Guessing netmask 255.0.0.0
IP-Config: Complete:
     device=eth0, addr=10.0.0.182, mask=255.0.0.0, gw=255.255.255.255,
     host=canyonlands, domain=, nis-domain=(none),
     bootserver=10.0.0.152, rootserver=10.0.0.152, rootpath=
Looking up port of RPC 100003/2 on 10.0.0.152
eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Looking up port of RPC 100005/1 on 10.0.0.152
VFS: Mounted root (nfs filesystem).
Freeing unused kernel memory: 140k init
modprobe: FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or 
directory

modprobe: FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or 
directory

INIT: version 2.86 booting
                Welcome to DENX Embedded Linux Environment
                Press 'I' to enter interactive startup.
modprobe: FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or 
directory

modprobe: FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or 
directory

Cannot access the Hardware Clock via any known method.
Use the --debug option to see the details of our search for an access method.
Setting clock : Thu Jan  1 01:00:06 CET 1970 [  OK  ]
Building the cache [  OK  ]
Setting hostname canyonlands:  [  OK  ]
Mounting local filesystems:  [  OK  ]
Enabling /etc/fstab swaps:  [  OK  ]
INIT: Entering runlevel: 3
Entering non-interactive startup
FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or directory
Bringing up loopback interface:  [  OK  ]
FATAL: Could not load /lib/modules/2.6.26/modules.dep: No such file or directory
Starting system logger: [  OK  ]
Starting kernel logger: [  OK  ]
Starting rpcbind: [  OK  ]
Mounting NFS filesystems:  [  OK  ]
Mounting other filesystems:  [  OK  ]
Starting xinetd: [  OK  ]

DENX ELDK version 4.2 build 2008-02-20
Linux 2.6.26 on a ppc

canyonlands login:


So it works for me. Only difference I can see is that I'm using 1000Mbps and you only 
100. Is this also 2.6.26 release from kernel.org? Which PCIe slot are you using? I'm 
using PCIe1.

Best regards,
Stefan

=====================================================================
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
=====================================================================
