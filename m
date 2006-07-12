From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1] net: fix __sk_stream_mem_reclaim
Date: Wed, 12 Jul 2006 20:46:09 +1000
Message-ID: <E1G0cEL-0004An-00@gondolin.me.apana.org.au>
References: <200607121909.17311.ian.mcdonald@jandi.co.nz>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42000 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750912AbWGLKqW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 06:46:22 -0400
To: ian.mcdonald@jandi.co.nz (Ian McDonald)
In-Reply-To: <200607121909.17311.ian.mcdonald@jandi.co.nz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> __sk_stream_mem_reclaim is only called by sk_stream_mem_reclaim.
> 
> As such the check on sk->sk_forward_alloc is not needed and can be removed.
> 
> At the same time remove the EXPORT_SYMBOL_GPL as not needed and shift it
> into include/net/sock.h

I don't see the point of moving it into net/sock.h.  Please keep it
in net/core/stream.c.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
