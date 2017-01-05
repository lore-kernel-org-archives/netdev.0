From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCHv2 1/1] r8169: fix the typo in the comment
Date: Thu,  5 Jan 2017 03:02:54 -0500
Message-ID: <1483603374-16765-1-git-send-email-yanjun.zhu@oracle.com>
Cc: Zhu Yanjun <yanjun.zhu@oracle.com>
To: nic_swsd@realtek.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50760 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968428AbdAEIDN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 03:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From the realtek data sheet, the PID0 should be bit 0.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
Change from v1 to v2:
 change the commit header. 

 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 44389c9..8f1623b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -696,7 +696,7 @@ enum rtl_tx_desc_bit_1 {
 enum rtl_rx_desc_bit {
 	/* Rx private */
 	PID1		= (1 << 18), /* Protocol ID bit 1/2 */
-	PID0		= (1 << 17), /* Protocol ID bit 2/2 */
+	PID0		= (1 << 17), /* Protocol ID bit 0/2 */
 
 #define RxProtoUDP	(PID1)
 #define RxProtoTCP	(PID0)
-- 
2.7.4
