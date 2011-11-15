From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: return NET_RX_DROP when arp_rcv drops the received packet.
Date: Tue, 15 Nov 2011 10:09:47 +0800
Message-ID: <1321322987-16042-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46526 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174Ab1KOCJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 21:09:53 -0500
Received: by iage36 with SMTP id e36so7904344iag.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 18:09:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

return NET_RX_DROP when arp_rcv drops the received packet.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/arp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d732827..9967385 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -969,7 +969,7 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 freeskb:
 	kfree_skb(skb);
 out_of_mem:
-	return 0;
+	return NET_RX_DROP;
 }
 
 /*
-- 
1.7.1
