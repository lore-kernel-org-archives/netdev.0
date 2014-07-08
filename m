From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: export phy_suspend and phy_resume
Date: Tue,  8 Jul 2014 10:38:36 -0700
Message-ID: <1404841116-8274-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vbridgers2013@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:60021 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbaGHRi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 13:38:59 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so5363986qge.39
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 10:38:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_suspend and phy_resume are two commonly used helper functions that
need to be exported for Ethernet drivers to be built as modules

Fixes: 40755a0fce17 ("net: systemport: add suspend and resume support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 35d753d22f78..4f4568ef124e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -696,6 +696,7 @@ int phy_suspend(struct phy_device *phydev)
 		return phydrv->suspend(phydev);
 	return 0;
 }
+EXPORT_SYMBOL(phy_suspend);
 
 int phy_resume(struct phy_device *phydev)
 {
@@ -705,6 +706,7 @@ int phy_resume(struct phy_device *phydev)
 		return phydrv->resume(phydev);
 	return 0;
 }
+EXPORT_SYMBOL(phy_resume);
 
 /* Generic PHY support and helper functions */
 
-- 
1.9.1
