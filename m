From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4: ip_options_compile() how can we avoid blowing up on a NULL skb???
Date: Fri, 17 Nov 2006 11:37:32 +1100
Message-ID: <E1GkrjY-0004Dt-00@gondolin.me.apana.org.au>
References: <20061116.184730.35014107.davem@davemloft.net>
Cc: jesper.juhl@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:62733 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1424818AbWKQAhh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 19:37:37 -0500
To: davem@davemloft.net (David Miller)
In-Reply-To: <20061116.184730.35014107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> I'm very happy to accept a patch which assert's this using BUG()
> checks :-)

A BUG() won't be necessary because the NULL pointer dereferences will
OOPS anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
