From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.27] cxgb3: Allow 64KB firmware images.
Date: Sat, 26 Jul 2008 15:40:56 -0500
Message-ID: <20080726204056.1366.28529.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, rdreier@cisco.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41880 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756605AbYGZUk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 16:40:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff,

This small patch is needed to allow loading the 7.0 firmware, which is
required for 2.6.27.  Any chance of this making 2.6.27-rc1?

Thanks,

Steve.

----
cxgb3: Allow 64KB firmware images.

Starting with FW version 7.0, the driver needs to allow larger images.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 47d5178..04c0e90 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -683,7 +683,7 @@ enum {
 	SF_ERASE_SECTOR = 0xd8,	/* erase sector */
 
 	FW_FLASH_BOOT_ADDR = 0x70000,	/* start address of FW in flash */
-	FW_VERS_ADDR = 0x77ffc,    /* flash address holding FW version */
+	FW_VERS_ADDR = 0x7fffc,    /* flash address holding FW version */
 	FW_MIN_SIZE = 8            /* at least version and csum */
 };
 
