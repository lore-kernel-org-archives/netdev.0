From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: udp6_gro_complete() is static
Date: Tue, 09 Sep 2014 08:16:17 -0700
Message-ID: <1410275777.7106.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41801 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaIIPQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:16:19 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so9216403pdj.34
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 08:16:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/ipv6/udp_offload.c:159:5: warning: symbol 'udp6_gro_complete' was
not declared. Should it be static?

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 57c67ff4bd92 ("udp: additional GRO support")
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv6/udp_offload.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 89cb9a9b8537..a1ad34b1c4ec 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -156,7 +156,7 @@ flush:
 	return NULL;
 }
 
-int udp6_gro_complete(struct sk_buff *skb, int nhoff)
+static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
