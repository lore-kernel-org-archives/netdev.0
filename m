From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 7/9] net: hns3: Fix typo error for feild in hclge_tm
Date: Wed, 20 Sep 2017 18:52:56 +0800
Message-ID: <1505904778-53217-8-git-send-email-linyunsheng@huawei.com>
References: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a typo error for feild, which should be field.

Fixes: 848440544b41f ("net: hns3: Add support of TX Scheduler & Shaper to HNS3 driver")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c    | 20 ++++++++++----------
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h    |  4 ++--
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index c91dbf1..fe659f7 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -280,11 +280,11 @@ static int hclge_tm_pg_shapping_cfg(struct hclge_dev *hdev,
 
 	shap_cfg_cmd->pg_id = pg_id;
 
-	hclge_tm_set_feild(shap_cfg_cmd->pg_shapping_para, IR_B, ir_b);
-	hclge_tm_set_feild(shap_cfg_cmd->pg_shapping_para, IR_U, ir_u);
-	hclge_tm_set_feild(shap_cfg_cmd->pg_shapping_para, IR_S, ir_s);
-	hclge_tm_set_feild(shap_cfg_cmd->pg_shapping_para, BS_B, bs_b);
-	hclge_tm_set_feild(shap_cfg_cmd->pg_shapping_para, BS_S, bs_s);
+	hclge_tm_set_field(shap_cfg_cmd->pg_shapping_para, IR_B, ir_b);
+	hclge_tm_set_field(shap_cfg_cmd->pg_shapping_para, IR_U, ir_u);
+	hclge_tm_set_field(shap_cfg_cmd->pg_shapping_para, IR_S, ir_s);
+	hclge_tm_set_field(shap_cfg_cmd->pg_shapping_para, BS_B, bs_b);
+	hclge_tm_set_field(shap_cfg_cmd->pg_shapping_para, BS_S, bs_s);
 
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
@@ -307,11 +307,11 @@ static int hclge_tm_pri_shapping_cfg(struct hclge_dev *hdev,
 
 	shap_cfg_cmd->pri_id = pri_id;
 
-	hclge_tm_set_feild(shap_cfg_cmd->pri_shapping_para, IR_B, ir_b);
-	hclge_tm_set_feild(shap_cfg_cmd->pri_shapping_para, IR_U, ir_u);
-	hclge_tm_set_feild(shap_cfg_cmd->pri_shapping_para, IR_S, ir_s);
-	hclge_tm_set_feild(shap_cfg_cmd->pri_shapping_para, BS_B, bs_b);
-	hclge_tm_set_feild(shap_cfg_cmd->pri_shapping_para, BS_S, bs_s);
+	hclge_tm_set_field(shap_cfg_cmd->pri_shapping_para, IR_B, ir_b);
+	hclge_tm_set_field(shap_cfg_cmd->pri_shapping_para, IR_U, ir_u);
+	hclge_tm_set_field(shap_cfg_cmd->pri_shapping_para, IR_S, ir_s);
+	hclge_tm_set_field(shap_cfg_cmd->pri_shapping_para, BS_B, bs_b);
+	hclge_tm_set_field(shap_cfg_cmd->pri_shapping_para, BS_S, bs_s);
 
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
index 7e67337..85158b0 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
@@ -94,10 +94,10 @@ struct hclge_bp_to_qs_map_cmd {
 	u32 rsvd1;
 };
 
-#define hclge_tm_set_feild(dest, string, val) \
+#define hclge_tm_set_field(dest, string, val) \
 			hnae_set_field((dest), (HCLGE_TM_SHAP_##string##_MSK), \
 				       (HCLGE_TM_SHAP_##string##_LSH), val)
-#define hclge_tm_get_feild(src, string) \
+#define hclge_tm_get_field(src, string) \
 			hnae_get_field((src), (HCLGE_TM_SHAP_##string##_MSK), \
 				       (HCLGE_TM_SHAP_##string##_LSH))
 
-- 
1.9.1
