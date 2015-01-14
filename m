From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ipv6:icmp:remove unnecessary brackets
Date: Wed, 14 Jan 2015 17:23:59 +0800
Message-ID: <1421227439-13996-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:41638 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbbANJYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 04:24:07 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so8771307pdi.7
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 01:24:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are too many brackets. Maybe only one bracket is enough.

Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/ipv6/icmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index d674152..a5e9519 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -427,7 +427,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Dest addr check
 	 */
 
-	if ((addr_type & IPV6_ADDR_MULTICAST || skb->pkt_type != PACKET_HOST)) {
+	if (addr_type & IPV6_ADDR_MULTICAST || skb->pkt_type != PACKET_HOST) {
 		if (type != ICMPV6_PKT_TOOBIG &&
 		    !(type == ICMPV6_PARAMPROB &&
 		      code == ICMPV6_UNK_OPTION &&
-- 
1.9.1
