From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCHv2 1/4] net: phy: at803x: Don't set gbit features for the AR8030 phy
Date: Fri, 15 Jan 2016 01:55:21 +0100
Message-ID: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, daniel@zonque.org, festevam@gmail.com,
	mans@mansr.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38578 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912AbcAOAzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 19:55:44 -0500
Received: by mail-wm0-f47.google.com with SMTP id b14so2263463wmb.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 16:55:43 -0800 (PST)
In-Reply-To: 1451089622-14957-2-git-send-email-martin.blumenstingl@googlemail.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8030 is only a "RMII Fast Ethernet PHY", thus it must not have the
SUPPORTED_1000* bits set.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
v2: refreshed patch

 drivers/net/phy/at803x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 8a8f6fb..3589447 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -322,7 +322,7 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
 	.resume			= at803x_resume,
-	.features		= PHY_GBIT_FEATURES,
+	.features		= PHY_BASIC_FEATURES,
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
-- 
2.7.0
