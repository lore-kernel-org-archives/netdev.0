From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 1/7] net: hns3: Cleanup for shifting true in hns3 driver
Date: Mon, 9 Oct 2017 15:43:55 +0800
Message-ID: <1507535041-204956-2-git-send-email-linyunsheng@huawei.com>
References: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
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
In-Reply-To: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a shifting true in hclge_main module.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 1a13614..5c1bf12 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1687,7 +1687,7 @@ static int hclge_rx_priv_buf_alloc(struct hclge_dev *hdev,
 		req->buf_num[i] =
 			cpu_to_le16(priv->buf_size >> HCLGE_BUF_UNIT_S);
 		req->buf_num[i] |=
-			cpu_to_le16(true << HCLGE_TC0_PRI_BUF_EN_B);
+			cpu_to_le16(1 << HCLGE_TC0_PRI_BUF_EN_B);
 	}
 
 	req->shared_buf =
-- 
1.9.1
