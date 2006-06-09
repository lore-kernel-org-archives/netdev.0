From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 06/17] neighbour.c, pneigh_get_next() skips published entry
Date: Fri, 09 Jun 2006 14:52:46 +1000
Message-ID: <E1FoYzG-0001id-00@gondolin.me.apana.org.au>
References: <413FEEF1743111439393FB76D0221E4804A56900@leopard.zoo.q9networks.com>
Cc: davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45838 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965161AbWFIExA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 00:53:00 -0400
To: Jari.Takkala@Q9.com (Jari Takkala)
In-Reply-To: <413FEEF1743111439393FB76D0221E4804A56900@leopard.zoo.q9networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jari Takkala <Jari.Takkala@q9.com> wrote:
> 
> I have not checked neigh seqfile iterators, the problem may exist in
> there as well. My patch solves this issue for us, however a more elegant
> solution would be most welcome.  Could the root of the problem be that
> *pos is off by one when pneigh_get_idx() is called?

Could you post an exact sequence of commands that reproduces the bug?
That would help us in verifying your fix.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
