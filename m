From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] ethernet: arc: remove unused dev
Date: Tue, 02 Sep 2014 10:48:11 +0900
Message-ID: <001a01cfc64f$f4421040$dcc630c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Romain Perier' <romain.perier@gmail.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:26347 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbaIBBsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:48:14 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NB9001WO3OCX900@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 02 Sep 2014 10:48:12 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused 'dev' variable from arc_emac_remove(), since it's
not being used any more.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/arc/emac_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b35c69e1b147..a7773923a7a0 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -829,7 +829,6 @@ EXPORT_SYMBOL_GPL(arc_emac_probe);
 
 int arc_emac_remove(struct net_device *ndev)
 {
-	struct device *dev = ndev->dev.parent;
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 
 	phy_disconnect(priv->phy_dev);
-- 
2.0.0
