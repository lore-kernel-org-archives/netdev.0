From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 01 Dec 2008 21:39:54 +0800
Message-ID: <E1L790E-0005hF-K2@gondolin.me.apana.org.au>
References: <87hc5o5eh5.fsf@basil.nowhere.org>
Cc: herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: andi@firstfloor.org (Andi Kleen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51287 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751348AbYLANkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 08:40:03 -0500
In-Reply-To: <87hc5o5eh5.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:
>
> I'm not sure that's a useful argument.  When cryptography is not
> CPU bound anymore it will be memory bandwidth bound. And in this case
> you can still get a win out of parallelization if you parallelize
> over multiple sockets with own memory controller or own FSB
> because that will give you more bandwidth.

That's a good point.

Of course you can achieve the same thing by doing the parallel
processing within the crypto layer, which would also benefit other
crypto users, such as disk encryption.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
