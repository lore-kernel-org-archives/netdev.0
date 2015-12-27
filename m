From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 06/10] net: hns: use to_platform_device()
Date: Sun, 27 Dec 2015 21:15:44 +0800
Message-ID: <0801535a0c35424d2fd2e91f6ed58058d884e147.1451221174.git.geliangtang@163.com>
References: <a554e6af3a3528c2206c94dab62b7800f96caa4b.1451221174.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Yisen Zhuang <yisen.zhuang@huawei.com>,
	yankejian <yankejian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a554e6af3a3528c2206c94dab62b7800f96caa4b.1451221174.git.geliangtang@163.com>
In-Reply-To: <a554e6af3a3528c2206c94dab62b7800f96caa4b.1451221174.git.geliangtang@163.com>
References: <a554e6af3a3528c2206c94dab62b7800f96caa4b.1451221174.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_platform_device() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 8c30cec..d2263c7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -499,8 +499,7 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 	int base_irq_idx = hns_rcb_get_base_irq_idx(rcb_common);
 	struct device_node *np = rcb_common->dsaf_dev->dev->of_node;
 	struct platform_device *pdev =
-		container_of(rcb_common->dsaf_dev->dev,
-			     struct platform_device, dev);
+		to_platform_device(rcb_common->dsaf_dev->dev);
 	bool is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
 
 	for (i = 0; i < ring_num; i++) {
-- 
2.5.0
