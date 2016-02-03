From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [PATCH] of: of_mdio: Add marvell,88e1145 to whitelist of PHY compatibilities.
Date: Wed,  3 Feb 2016 21:35:29 +0200
Message-ID: <1454528129-6144-1-git-send-email-aaro.koskinen@iki.fi>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Daney <ddaney@caviumnetworks.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:43838 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbcBCTnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ae461131960b ("of: of_mdio: Add a whitelist of PHY
compatibilities.") missed one compatible string used in in-tree DTBs:
in OCTEON, for selected boards, the kernel DTB pruning code will overwrite
the DTB compatible string with "marvell,88e1145", which is missing
from the whitelist. Add it.

The patch fixes broken networking on EdgeRouter Lite.

Fixes: ae461131960b ("of: of_mdio: Add a whitelist of PHY compatibilities.")
Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
---
 drivers/of/of_mdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 5648317..39c4be4 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -154,6 +154,7 @@ static const struct of_device_id whitelist_phys[] = {
 	{ .compatible = "marvell,88E1111", },
 	{ .compatible = "marvell,88e1116", },
 	{ .compatible = "marvell,88e1118", },
+	{ .compatible = "marvell,88e1145", },
 	{ .compatible = "marvell,88e1149r", },
 	{ .compatible = "marvell,88e1310", },
 	{ .compatible = "marvell,88E1510", },
-- 
2.4.0
