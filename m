From: <Frank.Li@freescale.com>
Subject: [Patch net-next v3 3/4] net:fec: increase DMA queue number
Date: Wed, 17 Sep 2014 05:18:53 +0800
Message-ID: <1410902334-7827-4-git-send-email-Frank.Li@freescale.com>
References: <1410902334-7827-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	"Fugang Duan" <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0134.outbound.protection.outlook.com ([157.56.110.134]:5984
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753820AbaIPWXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 18:23:13 -0400
In-Reply-To: <1410902334-7827-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

when enable interrupt coalesce, 8 BD is not enough.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index b948cdb..c0a66e7 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -296,7 +296,7 @@ struct bufdesc_ex {
  * the skbuffer directly.
  */
 
-#define FEC_ENET_RX_PAGES	8
+#define FEC_ENET_RX_PAGES	256
 #define FEC_ENET_RX_FRSIZE	2048
 #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
 #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
-- 
1.9.1
