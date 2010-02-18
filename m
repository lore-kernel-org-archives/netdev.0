From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 22:18:43 -0500
Message-ID: <1266463123.5719.93.camel@obelisk.thedillows.org>
References: <cover.1266454575.git.joe@perches.com>
	 <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
	 <1266458370.5719.43.camel@obelisk.thedillows.org>
	 <1266459504.8446.201.camel@Joe-Laptop.home>
	 <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <1266461631.8446.227.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:56873 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab0BRDSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 22:18:48 -0500
In-Reply-To: <1266461631.8446.227.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 18:53 -0800, Joe Perches wrote:
> On Wed, 2010-02-17 at 21:30 -0500, David Dillow wrote:
> > > Doesn't that mean that "%s: ...", tp->name should be removed?
> > No, because the routines that use tp->name are called both before and
> > after the netdev is registered. Prior to that time, it contains the PCI
> > slot name -- "00:01.0" etc -- so that the user can determine which card
> > is acting up. Once the card is registered, it has "ethX" to use a
> > commonly expected name for the card.
> 
> I think those messages should just use netdev_<level> then.
> 
> If not registered, "(unregistered net_device)" and
> the PCI slot are emitted.

Ugh on the length of the message now, but I'm certainly warming up to
the direction you're going.

I still don't see much harm in dropping the patches to typhoon for now
while I mull this over, and I don't like the loss of the driver prefix
during the initialization failures, but if David is hell-bent on doing
this tonight, then this version (plus the version string change) is an
improvement on the original patch.

You may also be able to get rid of the name field in struct typhoon
since it should now be unused.

Thank you for your willingness to address my concerns, Joe.

