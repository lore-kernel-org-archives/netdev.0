From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2] amd-xgbe-phy: Fix build break for missing
 declaration
Date: Sun, 7 Sep 2014 10:33:15 -0500
Message-ID: <20140907153315.24106.86368.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0107.outbound.protection.outlook.com ([65.55.169.107]:51771
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752375AbaIGPdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2014 11:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous patch inadvertently deleted a declaration in the
amd_xgbe_an_tx_training function causing the build to fail.

Add the declaration for 'priv' back to the function.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
Changes in v2:
- Add "Reported-by" tag to the changelog

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
