From: Florian Fainelli <florian@openwrt.org>
Subject: Re: =?utf-8?q?=D0=9E=D1=82=D0=B2=D0=B5=D1=82=3A_=5BPATCH_10/10=5D_ieee802154=3A?=
 =?utf-8?q?_add_at86rf230/rf231_spi?= driver
Date: Tue, 2 Jun 2009 10:46:51 +0200
Message-ID: <200906021046.52681.florian@openwrt.org>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com> <1243931809.3192.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Holger Schurig <hs4233@mail.mn-solutions.de>,
	linux-wireless@vger.kernel.org,
	=?utf-8?q?G=C3=A1bor_Stefanik?= <netrolller.3d@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:45928 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbZFBIy3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 04:54:29 -0400
In-Reply-To: <1243931809.3192.68.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 02 June 2009 10:36:49 Marcel Holtmann, vous avez =C3=A9crit=C2=
=A0:
> Hi Dmitry,
>
> > >> > I thought about drivers/net as about ip (well, more or less)
> > >> > network drivers. We have drivers/atm or drivers/bluetooth (and
> > >> > bluetooth is 802.15.1...).
> > >>
> > >> I actually like that this is drivers/bluetooth and not
> > >> drivers/ieee802151. Would you consider drivers/zigbee instead of
> > >> drivers/ieee802154 ???
> > >
> > > I fully agree here.
> > >
> > > Please use "zigbee" instead of "ieee*" names since that can becom=
e
> > > messy and confusing. I know that in theory the IEEE part of ZigBe=
e is
> > > more low-level radio and could be used by non-ZigBee devices, but=
 that
> > > is not gonna happen anyway. Especially with Bluetooth Low Energy
> > > pushing into the turf of ZigBee. So please use proper names and n=
ot
> > > confuse people with IEEE numbers ;)
> >
> > This gonna happen, as we are most probably going to implement 6lowp=
an
> > on top of our stack. 6lowpan is a way to encapsulate IPv6 frames in=
to
> > IEEE 802.15.4 and has nothing in common with ZigBee. Moreover
> > ZigBee is a trademark with strict rules upon it's usage. Our lawyer=
s are
> > currently investigating if it's possible to use this name in projec=
ts
> > like Linux kernel which are open-source, non-related to any project=
 but
> > OTOH can be encapsulated in any commercial project.
> >
> > IEEE 802.15.4 is a term like IEEE 802.11. We do have mac80211,
> > we have had (until recently) ieee80211 dir, so why bother?
> >
> > For Bluetooth naming directories 'bluetooth' is logical, as 802.15.=
1
> > standard is a less known name, doesn't incorporate latest changes
> > from Bluetooth, etc.
>
> and so is IEEE 802.15.4 hence we propose using "zigbee" here. Using t=
he
> mac80211 has historical reasons and 802.11 is a known name and even u=
sed
> on product marketing material. IEEE 802.15.4 is not. We are also usin=
g
> the term "wimax" and not its IEEE numbering.

Because you have an IEEE 802.15.4 PHY/MAC chip does not mean you want t=
o do=20
ZigBee on top of it and Dmitry explained that well. I would stick with =
the=20
ieee802154 name here for that reason. If your drivers go in ZigBee, it =
means=20
that your hardware implements parts of the ZigBee profiles, and that is=
 not=20
the case here.

The current Bluetooth implementation in the kernel deserves its name si=
nce=20
drivers are implementing the HCI Bluetooth profile (maybe others as wel=
l),=20
that is not plain IEEE 802.15.1.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
