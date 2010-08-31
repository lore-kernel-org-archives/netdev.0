From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] gro: unexport tcp4_gro_receive and
 tcp4_gro_complete
Date: Tue, 31 Aug 2010 22:23:47 +0200
Message-ID: <1283286227.2198.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51507 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201Ab0HaUYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 16:24:17 -0400
Received: by wyb35 with SMTP id 35so8302092wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 13:24:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp4_gro_receive() and tcp4_gro_complete() dont need to be exported.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0207662..a0232f3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2571,7 +2571,6 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	return tcp_gro_receive(head, skb);
 }
-EXPORT_SYMBOL(tcp4_gro_receive);
 
 int tcp4_gro_complete(struct sk_buff *skb)
 {
@@ -2584,7 +2583,6 @@ int tcp4_gro_complete(struct sk_buff *skb)
 
 	return tcp_gro_complete(skb);
 }
-EXPORT_SYMBOL(tcp4_gro_complete);
 
 struct proto tcp_prot = {
 	.name			= "TCP",


