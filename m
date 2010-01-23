From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 15:25:53 +0100
Message-ID: <1264256753.3469.55.camel@violet>
References: <cover.1264201406.git.jan.kiszka@web.de>
	 <445e1bf881b6f8b6a5886d6eee70f6435a5619d6.1264201408.git.jan.kiszka@web.de>
	 <20100123122430.5a078b4a@lxorguk.ukuu.org.uk>
	 <1264250892.3469.52.camel@violet>  <4B5AF5FF.6050702@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44242 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab0AWOY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 09:24:57 -0500
In-Reply-To: <4B5AF5FF.6050702@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan,

> >>> I found no trace of this mysterious "pcl181" device, neither in-tree nor
> >>> out there in the wild. At the same time, the in-tree CAPI middleware is
> >>> using major 191 for many years now and obviously without any conflict.
> >>> Let's officially claim this major number.
> >> This is not the way it should have been done but whoever needs spanking
> >> got away with it years ago. Given that this seems the best way forward.
> >>
> >> With LANANA hat on
> > 
> > actually in the days of udev, the capifs is not really needed anymore.
> > The right choice would be to remove it. I haven't been enabling it since
> > years.
> 
> First of all, the capifs story is orthogonal to the major claim.

my point here is merely that when using udev, you need to fixed assigned
major number. Dynamic major numbers will just work fine.

> But basically you are right, capifs is likely not needed anymore. The
> only user visible change - and that was holding me back to suggest its
> removal - is the time when the NCCI minor ttys show up under /dev/capi/
> (or wherever you direct them to). If I didn't miss something about udev,
> it will make all possible minors pop up once the major is registered.
> However, I'm not sure if there is some userland actually relying on this.

That is just an issue with the current code. There is no requirement to
create all minors are at the same. You can create/remove minors on
demand as you please. And udev will take care of the device nodes for
you.

Regards

Marcel


