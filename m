From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: SAD entries do not expire correctly after
	suspend-resume
Date: Mon, 9 Nov 2009 14:23:54 -0500
Message-ID: <20091109192354.GA10088@gondor.apana.org.au>
References: <20091108211249.2ecdfd38@penta.localdomain> <20091109153910.GA8039@gondor.apana.org.au> <20091109133153.668bb296@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, peterz@infradead.org,
	yoshfuji@linux-ipv6.org, tglx@linutronix.de, mingo@elte.hu
To: Yury Polyanskiy <ypolyans@princeton.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34364 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751470AbZKITXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 14:23:54 -0500
Content-Disposition: inline
In-Reply-To: <20091109133153.668bb296@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2009 at 01:31:53PM -0500, Yury Polyanskiy wrote:
>
> But why would it be inoperable for hours? 

As I said the other end is buggy and won't allow you to reconnect
when you've just connected successfully.  Eventially it'll timeout
and let you back in but it could take hours.

> In any case, running ntpdate before racoon fixes the problem.

Not if the only trusted time source is over IPsec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
