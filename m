From: Vitaly Wool <vwool@ru.mvista.com>
Subject: [PATCH] smc911x: fix compilation breakage wjen debug is on
Date: Fri, 27 Apr 2007 14:42:09 +0400
Message-ID: <20070427144209.00006694.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:55792 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1755573AbXD0KmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 06:42:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jeff,

the patch below fixes compilation breakage of smc911x driver when ENABLE_SMC_DEBUG_PKTS equals to 1.

 smc911x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Index: linux-2.6/drivers/net/smc911x.c
===================================================================
--- linux-2.6.orig/drivers/net/smc911x.c
+++ linux-2.6/drivers/net/smc911x.c
@@ -499,7 +499,7 @@ static inline void	 smc911x_rcv(struct n
 		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
 		SMC_PULL_DATA(data, pkt_len+2+3);
 
-		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name,);
+		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
 		dev->last_rx = jiffies;
 		skb->dev = dev;
