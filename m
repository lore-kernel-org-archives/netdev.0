From: David Miller <davem@davemloft.net>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 13:12:24 -0700 (PDT)
Message-ID: <20080919.131224.193729733.davem@davemloft.net>
References: <20080918.193815.175549834.davem@davemloft.net>
	<1221824281.3103.8.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752176AbYISUMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 16:12:36 -0400
In-Reply-To: <1221824281.3103.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Sep 2008 12:38:01 +0100

> On Thu, 2008-09-18 at 19:38 -0700, David Miller wrote:
> [...]
> > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> > have names like:
> > 
> > 	eth0-rx-0
> > 	eth0-rx-1
> > 	eth0-tx-0
> > 	eth0-tx-1
> > 
> > So let's make an effort to get this done right in 2.6.28 and meanwhile
> > Arjan can add the irqbalanced code.
> 
> What about the case where an interrupt is shared between RX and TX
> completions?  Our hardware is very flexible in this regard, but based on
> performance testing prior to the introduction of TX multiqueue we
> currently allocate multiple interrupts for RX completions and share the
> first with TX completions.

Probably it would be sufficient to purely use eth0-N, it's just so
that irqbalanced knows that the interrupts are related.
