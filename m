From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] xfrm4: Remove duplicate semicolon
Date: Sat, 28 Jun 2014 14:12:44 +0200
Message-ID: <1403957564-6069-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:49298 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbaF1MMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 08:12:53 -0400
Received: by mail-we0-f178.google.com with SMTP id x48so6175413wes.9
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 05:12:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3328715e6c1fc (xfrm4: Add IPsec protocol multiplexer) adds a
duplicate semicolon after the return-statement.

Although it has no negative impact, the second semicolon should be
removed.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/xfrm4_protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index a2ce0101eaac..dccefa9d84cf 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -124,7 +124,7 @@ static int xfrm4_ah_rcv(struct sk_buff *skb)
 
 	for_each_protocol_rcu(ah4_handlers, handler)
 		if ((ret = handler->handler(skb)) != -EINVAL)
-			return ret;;
+			return ret;
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
-- 
1.9.3
