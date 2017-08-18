From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: hns3: fix a handful of spelling mistakes
Date: Fri, 18 Aug 2017 16:30:00 +0100
Message-ID: <20170818153000.18516-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trival fix to spelling mistakes:

firware -> firmware
invald -> invalid
mutilcast -> multicast

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c  | 2 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
index bc869842728f..8b511e6e0ce9 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
@@ -334,7 +334,7 @@ int hclge_cmd_init(struct hclge_dev *hdev)
 	}
 	hdev->fw_version = version;
 
-	dev_info(&hdev->pdev->dev, "The firware version is %08x\n", version);
+	dev_info(&hdev->pdev->dev, "The firmware version is %08x\n", version);
 
 	return 0;
 err_csq:
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 6fb7648bb2f2..bb45365fb817 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1952,7 +1952,7 @@ int hclge_cfg_mac_speed_dup(struct hclge_dev *hdev, int speed, u8 duplex)
 			       HCLGE_CFG_SPEED_S, 5);
 		break;
 	default:
-		dev_err(&hdev->pdev->dev, "invald speed (%d)\n", speed);
+		dev_err(&hdev->pdev->dev, "invalid speed (%d)\n", speed);
 		return -EINVAL;
 	}
 
@@ -3476,7 +3476,7 @@ int hclge_rm_mc_addr_common(struct hclge_vport *vport,
 	} else {
 		/* This mac addr do not exist, can't delete it */
 		dev_err(&hdev->pdev->dev,
-			"Rm mutilcast mac addr failed, ret = %d.\n",
+			"Rm multicast mac addr failed, ret = %d.\n",
 			status);
 		return -EIO;
 	}
-- 
2.11.0
