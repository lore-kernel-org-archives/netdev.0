From: Wei Yongjun <weiyongjun1@huawei.com>
Subject: [PATCH net-next] net: hns3: make local functions static
Date: Wed, 11 Oct 2017 02:35:23 +0000
Message-ID: <1507689323-183009-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Lipeng <lipeng321@huawei.com>,
        Yunsheng Lin <linyunsheng@huawei.com>,
        Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:7547 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756781AbdJKCeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 22:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sparse warnings:

drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c:464:5: warning:
 symbol 'hns3_change_all_ring_bd_num' was not declared. Should it be static?
drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c:477:5: warning:
 symbol 'hns3_set_ringparam' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index 9b36ce0..ddbd7f3 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -461,7 +461,8 @@ static int hns3_get_rxnfc(struct net_device *netdev,
 	return 0;
 }
 
-int hns3_change_all_ring_bd_num(struct hns3_nic_priv *priv, u32 new_desc_num)
+static int hns3_change_all_ring_bd_num(struct hns3_nic_priv *priv,
+				       u32 new_desc_num)
 {
 	struct hnae3_handle *h = priv->ae_handle;
 	int i;
@@ -474,7 +475,8 @@ int hns3_change_all_ring_bd_num(struct hns3_nic_priv *priv, u32 new_desc_num)
 	return hns3_init_all_ring(priv);
 }
 
-int hns3_set_ringparam(struct net_device *ndev, struct ethtool_ringparam *param)
+static int hns3_set_ringparam(struct net_device *ndev,
+			      struct ethtool_ringparam *param)
 {
 	struct hns3_nic_priv *priv = netdev_priv(ndev);
 	struct hnae3_handle *h = priv->ae_handle;
