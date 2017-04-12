From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 7/8] ftgmac100: Display the discovered PHY device info
Date: Thu, 13 Apr 2017 08:44:42 +1000
Message-ID: <20170412224443.17906-8-benh@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33736 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752870AbdDLWqx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:46:53 -0400
In-Reply-To: <20170412224443.17906-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index c1afda8..d04ad31 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1075,6 +1075,9 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv, phy_interface_t intf)
 	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 	phydev->advertising = phydev->supported;
 
+	/* Display what we found */
+	phy_attached_info(phydev);
+
 	return 0;
 }
 
-- 
2.9.3
