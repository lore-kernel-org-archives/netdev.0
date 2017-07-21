From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2 2/4] net: ethernet: nb8800: Set RGMII_MODE for all RGMII
 modes
Date: Fri, 21 Jul 2017 13:25:52 +0200
Message-ID: <237905ff-385e-fa2f-bbbf-6c550a48e15c@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:59392 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752433AbdGULxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 07:53:10 -0400
In-Reply-To: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 4 RGMII phy-modes to handle.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 041cfb7952f8..ded041dbafe7 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
 		mac_mode |= HALF_DUPLEX;
 
 	if (gigabit) {
-		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		if (phy_interface_is_rgmii(dev->phydev))
 			mac_mode |= RGMII_MODE;
 
 		mac_mode |= GMAC_MODE;
-- 
2.11.0
