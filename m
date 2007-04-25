From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Wed, 25 Apr 2007 10:47:08 +1000
Message-ID: <E1HgVf2-0001K7-00@gondolin.me.apana.org.au>
References: <20070424073151.GA2333@ff.dom.local>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	snakebyte@gmx.de
To: jarkao2@o2.pl (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1324 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753493AbXDYArv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 20:47:51 -0400
In-Reply-To: <20070424073151.GA2333@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski <jarkao2@o2.pl> wrote:
>
> My proposal is: maybe Eric could change this in
> xfrm6_tunnel_rcv() from xfrm6_tunnel.c e.g. like this:
> 
> return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
> 
> and, if no errors in testing, he could resubmit this patch? 

I agree, this is the right fix.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
