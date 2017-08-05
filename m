From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: hns3: fix spelling mistake: "capabilty" -> "capability"
Date: Sat,  5 Aug 2017 14:46:35 +0100
Message-ID: <20170805134635.1256-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        lipeng <lipeng321@huawei.com>, Wei Hu <xavier.huwei@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_err error message and also
split overly long line to avoid a checkpatch warning.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 3611991689bc..770c06d80438 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -4091,7 +4091,8 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 
 	ret = hclge_get_cap(hdev);
 	if (ret) {
-		dev_err(&pdev->dev, "get hw capabilty error, ret = %d.\n", ret);
+		dev_err(&pdev->dev, "get hw capability error, ret = %d.\n",
+			ret);
 		return ret;
 	}
 
-- 
2.11.0
