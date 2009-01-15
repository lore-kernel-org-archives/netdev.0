From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - REPOST] asix.c - Add support for AX88772A devices -
Date: Thu, 15 Jan 2009 08:22:53 -0800 (PST)
Message-ID: <20090115.082253.154478845.davem@davemloft.net>
References: <1231949520.4105.97.camel@dhollis-lnx>
	<1231952036.3010.21.camel@achroite>
	<1232024974.4105.251.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeff@garzik.org, netdev@vger.kernel.org
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756745AbZAOQWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 11:22:52 -0500
In-Reply-To: <1232024974.4105.251.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Thu, 15 Jan 2009 08:09:34 -0500

> On Wed, 2009-01-14 at 16:53 +0000, Ben Hutchings wrote:
> 
> > > @@ -1451,6 +1588,10 @@ static const struct usb_device_id        produc
> > >         // Cables-to-Go USB Ethernet Adapter
> > >         USB_DEVICE(0x0b95, 0x772a),
> > >         .driver_info = (unsigned long) &ax88772_info,
> > > +}, {
> > > +       // ASIX AX88772A
> > > +       USB_DEVICE(0x0b95, 0x772a),
> > > +       .driver_info = (unsigned long) &ax88772a_info,
> > 
> > This is matching the same id as the entry above, so how will it ever be
> > used?  Do the bind operations distinguish them somehow?
> > 
> 
> Ugh!  I didn't notice that either.  Unfortunately, I don't have this new
> device to be able to test with so I have to rely on the vendors
> contribution.  I would presume that the Cables-to-Go device needs to be
> using ax88772a_info and in the current state, it isn't going to.  I'll
> check with the contributor for an assist on that.

Grrr, I just noticed this and I'm ripping this patch out of
my tree.

Sigh.
