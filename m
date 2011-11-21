From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/3] be2net: fix to display Pause autonegotiation
 setting
Date: Sun, 20 Nov 2011 23:12:40 -0600
Message-ID: <20111121051240.GA17132@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:18372 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750803Ab1KUFMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:12:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pause autonegotiation is supported by default.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 575c783..ff53489 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -538,7 +538,7 @@ be_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	be_cmd_get_flow_control(adapter, &ecmd->tx_pause, &ecmd->rx_pause);
-	ecmd->autoneg = 0;
+	ecmd->autoneg = 1;
 }
 
 static int
-- 
1.7.5.4
