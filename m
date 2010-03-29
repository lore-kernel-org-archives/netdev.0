From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Mon, 29 Mar 2010 22:43:39 +0800
Message-ID: <20100329144339.GA26214@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56614 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752713Ab0C2Onn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:43:43 -0400
Content-Disposition: inline
In-Reply-To: <1269871964-5412-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 05:12:38PM +0300, Timo Teras wrote:
>
> @@ -1132,7 +1119,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
>  		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
>  	}
>  	if (old_pol)
> -		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
> +		old_pol = __xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>  	write_unlock_bh(&xfrm_policy_lock);
>  
>  	if (old_pol) {

So when can this actually fail?

Otherwise this patch looks good to me.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
