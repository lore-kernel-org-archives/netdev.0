From: <ganesanr@broadcom.com>
Subject: [PATCH 2/3] Staging: PHY address calculation fix
Date: Wed, 18 Jun 2014 18:43:57 +0530
Message-ID: <20fcbf14feaa9b27cd043a1d6af21debacacf63a.1403096668.git.ganesanr@broadcom.com>
References: <cover.1403096668.git.ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ganesan Ramalingam <ganesanr@broadcom.com>,
	<jchandra@broadcom.com>, <linux-mips@linux-mips.org>,
	<ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: <kristina.martsenko@gmail.com>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:26699 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966138AbaFRMfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 08:35:40 -0400
In-Reply-To: <cover.1403096668.git.ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

SGMII PHY address calculation should be based on phy_addr of priv data

Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
---
 drivers/staging/netlogic/xlr_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index 69ae8b6..6d7a6a7 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -776,7 +776,7 @@ static void xlr_sgmii_init(struct xlr_net_priv *priv)
 	xlr_nae_wreg(priv->gpio_addr, 0x21, 0x7104);
 
 	/* enable autoneg - more magic */
-	phy = priv->port_id % 4 + 27;
+	phy = priv->phy_addr % 4 + 27;
 	xlr_phy_write(priv->pcs_addr, phy, 0, 0x1000);
 	xlr_phy_write(priv->pcs_addr, phy, 0, 0x0200);
 }
-- 
1.7.9.5
