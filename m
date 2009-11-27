From: Frederic Leroy <fredo@starox.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Fri, 27 Nov 2009 21:53:24 +0100
Message-ID: <20091127215324.5f494a86@houba>
References: <4B0CB1B8.8030402@shiftmail.org>
	<20091126233302.42be8780@houba>
	<4B0FCC6D.3050003@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
To: Asdo <asdo@shiftmail.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:46549 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbZK0Uxm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 15:53:42 -0500
In-Reply-To: <4B0FCC6D.3050003@shiftmail.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Fri, 27 Nov 2009 13:56:13 +0100,
Asdo <asdo@shiftmail.org> a =C3=A9crit :

> Frederic Leroy wrote:
> > Le Wed, 25 Nov 2009 05:25:28 +0100,
> > Asdo <asdo@shiftmail.org> a =C3=A9crit :
> >
> >  =20
> >> Hi netdev and e1000 people,
> >>
> >> I have a weird problem here.
> >> [...]
> > I have the same kind of problem at home. I can't copy big files ove=
r
> > [...]
> Good God it's true then!

Yes :)

> Still if I am right, with Netcat you might end up with a corrupted
> file on the other side (shorter). Or maybe not, depending on how
> exactly the bug is made. Could you check this? Filesize and md5sum.

md5sum are ok.
I can't reproduce the problem on wire with a switch ( using both
10 and 100Mbp FD )  =20

> Do you have Intel network card, with e1000e driver on SG? (see lsmod)=
=20
> (sorry I was wrong before, it's e1000e in my case not e1000)
> Otherwise it's probably the TCP layer...

Sorry, I forgot to precise the network hardware.
I forgot a noname 100Mbp switch between the isv box and sg host.

SG:

00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
using module 8139cp

Devel:

02:02.0 Network controller: Broadcom Corporation BCM4306 802.11b/g
Wireless LAN Controller (rev 03)
using b43 driver.

02:08.0 Ethernet controller: Intel Corporation 82801DB PRO/100 VE (MOB)
Ethernet Controller (rev 81)
using e100 in kernel ( no module )

My isv box is broadcom based, but I don't know which chipset for
wireless.

Since our hardware are different, I don't think it's coming from
hardware driver. I'm preparing traces for Ilpo

--=20
=46r=C3=A9d=C3=A9ric Leroy
