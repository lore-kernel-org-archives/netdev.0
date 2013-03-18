From: Ben Collins <ben.c@servergy.com>
Subject: [PATCH] phy: Add XGMII phy interface type
Date: Mon, 18 Mar 2013 19:53:42 -0400
Message-ID: <E1UJ1fR-0004hy-AI@swissweb.swissdisk.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swissweb.swissdisk.com ([174.129.12.238]:52787 "EHLO
	swissweb.swissdisk.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792Ab3CVNjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 09:39:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used by systems based on certain Freescale SoCs (specifically the
Servergy CTS-1000 system).

Signed-off-by: Ben Collins <ben.c@servergy.com>
Cc: netdev@vger.kernel.org
---
 include/linux/phy.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 33999ad..5a94ec7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -64,6 +64,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
+	PHY_INTERFACE_MODE_XGMII,
 } phy_interface_t;
 
 
-- 
1.8.1.2
