From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 1/5] smc911x: Compile error with debugging enabled
Date: Wed, 23 Aug 2006 15:16:04 -0400
Message-ID: <1156360564.15824.71.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.somanetworks.com ([216.126.67.42]:19103 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S965121AbWHWTQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:16:08 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:16:04 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a compile error when debugging is turned on.

Signed-off-by: Jason Borg <jcborg@somanetworks.com>
---

diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.c linux-2.6.18-rc4/drivers/net/smc911x.c
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.c	2006-08-22 12:02:50.000000000 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-08-22 15:35:01.674983089 -0400
@@ -499,7 +499,7 @@ static inline void	 smc911x_rcv(struct n
 		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
 		SMC_PULL_DATA(data, pkt_len+2+3);
 
-		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name,);
+		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
 		dev->last_rx = jiffies;
 		skb->dev = dev;


