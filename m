From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1] net: fix __sk_stream_mem_reclaim
Date: Thu, 13 Jul 2006 10:54:07 +1000
Message-ID: <E1G0pSx-0006ZI-00@gondolin.me.apana.org.au>
References: <5640c7e00607121623i34133297n6894878afd74f27e@mail.gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37647 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751473AbWGMAyb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 20:54:31 -0400
To: ian.mcdonald@jandi.co.nz (Ian McDonald)
In-Reply-To: <5640c7e00607121623i34133297n6894878afd74f27e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> __sk_stream_mem_reclaim is only called by sk_stream_mem_reclaim.
> 
> As such the check on sk->sk_forward_alloc is not needed and can be removed.
> 
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

What's more, even if the check does turn out to be false for some renegade
caller, the function will still work since all the operations turn out to
be no-ops.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
