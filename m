From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] ath10k: make ath10k_hw_ce_regs const
Date: Thu, 14 Sep 2017 00:31:52 +0530
Message-ID: <1505329312-26432-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, kvalo@qca.qualcomm.com,
        ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make them const as they are not modified in the file referencing
them. They are only stored in the const field 'hw_ce_reg' of an ath10k
structure. Also, make the declarations in the header const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/ath/ath10k/hw.c | 4 ++--
 drivers/net/wireless/ath/ath10k/hw.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/hw.c b/drivers/net/wireless/ath/ath10k/hw.c
index a860691..07df7c6 100644
--- a/drivers/net/wireless/ath/ath10k/hw.c
+++ b/drivers/net/wireless/ath/ath10k/hw.c
@@ -310,7 +310,7 @@
 	.wm_high	= &wcn3990_dst_wm_high,
 };
 
-struct ath10k_hw_ce_regs wcn3990_ce_regs = {
+const struct ath10k_hw_ce_regs wcn3990_ce_regs = {
 	.sr_base_addr		= 0x00000000,
 	.sr_size_addr		= 0x00000008,
 	.dr_base_addr		= 0x0000000c,
@@ -457,7 +457,7 @@ struct ath10k_hw_ce_regs wcn3990_ce_regs = {
 	.wm_high	= &qcax_dst_wm_high,
 };
 
-struct ath10k_hw_ce_regs qcax_ce_regs = {
+const struct ath10k_hw_ce_regs qcax_ce_regs = {
 	.sr_base_addr		= 0x00000000,
 	.sr_size_addr		= 0x00000004,
 	.dr_base_addr		= 0x00000008,
diff --git a/drivers/net/wireless/ath/ath10k/hw.h b/drivers/net/wireless/ath/ath10k/hw.h
index 0c089f6..f80840f 100644
--- a/drivers/net/wireless/ath/ath10k/hw.h
+++ b/drivers/net/wireless/ath/ath10k/hw.h
@@ -369,8 +369,8 @@ struct ath10k_hw_values {
 extern const struct ath10k_hw_values qca9888_values;
 extern const struct ath10k_hw_values qca4019_values;
 extern const struct ath10k_hw_values wcn3990_values;
-extern struct ath10k_hw_ce_regs wcn3990_ce_regs;
-extern struct ath10k_hw_ce_regs qcax_ce_regs;
+extern const struct ath10k_hw_ce_regs wcn3990_ce_regs;
+extern const struct ath10k_hw_ce_regs qcax_ce_regs;
 
 void ath10k_hw_fill_survey_time(struct ath10k *ar, struct survey_info *survey,
 				u32 cc, u32 rcc, u32 cc_prev, u32 rcc_prev);
-- 
1.9.1
