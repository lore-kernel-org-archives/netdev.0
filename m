From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 19:45:50 +0800
Message-ID: <20090227114550.GC24024@gondor.apana.org.au>
References: <20090226.041037.134928084.davem@davemloft.net> <20090226130631.GA14125@gondor.apana.org.au> <20090227041136.GA21468@gondor.apana.org.au> <20090227.000350.107894710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43080 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752659AbZB0LqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 06:46:02 -0500
Content-Disposition: inline
In-Reply-To: <20090227.000350.107894710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 12:03:50AM -0800, David Miller wrote:
> 
> This case should use netpoll_rx().

Good point.

> netif_rx_skb() --> netpoll_rx()
> netif_receive_skb() --> netpoll_receive_skb()

Actually I think we could just use netpoll_rx as netpoll_receive_skb
is just an optimisation that skips the test if we've already done it.

I'll do another version with combining the bonding check as you
suggested.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
