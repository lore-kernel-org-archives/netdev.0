From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4: Make icmp route lookup code a bit clearer.
Date: Wed, 2 Mar 2011 08:43:25 +0800
Message-ID: <20110302004325.GB15009@gondor.apana.org.au>
References: <20110301.154816.212683830.davem@davemloft.net> <20110301.155015.258117084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49662 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099Ab1CBAn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 19:43:28 -0500
Content-Disposition: inline
In-Reply-To: <20110301.155015.258117084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 03:50:15PM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 01 Mar 2011 15:48:16 -0800 (PST)
> 
> > 
> > The route lookup code in icmp_send() is slightly tricky as a result of
> > having to handle all of the requirements of RFC 4301 host relookups.
> > 
> > Pull the route resolution into a seperate function, so that the error
> > handling and route reference counting is hopefully easier to see and
> > contained wholly within this new routine.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> ...
> > +struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
> 
> Of course this should be static :-)

Looks good to me.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
