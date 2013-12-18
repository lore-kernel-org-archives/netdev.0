From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/9] net: phy: cicada: fix checkpath errors
Date: Tue, 17 Dec 2013 21:38:05 -0800
Message-ID: <1387345093-14168-2-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:48160 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3LRFiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:23 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so7780694oah.1
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:23 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpath spotted a few stylistic errors fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/cicada.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index 313a037..b57ce0c 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -92,8 +92,8 @@ static int cis820x_config_intr(struct phy_device *phydev)
 {
 	int err;
 
-	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, MII_CIS8201_IMASK, 
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_CIS8201_IMASK,
 				MII_CIS8201_IMASK_MASK);
 	else
 		err = phy_write(phydev, MII_CIS8201_IMASK, 0);
-- 
1.8.3.2
