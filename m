From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: __netif_receive_skb should be static
Date: Mon, 29 Mar 2010 07:24:52 +0200
Message-ID: <1269840292.2256.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42140 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab0C2FY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 01:24:57 -0400
Received: by bwz1 with SMTP id 1so3267516bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 22:24:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index bcb3ed2..887aa84 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2621,7 +2621,7 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
-int __netif_receive_skb(struct sk_buff *skb)
+static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;


