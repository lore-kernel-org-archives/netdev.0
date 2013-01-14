From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 02/10] bnx2x: Add an additional fatal hw
 assertion - BRB_HW_INTERRUPT
Date: Mon, 14 Jan 2013 17:11:42 +0200
Message-ID: <1358176310-31504-3-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4309 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757247Ab3ANQKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:00 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 02c93e3..cab91da 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2154,6 +2154,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 				(AEU_INPUTS_ATTN_BITS_TSDM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TCM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TSEMI_HW_INTERRUPT | \
+				 AEU_INPUTS_ATTN_BITS_BRB_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_PBCLIENT_HW_INTERRUPT)
 #define HW_PRTY_ASSERT_SET_0	(AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR | \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 765e2dc..dec014e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5991,6 +5991,7 @@
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define AEU_INPUTS_ATTN_BITS_ATC_HW_INTERRUPT			 (0x1<<4)
 #define AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR			 (0x1<<5)
+#define AEU_INPUTS_ATTN_BITS_BRB_HW_INTERRUPT			 (0x1<<19)
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR			 (0x1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT			 (0x1<<31)
 #define AEU_INPUTS_ATTN_BITS_CCM_PARITY_ERROR			 (0x1<<30)
-- 
1.8.1.227.g44fe835
