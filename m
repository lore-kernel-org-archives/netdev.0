From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Sun, 20 Jul 2008 22:32:35 +0800
Message-ID: <E1KKZxj-0000vD-00@gondolin.me.apana.org.au>
References: <20080717.152447.89672084.davem@davemloft.net>
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40760 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753157AbYGTOcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 10:32:45 -0400
In-Reply-To: <20080717.152447.89672084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> Are we really really sure it's OK to let users do this?  :)

Well security questions aside, I have seen this used on routers
to ensure certain traffic (e.g., VOIP) get preferential treatment
when it comes to transmission.

Of course some of these routers setup custom qdiscs so they wouldn't
be affected, but there may be ones out there relying on the default
pfifo.

Now I understand that having a pfifo is an anathema to multi-queue TX
by definition.  However, even if we couldn't preserve the full
semantics by default, if we could at least preserve the ordering
within each queue it would still be a plus.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
