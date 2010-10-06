From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 12/19] bnx2x: remove unused fields in main
 driver structure
Date: Wed, 6 Oct 2010 15:29:41 +0200
Message-ID: <1286371781.30552.46.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932228Ab0JFNkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 6f8e266..9b78a04 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1053,15 +1053,8 @@ struct bnx2x {
 #ifdef BCM_CNIC
 	u32			cnic_flags;
 #define BNX2X_CNIC_FLAG_MAC_SET		1
-
-	void			*t1;
-	dma_addr_t		t1_mapping;
 	void			*t2;
 	dma_addr_t		t2_mapping;
-	void			*timers;
-	dma_addr_t		timers_mapping;
-	void			*qm;
-	dma_addr_t		qm_mapping;
 	struct cnic_ops		*cnic_ops;
 	void			*cnic_data;
 	u32			cnic_tag;
-- 
1.7.1




