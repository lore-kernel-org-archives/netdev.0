From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix key lengths for rfc3686(ctr(aes))
Date: Fri, 29 Jul 2011 08:05:37 +0800
Message-ID: <20110729000537.GC12183@gondor.apana.org.au>
References: <alpine.LFD.1.10.1107281246381.11308@net-test1.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joy Latten <latten@austin.ibm.com>, netdev <netdev@vger.kernel.org>
To: Tushar Gohad <tgohad@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35655 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab1G2AFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 20:05:51 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.1107281246381.11308@net-test1.az.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2011 at 01:36:20PM -0700, Tushar Gohad wrote:
>
> Fix the min and max bit lengths for AES-CTR (RFC3686) keys.
> The number of bits in key spec is the key length (128/256)
> plus 32 bits of nonce.
>
> This change takes care of the "Invalid key length" errors
> reported by setkey when specifying 288 bit keys for aes-ctr.
>
> Signed-off-by: Tushar Gohad <tgohad@mvista.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
