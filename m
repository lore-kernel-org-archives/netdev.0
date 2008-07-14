From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Mon, 14 Jul 2008 11:16:53 +0300
Message-ID: <487B0B75.1070506@embedded-sol.com>
References: <4866211E.6040704@embedded-sol.com> <36D9DB17C6DE9E40B059440DB8D95F5205953CF7@orsmsx418.amr.corp.intel.com> <487AFE97.8090107@embedded-sol.com> <200807140947.46733.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:43311 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbYGNIRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 04:17:09 -0400
In-Reply-To: <200807140947.46733.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stefan

I first tried linux-2.6-denx-0d541371126dc3598cfa45a17a0bf34a5757ad46,
but e1000e driver failed to load since it was unable to perform ioremap=
().
So I switched to linux-2.6.26-rc from kernel.org . Below is boot log.

CPU: AMCC PowerPC 460EX Rev. A at 600 MHz (PLB=3D200, OPB=3D100, EBC=3D=
100 MHz)
Security/Kasumi support
Bootstrap Option H - Boot ROM Location I2C (Addr 0x52)
Internal PCI arbiter disabled
32 kB I-Cache 32 kB D-Cache
Board: Canyonlands - AMCC PPC460EX Evaluation Board, 2*PCIe, Rev. 14
I2C: ready
DTT: 1 is 52 C
DRAM: 512 MB (ECC not enabled, 400 MHz, CL3)
=46LASH: 64 MB
NAND: 128 MiB
PCI: Bus Dev VenId DevId Class Int
PCIE0: successfully set as root-complex
02 00 8086 10b9 0200 00
01 00 aaa0 bed0 0604 00
PCIE1: link is not up.
PCIE1: initialization as root-complex failed
Net: ppc_4xx_eth0, ppc_4xx_eth1

Type run flash_nfs to mount root filesystem over NFS

Hit any key to stop autoboot: 0
Waiting for PHY auto negotiation to complete.. done
ENET Speed is 100 Mbps - FULL duplex connection (EMAC0)
BOOTP broadcast 1
DHCP client bound to address 10.0.0.30
ENET Speed is 100 Mbps - FULL duplex connection (EMAC0)
Using ppc_4xx_eth0 device
TFTP from server 10.0.0.1; our IP address is 10.0.0.30
=46ilename 'canyonlands/uImage'.
Load address: 0x200000
Loading: ##############################################################=
###
##########################
done
Bytes transferred =3D 1326780 (143ebc hex)
ENET Speed is 100 Mbps - FULL duplex connection (EMAC0)
Using ppc_4xx_eth0 device
TFTP from server 10.0.0.1; our IP address is 10.0.0.30
=46ilename 'canyonlands/canyonlands.dtb'.
Load address: 0xfc1e0000
Loading: #
done
Bytes transferred =3D 11597 (2d4d hex)
## Booting kernel from Legacy Image at 00200000 ...
Image Name: Linux-2.6.26-rc9
Created: 2008-07-13 9:56:47 UTC
Image Type: PowerPC Linux Kernel Image (gzip compressed)
Data Size: 1326716 Bytes =3D 1.3 MB
Load Address: 00000000
Entry Point: 00000000
Verifying Checksum ... OK
Uncompressing Kernel Image ... OK
## Flattened Device Tree blob at fc1e0000
Booting using the fdt blob at 0xfc1e0000
Loading Device Tree to 007fd000, end 007ff70f ... OK

