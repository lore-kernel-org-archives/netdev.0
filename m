From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 14:36:45 +1000
Message-ID: <20080818043645.GA32755@gondor.apana.org.au>
References: <20080818013633.GA31653@gondor.apana.org.au> <20080817.184921.08829673.davem@davemloft.net> <20080818042731.GA32637@gondor.apana.org.au> <20080817.213131.62127589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34066 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750741AbYHREgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 00:36:51 -0400
Content-Disposition: inline
In-Reply-To: <20080817.213131.62127589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 09:31:31PM -0700, David Miller wrote:
> 
> Ok, here is what I'll do as a rough plan:
> 
> 1) Integrate this patch with your drop suggestion and ingress
>    fixed up.
> 
> 2) Integrate Jarek's patch that closes the "both bits clear"
>    hole.
> 
> 3) Add my bit that makes dev_deactivate() always take the spinlock
>    so there is just one simple yield() loop.
> 
> And, finally, we can be at the point where we can get rid of the
> RCU deferral of qdisc_destroy().
> 
> Should be fun evening :-)

Worthy of a gold medal :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
