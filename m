From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: include/linux/skbuff.h: checksumming documentation
Date: Mon, 08 Sep 2008 20:10:11 +1000
Message-ID: <E1KcdhD-0003sr-UA@gondolin.me.apana.org.au>
References: <49c0ff980809051037p14de9835y4293f7c63b23a37d@mail.gmail.com>
Cc: ben-linux@fluff.org, netdev@vger.kernel.org
To: prodyuth@gmail.com (prodyut hazarika)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49813 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751075AbYIHKKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 06:10:20 -0400
In-Reply-To: <49c0ff980809051037p14de9835y4293f7c63b23a37d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prodyut hazarika <prodyuth@gmail.com> wrote:
> 
> Note that Linux TCP stack does not support IP checksum offload.

Unless you've got options, the IP header is only 20 bytes.  Plus
we've just written it so it's hot in the cache, so calculating
the IP checksum is essentially free.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
