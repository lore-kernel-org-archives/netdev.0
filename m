From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC] add missing MODULE_DESCRIPTION to drivers/net/*
Date: Thu, 16 Apr 2009 14:55:01 -0400
Message-ID: <7d1d9c250904161155n1d63c4f3u9af8df256a5e7dd1@mail.gmail.com>
References: <673528018@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org,
	Sam Ravnborg <sam@ravnborg.org>
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:30849 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbZDPSzE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 14:55:04 -0400
Received: by an-out-0708.google.com with SMTP id d11so310359and.1
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:55:02 -0700 (PDT)
In-Reply-To: <673528018@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 11:32 AM,  <devzero@web.de> wrote:
> Hello,
>
> we would like to add a built-time check for missing MODULE_DESCRIPTIO=
N (as it exists for MODULE_LICENSE) and currently have >400 modules whi=
ch are missing that field.
>
> As modinfo should provide necessary basic information about a module =
to the end-user, it`s bad if he needs the whole kernel-source for getti=
ng that information.
>
> Attached is a list of drivers from drivers/net/* currently lacking MO=
DULE_DESCRIPTION.
>
> I have created the description, mostly from what`s in Kconfig or the =
driver comments.
>
> If welcomed, please could you give a comment if this list is ok or fi=
x it appropriately ?
>
> I will then create a patch from that and send it here (and continue w=
ith net/* )
>
> regards
> Roland Kletzing
>
>
> drivers/net/8390.o - =A08390 core for usual drivers

core library for 8390 based ethernet cards

> drivers/net/appletalk/ipddp.o - IP<->Appletalk-IP Encapsulation/Decap=
sulation driver
> drivers/net/arcnet/arc-rawmode.o - ARCnet driver - "raw mode" packet =
encapsulation
> drivers/net/arcnet/arc-rimi.o - ARCnet driver for "RIM I" cards
> drivers/net/arcnet/arcnet.o - ARCnet driver - device-independent rout=
ines
> drivers/net/arcnet/capmode.o - ARCnet driver - "cap mode" packet enca=
psulation

Not sure if embedding a " into the strings will pose any problems for
any userspace, might be worth keeping in mind if there isn't a
precedent for this already.

> drivers/net/arcnet/com20020-pci.o - ARCnet driver - COM20020 PCI supp=
ort
> drivers/net/arcnet/com20020.o - ARCnet driver - COM20020 chipset supp=
ort
> drivers/net/arcnet/com90io.o - ARCnet driver - COM90xx chipset
> drivers/net/arcnet/com90xx.o - ARCnet driver - COM90xx chipset
> drivers/net/arcnet/rfc1051.o - ARCnet driver - RFC1051 ("simple" stan=
dard) packet encapsulation
> drivers/net/arcnet/rfc1201.o - ARCnet driver - RFC1201 (standard) pac=
ket encapsulation
> drivers/net/bsd_comp.o - PPP "BSD compress" compression
> drivers/net/de600.o - driver for the D-Link DE-600 Ethernet pocket ad=
apter
> drivers/net/de620.o - driver for the D-Link DE-620 Ethernet pocket ad=
apter

We can probably drop the "driver for the"  text from the above and any
similar ones; it is kind of like starting git commit messages with
"This patch does...." -- semi redundant information to indicate it is
a driver.

Paul.

> drivers/net/dummy.o - dummy net driver
> drivers/net/eql.o - Equalizer Load-balancer for serial network interf=
aces
> drivers/net/ifb.o - Intermediate Functional Block support
> drivers/net/pcmcia/com20020_cs.o - ARCnet driver - COM20020 PCMCIA su=
pport
> drivers/net/pcmcia/ibmtr_cs.o - PCMCIA token-ring driver for IBM-base=
d cards
> drivers/net/phy/mdio-bitbang.o - Bitbanged MDIO support
> drivers/net/plip.o - parallel port "network" driver
> drivers/net/ppp_async.o - PPP async serial channel driver
> drivers/net/ppp_deflate.o - PPP Deflate compression
> drivers/net/ppp_generic.o - Generic PPP layer
> drivers/net/ppp_synctty.o - PPP synchronous tty channel driver
> drivers/net/s2io.o - Linux PCI-X Ethernet driver for Neterion 10GbE S=
erver NIC
> drivers/net/skfp/skfp.o - device driver supporting the SysKonnect FDD=
I PCI controller family
> drivers/net/slhc.o - Van Jacobsen serial line header compression
> drivers/net/slip.o - Serial Line Internet Protocol driver
> drivers/net/smsc9420.o - SMSC LAN9420 PCI ethernet adapter driver
> drivers/net/sungem_phy.o - PHY drivers for the sungem ethernet driver
> drivers/net/tokenring/abyss.o - network driver for the Madge Smart 16=
/4 PCI Mk2 token ring card
> drivers/net/tokenring/tms380tr.o - network driver library for Texas I=
nstruments TMS380-based Token Ring Adapters
> drivers/net/tokenring/tmspci.o - generic network driver for TMS380-ba=
sed PCI token ring cards
> drivers/net/tulip/de4x5.o - DIGITAL DC21x4x DECchip and DE425/DE434/D=
E435/DE450/DE500 ethernet driver
> drivers/net/wan/lmc/lmc.o - Driver for the LanMedia LMC5200, LMC5245,=
 LMC1000, LMC1200 cards
> drivers/net/wan/sbni.o - Granch SBNI12 leased line adapters driver
> drivers/net/wan/x25_asy.o - X.25 async driver
> drivers/net/wireless/netwave_cs.o - Netwave AirSurfer Wireless LAN PC=
 Card driver
> drivers/net/wireless/p54/p54spi.o - Prism54 SPI (stlc45xx) driver
> drivers/net/wireless/wavelan_cs.o - Wavelan Pcmcia driver
>
>
>
>
>> Von: Sam Ravnborg <sam@ravnborg.org>
>> Gesendet: 16.04.09 13:23:46
>> An: devzero@web.de
>> CC: Randy Dunlap <randy.dunlap@oracle.com>, alan@lxorguk.ukuu.org.uk=
, linux-kernel@vger.kernel.org
>> Betreff: Re: Should MODULE_DESCRIPTION be mandatory ?
>
>> > >
>> >
>> > i can offer spending an afternoon (or more) on compiling a list of=
 modulenames + missing description for review.
>> > if that list is complete and ack`ed, i could create a patch or pat=
ch series from that.
>> > (maybe the list could be split into logical parts, too)
>>
>> If you do this then you should feed the patches via the maintainers.
>> I suggest to start out with the network stuff and see if netdev/Davi=
d Miller
>> will take them.
>>
>> =A0 =A0 =A0 Sam
>>
>
>
> ____________________________________________________________________
> Psssst! Schon vom neuen WEB.DE MultiMessenger geh=F6rt?
> Der kann`s mit allen: http://www.produkte.web.de/messenger/?did=3D312=
3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
