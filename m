From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] drivers: net: cpsw: add newline after MACID log
Date: Thu, 27 Jun 2013 11:40:47 +0200
Message-ID: <1372326047-28074-1-git-send-email-zonque@gmail.com>
Cc: mugunthanvnm@ti.com, davem@davemloft.net,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:39049 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531Ab3F0Jqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 05:46:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic patch to add a newline after logging the device's MACID.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d1a769f..e10328d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1698,10 +1698,10 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
-		pr_info("Detected MACID = %pM", priv->mac_addr);
+		pr_info("Detected MACID = %pM\n", priv->mac_addr);
 	} else {
 		eth_random_addr(priv->mac_addr);
-		pr_info("Random MACID = %pM", priv->mac_addr);
+		pr_info("Random MACID = %pM\n", priv->mac_addr);
 	}
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
-- 
1.8.1.4
