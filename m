From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 5/7] Remove unused variable
Date: Fri, 11 Jun 2010 14:47:38 +0200
Message-ID: <1276260460-14531-5-git-send-email-jonas@southpole.se>
References: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49428 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760091Ab0FKMrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:51 -0400
In-Reply-To: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 1ee9947..e5c2f5b 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -636,7 +636,6 @@ static int ethoc_mdio_probe(struct net_device *dev)
 	struct ethoc *priv = netdev_priv(dev);
 	struct phy_device *phy;
 	int err;
-	int i;
 
 	if (priv->phy_id != -1) {
 		phy = priv->mdio->phy_map[priv->phy_id];
-- 
1.7.0.4

