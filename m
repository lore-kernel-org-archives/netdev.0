From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 1/5] net: hns3: fixes the ring index in hns3_fini_ring
Date: Tue, 10 Oct 2017 16:42:03 +0800
Message-ID: <1507624927-98008-2-git-send-email-lipeng321@huawei.com>
References: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the ring index in hns3_fini_ring.

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 26bbc91..acb82cf 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2661,7 +2661,7 @@ static int hns3_init_all_ring(struct hns3_nic_priv *priv)
 
 out_when_alloc_ring_memory:
 	for (j = i - 1; j >= 0; j--)
-		hns3_fini_ring(priv->ring_data[i].ring);
+		hns3_fini_ring(priv->ring_data[j].ring);
 
 	return -ENOMEM;
 }
-- 
1.9.1
