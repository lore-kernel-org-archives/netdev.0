From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH 2/2 net-next] hns3pf: Fix some harmless copy and paste bugs
Date: Thu, 10 Aug 2017 12:56:14 +0300
Message-ID: <20170810095549.jxkthoyym5gn5oh3@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        "Wei Hu (Xavier)" <xavier.huwei@huawei.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35973 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdHJJ5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 05:57:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were copy and paste bugs, but I believe they are harmless.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index e519795dff7c..9589b7e1d24c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -330,7 +330,7 @@ static int hns3_nic_mc_sync(struct net_device *netdev,
 	struct hns3_nic_priv *priv = netdev_priv(netdev);
 	struct hnae3_handle *h = priv->ae_handle;
 
-	if (h->ae_algo->ops->add_uc_addr)
+	if (h->ae_algo->ops->add_mc_addr)
 		return h->ae_algo->ops->add_mc_addr(h, addr);
 
 	return 0;
@@ -342,7 +342,7 @@ static int hns3_nic_mc_unsync(struct net_device *netdev,
 	struct hns3_nic_priv *priv = netdev_priv(netdev);
 	struct hnae3_handle *h = priv->ae_handle;
 
-	if (h->ae_algo->ops->rm_uc_addr)
+	if (h->ae_algo->ops->rm_mc_addr)
 		return h->ae_algo->ops->rm_mc_addr(h, addr);
 
 	return 0;
