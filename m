From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#584238: linux-image-2.6.32-3-486: When using USB to
 Ethernet nework adapter later on get error: blocked for more than 120
 seconds
Date: Thu, 03 Jun 2010 00:24:13 +0100
Message-ID: <1275521053.2870.70.camel@localhost>
References: <20100602144551.2330.64473.reportbug@debian-laptop.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2IClXdjGD6eO4+V/XWBp"
Cc: Petko Manolov <petkan@users.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Paul Chany <csanyipal@gmail.com>, 584238@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38535 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758254Ab0FBXYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 19:24:34 -0400
In-Reply-To: <20100602144551.2330.64473.reportbug@debian-laptop.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2IClXdjGD6eO4+V/XWBp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-06-02 at 16:45 +0200, Paul Chany wrote:
> Package: linux-2.6
> Version: 2.6.32-9
> Severity: normal
> Tags: squeeze
>=20
> When using USB to Ethernet adapter later on get error on console:
>=20
> [11531.988248] INOF: task khubd:618 blocked for more than 120 seconds.
> [11531.988377] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disable=
s this
> message.
> [11531.990656] INFO: task pegasus:1156 blocked for more than 120 seconds.
> [11531.990722] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disable=
s this
> message.
>=20
> After that I can't reconfigure anymore network, nor reboot the system wit=
h the command:=20
> sudo shutdown -t 1 -r now
> because the system hangs forever.
>=20
> It is not help if I unplug and plug in again the network adapter, it is n=
ot recognised by=20
> the kernel anymore.

I'm forwarding this to the pegasus driver developers so they can comment
on it.

Debian kernel version 2.6.32-9 is closely based on stable kernel
2.6.32.9.

Ben.

