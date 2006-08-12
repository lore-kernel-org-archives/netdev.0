From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Sat, 12 Aug 2006 15:05:31 +0400
Message-ID: <20060812110531.GB31479@ms2.inr.ac.ru>
References: <20060811153549.GA16351@ms2.inr.ac.ru> <E1GBjom-0004oA-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:25752 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964824AbWHLLFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 07:05:40 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GBjom-0004oA-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Actually I think the only safe solution is to allocate a separate
> socket for multicast messages.  In other words, if you want reliable
> unicast reception on a socket, don't bind it to a multicast group.

Yes, it was the point of my advocacy of NLM_F_ECHO. :-)

Alexey
