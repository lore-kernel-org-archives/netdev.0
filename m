From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2] net: fec: Place 'inline' in the beginning of declaration
Date: Tue,  8 Jan 2013 01:29:11 -0200
Message-ID: <1357615751-11659-1-git-send-email-festevam@gmail.com>
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:38597 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab3AHD31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:29:27 -0500
Received: by mail-yh0-f53.google.com with SMTP id q11so3279937yhf.12
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 19:29:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Fix the following warning when building with W=1 option:

drivers/net/ethernet/freescale/fec.c:810:1: warning: '__inline__' is not at beginning of declaration [-Wold-style-declaration]

The inline declaration is pointless in this function, so just remove it.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Remove the 'inline'

 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a379319..69d6069 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -807,7 +807,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 
 /* ------------------------------------------------------------------------- */
-static void __inline__ fec_get_mac(struct net_device *ndev)
+static void fec_get_mac(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
-- 
1.7.9.5
