From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH 1/4] net: phy: at803x: Don't set gbit features for the AR8030 phy
Date: Sat, 26 Dec 2015 01:26:59 +0100
Message-ID: <1451089622-14957-2-git-send-email-martin.blumenstingl@googlemail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, slash.tmp@free.fr,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34197 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbbLZA1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 19:27:38 -0500
Received: by mail-wm0-f41.google.com with SMTP id l126so210932430wml.1
        for <netdev@vger.kernel.org>; Fri, 25 Dec 2015 16:27:38 -0800 (PST)
In-Reply-To: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8030 is only a "RMII Fast Ethernet PHY", thus it must not have the
SUPPORTED_1000* bits set.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/phy/at803x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2d020a3..f566b6e 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -325,7 +325,7 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
 	.resume			= at803x_resume,
-	.features		= PHY_GBIT_FEATURES,
+	.features		= PHY_BASIC_FEATURES,
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
-- 
2.6.4
