From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 3/6] drivers/net: remove null pointer dereference
Date: Mon, 12 May 2008 20:48:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805122046260.20369@ask.diku.dk>
References: <Pine.LNX.4.64.0805121537320.3694@ask.diku.dk>
 <20080512161734.GA22190@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.64.0805121852510.16384@ask.diku.dk> <48287916.2090203@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:37344 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756489AbYELSsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 14:48:18 -0400
In-Reply-To: <48287916.2090203@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008, Jeff Garzik wrote:

> Julia Lawall wrote:
> > On Mon, 12 May 2008, Francois Romieu wrote:
> > 
> > > Julia Lawall <julia@diku.dk> :
> > > [...]
> > > > diff -u -p a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> > > > --- a/drivers/net/au1000_eth.c	2008-04-27 11:41:11.000000000 +0200
> > > > +++ b/drivers/net/au1000_eth.c	2008-05-12 09:32:54.000000000 +0200
> >>> @@ -1242,7 +1242,7 @@ static irqreturn_t au1000_interrupt(int 
> > > >   struct net_device *dev = (struct net_device *) dev_id;
> > > >  
> > > > 	if (dev == NULL) {
> > > > -		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
> > > > +		printk(KERN_ERR "isr: null dev ptr\n");
> > > >   	return IRQ_RETVAL(1);
> > > >   }
> > > The lifespan of 'dev' covers the request_irq..free_irq interval in this
> > > driver. The whole 'dev == NULL' block can be removed.
> > 
> > Will you do that?
> 
> It's normal within the Linux community to give feedback on patches, and
> sometimes the authors need to revise their patches if helpful feedback arises.

Sorry.  In principle, I would be happy to do it, but I felt slightly 
uneasy about doing something I didn't completely understand.

julia
