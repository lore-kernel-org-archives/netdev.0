From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: lpc_eth: Remove unused 'pldat' variable
Date: Mon,  4 Jul 2016 10:13:21 -0300
Message-ID: <1467638001-7183-1-git-send-email-festevam@gmail.com>
Cc: tremyfr@gmail.com, netdev@vger.kernel.org,
	Fabio Estevam <festevam@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35529 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932512AbcGDNNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:13:47 -0400
Received: by mail-qk0-f194.google.com with SMTP id t2so9704133qkh.2
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 06:13:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit f786f3564c4f02d5026 ("net: ethernet: lpc_eth: use phydev
from struct net_device") the 'pldat' variable became unused, so
just remove it.

Reported-by: Olof's autobuilder <build@lixom.net>
Signed-off-by: Fabio Estevam <festevam@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 01b50ff..4d4ecba 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1183,7 +1183,6 @@ static void lpc_eth_set_multicast_list(struct net_device *ndev)
 
 static int lpc_eth_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 {
-	struct netdata_local *pldat = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
-- 
1.9.1
