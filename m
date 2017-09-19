From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 2/7] net: hns3: fix the command used to unmap ring from vector
Date: Tue, 19 Sep 2017 02:06:23 +0100
Message-ID: <20170919010628.175732-3-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919010628.175732-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>

When unmap ring from vector, it use wrong command, this will cause
error if the unmap action need multi command description. This patch
fix the error.

Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index db4e07dac29a..e324bc6e9f4f 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2779,7 +2779,7 @@ static int hclge_unmap_ring_from_vector(
 			}
 			i = 0;
 			hclge_cmd_setup_basic_desc(&desc,
-						   HCLGE_OPC_ADD_RING_TO_VECTOR,
+						   HCLGE_OPC_DEL_RING_TO_VECTOR,
 						   false);
 			req->int_vector_id = vector_id;
 		}
-- 
2.11.0
