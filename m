From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Wed, 09 Jan 2008 17:15:12 +1100
Message-ID: <E1JCUDY-000791-00@gondolin.me.apana.org.au>
References: <4783C2E2.5060102@cosmosbay.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2625 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750822AbYAIGPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:15:18 -0500
In-Reply-To: <4783C2E2.5060102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 58dfa82..731f0a8 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1188,10 +1188,15 @@ static inline int xfrm_aevent_is_on(void)
>        return ret;
> }
> 
> +static inline int alg_len(struct xfrm_algo *alg)

Could you please add an xfrm prefix to this?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
