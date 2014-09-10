From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4: Allow T4/T5 firmware sizes up to 1MB
Date: Wed, 10 Sep 2014 17:44:27 +0530
Message-ID: <1410351271-26428-2-git-send-email-hariprasad@chelsio.com>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42769
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750882AbaIJMI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:08:58 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 35e3d8e..06fa583 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -175,7 +175,7 @@ enum {
 	 * Location of firmware image in FLASH.
 	 */
 	FLASH_FW_START_SEC = 8,
-	FLASH_FW_NSECS = 8,
+	FLASH_FW_NSECS = 16,
 	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
 	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
 
-- 
1.7.1
