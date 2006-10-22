From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] add the algorithm to IPsec
Date: Sun, 22 Oct 2006 15:04:30 +1000
Message-ID: <20061022050430.GA20814@gondor.apana.org.au>
References: <20061018112623.29ed9324.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5898 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422983AbWJVFEi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 01:04:38 -0400
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20061018112623.29ed9324.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 11:26:23AM +0900, Kazunori MIYAZAWA wrote:
>  
> diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
> index 5a0dbeb..e03eadd 100644
> --- a/net/xfrm/xfrm_algo.c
> +++ b/net/xfrm/xfrm_algo.c
> @@ -119,6 +119,24 @@ static struct xfrm_algo_desc aalg_list[]
>  		.sadb_alg_maxbits = 160
>  	}
>  },
> +{
> +	.name = "xcbc(aes)",
> +	.compat = "aes_xcbc_128",

BTW, new algorithms should not have a compat field.  The whole point
of the compat field is to allow existing users to get the correct
algorithm without updating their configuration.  This does not make
sense for new algorithms as there aren't any existing configurations
for us to worry about yet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
