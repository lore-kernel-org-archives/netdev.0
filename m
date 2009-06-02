From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 4/4] net: skb cleanup
Date: Tue, 02 Jun 2009 17:20:21 +0200
Message-ID: <4A254335.8050603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40966 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbZFBPUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:20:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can remove anonymous union now it has one field.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9ef6eb2..7305da9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -322,9 +322,7 @@ struct sk_buff {
 	ktime_t			tstamp;
 	struct net_device	*dev;
 
-	union {
-		unsigned long		_skb_dst;
-	};
+	unsigned long		_skb_dst;
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
 #endif
