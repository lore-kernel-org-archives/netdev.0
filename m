From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: ipv4: un-inline ip_finish_output2
Date: Fri, 12 Jun 2015 12:12:22 +0200
Message-ID: <1434103942-20176-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52773 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752484AbbFLKMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 06:12:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     text    data     bss     dec     hex filename
old: 16527      44       0   16571    40bb net/ipv4/ip_output.o
new: 14935      44       0   14979    3a83 net/ipv4/ip_output.o

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f5f5ef1..55f3c2e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -172,7 +172,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
+static int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
-- 
2.0.5
