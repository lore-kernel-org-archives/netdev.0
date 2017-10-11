From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net 2/7] net: qualcomm: rmnet: Remove some unused defines
Date: Tue, 10 Oct 2017 18:20:24 -0600
Message-ID: <1507681229-27861-3-git-send-email-subashab@codeaurora.org>
References: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43656 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756641AbdJKAVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 20:21:11 -0400
In-Reply-To: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of these constants were used in the initial patchset where
custom netlink configuration was used and hence are no longer relevant.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
index 7967198..49102f9 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
@@ -19,23 +19,15 @@
 #define RMNET_TX_QUEUE_LEN         1000
 
 /* Constants */
-#define RMNET_EGRESS_FORMAT__RESERVED__         BIT(0)
 #define RMNET_EGRESS_FORMAT_MAP                 BIT(1)
 #define RMNET_EGRESS_FORMAT_AGGREGATION         BIT(2)
 #define RMNET_EGRESS_FORMAT_MUXING              BIT(3)
-#define RMNET_EGRESS_FORMAT_MAP_CKSUMV3         BIT(4)
-#define RMNET_EGRESS_FORMAT_MAP_CKSUMV4         BIT(5)
 
-#define RMNET_INGRESS_FIX_ETHERNET              BIT(0)
 #define RMNET_INGRESS_FORMAT_MAP                BIT(1)
 #define RMNET_INGRESS_FORMAT_DEAGGREGATION      BIT(2)
 #define RMNET_INGRESS_FORMAT_DEMUXING           BIT(3)
 #define RMNET_INGRESS_FORMAT_MAP_COMMANDS       BIT(4)
-#define RMNET_INGRESS_FORMAT_MAP_CKSUMV3        BIT(5)
-#define RMNET_INGRESS_FORMAT_MAP_CKSUMV4        BIT(6)
 
-/* Pass the frame up the stack with no modifications to skb->dev */
-#define RMNET_EPMODE_NONE (0)
 /* Replace skb->dev to a virtual rmnet device and pass up the stack */
 #define RMNET_EPMODE_VND (1)
 /* Pass the frame directly to another device with dev_queue_xmit() */
-- 
1.9.1
