From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 5/9] net: hns: add a space before "*/"
Date: Thu, 30 Jun 2016 15:25:05 +0800
Message-ID: <1467271509-63162-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

In comment line, some time miss a space before */, so this
patch adds a space before */.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index d5297ec..d7e1f8c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -762,13 +762,13 @@ static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 	recv_pkts = 0, recv_bds = 0, clean_count = 0;
 recv:
 	while (recv_pkts < budget && recv_bds < num) {
-		/* reuse or realloc buffers*/
+		/* reuse or realloc buffers */
 		if (clean_count >= RCB_NOF_ALLOC_RX_BUFF_ONCE) {
 			hns_nic_alloc_rx_buffers(ring_data, clean_count);
 			clean_count = 0;
 		}
 
-		/* poll one pkt*/
+		/* poll one pkt */
 		err = hns_nic_poll_rx_skb(ring_data, &skb, &bnum);
 		if (unlikely(!skb)) /* this fault cannot be repaired */
 			goto out;
-- 
1.9.1
