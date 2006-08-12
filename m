From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Sat, 12 Aug 2006 13:05:44 +1000
Message-ID: <E1GBjom-0004oA-00@gondolin.me.apana.org.au>
References: <20060811153549.GA16351@ms2.inr.ac.ru>
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39687 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750789AbWHLDGL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 23:06:11 -0400
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
In-Reply-To: <20060811153549.GA16351@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> Probably, unicasts sent due to NLM_F_ECHO should somehow override
> rcvbuf limits.

Actually I think the only safe solution is to allocate a separate
socket for multicast messages.  In other words, if you want reliable
unicast reception on a socket, don't bind it to a multicast group.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
