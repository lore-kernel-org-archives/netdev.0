From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]NET: Fix GSO problems in dev_hard_start_xmit()
Date: Mon, 26 Jun 2006 09:36:02 +1000
Message-ID: <20060625233602.GA22255@gondor.apana.org.au>
References: <1151275085.4468.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29968 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964905AbWFYXxa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 19:53:30 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151275085.4468.2.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 25, 2006 at 03:38:05PM -0700, Michael Chan wrote:
> Fix 2 problems in dev_hard_start_xmit():
> 
> 1. nskb->next needs to link back to skb->next if hard_start_xmit()
> returns non-zero.
> 
> 2. Since the total number of GSO fragments may exceed MAX_SKB_FRAGS + 1,
> it needs to stop transmitting if the netif_queue is stopped.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