Using Canyonlands machine description
Linux version 2.6.26-rc9 (felix@felix.lan) (gcc version 4.2.2) #9 Sun=20
Jul 13 12:
56:44 IDT 2008
=46ound legacy serial port 0 for /plb/opb/serial@ef600300
mem=3D4ef600300, taddr=3D4ef600300, irq=3D0, clk=3D7407407, speed=3D0
=46ound legacy serial port 1 for /plb/opb/serial@ef600400
mem=3D4ef600400, taddr=3D4ef600400, irq=3D0, clk=3D7407407, speed=3D0
=46ound legacy serial port 2 for /plb/opb/serial@ef600500
mem=3D4ef600500, taddr=3D4ef600500, irq=3D0, clk=3D7407407, speed=3D0
=46ound legacy serial port 3 for /plb/opb/serial@ef600600
mem=3D4ef600600, taddr=3D4ef600600, irq=3D0, clk=3D7407407, speed=3D0
Entering add_active_range(0, 0, 131072) 0 entries of 256 used
Top of RAM: 0x20000000, Total RAM: 0x20000000
Memory hole size: 0MB
Zone PFN ranges:
DMA 0 -> 131072
Normal 131072 -> 131072
HighMem 131072 -> 131072
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
0: 0 -> 131072
On node 0 totalpages: 131072
DMA zone: 1024 pages used for memmap
DMA zone: 0 pages reserved
DMA zone: 130048 pages, LIFO batch:31
Normal zone: 0 pages used for memmap
HighMem zone: 0 pages used for memmap
Movable zone: 0 pages used for memmap
Built 1 zonelists in Zone order, mobility grouping on. Total pages: 130=
048
Kernel command line: console=3DttyS0,115200 root=3D/dev/nfs rw ip=3Dany
UIC0 (32 IRQ sources) at DCR 0xc0
UIC1 (32 IRQ sources) at DCR 0xd0
UIC2 (32 IRQ sources) at DCR 0xe0
UIC3 (32 IRQ sources) at DCR 0xf0
PID hash table entries: 2048 (order: 11, 8192 bytes)
time_init: decrementer frequency =3D 600.000007 MHz
time_init: processor frequency =3D 600.000007 MHz
clocksource: timebase mult[6aaaab] shift[22] registered
clockevent: decrementer mult[9999] shift[16] cpu[0]
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
High memory: 0k
Memory: 516608k/524288k available (2608k kernel code, 7408k reserved,=20
100k data,
139k bss, 144k init)
SLUB: Genslabs=3D10, HWalign=3D32, Order=3D0-3, MinObjects=3D0, CPUs=3D=
1, Nodes=3D1
Calibrating delay loop... 1196.03 BogoMIPS (lpj=3D2392064)
Mount-cache hash table entries: 512
net_namespace: 192 bytes
NET: Registered protocol family 16
256k L2-cache enabled
PCIE0: Checking link...
PCIE0: Device detected, waiting for link...
PCIE0: link is up !
PCI host bridge /plb/pciex@d00000000 (primary) ranges:
MEM 0x0000000e00000000..0x0000000e7fffffff -> 0x0000000080000000
IO 0x0000000f80000000..0x0000000f8000ffff -> 0x0000000000000000
4xx PCI DMA offset set to 0x00000000
PCIE0: successfully set as root-complex
PCIE1: Checking link...
PCIE1: No device detected.
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
IO window: 0000-0fff
MEM window: 0x80000000-0x800fffff
PREFETCH window: 0x0000000080100000-0x00000000801fffff
PCI: Bridge: 0001:80:00.0
IO window: disabled.
MEM window: disabled.
PREFETCH window: disabled.
NET: Registered protocol family 2
Switched to high resolution mode on CPU 0
IP route cache hash table entries: 16384 (order: 4, 65536 bytes)
TCP established hash table entries: 65536 (order: 7, 524288 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 65536 bind 65536)
TCP reno registered
NET: Registered protocol family 1
JFFS2 version 2.2. (NAND) (SUMMARY) ?=A9 2001-2006 Red Hat, Inc.
msgmni has been set to 1009
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:40:00.0:pcie00]
Allocate Port Service[0000:40:00.0:pcie01]
assign_interrupt_mode Found MSI capability
Allocate Port Service[0001:80:00.0:pcie00]
Allocate Port Service[0001:80:00.0:pcie01]
aer_probe: Request ISR fails on PCIE device[0000:40:00.0:pcie01]
aer: probe of 0000:40:00.0:pcie01 failed with error -38
aer_probe: Request ISR fails on PCIE device[0001:80:00.0:pcie01]
aer: probe of 0001:80:00.0:pcie01 failed with error -38
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enable=
d
serial8250.0: ttyS0 at MMIO 0x4ef600300 (irq =3D 19) is a 16550A
console [ttyS0] enabled
serial8250.0: ttyS1 at MMIO 0x4ef600400 (irq =3D 20) is a 16550A
serial8250.0: ttyS2 at MMIO 0x4ef600500 (irq =3D 29) is a 16550A
serial8250.0: ttyS3 at MMIO 0x4ef600600 (irq =3D 21) is a 16550A
4ef600300.serial: ttyS0 at MMIO 0x4ef600300 (irq =3D 19) is a 16550A
4ef600400.serial: ttyS1 at MMIO 0x4ef600400 (irq =3D 20) is a 16550A
4ef600500.serial: ttyS2 at MMIO 0x4ef600500 (irq =3D 29) is a 16550A
4ef600600.serial: ttyS3 at MMIO 0x4ef600600 (irq =3D 21) is a 16550A
brd: module loaded
PPC 4xx OCP EMAC driver, version 3.54
MAL v2 /plb/mcmal, 2 TX channels, 16 RX channels
ZMII /plb/opb/emac-zmii@ef600d00 initialized
RGMII /plb/opb/emac-rgmii@ef601500 initialized with MDIO support
TAH /plb/opb/emac-tah@ef601350 initialized
TAH /plb/opb/emac-tah@ef601450 initialized
/plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
eth0: EMAC-0 /plb/opb/ethernet@ef600e00, MAC 00:10:ec:00:f9:f8
eth0: found Generic MII PHY (0x00)
/plb/opb/emac-rgmii@ef601500: input 1 in RGMII mode
eth1: EMAC-1 /plb/opb/ethernet@ef600f00, MAC 00:10:ec:80:f9:f8
eth1: found Generic MII PHY (0x01)
4cc000000.nor_flash: Found 1 x16 devices at 0x0 in 16-bit bank
Amd/Fujitsu Extended Query Table at 0x0040
4cc000000.nor_flash: CFI does not contain boot bank location. Assuming =
top.
number of CFI chips: 1
cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness=
=2E
RedBoot partition parsing not available
Creating 7 MTD partitions on "4cc000000.nor_flash":
0x00000000-0x001e0000 : "kernel"
0x001e0000-0x00200000 : "dtb"
0x00200000-0x01600000 : "ramdisk"
0x01600000-0x01a00000 : "jffs2"
0x01a00000-0x03f60000 : "user"
0x03f60000-0x03fa0000 : "env"
0x03fa0000-0x04000000 : "u-boot"
i2c /dev entries driver
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
eth0: link is down
eth1: link is down
Sending DHCP requests .<6>eth0: link is up, 100 FDX, pause enabled
=2E, OK
IP-Config: Got DHCP answer from 10.0.0.1, my address is 10.0.0.30
IP-Config: Complete:
device=3Deth0, addr=3D10.0.0.30, mask=3D255.0.0.0, gw=3D255.255.255.255=
,
host=3DCanyonlands, domain=3D, nis-domain=3D(none),
bootserver=3D10.0.0.1, rootserver=3D10.0.0.1, rootpath=3D/nfsroot
Looking up port of RPC 100003/2 on 10.0.0.1
Looking up port of RPC 100005/1 on 10.0.0.1
VFS: Mounted root (nfs filesystem).
=46reeing unused kernel memory: 144k init
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:41:00.0: enabling device (0006 -> 0007)
eth2: (PCI Express:2.5GB/s:Width x1) 00:1b:21:1e:2d:2a
eth2: Intel(R) PRO/1000 Network Connection
eth2: MAC: 1, PHY: 4, PBA No: d50854-003


Stefan Roese wrote:
> Felix,
>
> On Monday 14 July 2008, Felix Radensky wrote:
>  =20
>> I'm CC-ing Stefan, who ported Linux to this platform.
>>
>> Applying the patch you suggested did not help. I'm still getting TX =
unit
>> hangs. I don't see any netdev watchdog messages. When the hang occur=
s
>> I cannot get the prompt, so I cannot run ethtool.
>>
>> The following command works always
>>
>> dd if=3D/dev/zero of=3D/mnt/test bs=3D512 count=3D2
>>
>> and the following causes Tx unit hang
>>
>>  dd if=3D/dev/zero of=3D/mnt/test bs=3D512 count=3D3
>>
>> Stefan, are you aware of any PCIe related problems on Canyonlands ?
>> AMCC have compatibility chart on their site, which indicates that th=
is
>> particular card (Intel PRO/1000 T Desktop Adapter) Iwas tested with
>> linux-2.6.25 kernel.
>>    =20
>
> What Linux kernel version did you use? From kernel.org or from the=20
> linux-2.6-denx repository? Please send the complete bootup log includ=
ing=20
> U-Boot startup log.
>
> Thanks.
>
> Best regards,
> Stefan
>  =20

