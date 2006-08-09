From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_shared_info()
Date: Wed, 9 Aug 2006 10:36:16 +1000
Message-ID: <20060809003616.GC19881@gondor.apana.org.au>
References: <20060808.163915.03600382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58887 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030377AbWHIAxP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:53:15 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.163915.03600382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 04:39:15PM -0700, David Miller wrote:
> 
> I'm beginning to think that where we store the
> skb_shared_info() is a weakness of the SKB design.

I'm not sure whether the problem is where we store skb_shared_info,
or the fact that we can't put kmalloc'ed memory into skb_shinfo->frags.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
