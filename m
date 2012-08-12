From: Joren Van Onder <joren.vanonder@gmail.com>
Subject: [PATCH] bnx2x: Fix compiler warnings
Date: Sun, 12 Aug 2012 05:10:35 +0200
Message-ID: <1344741035-1493-1-git-send-email-joren.vanonder@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joren Van Onder <joren.vanonder@gmail.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59705 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928Ab2HLDYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 23:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following compiler warnings:

 - drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2908:3: warning: comparison
   of distinct pointer types lacks a cast [enabled by default]
 - drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:1709:7: warning: comparison
   of distinct pointer types lacks a cast [enabled by default]

Signed-off-by: Joren Van Onder <joren.vanonder@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 77bcd4c..463b9ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1278,7 +1278,7 @@ struct bnx2x {
 #define BNX2X_FW_RX_ALIGN_START	(1UL << BNX2X_RX_ALIGN_SHIFT)
 
 #define BNX2X_FW_RX_ALIGN_END					\
-	max(1UL << BNX2X_RX_ALIGN_SHIFT, 			\
+	max_t(u64, 1UL << BNX2X_RX_ALIGN_SHIFT,			\
 	    SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 #define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
-- 
1.7.9.5
