From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] xfrm4: Remove duplicate semicolon
Date: Wed, 30 Jul 2014 13:12:28 +0200
Message-ID: <1406718748-21144-4-git-send-email-steffen.klassert@secunet.com>
References: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43718 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663AbaG3LMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 07:12:52 -0400
In-Reply-To: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>

3328715e6c1fc (xfrm4: Add IPsec protocol multiplexer) adds a
duplicate semicolon after the return-statement.

Although it has no negative impact, the second semicolon should be
removed.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index a2ce010..dccefa9 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -124,7 +124,7 @@ static int xfrm4_ah_rcv(struct sk_buff *skb)
 
 	for_each_protocol_rcu(ah4_handlers, handler)
 		if ((ret = handler->handler(skb)) != -EINVAL)
-			return ret;;
+			return ret;
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
-- 
1.9.1