> -- Package-specific info:
> ** Version:
> Linux version 2.6.32-3-486 (Debian 2.6.32-9) (maks@debian.org) (gcc versi=
on 4.3.4 (Debian 4.3.4-8) ) #1 Thu Feb 25 05:35:13 UTC 2010
>=20
> ** Command line:
> BOOT_IMAGE=3D/boot/vmlinuz-2.6.32-3-486 root=3DUUID=3D127a8e72-b9d4-4a28-=
8aa9-e6cdcb3985c9 ro all_generic_ide quiet
>=20
> ** Not tainted
>=20
> ** Kernel log:
> [    9.225611] PM: Error -22 checking image file
> [    9.225628] PM: Resume from disk failed.
> [    9.414135] EXT3-fs: INFO: recovery required on readonly filesystem.
> [    9.414163] EXT3-fs: write access will be enabled during recovery.
> [   10.688535] kjournald starting.  Commit interval 5 seconds
> [   10.688652] EXT3-fs: recovery complete.
> [   10.710733] EXT3-fs: mounted filesystem with ordered data mode.
> [   14.472786] udev: starting version 154
> [   16.350029] Marking TSC unstable due to TSC halts in idle
> [   16.360220] Switching to clocksource acpi_pm
> [   16.364952] processor LNXCPU:00: registered as cooling_device1
> [   16.973885] ACPI: AC Adapter [ADP1] (on-line)
> [   17.006719] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0D:00/input/input1
> [   17.009207] ACPI: Lid Switch [LID]
> [   17.014108] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input2
> [   17.016375] ACPI: Power Button [PWRF]
> [   17.061928] ACPI: Battery Slot [MBAT] (battery absent)
> [   17.171064] input: PC Speaker as /devices/platform/pcspkr/input/input3
> [   17.264959] psmouse serio1: ID: 12 02 3c
> [   17.988705] input: PS/2 Generic Mouse as /devices/platform/i8042/serio=
1/input/input4
> [   18.017149] NET: Registered protocol family 23
> [   18.052666] yenta_cardbus 0000:00:13.0: CardBus bridge found [1179:000=
1]
> [   18.116480] parport_pc 00:0b: reported by Plug and Play ACPI
> [   18.116647] parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE=
]
> [   18.137705] toshiba_acpi: Toshiba Laptop ACPI Extras version 0.19
> [   18.137734] toshiba_acpi:     HCI method: \_SB_.VALD.GHCI
> [   18.232354] yenta_cardbus 0000:00:13.0: ISA IRQ mask 0x0638, PCI irq 1=
1
> [   18.232382] yenta_cardbus 0000:00:13.0: Socket status: 30000007
> [   18.237856] yenta_cardbus 0000:00:13.1: CardBus bridge found [1179:000=
1]
> [   18.365096] yenta_cardbus 0000:00:13.1: ISA IRQ mask 0x0638, PCI irq 1=
1
> [   18.365127] yenta_cardbus 0000:00:13.1: Socket status: 30000007
> [   18.589661] donauboe 0000:00:11.0: power state changed by ACPI to D0
> [   18.673099] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
> [   18.673147] donauboe 0000:00:11.0: PCI INT A -> Link[LNKC] -> GSI 11 (=
level, low) -> IRQ 11
> [   18.683045] IrDA: Registered device irda0
> [   18.683071] toshoboe: Using multiple tasks
> [   19.942533] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x3a=
f: excluding 0x220-0x22f 0x330-0x337 0x388-0x38f
> [   19.943975] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x3e0-0x4f=
f: clean.
> [   19.946283] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x100-0x3a=
f: excluding 0x220-0x22f 0x330-0x337 0x388-0x38f
> [   19.947698] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x3e0-0x4f=
f: clean.
> [   19.948699] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x820-0x8f=
f: clean.
> [   19.949502] pcmcia_socket pcmcia_socket1: cs: IO port probe 0xc00-0xcf=
7: clean.
> [   19.951565] pcmcia_socket pcmcia_socket1: cs: IO port probe 0xa00-0xaf=
f: clean.
> [   19.952689] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x820-0x8f=
f: clean.
> [   19.953498] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcf=
7: clean.
> [   19.955555] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaf=
f: clean.
> [   22.724794] Adding 176672k swap on /dev/sda8.  Priority:-1 extents:1 a=
cross:176672k=20
> [   23.986386] EXT3 FS on sda1, internal journal
> [   24.322216] device-mapper: uevent: version 1.0.3
> [   24.330289] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialise=
d: dm-devel@redhat.com
> [   25.052483] loop: module loaded
> [   48.955794] kjournald starting.  Commit interval 5 seconds
> [   48.956308] EXT3 FS on sda6, internal journal
> [   48.956349] EXT3-fs: mounted filesystem with ordered data mode.
> [   49.174455] kjournald starting.  Commit interval 5 seconds
> [   49.174926] EXT3 FS on sda7, internal journal
> [   49.174962] EXT3-fs: mounted filesystem with ordered data mode.
> [   49.432381] kjournald starting.  Commit interval 5 seconds
> [   49.432966] EXT3 FS on sda5, internal journal
> [   49.433005] EXT3-fs: mounted filesystem with ordered data mode.
> [   49.665115] kjournald starting.  Commit interval 5 seconds
> [   49.665786] EXT3 FS on sda9, internal journal
> [   49.665823] EXT3-fs: mounted filesystem with ordered data mode.
> [   54.377286] fuse init (API version 7.13)
> [   74.213762] Program wdm tried to access /dev/mem between 100000->10200=
0.
> [  567.364143] usb 1-1: new full speed USB device using ohci_hcd and addr=
ess 2
> [  567.582139] usb 1-1: New USB device found, idVendor=3D07a6, idProduct=
=3D8515
> [  567.582166] usb 1-1: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D3
> [  567.582188] usb 1-1: Product: USB To LAN Converter
> [  567.582205] usb 1-1: Manufacturer: ADMtek
> [  567.582221] usb 1-1: SerialNumber: 0001
> [  567.583936] usb 1-1: configuration #1 chosen from 1 choice
> [  571.013676] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethe=
rnet driver
> [  571.045528] pegasus 1-1:1.0: setup Pegasus II specific registers
> [  571.210220] pegasus 1-1:1.0: eth0, ADMtek ADM8515 "Pegasus II" USB-2.0=
 Ethernet, 00:00:70:01:11:f1
