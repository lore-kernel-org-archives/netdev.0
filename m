From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: lpc_eth: Remove unused variables
Date: Fri,  8 Jan 2016 10:19:16 -0200
Message-ID: <1452255556-21827-1-git-send-email-festevam@gmail.com>
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33604 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbcAHMTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 07:19:35 -0500
Received: by mail-yk0-f173.google.com with SMTP id k129so337496032yke.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 04:19:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

Commit e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
introduced the following build warnings:

drivers/net/ethernet/nxp/lpc_eth.c: In function 'lpc_mii_init':
drivers/net/ethernet/nxp/lpc_eth.c:865:1: warning: label 'err_out_1' defined but not used [-Wunused-label]
drivers/net/ethernet/nxp/lpc_eth.c:826:20: warning: unused variable 'i' [-Wunused-variable]

Remove the unused variables to fix them.

Reported-by: Olof's autobuilder <build@lixom.net>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index a9ce37f..b1ce7aa 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -823,7 +823,7 @@ static int lpc_mii_probe(struct net_device *ndev)
 
 static int lpc_mii_init(struct netdata_local *pldat)
 {
-	int err = -ENXIO, i;
+	int err = -ENXIO;
 
 	pldat->mii_bus = mdiobus_alloc();
 	if (!pldat->mii_bus) {
@@ -862,7 +862,6 @@ static int lpc_mii_init(struct netdata_local *pldat)
 
 err_out_unregister_bus:
 	mdiobus_unregister(pldat->mii_bus);
-err_out_1:
 	mdiobus_free(pldat->mii_bus);
 err_out:
 	return err;
-- 
1.9.1
