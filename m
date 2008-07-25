From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 23:34:34 +0800
Message-ID: <E1KMPJS-0005Dh-00@gondolin.me.apana.org.au>
References: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51649 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752490AbYGYPer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 11:34:47 -0400
In-Reply-To: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>
> diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
> index a75807b..ee1bbf9 100644
> --- a/net/ipv4/ipcomp.c
> +++ b/net/ipv4/ipcomp.c
> @@ -293,7 +293,7 @@ static void ipcomp_free_tfms(struct crypto_comp **tfms)
>                        break;
>        }
> 
> -       BUG_TRAP(pos);
> +       WARN_ON(!pos);

Sorry I've just moved this to net/xfrm/xfrm_ipcomp.c.  BTW,
please also remove rtnetlink.h from ipcomp.c since that's only
included for this macro.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
