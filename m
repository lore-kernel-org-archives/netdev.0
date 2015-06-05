From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH 1/2] net/phy: micrel: Comment MMD address of extended registers
Date: Fri, 5 Jun 2015 12:57:26 -0500
Message-ID: <1433527047-28686-1-git-send-email-jaeden.amero@ni.com>
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:38154 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751627AbbFER6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 13:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some defines for a few pad skew related extended registers.
Specify for which MMD Address (dev_addr) they are for.

Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
---
 drivers/net/phy/micrel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index ebdc357..41a2e02 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -365,6 +365,7 @@ static int ksz9021_config_init(struct phy_device *phydev)
 #define KSZ9031_PS_TO_REG		60
 
 /* Extended registers */
+/* MMD Address 0x2 */
 #define MII_KSZ9031RN_CONTROL_PAD_SKEW	4
 #define MII_KSZ9031RN_RX_DATA_PAD_SKEW	5
 #define MII_KSZ9031RN_TX_DATA_PAD_SKEW	6
-- 
2.1.4