> [  571.211093] usbcore: registered new interface driver pegasus
> [  574.285384] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [  574.285772] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [  574.285887] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [  574.286411] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [  578.781286] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [  585.052090] eth0: no IPv6 routers present
> [ 1947.028159] end_request: I/O error, dev fd0, sector 0
> [ 1947.232118] end_request: I/O error, dev fd0, sector 0
> [ 2105.253068] usb 1-1: USB disconnect, address 2
> [ 2544.772228] usb 1-1: new full speed USB device using ohci_hcd and addr=
ess 3
> [ 2544.990232] usb 1-1: New USB device found, idVendor=3D07a6, idProduct=
=3D8515
> [ 2544.990264] usb 1-1: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D3
> [ 2544.990287] usb 1-1: Product: USB To LAN Converter
> [ 2544.990304] usb 1-1: Manufacturer: ADMtek
> [ 2544.990320] usb 1-1: SerialNumber: 0001
> [ 2544.991871] usb 1-1: configuration #1 chosen from 1 choice
> [ 2545.028225] pegasus 1-1:1.0: setup Pegasus II specific registers
> [ 2545.254633] pegasus 1-1:1.0: eth0, ADMtek ADM8515 "Pegasus II" USB-2.0=
 Ethernet, 00:00:70:01:11:f1
> [ 2556.080650] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [ 2556.081018] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [ 2556.081132] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [ 2556.081408] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [ 2558.463393] pegasus 1-1:1.0: update_eth_regs_async, status -22
> [ 2566.472084] eth0: no IPv6 routers present
>=20
> ** Model information
> not available
>=20
> ** Loaded modules:
> Module                  Size  Used by
> pegasus                14734  0=20
> mii                     2654  1 pegasus
> fuse                   42747  1=20
> loop                    9561  0=20
> dm_crypt                9023  0=20
> dm_mod                 45901  1 dm_crypt
> snd_opl3sa2            10888  1=20
> snd_wss_lib            17401  1 snd_opl3sa2
> snd_pcm_oss            28551  0=20
> snd_mixer_oss          10473  2 snd_pcm_oss
> snd_pcm                46210  2 snd_wss_lib,snd_pcm_oss
> snd_page_alloc          5017  2 snd_wss_lib,snd_pcm
> snd_opl3_lib            6130  1 snd_opl3sa2
> snd_hwdep               4022  1 snd_opl3_lib
> snd_mpu401_uart         4155  1 snd_opl3sa2
> snd_seq_midi            3572  0=20
> snd_rawmidi            12737  2 snd_mpu401_uart,snd_seq_midi
> snd_seq_midi_event      3848  1 snd_seq_midi
> snd_seq                35413  2 snd_seq_midi,snd_seq_midi_event
> snd_timer              12292  4 snd_wss_lib,snd_pcm,snd_opl3_lib,snd_seq
> snd_seq_device          3661  4 snd_opl3_lib,snd_seq_midi,snd_rawmidi,snd=
_seq
> pcmcia                 16438  0=20
> donauboe                6996  0=20
> snd                    34102  12 snd_opl3sa2,snd_wss_lib,snd_pcm_oss,snd_=
mixer_oss,snd_pcm,snd_opl3_lib,snd_hwdep,snd_mpu401_uart,snd_rawmidi,snd_se=
q,snd_timer,snd_seq_device
> toshiba_acpi            4361  0=20
> parport_pc             15783  0=20
> serio_raw               2912  0=20
> yenta_socket           16335  2=20
> irda                   71654  1 donauboe
> rsrc_nonstatic          7061  1 yenta_socket
> parport                22170  1 parport_pc
> soundcore               3294  2 snd
> pcspkr                  1235  0=20
> container               1833  0=20
> rfkill                 10658  1 toshiba_acpi
> battery                 3774  0=20
> crc_ccitt               1039  2 donauboe,irda
> button                  3578  0=20
> ac                      1628  0=20
> psmouse                48174  0=20
> pcmcia_core            20506  3 pcmcia,yenta_socket,rsrc_nonstatic
> evdev                   5520  6=20
> processor              23235  1=20
> ext3                   92724  5=20
> jbd                    27946  1 ext3
> mbcache                 3482  1 ext3
> sg                     16463  0=20
> ohci_hcd               17096  0=20
> ehci_hcd               27716  0=20
> fan                     2590  0=20
> sr_mod                 10734  1=20
> floppy                 41131  0=20
> usbcore                98034  4 pegasus,ohci_hcd,ehci_hcd
> sd_mod                 25733  7=20
> cdrom                  26475  1 sr_mod
> thermal                 9210  0=20
> crc_t10dif              1012  1 sd_mod
> nls_base                4445  1 usbcore
> thermal_sys             9346  3 processor,fan,thermal
> ata_generic             2011  7=20
> libata                115918  1 ata_generic
> scsi_mod              102173  4 sg,sr_mod,sd_mod,libata
>=20
> ** Network interface configuration:
>=20
> auto lo
> iface lo inet loopback
>=20
> allow-hotplug eth0
> iface eth0 inet dhcp
>=20
> ** Network status:
> *** IP interfaces and addresses:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host=20
>        valid_lft forever preferred_lft forever
> 2: irda0: <NOARP> mtu 2048 qdisc noop state DOWN qlen 8
>     link/irda 00:00:00:00 brd ff:ff:ff:ff
> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast stat=
e UP qlen 1000
>     link/ether 00:00:70:01:11:f1 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.10.92/24 brd 192.168.10.255 scope global eth0
>     inet6 fe80::200:70ff:fe01:11f1/64 scope link=20
>        valid_lft forever preferred_lft forever
>=20
> *** Device statistics:
> Inter-|   Receive                                                |  Trans=
mit
>  face |bytes    packets errs drop fifo frame compressed multicast|bytes  =
  packets errs drop fifo colls carrier compressed
