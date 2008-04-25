From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: alg_key_len & alg_icv_len should be unsigned
Date: Fri, 25 Apr 2008 15:14:20 +0800
Message-ID: <20080425071419.GA17997@gondor.apana.org.au>
References: <48118391.3010109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51651 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759136AbYDYHO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:14:26 -0400
Content-Disposition: inline
In-Reply-To: <48118391.3010109@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2008 at 09:09:05AM +0200, Eric Dumazet wrote:
> In commit ba749ae98d5aa9d2ce9a7facde0deed454f92230 ([XFRM]: alg_key_len 
> should be unsigned to avoid integer divides 
> <http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=ba749ae98d5aa9d2ce9a7facde0deed454f92230>) 
> alg_key_len field of struct xfrm_algo was converted to unsigned int to 
> avoid integer divides.
> 
> Then Herbert in commit 1a6509d991225ad210de54c63314fd9542922095 
> ([IPSEC]: Add support for combined mode algorithms) added a new 
> structure xfrm_algo_aead, that resurrected a signed int for alg_key_len 
> and re-introduce integer divides.
> 
> This patch avoids these divides and saves 64 bytes of text on i386.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I actually wrote my patch before yours was merged which was why
it was signed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
