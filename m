From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 1/5] bnxt_en: Change sp events definitions to represent bit position.
Date: Thu, 5 Nov 2015 16:25:47 -0500
Message-ID: <1446758751-27999-2-git-send-email-mchan@broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jeffrey Huang <huangjw@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:6079 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757017AbbKEVZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:52 -0500
In-Reply-To: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

Fix the sp event bits to be bit positions instead of bit values since
the bit helper functions are expecting the former.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 4f2267c..4cae492 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -959,11 +959,11 @@ struct bnxt {
 #define BNXT_RX_MASK_SP_EVENT		0
 #define BNXT_RX_NTP_FLTR_SP_EVENT	1
 #define BNXT_LINK_CHNG_SP_EVENT		2
-#define BNXT_HWRM_EXEC_FWD_REQ_SP_EVENT	4
-#define BNXT_VXLAN_ADD_PORT_SP_EVENT	8
-#define BNXT_VXLAN_DEL_PORT_SP_EVENT	16
-#define BNXT_RESET_TASK_SP_EVENT	32
-#define BNXT_RST_RING_SP_EVENT		64
+#define BNXT_HWRM_EXEC_FWD_REQ_SP_EVENT	3
+#define BNXT_VXLAN_ADD_PORT_SP_EVENT	4
+#define BNXT_VXLAN_DEL_PORT_SP_EVENT	5
+#define BNXT_RESET_TASK_SP_EVENT	6
+#define BNXT_RST_RING_SP_EVENT		7
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
