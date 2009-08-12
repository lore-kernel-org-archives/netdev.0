From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 16/36] bnx2x: Adding Likely directive
Date: Wed, 12 Aug 2009 21:23:23 +0300
Message-ID: <1250101403.27379.168.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3711 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbZHLSYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 594168a..c4427ef 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1612,7 +1612,8 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 				skb = new_skb;
 
-			} else if (bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0) {
+			} else
+			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
 				pci_unmap_single(bp->pdev,
 					pci_unmap_addr(rx_buf, mapping),
 						 bp->rx_buf_size,
-- 
1.5.4.3




