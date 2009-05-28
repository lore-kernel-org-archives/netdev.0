From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH 1/4] net/phy/marvell: update m88e1111 support for SGMII mode
Date: Thu, 28 May 2009 09:20:27 -0400
Message-ID: <12435168302841-git-send-email-Haiying.Wang@freescale.com>
Cc: Haiying Wang <Haiying.Wang@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48109 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175AbZE1NUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 09:20:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable fiber/copper auto selection for Marvell m88e1111 SGMII support.

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 drivers/net/phy/marvell.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 7a3ec9d..dd6f54d 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -243,6 +243,7 @@ static int m88e1111_config_init(struct phy_device *phydev)
 
 		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
 		temp |= MII_M1111_HWCFG_MODE_SGMII_NO_CLK;
+		temp |= MII_M1111_HWCFG_FIBER_COPPER_AUTO;
 
 		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
 		if (err < 0)
-- 
1.6.0.2

