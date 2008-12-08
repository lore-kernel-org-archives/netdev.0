From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Mon, 08 Dec 2008 12:29:14 -0800 (PST)
Message-ID: <20081208.122914.97675406.davem@davemloft.net>
References: <1228499870.3520.66.camel@achroite>
	<1228734318.19000.84.camel@petitemort>
	<1228749474.3177.10.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsilvers@simtec.co.uk, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751977AbYLHU3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 15:29:13 -0500
In-Reply-To: <1228749474.3177.10.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 08 Dec 2008 15:17:53 +0000

> On Mon, 2008-12-08 at 11:05 +0000, Daniel Silverstone wrote:
> [...]
> > > > +static inline struct ks8695_priv *
> > > > +ks8695_get_priv(struct net_device *ndev)
> > > Don't use ndev->priv, use netdev_priv(ndev).  Which makes this function
> > > redundant, except for the implicit pointer conversion.
> > 
> > Aah, I didn't know about that one, updated.
> 
> Until recently they have been equivalent by default; direct access to
> priv is now deprecated and it will be removed.

Not just "will be removed", but "is removed" in the current
net-next-2.6 tree so this driver wouldn't even compile :-)
