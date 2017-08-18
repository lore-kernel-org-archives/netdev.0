From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 01/13] amd-xgbe: Set the MDIO mode for
 10000Base-T configuration
Date: Fri, 18 Aug 2017 09:02:18 -0500
Message-ID: <20170818140218.14804.24933.stgit@tlendack-t1.amdoffice.net>
References: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0060.outbound.protection.outlook.com ([104.47.42.60]:59328
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753215AbdHROCX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 10:02:23 -0400
In-Reply-To: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the MDIO mode is set to none for the 10000Base-T, which is
incorrect.  The MDIO mode should for this configuration should be
clause 45.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 04b5c14..81c45fa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -2921,7 +2921,7 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 			phy_data->start_mode = XGBE_MODE_KR;
 		}
 
-		phy_data->phydev_mode = XGBE_MDIO_MODE_NONE;
+		phy_data->phydev_mode = XGBE_MDIO_MODE_CL45;
 		break;
 
 	/* 10GBase-R support */
