From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 32/41]bnx2x: Better struct naming
Date: Thu, 12 Feb 2009 20:38:11 +0200
Message-ID: <1234463891.1863.164.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122AbZBLSih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 32/41]bnx2x: Better struct naming
This is the device info from the chip shared memory - rename to avoid confusion

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 8452605..88b2aa3 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -488,7 +488,7 @@ struct port_feat_cfg {			    /* port 0: 0x454  port 1: 0x4c8 */
 /****************************************************************************
  * Device Information							    *
  ****************************************************************************/
-struct dev_info {						    /* size */
+struct shm_dev_info {						    /* size */
 
 	u32    bc_rev; /* 8 bits each: major, minor, build */	       /* 4 */
 
@@ -841,7 +841,7 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 #define SHR_MEM_VALIDITY_ACTIVE_MFW_NONE	    0x000001c0
 #define SHR_MEM_VALIDITY_ACTIVE_MFW_MASK	    0x000001c0
 
-	struct dev_info 	dev_info;		 /* 0x8     (0x438) */
+	struct shm_dev_info	dev_info;		 /* 0x8     (0x438) */
 
 	u8			reserved[52*PORT_MAX];
 
-- 
1.5.4.3




