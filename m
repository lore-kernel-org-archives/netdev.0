From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/9] net: phy: davicom: fix checkpath errors
Date: Tue, 17 Dec 2013 21:38:06 -0800
Message-ID: <1387345093-14168-3-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:41491 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3LRFiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:25 -0500
Received: by mail-ob0-f169.google.com with SMTP id wm4so7405004obc.14
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:24 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpath spotted a few stylistic errors, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/davicom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 383e833..d2c08f6 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -72,7 +72,7 @@ static int dm9161_config_intr(struct phy_device *phydev)
 	if (temp < 0)
 		return temp;
 
-	if(PHY_INTERRUPT_ENABLED == phydev->interrupts )
+	if (PHY_INTERRUPT_ENABLED == phydev->interrupts)
 		temp &= ~(MII_DM9161_INTR_STOP);
 	else
 		temp |= MII_DM9161_INTR_STOP;
-- 
1.8.3.2
