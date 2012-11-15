From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHES] Networking fixes for -stable.
Date: Wed, 14 Nov 2012 20:06:24 -0800
Message-ID: <20121115040624.GA20536@kroah.com>
References: <20121112.002558.46179003870204789.davem@davemloft.net>
 <1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
 <20121114.223145.1718907430767854932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, peter.senna@gmail.com, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48606 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933309Ab2KOEFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 23:05:42 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so866266pbc.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 20:05:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121114.223145.1718907430767854932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 14, 2012 at 10:31:45PM -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 13 Nov 2012 19:51:26 +0000
> 
> > On Mon, 2012-11-12 at 00:25 -0500, David Miller wrote:
> >> Please queue up the following networking bug fixes for
> >> 3.0.x, 3.2.x, 3.4.x, and 3.6.x, respectively.
> > [...]
> >> From 2204849a85383fbde75680aa199142abe504adbb Mon Sep 17 00:00:00 2001
> >> From: Peter Senna Tschudin <peter.senna@gmail.com>
> >> Date: Sun, 28 Oct 2012 06:12:01 +0000
> >> Subject: [PATCH 7/9] drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister
> >>  before mdiobus_free
> >> 
> >> [ Upstream commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e ]
> >> 
> >> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
> >> 
> >> Calling mdiobus_free without calling mdiobus_unregister causes
> >> BUG_ON(). This patch fixes the issue.
> > [...]
> > 
> > This introduces a regresssion, as mdiobus_unregister() is not safe to
> > call if the bus isn't registered.  Registration is controlled by the
> > drivers that use mdio-bitbang, and they should take care of
> > unregistration too - and most of them do.
> > 
> > This should be reverted in mainline and not applied to any stable
> > series.
> 
> Ok, I'll revert.
> 
> Greg, please toss it from your -stable queue as well.

Now tossed, thanks.

greg k-h
