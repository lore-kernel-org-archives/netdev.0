From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v3 3/5] ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
Date: Thu, 17 Nov 2016 13:07:22 +0100
Message-ID: <1479384444-31122-4-git-send-email-allan.nielsen@microsemi.com>
References: <1479384444-31122-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0046.outbound.protection.outlook.com ([104.47.34.46]:6009
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941126AbcKQRkk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:40:40 -0500
In-Reply-To: <1479384444-31122-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

For operation in cabling environments that are incompatible with
1000BASE-T, PHY device may provide an automatic link speed downshift
operation. When enabled, the device automatically changes its 1000BASE-T
auto-negotiation to the next slower speed after a configured number of
failed attempts at 1000BASE-T.  This feature is useful in setting up in
networks using older cable installations that include only pairs A and B,
and not pairs C and D.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 include/uapi/linux/ethtool.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 42f696f..f0db778 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -248,9 +248,12 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+#define DOWNSHIFT_DEV_DEFAULT_COUNT	0xff
+#define DOWNSHIFT_DEV_DISABLE		0
+
 enum phy_tunable_id {
 	ETHTOOL_PHY_ID_UNSPEC,
-
+	ETHTOOL_PHY_DOWNSHIFT,
 	/*
 	 * Add your fresh new phy tunable attribute above and remember to update
 	 * phy_tunable_strings[] in net/core/ethtool.c
-- 
2.7.3
