From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 3/5] gianfar: GRO_DROP is unlikely
Date: Tue, 12 Feb 2013 14:47:15 +0200
Message-ID: <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:10384
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932967Ab3BLMsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:48:39 -0500
In-Reply-To: <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 096fb5f..5622134 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2745,7 +2745,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Send the packet up the stack */
 	ret = napi_gro_receive(napi, skb);
 
-	if (GRO_DROP == ret)
+	if (unlikely(GRO_DROP == ret))
 		priv->extra_stats.kernel_dropped++;
 
 	return 0;
-- 
1.6.6
