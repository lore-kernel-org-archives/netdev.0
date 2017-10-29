From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next] net: dpaa: remove init which already done in per-cpu allocation
Date: Sun, 29 Oct 2017 09:48:44 +0800
Message-ID: <1509241724-16997-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:43843 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751646AbdJ2Btg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 21:49:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index a8d0be8..1ccc316 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2814,10 +2814,6 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 		err = -ENOMEM;
 		goto free_dpaa_fqs;
 	}
-	for_each_possible_cpu(i) {
-		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
-		memset(percpu_priv, 0, sizeof(*percpu_priv));
-	}
 
 	priv->num_tc = 1;
 	netif_set_real_num_tx_queues(net_dev, priv->num_tc * DPAA_TC_TXQ_NUM);
-- 
2.7.4
