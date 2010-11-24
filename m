From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 2/8] ethoc: remove unused spinlock
Date: Wed, 24 Nov 2010 14:40:52 +0100
Message-ID: <1290606058-26703-3-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38156 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0KXOCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:50 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6b4b9e1..fc8c044 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -185,7 +185,6 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @netdev:	pointer to network device structure
  * @napi:	NAPI structure
  * @msg_enable:	device state flags
- * @rx_lock:	receive lock
  * @lock:	device lock
  * @phy:	attached PHY
  * @mdio:	MDIO bus for PHY access
@@ -210,7 +209,6 @@ struct ethoc {
 	struct napi_struct napi;
 	u32 msg_enable;
 
-	spinlock_t rx_lock;
 	spinlock_t lock;
 
 	struct phy_device *phy;
@@ -1061,7 +1059,6 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	/* setup NAPI */
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
 
-	spin_lock_init(&priv->rx_lock);
 	spin_lock_init(&priv->lock);
 
 	ret = register_netdev(netdev);
-- 
1.7.1

