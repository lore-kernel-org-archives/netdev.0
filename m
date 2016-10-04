From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: hns: qdd missing \n to end of dev_err messages
Date: Tue,  4 Oct 2016 12:06:18 +0100
Message-ID: <20161004110618.11615-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Kejian Yan <yankejian@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        lipeng <lipeng321@huawei.com>, Lisheng <lisheng011@huawei.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40741 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbcJDLG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 07:06:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trival fix, dev_err messages are missing a \n, so add it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index a834774..7aeed08 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -547,7 +547,7 @@ int hns_mac_set_autoneg(struct hns_mac_cb *mac_cb, u8 enable)
 	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
 
 	if (mac_cb->phy_if == PHY_INTERFACE_MODE_XGMII && enable) {
-		dev_err(mac_cb->dev, "enable autoneg is not allowed!");
+		dev_err(mac_cb->dev, "enable autoneg is not allowed!\n");
 		return -ENOTSUPP;
 	}
 
@@ -571,7 +571,7 @@ int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en)
 
 	if (mac_cb->mac_type == HNAE_PORT_DEBUG) {
 		if (is_ver1 && (tx_en || rx_en)) {
-			dev_err(mac_cb->dev, "macv1 cann't enable tx/rx_pause!");
+			dev_err(mac_cb->dev, "macv1 cann't enable tx/rx_pause!\n");
 			return -EINVAL;
 		}
 	}
-- 
2.9.3
