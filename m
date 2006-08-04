From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 04 Aug 2006 15:52:40 +1000
Message-ID: <E1G8sbw-0003mT-00@gondolin.me.apana.org.au>
References: <20060803135925.GA28348@2ka.mipt.ru>
Cc: arnd@arndnet.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24590 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030323AbWHDFwy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 01:52:54 -0400
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20060803135925.GA28348@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> But it does not support splitting them into page sized chunks, so it
> requires the whole jumbo frame allocation in one contiguous chunk, 9k
> will be transferred into 16k allocation (order 3), since SLAB uses
> power-of-2 allocation.

Actually order 3 is 32KB.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
