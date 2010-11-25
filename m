From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 2/8] ethoc: remove unused spinlock
Date: Thu, 25 Nov 2010 13:30:26 +0100
Message-ID: <1290688232-25142-3-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38969 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab0KYMaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:35 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 9ea3c54..e9e712e 100644
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
@@ -1060,7 +1058,6 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	/* setup NAPI */
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
 
-	spin_lock_init(&priv->rx_lock);
 	spin_lock_init(&priv->lock);
 
 	ret = register_netdev(netdev);
-- 
1.7.1

