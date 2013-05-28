From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH net-next] phy: add reverse MII PHY connection type
Date: Tue, 28 May 2013 15:07:21 +0100
Message-ID: <1369750041-30396-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2760 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934168Ab3E1OHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 10:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library currently does not know about the the reverse MII
connection type. Add it to the list of supported PHY modes and update
of_get_phy_mode() to support it and look for the string "rev-mii".

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_net.c | 1 +
 include/linux/phy.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index ffab033..ea174c8 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -22,6 +22,7 @@ static const char *phy_modes[] = {
 	[PHY_INTERFACE_MODE_GMII]	= "gmii",
 	[PHY_INTERFACE_MODE_SGMII]	= "sgmii",
 	[PHY_INTERFACE_MODE_TBI]	= "tbi",
+	[PHY_INTERFACE_MODE_REVMII]	= "rev-mii",
 	[PHY_INTERFACE_MODE_RMII]	= "rmii",
 	[PHY_INTERFACE_MODE_RGMII]	= "rgmii",
 	[PHY_INTERFACE_MODE_RGMII_ID]	= "rgmii-id",
diff --git a/include/linux/phy.h b/include/linux/phy.h
index ee411b0..64ab823 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -58,6 +58,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_GMII,
 	PHY_INTERFACE_MODE_SGMII,
 	PHY_INTERFACE_MODE_TBI,
+	PHY_INTERFACE_MODE_REVMII,
 	PHY_INTERFACE_MODE_RMII,
 	PHY_INTERFACE_MODE_RGMII,
 	PHY_INTERFACE_MODE_RGMII_ID,
-- 
1.8.1.2
