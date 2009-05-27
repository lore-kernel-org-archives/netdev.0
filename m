From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux
Date: Wed, 27 May 2009 11:58:55 +0200
Message-ID: <200905271158.57067.florian@openwrt.org>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:62504 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760795AbZE0J7A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 05:59:00 -0400
In-Reply-To: <20090526112157.GA19976@doriath.ww600.siemens.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

Le Tuesday 26 May 2009 13:21:57 Dmitry Eremin-Solenikov, vous avez =E9c=
rit=A0:
> Hi,
>
> As a part of research activities in the Embedded Systems - Open Platf=
orm
> Group from Siemens Corporate Technology we are working on adding supp=
ort
> for the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. O=
ur
> current implementation is neither certified nor even feature complete=
=2E
> However we'd like to present current state of our patchset to the Lin=
ux
> developers community to gain comments, fixes, ideas, etc. This is not=
 yet a
> pull request, but more like an RFC.

Let met just thank you for doing this, I am glad some people worked on =
this.=20
Got a couple of questions below.

>
> The project page is available at
> http://apps.sourceforge.net/trac/linux-zigbee with source code of ker=
nel
> part available from git at
> http://zigbee-linux.git.sourceforge.net, mirrored for convenience at
> git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
>
> The source code for userspace utils is available from git at
> http://linux-zigbee.git.sourceforge.net/

=46rom the project page I understand that you plan on providing a ZigBe=
e stack,=20
based on this 802.15.4 stack ? Do you plan on submitting the ZigBee sta=
ck=20
later on ?

Maybe you should mention that this implementation is royalty-free, but =
that=20
commercial products using it should both respect the GPL license and pa=
y a=20
ZigBee royalty as per the ZigBee Alliance . That is just for clarificat=
ion=20
since right now it simply does 802.15.4 which is not subject to this ro=
yalty=20
thing.

>
> Several comments about our implementation:
> * As with 802.11 there are two types of devices: the smart ones that
> implement most parts of the protocol by themselves and more or less d=
umb
> ones which simply send and receive what they are told. Currently we d=
o only
> support the second type of devices (SoftMAC)
> * The implementation is split between code driving radio, (master, mw=
panX
>   interface: mdev.c), code processing frames according the IEEE 802.1=
5.4
>   rules (slave wpanX devices) and finally sockets (af_ieee802154.c,
> dgram.c, raw.c).

This sounds good. Do you also plan on integrating some meshing algorith=
m on=20
top of 802.15.4 ? If so,=20

> * We do present two example drivers using our stack. One is purely vi=
rtual
>   one either looping the packets back or connecting several virtual
> interfaces (the one at fakelb.c), and the driver for the Freescale MC=
13192
> evaluation boards (13192-SARD, 13192-EVK) using our custom firmware
> (currently only available at request, we are working on publishing it=
). The
> driver for the Atmel at86rf230/at86rf231 chips will follow in several
> weeks.

Is the virtual interface just like mac80211_hwsim for 802.11 ?h
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
