From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/9] net: phy: lxt: fix checkpath errors
Date: Tue, 17 Dec 2013 21:38:09 -0800
Message-ID: <1387345093-14168-6-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:54469 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3LRFi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:29 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so7780768oah.1
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:28 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpath spotted a few errors in this file, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/lxt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index ff2e45e..9108f31 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -82,7 +82,7 @@ static int lxt970_config_intr(struct phy_device *phydev)
 {
 	int err;
 
-	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_LXT970_IER, MII_LXT970_IER_IEN);
 	else
 		err = phy_write(phydev, MII_LXT970_IER, 0);
@@ -114,7 +114,7 @@ static int lxt971_config_intr(struct phy_device *phydev)
 {
 	int err;
 
-	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_LXT971_IER, MII_LXT971_IER_IEN);
 	else
 		err = phy_write(phydev, MII_LXT971_IER, 0);
-- 
1.8.3.2
