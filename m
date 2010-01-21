From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][XFRM] Use the simple name when adding SAD with ip xfrm
	state
Date: Thu, 21 Jan 2010 22:10:59 +1300
Message-ID: <20100121091059.GA14808@gondor.apana.org.au>
References: <20100119022033.GA18155@gondor.apana.org.au> <4B556C72.40403@cn.fujitsu.com> <20100119.003041.193317921.davem@davemloft.net> <4B57E489.6010707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Li Yewang <lyw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50568 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750732Ab0AUJLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:11:10 -0500
Content-Disposition: inline
In-Reply-To: <4B57E489.6010707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 01:22:17PM +0800, Li Yewang wrote:
> Sorry, I am new to crypto.
> 
> I searched the soucre code in the directory of /crypto,
> and found that, all cryptos use shortname, for example:
> 
> crypto/xcbc.c
> static struct crypto_template crypto_xcbc_tmpl = {
>         .name = "xcbc",
>         .create = xcbc_create,
>         .free = shash_free_instance,
>         .module = THIS_MODULE,
> };

No this is a template name, not an algorithm name.  IOW if you
try to allocate it won't exist.  You need to use it together
with parameters, e.g., xcbc(aes).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
