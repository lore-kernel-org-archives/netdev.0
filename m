From: David Hollis <dhollis@davehollis.com>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Tue, 21 Aug 2007 20:48:43 +0000
Message-ID: <1187729323.2879.32.camel@dhollis-lnx.sunera.com>
References: <467915D9.3030900@slagter.name>
	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>
	<467FF5DB.5090006@slagter.name>
	<1182923692.6644.4.camel@dhollis-lnx.sunera.com>
	<46ADAF1B.4060500@slagter.name>
	<1185820074.8086.4.camel@dhollis-lnx.sunera.com>
	<46B4A826.7010705@slagter.name>
	<1186603993.3078.16.camel@dhollis-lnx.sunera.com>
	<46C9BFF2.8030206@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Slagter <erik@slagter.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:64075 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbXHUUs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 16:48:58 -0400
Received: from smtp.davehollis.com ([72.64.146.68])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JN500DCC5THXXU6@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 21 Aug 2007 15:48:54 -0500 (CDT)
In-reply-to: <46C9BFF2.8030206@slagter.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-20 at 18:23 +0200, Erik Slagter wrote:

> > /*
> >         if ((eeprom >> 8) != 1) {
> >                 asix_write_gpio(dev, 0x003c, 30);
> >                 asix_write_gpio(dev, 0x001c, 300);
> >                 asix_write_gpio(dev, 0x003c, 30);
> >         } else {
> > */
> >                 dbg("gpio phymode == 1 path");
> >                 asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
> >                 asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1,
> > 30);
> > //      }
> 
> Tried, but now it doesn't work at all, no LEDs and no traffic.

Ok, that's what I expected.  It's very interesting that this was working
with older kernels, and now it isn't.  Very little has changed in the
last few releases.  I would think that it could be some type of changes
in usbnet, but that would seem to affect far more devices.  My AX88178
devices (not the Linksys one, they are manufacturing samples) still work
fine.  I may have to pickup on the Linksys ones to figure out what is up
with it.

-- 
David Hollis <dhollis@davehollis.com>

