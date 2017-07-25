From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH] net: phy: Remove trailing semicolon in macro definition
Date: Tue, 25 Jul 2017 11:08:15 +0200
Message-ID: <d1f4d4f1-e60b-6b4d-6f98-3be70da859b5@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:26532 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750790AbdGYJIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 05:08:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e5a03bfd873c2 ("phy: Add an mdio_device structure")
introduced a spurious trailing semicolon. Remove it.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 include/linux/phy.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2a9567bb8186..0bb5b212ab42 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -830,7 +830,7 @@ static inline int phy_read_status(struct phy_device *phydev)
 	dev_err(&_phydev->mdio.dev, format, ##args)
 
 #define phydev_dbg(_phydev, format, args...)	\
-	dev_dbg(&_phydev->mdio.dev, format, ##args);
+	dev_dbg(&_phydev->mdio.dev, format, ##args)
 
 static inline const char *phydev_name(const struct phy_device *phydev)
 {
-- 
2.11.0