>     lo:       0       0    0    0    0     0          0         0        =
0       0    0    0    0     0       0          0
>  irda0:       0       0    0    0    0     0          0         0        =
0       0    0    0    0     0       0          0
>   eth0:  179607     301    0    0    0     0          0         0    2282=
0     231    0    0    0     0       0          0
>=20
> *** Protocol statistics:
> Ip:
>     1833 total packets received
>     4 with invalid addresses
>     0 forwarded
>     0 incoming packets discarded
>     1649 incoming packets delivered
>     1312 requests sent out
>     44 dropped because of missing route
> Icmp:
>     0 ICMP messages received
>     0 input ICMP message failed.
>     ICMP input histogram:
>     0 ICMP messages sent
>     0 ICMP messages failed
>     ICMP output histogram:
> Tcp:
>     33 active connections openings
>     0 passive connection openings
>     0 failed connection attempts
>     16 connection resets received
>     0 connections established
>     1363 segments received
>     1086 segments send out
>     0 segments retransmited
>     0 bad segments received.
>     27 resets sent
> Udp:
>     213 packets received
>     0 packets to unknown port received.
>     0 packet receive errors
>     222 packets sent
> UdpLite:
> TcpExt:
>     1 TCP sockets finished time wait in fast timer
>     33 delayed acks sent
>     923 packets directly queued to recvmsg prequeue.
>     8688 bytes directly in process context from backlog
>     1131509 bytes directly received in process context from prequeue
>     275 packet headers predicted
>     784 packets header predicted and directly queued to user
>     51 acknowledgments not containing data payload received
>     131 predicted acknowledgments
>     1 connections reset due to unexpected data
>     16 connections reset due to early user close
> IpExt:
>     InMcastPkts: 21
>     OutMcastPkts: 25
>     InBcastPkts: 73
>     InOctets: 1695218
>     OutOctets: 106998
>     InMcastOctets: 5451
>     OutMcastOctets: 5611
>     InBcastOctets: 13564
>=20
> *** Device features:
> eth0: 0x0
> irda0: 0x0
> lo: 0x13865
>=20
> ** PCI devices:
> 00:00.0 Host bridge [0600]: Toshiba America Info Systems CPU to PCI bridg=
e [1179:0601] (rev a2)
> 	Subsystem: Toshiba America Info Systems Satellite Pro [1179:0001]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:07.0 Communication controller [0780]: Agere Systems 56k WinModem [11c1=
:0441] (rev 01)
> 	Subsystem: Toshiba America Info Systems Internal V.90 Modem [1179:0001]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0 (63000ns min, 3500ns max)
> 	Interrupt: pin A routed to IRQ 3
> 	Region 0: Memory at ffefff00 (32-bit, non-prefetchable) [size=3D256]
> 	Region 1: I/O ports at 02f8 [size=3D8]
> 	Region 2: I/O ports at 1c00 [size=3D256]
> 	Capabilities: <access denied>
>=20
> 00:08.0 VGA compatible controller [0300]: S3 Inc. ViRGE/MX [5333:8c01] (r=
ev 06) (prog-if 00 [VGA controller])
> 	Subsystem: Toshiba America Info Systems ViRGE/MX [1179:0001]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0 (1000ns min, 63750ns max)
> 	Region 0: Memory at f8000000 (32-bit, non-prefetchable) [size=3D64M]
> 	Expansion ROM at 18000000 [disabled] [size=3D64K]
>=20
> 00:0b.0 USB Controller [0c03]: NEC Corporation USB [1033:0035] (rev 02) (=
prog-if 10 [OHCI])
> 	Subsystem: Toshiba America Info Systems USB [1179:0001]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR+ INTx-
> 	Latency: 64 (250ns min, 5250ns max)
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at f7fff000 (32-bit, non-prefetchable) [size=3D4K]
> 	Kernel driver in use: ohci_hcd
> 	Kernel modules: ohci-hcd
>=20
> 00:10.0 IDE interface [0101]: Toshiba America Info Systems Extended IDE C=
ontroller [1179:0102] (rev 34) (prog-if f0)
> 	Subsystem: Toshiba America Info Systems Device [1179:0002]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dslow >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (500ns min, 10000ns max)
> 	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=
=3D8]
> 	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=
=3D1]
> 	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=
=3D8]
> 	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [size=
=3D1]
> 	Region 4: I/O ports at 1800 [size=3D16]
> 	Kernel driver in use: ata_generic
> 	Kernel modules: ata_generic, ide-pci-generic
>=20
> 00:11.0 Communication controller [0780]: Toshiba America Info Systems FIR=
 Port Type-O [1179:0701] (rev 23)
