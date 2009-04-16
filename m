From: devzero@web.de
Subject: [RFC] add missing MODULE_DESCRIPTION to drivers/net/*
Date: Thu, 16 Apr 2009 17:32:37 +0200
Message-ID: <673528018@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sam Ravnborg <sam@ravnborg.org>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate05.web.de ([217.72.192.243]:52743 "EHLO
	fmmailgate05.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbZDPPcj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,=20

we would like to add a built-time check for missing MODULE_DESCRIPTION =
(as it exists for MODULE_LICENSE) and currently have >400 modules which=
 are missing that field.

As modinfo should provide necessary basic information about a module to=
 the end-user, it`s bad if he needs the whole kernel-source for getting=
 that information.

Attached is a list of drivers from drivers/net/* currently lacking MODU=
LE_DESCRIPTION.=20

I have created the description, mostly from what`s in Kconfig or the dr=
iver comments.

If welcomed, please could you give a comment if this list is ok or fix =
it appropriately ?=20

I will then create a patch from that and send it here (and continue wit=
h net/* )

regards
Roland Kletzing


drivers/net/8390.o -  8390 core for usual drivers
drivers/net/appletalk/ipddp.o - IP<->Appletalk-IP Encapsulation/Decapsu=
lation driver
drivers/net/arcnet/arc-rawmode.o - ARCnet driver - "raw mode" packet en=
capsulation
drivers/net/arcnet/arc-rimi.o - ARCnet driver for "RIM I" cards
drivers/net/arcnet/arcnet.o - ARCnet driver - device-independent routin=
es
drivers/net/arcnet/capmode.o - ARCnet driver - "cap mode" packet encaps=
ulation
drivers/net/arcnet/com20020-pci.o - ARCnet driver - COM20020 PCI suppor=
t
drivers/net/arcnet/com20020.o - ARCnet driver - COM20020 chipset suppor=
t
drivers/net/arcnet/com90io.o - ARCnet driver - COM90xx chipset
drivers/net/arcnet/com90xx.o - ARCnet driver - COM90xx chipset
drivers/net/arcnet/rfc1051.o - ARCnet driver - RFC1051 ("simple" standa=
rd) packet encapsulation
drivers/net/arcnet/rfc1201.o - ARCnet driver - RFC1201 (standard) packe=
t encapsulation
drivers/net/bsd_comp.o - PPP "BSD compress" compression
drivers/net/de600.o - driver for the D-Link DE-600 Ethernet pocket adap=
ter
drivers/net/de620.o - driver for the D-Link DE-620 Ethernet pocket adap=
ter
drivers/net/dummy.o - dummy net driver
drivers/net/eql.o - Equalizer Load-balancer for serial network interfac=
es
drivers/net/ifb.o - Intermediate Functional Block support
drivers/net/pcmcia/com20020_cs.o - ARCnet driver - COM20020 PCMCIA supp=
ort
drivers/net/pcmcia/ibmtr_cs.o - PCMCIA token-ring driver for IBM-based =
cards
drivers/net/phy/mdio-bitbang.o - Bitbanged MDIO support
drivers/net/plip.o - parallel port "network" driver
drivers/net/ppp_async.o - PPP async serial channel driver
drivers/net/ppp_deflate.o - PPP Deflate compression
drivers/net/ppp_generic.o - Generic PPP layer
drivers/net/ppp_synctty.o - PPP synchronous tty channel driver
drivers/net/s2io.o - Linux PCI-X Ethernet driver for Neterion 10GbE Ser=
ver NIC
drivers/net/skfp/skfp.o - device driver supporting the SysKonnect FDDI =
PCI controller family
drivers/net/slhc.o - Van Jacobsen serial line header compression
drivers/net/slip.o - Serial Line Internet Protocol driver
drivers/net/smsc9420.o - SMSC LAN9420 PCI ethernet adapter driver
drivers/net/sungem_phy.o - PHY drivers for the sungem ethernet driver
drivers/net/tokenring/abyss.o - network driver for the Madge Smart 16/4=
 PCI Mk2 token ring card
drivers/net/tokenring/tms380tr.o - network driver library for Texas Ins=
truments TMS380-based Token Ring Adapters
drivers/net/tokenring/tmspci.o - generic network driver for TMS380-base=
d PCI token ring cards
drivers/net/tulip/de4x5.o - DIGITAL DC21x4x DECchip and DE425/DE434/DE4=
35/DE450/DE500 ethernet driver
drivers/net/wan/lmc/lmc.o - Driver for the LanMedia LMC5200, LMC5245, L=
MC1000, LMC1200 cards
drivers/net/wan/sbni.o - Granch SBNI12 leased line adapters driver
drivers/net/wan/x25_asy.o - X.25 async driver
drivers/net/wireless/netwave_cs.o - Netwave AirSurfer Wireless LAN PC C=
ard driver
drivers/net/wireless/p54/p54spi.o - Prism54 SPI (stlc45xx) driver
drivers/net/wireless/wavelan_cs.o - Wavelan Pcmcia driver




> Von: Sam Ravnborg <sam@ravnborg.org>
> Gesendet: 16.04.09 13:23:46
> An: devzero@web.de
> CC: Randy Dunlap <randy.dunlap@oracle.com>, alan@lxorguk.ukuu.org.uk,=
 linux-kernel@vger.kernel.org
> Betreff: Re: Should MODULE_DESCRIPTION be mandatory ?

> > >=20
> >=20
> > i can offer spending an afternoon (or more) on compiling a list of =
modulenames + missing description for review.
> > if that list is complete and ack`ed, i could create a patch or patc=
h series from that.=20
> > (maybe the list could be split into logical parts, too)
>=20
> If you do this then you should feed the patches via the maintainers.
> I suggest to start out with the network stuff and see if netdev/David=
 Miller
> will take them.
>=20
> 	Sam
>=20


____________________________________________________________________
Psssst! Schon vom neuen WEB.DE MultiMessenger geh=F6rt?=20
Der kann`s mit allen: http://www.produkte.web.de/messenger/?did=3D3123

