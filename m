From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP]: Fix TCP header misalignment
Date: Mon, 19 Nov 2007 09:28:26 +0800
Message-ID: <E1ItvR4-00007i-00@gondolin.me.apana.org.au>
References: <20071118.133602.193701128.davem@davemloft.net>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2207 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752518AbXKSB23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 20:28:29 -0500
In-Reply-To: <20071118.133602.193701128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> I'm getting this without IPSEC FWIW.  I believe it occurs when I talk
> to sites with sub-1500 MTUs.

It is possible to get this with any MTU that's not a multiple
of 4.  I was basing my comment above on the fact that such MTUs
are usually rare.  However, perhaps that is no longer the case
on today's Internet :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
