From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] bnx2x: fix typos in "configure"
Date: Thu, 18 Dec 2014 09:04:35 +0100
Message-ID: <fcb186d22a0f6a2e3b07a6a88baebbada6742003.1418889837.git.jbenc@redhat.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbaLRIFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 03:05:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed when debugging ptp.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 691f0bf09ee1..9f5e38769a29 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13256,7 +13256,7 @@ static int bnx2x_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 		return -EFAULT;
 	}
 
-	DP(BNX2X_MSG_PTP, "Configrued val = %d, period = %d\n", best_val,
+	DP(BNX2X_MSG_PTP, "Configured val = %d, period = %d\n", best_val,
 	   best_period);
 
 	return 0;
@@ -14784,7 +14784,7 @@ static int bnx2x_hwtstamp_ioctl(struct bnx2x *bp, struct ifreq *ifr)
 		-EFAULT : 0;
 }
 
-/* Configrues HW for PTP */
+/* Configures HW for PTP */
 static int bnx2x_configure_ptp(struct bnx2x *bp)
 {
 	int rc, port = BP_PORT(bp);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index b0779d773343..6fe547c93e74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7549,7 +7549,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define IGU_REG_SISR_MDPC_WOMASK_UPPER		0x05a6
 
 #define IGU_REG_RESERVED_UPPER				0x05ff
-/* Fields of IGU PF CONFIGRATION REGISTER */
+/* Fields of IGU PF CONFIGURATION REGISTER */
 #define IGU_PF_CONF_FUNC_EN	  (0x1<<0)  /* function enable	      */
 #define IGU_PF_CONF_MSI_MSIX_EN   (0x1<<1)  /* MSI/MSIX enable	      */
 #define IGU_PF_CONF_INT_LINE_EN   (0x1<<2)  /* INT enable	      */
@@ -7557,7 +7557,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define IGU_PF_CONF_SINGLE_ISR_EN (0x1<<4)  /* single ISR mode enable */
 #define IGU_PF_CONF_SIMD_MODE	  (0x1<<5)  /* simd all ones mode     */
 
-/* Fields of IGU VF CONFIGRATION REGISTER */
+/* Fields of IGU VF CONFIGURATION REGISTER */
 #define IGU_VF_CONF_FUNC_EN	   (0x1<<0)  /* function enable        */
 #define IGU_VF_CONF_MSI_MSIX_EN    (0x1<<1)  /* MSI/MSIX enable        */
 #define IGU_VF_CONF_PARENT_MASK    (0x3<<2)  /* Parent PF	       */
-- 
1.8.3.1
