From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] hns: remove useless void cast
Date: Tue, 18 Jul 2017 15:59:26 -0700
Message-ID: <20170718225927.15944-3-sthemmin@microsoft.com>
References: <20170718225927.15944-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33426 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdGRW7d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 18:59:33 -0400
Received: by mail-pf0-f178.google.com with SMTP id s70so8965097pfs.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 15:59:33 -0700 (PDT)
In-Reply-To: <20170718225927.15944-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to cast away return value of dev_close.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index a8db27e86a11..78cb20c67aa6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -595,7 +595,7 @@ static void hns_nic_self_test(struct net_device *ndev,
 		set_bit(NIC_STATE_TESTING, &priv->state);
 
 		if (if_running)
-			(void)dev_close(ndev);
+			dev_close(ndev);
 
 		for (i = 0; i < SELF_TEST_TPYE_NUM; i++) {
 			if (!st_param[i][1])
-- 
2.11.0
