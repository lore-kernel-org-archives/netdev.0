From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 1/4] net: phy: add mdix_ctrl to hold the user configuration.
Date: Tue, 29 Nov 2016 15:16:46 +0530
Message-ID: <1480412809-6122-2-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0081.outbound.protection.outlook.com ([104.47.36.81]:24848
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756684AbcK2KBr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:01:47 -0500
In-Reply-To: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Add new parameter mdix_ctrl to hold the user configuration.
Existing mdix maintain the current status of MDI(X) crossover performed or
not.
mdix_ctrl can configure either ETH_TP_MDI or ETH_TP_MDI_X orETH_TP_MDI_AUTO.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 include/linux/phy.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index edde28c..bd4e2d6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -447,6 +447,7 @@ struct phy_device {
 	struct net_device *attached_dev;
 
 	u8 mdix;
+	u8 mdix_ctrl;
 
 	void (*adjust_link)(struct net_device *dev);
 };
-- 
2.7.4
