From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Sun, 03 Feb 2008 09:59:53 +1100
Message-ID: <E1JLRKz-0008Fz-00@gondolin.me.apana.org.au>
References: <20080201043113.GA10720@one.firstfloor.org>
Cc: rick.jones2@hp.com, andi@firstfloor.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: andi@firstfloor.org (Andi Kleen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48488 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934028AbYBBXAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 18:00:16 -0500
In-Reply-To: <20080201043113.GA10720@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:
> 
> Hmm, that would probably be possible for TBF, but I'm not sure this can be
> really done in a useful way for the more complicated qdiscs. Especially
> since they would likely need to turn on/off GSO regularly when dynamic
> circumstances change and there is not really a good way to affect a socket 
> after it was created.

You don't need to change the socket if you just call skb_gso_segment
when necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
