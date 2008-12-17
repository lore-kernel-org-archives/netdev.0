From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 21:47:11 +1100
Message-ID: <20081217104711.GA17504@gondor.apana.org.au>
References: <E1LCtSp-0004Rc-Lb@gondolin.me.apana.org.au> <1229510713.13305.17.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58473 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752634AbYLQKrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 05:47:21 -0500
Content-Disposition: inline
In-Reply-To: <1229510713.13305.17.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 11:45:13AM +0100, Petr Tesarik wrote:
>
> You're talking about the urgent-data case, right? Yes, for urgent data,
> correctly implemented GSO will no doubt be faster than splitting the
> skb. But GSO will also get (a bit) slower for the non-urgent-data case,
> where the slowdown is not compensated by anything. Or did I miss
> something obvious?

Unless you've got numbers I'm not buying this :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
