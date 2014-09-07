From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe-phy: Fix build break for missing declaration
Date: Sun, 7 Sep 2014 09:54:41 -0500
Message-ID: <20140907145441.7257.26465.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0138.outbound.protection.outlook.com ([157.56.111.138]:22930
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752183AbaIGOys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2014 10:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous patch inadvertently deleted a declaration in the
amd_xgbe_an_tx_training function causing the build to fail.

Add the declaration for 'priv' back to the function.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 4e1f7f7..c456559 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -638,6 +638,7 @@ static int amd_xgbe_phy_set_mode(struct phy_device *phydev,
 static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 						    enum amd_xgbe_phy_rx *state)
 {
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	int ad_reg, lp_reg, ret;
 
 	*state = AMD_XGBE_RX_COMPLETE;
