From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: =?UTF-8?Q?=D0=9E=D1=82=D0=B2=D0=B5=D1=82=3A?= [PATCH 10/10]
 ieee802154: add at86rf230/rf231 spi driver
Date: Tue, 02 Jun 2009 10:36:49 +0200
Message-ID: <1243931809.3192.68.camel@localhost.localdomain>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com>
	 <20090601203348.GC7143@doriath.ww600.siemens.net>
	 <200906021010.49613.hs4233@mail.mn-solutions.de>
	 <1243930893.3192.62.camel@localhost.localdomain>
	 <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Holger Schurig <hs4233@mail.mn-solutions.de>,
	linux-wireless@vger.kernel.org,
	=?ISO-8859-1?Q?G=E1bor?= Stefanik <netrolller.3d@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760485AbZFBIhW@vger.kernel.org>
In-Reply-To: <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

> >> > I thought about drivers/net as about ip (well, more or less)
> >> > network drivers. We have drivers/atm or drivers/bluetooth (and
> >> > bluetooth is 802.15.1...).
> >>
> >> I actually like that this is drivers/bluetooth and not
> >> drivers/ieee802151. Would you consider drivers/zigbee instead of
> >> drivers/ieee802154 ???
> >
> > I fully agree here.
> >
> > Please use "zigbee" instead of "ieee*" names since that can become messy
> > and confusing. I know that in theory the IEEE part of ZigBee is more
> > low-level radio and could be used by non-ZigBee devices, but that is not
> > gonna happen anyway. Especially with Bluetooth Low Energy pushing into
> > the turf of ZigBee. So please use proper names and not confuse people
> > with IEEE numbers ;)
> 
> This gonna happen, as we are most probably going to implement 6lowpan
> on top of our stack. 6lowpan is a way to encapsulate IPv6 frames into
> IEEE 802.15.4 and has nothing in common with ZigBee. Moreover
> ZigBee is a trademark with strict rules upon it's usage. Our lawyers are
> currently investigating if it's possible to use this name in projects like
> Linux kernel which are open-source, non-related to any project but
> OTOH can be encapsulated in any commercial project.
> 
> IEEE 802.15.4 is a term like IEEE 802.11. We do have mac80211,
> we have had (until recently) ieee80211 dir, so why bother?
> 
> For Bluetooth naming directories 'bluetooth' is logical, as 802.15.1
> standard is a less known name, doesn't incorporate latest changes
> from Bluetooth, etc.

and so is IEEE 802.15.4 hence we propose using "zigbee" here. Using the
mac80211 has historical reasons and 802.11 is a known name and even used
on product marketing material. IEEE 802.15.4 is not. We are also using
the term "wimax" and not its IEEE numbering.

Regards

Marcel
