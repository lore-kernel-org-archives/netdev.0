From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 05:24:03 -0800 (PST)
Message-ID: <20090227.052403.209887355.davem@davemloft.net>
References: <20090227041136.GA21468@gondor.apana.org.au>
	<20090227.000350.107894710.davem@davemloft.net>
	<20090227114550.GC24024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754958AbZB0NYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 08:24:21 -0500
In-Reply-To: <20090227114550.GC24024@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 27 Feb 2009 19:45:50 +0800

> On Fri, Feb 27, 2009 at 12:03:50AM -0800, David Miller wrote:
> > 
> > This case should use netpoll_rx().
> 
> Good point.
> 
> > netif_rx_skb() --> netpoll_rx()
> > netif_receive_skb() --> netpoll_receive_skb()
> 
> Actually I think we could just use netpoll_rx as netpoll_receive_skb
> is just an optimisation that skips the test if we've already done it.
> 
> I'll do another version with combining the bonding check as you
> suggested.

Thanks a lot Herbert.
