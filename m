From: Carsten Langgaard <carstenl@mips.com>
Subject: Re: pcnet32 fiberoptic
Date: Tue, 23 Apr 2002 08:38:57 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CC50181.A1B28F24@mips.com>
References: <014201c1ea01$07094740$3201a8c0@thinstuff.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-net-owner@vger.kernel.org>
To: Michael Gibson <mgibson@esesixtech.com>, tsbogend@alpha.franken.de,
	linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not the maintainer of this driver, Thomas Bogend=F6rfer
(tsbogend@alpha.franken.de) is.
You can also direct you questions to linux-net@vger.kernel.org list.

/Carsten


Michael Gibson wrote:

> Hi Carsten,
>
> 1. We have applied following patch to the pcnet32 driver for kernel 2=
=2E4.17
> http://www.uwsg.iu.edu/hypermail/linux/net/0102.0/0019.html
> to make the fiberoptic port work for Allied Telesyn AT-2450FTX NW car=
d.
> This card has 2 interfaces: a Fiberoptic 10Mbit (ST Inerface) and a T=
P
> 10/100Mbit interface
> We are using it togeteher with the "MC13 Ethernet Media Converter" al=
so from
> allied telesyn.
> This is a media converter from fiberoptic (10MBit) to 10MBit TP.
> We connected it to a 10Mbit TP HUB.
> We are using the 10Mbit Fiberoptic interface of this card and it is a=
bout 30
> times slower then a normal 10Mbit TP Lan.
> So IMHO that should be a driver problem and not normal.
> But maybe I am wrong.
>
> We are also using an Allied Telesyn AT-2700FX card.
> This card has only one interface: a Fiberoptic 100Mbit (ST Inerface)
> We are using this one together with the "MC101XL Fast Ethernet Media
> Converter" also from Allied Telesyn.
> This is a media converter from fiberoptic (100MBit) to 100MBit TP.
> We connected it to a 100Mbit TP switch.
> This card is about the same speed as a normal 100Mbit TP card.
>
> Both above cards. The 10Mbit fiber and the 100Mbit fiber have exactel=
y the
> same AMD chip: PCnet Fast+, AM79C972BKC.
>
> Do you have any idea what could be causing the problem that the 10Mbi=
t fiber
> card is so terribly slow?
> Do you want to include this fiber patch into the pcnet32 driver?
>
> Best regards
> Michael Gibson

--
_    _ ____  ___   Carsten Langgaard   Mailto:carstenl@mips.com
|\  /|||___)(___   MIPS Denmark        Direct: +45 4486 5527
| \/ |||    ____)  Lautrupvang 4B      Switch: +45 4486 5555
  TECHNOLOGIES     2750 Ballerup       Fax...: +45 4486 5556
                   Denmark             http://www.mips.com



