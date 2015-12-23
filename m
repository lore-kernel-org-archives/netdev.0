From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/9] cxgb4: Pass correct argument to t4_link_l1cfg()
Date: Wed, 23 Dec 2015 22:47:11 +0530
Message-ID: <1450891039-17196-2-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:23980 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751728AbbLWRP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:15:58 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 2a61a42..7a0b92b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -686,7 +686,7 @@ static int set_pauseparam(struct net_device *dev,
 	if (epause->tx_pause)
 		lc->requested_fc |= PAUSE_TX;
 	if (netif_running(dev))
-		return t4_link_l1cfg(p->adapter, p->adapter->pf, p->tx_chan,
+		return t4_link_l1cfg(p->adapter, p->adapter->mbox, p->tx_chan,
 				     lc);
 	return 0;
 }
-- 
2.3.4
