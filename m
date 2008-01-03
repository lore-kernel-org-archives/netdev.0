From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 03 Jan 2008 15:25:17 -0800 (PST)
Message-ID: <20080103.152517.242377970.davem@davemloft.net>
References: <200801031620.06603.paul.moore@hp.com>
	<20080103.150518.05131300.davem@davemloft.net>
	<200801031813.57621.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751600AbYACXZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 18:25:18 -0500
In-Reply-To: <200801031813.57621.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 3 Jan 2008 18:13:57 -0500

> On Thursday 03 January 2008 6:05:18 pm David Miller wrote:
> > From: Paul Moore <paul.moore@hp.com>
> > Date: Thu, 3 Jan 2008 16:20:06 -0500
> >
> > > On Thursday 03 January 2008 4:13:12 pm Jarek Poplawski wrote:
> > > > On Thu, Jan 03, 2008 at 11:15:34AM -0500, Paul Moore wrote:
> > > > ...
> > > >
> > > > > While I'm at it, is there some reason for this #define in
> > > > > __skb_clone()?
> > > > >
> > > > >  #define C(x) n->x = skb->x
> > > > >
> > > > > ... it seems kinda silly to me and I tend to think the code
> > > > > would be better without it.
> > > >
> > > > IMHO, if there are a lot of this, it's definitely more readable:
> > > > easier to check which values are simply copied and which need
> > > > something more. But, as usual, it's probably a question of taste,
> > > > and of course without it it would definitely look classier...
> > >
> > > For me personally, I would argue the readability bit.
> >
> > I definitely think the C() thing is more readable.
> >
> > Less typing, less reading...
> 
> Well, you're the boss :)  I just put the C() macro back in, but I kept 
> the reordering that was suggested to help reduce cacheline bounces 
> since that still makes sense to me.  The function now looks like this:

Looks ok to me.
