From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] bridge: Fix build error when
	IGMP_SNOOPING is not enabled
Date: Tue, 2 Mar 2010 08:46:26 +0800
Message-ID: <20100302004626.GA28274@gondor.apana.org.au>
References: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48299 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752701Ab0CBAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 19:46:33 -0500
Content-Disposition: inline
In-Reply-To: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 01, 2010 at 11:53:04AM -0800, Sridhar Samudrala wrote:
> Fix the following build error when IGMP_SNOOPING is not enabled.
> In file included from net/bridge/br.c:24:
> net/bridge/br_private.h: In function 'br_multicast_is_router':
> net/bridge/br_private.h:361: error: 'struct net_bridge' has no member named 'multicast_router'
> net/bridge/br_private.h:362: error: 'struct net_bridge' has no member named 'multicast_router'
> net/bridge/br_private.h:363: error: 'struct net_bridge' has no member named 'multicast_router_timer'
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks for the fix.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I'd originally left the struct data outside ifdefs and then added
the ifdefs without testing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