> 	Subsystem: Toshiba America Info Systems Device [1179:0001]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dslow >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: I/O ports at ffe0 [size=3D32]
> 	Kernel driver in use: donauboe
> 	Kernel modules: donauboe
>=20
> 00:13.0 CardBus bridge [0607]: Toshiba America Info Systems ToPIC97 [1179=
:060f] (rev 07)
> 	Subsystem: Toshiba America Info Systems Satellite 4010 [1179:0001]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dslow >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at 18010000 (32-bit, non-prefetchable) [size=3D4K]
> 	Bus: primary=3D00, secondary=3D01, subordinate=3D04, sec-latency=3D0
> 	Memory window 0: 08000000-0bfff000 (prefetchable)
> 	Memory window 1: 0c000000-0ffff000
> 	I/O window 0: 00001000-000010ff
> 	I/O window 1: 00001400-000014ff
> 	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
> 	16-bit legacy interface ports at 0001
> 	Kernel driver in use: yenta_cardbus
> 	Kernel modules: yenta_socket
>=20
> 00:13.1 CardBus bridge [0607]: Toshiba America Info Systems ToPIC97 [1179=
:060f] (rev 07)
> 	Subsystem: Toshiba America Info Systems Satellite 4010 [1179:0001]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dslow >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 11
> 	Region 0: Memory at 18011000 (32-bit, non-prefetchable) [size=3D4K]
> 	Bus: primary=3D00, secondary=3D05, subordinate=3D08, sec-latency=3D0
> 	Memory window 0: 10000000-13fff000 (prefetchable)
> 	Memory window 1: 14000000-17fff000
> 	I/O window 0: 00002000-000020ff
> 	I/O window 1: 00002400-000024ff
> 	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
> 	16-bit legacy interface ports at 0001
> 	Kernel driver in use: yenta_cardbus
> 	Kernel modules: yenta_socket
>=20
>=20
> ** USB devices:
> Bus 001 Device 003: ID 07a6:8515 ADMtek, Inc. AN8515 Ethernet
> Bus 001 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
>=20
>=20
> -- System Information:
> Debian Release: squeeze/sid
>   APT prefers testing
>   APT policy: (500, 'testing')
> Architecture: i386 (i586)
>=20
> Kernel: Linux 2.6.32-3-486
> Locale: LANG=3Dhu_HU.UTF-8, LC_CTYPE=3Dhu_HU.UTF-8 (charmap=3DUTF-8)
> Shell: /bin/sh linked to /bin/dash
>=20
> Versions of packages linux-image-2.6.32-3-486 depends on:
> ii  debconf [debconf-2.0]        1.5.32      Debian configuration managem=
ent sy
> ii  initramfs-tools [linux-initr 0.94.4      tools for generating an init=
ramfs
> ii  module-init-tools            3.12~pre2-3 tools for managing Linux ker=
nel mo
>=20
> Versions of packages linux-image-2.6.32-3-486 recommends:
> ii  firmware-linux-free           2.6.32-9   Binary firmware for various =
driver
>=20
> Versions of packages linux-image-2.6.32-3-486 suggests:
> ii  grub                          0.97-61    GRand Unified Bootloader (du=
mmy pa
> pn  linux-doc-2.6.32              <none>     (no description available)
>=20
> Versions of packages linux-image-2.6.32-3-486 is related to:
> pn  firmware-bnx2                 <none>     (no description available)
> pn  firmware-bnx2x                <none>     (no description available)
> pn  firmware-ipw2x00              <none>     (no description available)
> pn  firmware-ivtv                 <none>     (no description available)
> pn  firmware-iwlwifi              <none>     (no description available)
> pn  firmware-linux                <none>     (no description available)
> pn  firmware-linux-nonfree        <none>     (no description available)
> pn  firmware-qlogic               <none>     (no description available)
> pn  firmware-ralink               <none>     (no description available)
>=20
> -- debconf information:
>   shared/kernel-image/really-run-bootloader: true
>   linux-image-2.6.32-3-486/prerm/removing-running-kernel-2.6.32-3-486: tr=
ue
>   linux-image-2.6.32-3-486/postinst/bootloader-error-2.6.32-3-486:
>   linux-image-2.6.32-3-486/postinst/missing-firmware-2.6.32-3-486:
>   linux-image-2.6.32-3-486/postinst/bootloader-test-error-2.6.32-3-486:
>   linux-image-2.6.32-3-486/postinst/depmod-error-initrd-2.6.32-3-486: fal=
se
>   linux-image-2.6.32-3-486/prerm/would-invalidate-boot-loader-2.6.32-3-48=
6: true
>=20
>=20
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-2IClXdjGD6eO4+V/XWBp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATAboHOe/yOyVhhEJAQLlmA/9FDPBz2YrilJaa18c6VXfknU4EUNJ67LR
nM8Cgi/jjP265KoyD8VZmqrAi0jB8vxoBKcPu8o9hA6XznHG8bBDyyyrOA6Pb5Lm
a3YFUUFDCI45lz8nL1fSedzWzuXdGSeoEA6N2SpnEK6N486FtuSqL6ZcYxhNOKDD
wjPKJdHwF3DTtrtqNcL4N55eaD+rlQnxW3PsBE9Gjs4iztP1+UfXvsqQVCLnEQBM
E83/x/B8VWHChiSj/4wWRf6d7c7uKqHWGj4XEuUC0BMmhG/VJEVJYg0tatqjy6gt
QmZbmQ6comUoVevuvm/h97qRn+wZRYXOjOdJEQzg1fASPzm2Tw9bI9/Gq7mE993d
uJ2PF8msr30CHlQQcuTef5uk/E3UV6bUaD8k2gb7dO88SEPCPwQ2Eqg97BGj8eFu
HxbIvSOaS3uR4br7kdLy3HEjzFl/cOK1rvgZg1iSg2lDYJiRdjLCf9ecIZw4cR5n
oZhlYB9SgkHZERZSrkxFgsakevDsGww8fLT316qBWwHSiQH+dnqcb7u0NcIKZw2W
uXa2PSBimyF5MZ7Iobt/Tgac6vvYY6H0Cp9Bhi6/IloJq4vgtUotKpjXHKZcH2Tm
XKvGJ+S6yutAb7TSCcA8aZETm2vneC7zTcz4kYVq0ksQ9UOjaas+y+R/D9AAVAzd
xEmFdnn5P0M=
=yaJe
-----END PGP SIGNATURE-----

--=-2IClXdjGD6eO4+V/XWBp--
