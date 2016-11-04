From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 3/5] ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
Date: Fri, 4 Nov 2016 11:35:40 +0100
Message-ID: <1478255742-25693-4-git-send-email-allan.nielsen@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0042.outbound.protection.outlook.com ([104.47.36.42]:43360
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755134AbcKDKgT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:36:19 -0400
In-Reply-To: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

For operation in cabling environments that are incompatible with
1000BAST-T, PHY device may provide an automatic link speed downshift
operation. When enabled, the device automatically changes its 1000BAST-T
auto-negotiation to the next slower speed after a configured number of
failed attempts at 1000BAST-T.  This feature is useful in setting up in
networks using older cable installations that include only pairs A and B,
and not pairs C and D.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 include/uapi/linux/ethtool.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index fd0bd36..040c5b5 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -248,8 +248,12 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+#define DOWNSHIFT_DEV_DEFAULT_COUNT	0xff
+#define DOWNSHIFT_DEV_DISABLE		0
+
 enum phy_tunable_id {
 	ETHTOOL_PHY_ID_UNSPEC,
+	ETHTOOL_PHY_DOWNSHIFT,
 };
 
 /**
-- 
2.7.3
