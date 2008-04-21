From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: poor network loopback performance and scalability (was: Re:	[RFC,PATCH] loopback: calls netif_receive_skb() instead of	netif_rx())
Date: Mon, 21 Apr 2008 11:24:04 +0800
Message-ID: <E1JnmdQ-0001qO-00@gondolin.me.apana.org.au>
References: <20080331113602.GA13526@elte.hu>
Cc: davem@davemloft.net, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: mingo@elte.hu (Ingo Molnar)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45137 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753609AbYDUDYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 23:24:24 -0400
In-Reply-To: <20080331113602.GA13526@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> wrote:
> 
>   # ifconfig lo mtu 1048576

Chiming in late here, but 1048576 can't possibly work with IP
which uses a 16-bit quantity as the length header.  In fact a
quick test seems to indicate that an 1048576 mtu doesn't generate
anything bigger than the default 16K mtu.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
