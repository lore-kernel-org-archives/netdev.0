From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH] phylib: export phy_suspend and phy_resume
Date: Tue, 8 Apr 2014 09:11:01 +0200
Message-ID: <20140408071101.GA14453@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35310 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbaDHHLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 03:11:44 -0400
Received: by mail-lb0-f182.google.com with SMTP id n15so485491lbi.27
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 00:11:43 -0700 (PDT)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id q4sm961538lbl.14.2014.04.08.00.11.42
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 00:11:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are exported in include/linux/phy.h but the symbol
exports where missing.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 drivers/net/phy/phy_device.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0ce6066..7485334 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -695,6 +695,7 @@ int phy_suspend(struct phy_device *phydev)
 		return phydrv->suspend(phydev);
 	return 0;
 }
+EXPORT_SYMBOL(phy_suspend);
 
 int phy_resume(struct phy_device *phydev)
 {
@@ -704,6 +705,7 @@ int phy_resume(struct phy_device *phydev)
 		return phydrv->resume(phydev);
 	return 0;
 }
+EXPORT_SYMBOL(phy_resume);
 
 /* Generic PHY support and helper functions */
 
-- 
1.8.4.357.g8d83871.dirty
