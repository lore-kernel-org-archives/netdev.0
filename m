From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/9] net: phy: micrel: fix checkpath errors
Date: Tue, 17 Dec 2013 21:38:11 -0800
Message-ID: <1387345093-14168-8-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:49322 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab3LRFic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:32 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so7784677oah.29
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:32 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch spotted a few spaces vs tabs errors, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/micrel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 3ae28f4..2a470e5 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -81,14 +81,14 @@ static int ksz_config_flags(struct phy_device *phydev)
 }
 
 static int kszphy_extended_write(struct phy_device *phydev,
-                                 u32 regnum, u16 val)
+				u32 regnum, u16 val)
 {
 	phy_write(phydev, MII_KSZPHY_EXTREG, KSZPHY_EXTREG_WRITE | regnum);
 	return phy_write(phydev, MII_KSZPHY_EXTREG_WRITE, val);
 }
 
 static int kszphy_extended_read(struct phy_device *phydev,
-                                 u32 regnum)
+				u32 regnum)
 {
 	phy_write(phydev, MII_KSZPHY_EXTREG, regnum);
 	return phy_read(phydev, MII_KSZPHY_EXTREG_READ);
-- 
1.8.3.2
