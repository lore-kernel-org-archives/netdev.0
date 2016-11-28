From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 2/3] ethtool: Core impl for ETHTOOL_PHY_LOOPBACK tunable.
Date: Mon, 28 Nov 2016 14:24:31 +0100
Message-ID: <1480339472-5823-3-git-send-email-allan.nielsen@microsemi.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0049.outbound.protection.outlook.com ([104.47.33.49]:47581
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754608AbcK1NZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:26 -0500
In-Reply-To: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Adding validation support for the ETHTOOL_PHY_LOOPBACK. Functional
implementation needs to be done in the individual PHY drivers.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 net/core/ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e23766c..0542467 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -123,6 +123,7 @@ static const char
 phy_tunable_strings[__ETHTOOL_PHY_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
 	[ETHTOOL_ID_UNSPEC]     = "Unspec",
 	[ETHTOOL_PHY_DOWNSHIFT]	= "phy-downshift",
+	[ETHTOOL_PHY_LOOPBACK]	= "phy-loopback",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
@@ -2437,6 +2438,7 @@ static int ethtool_phy_tunable_valid(const struct ethtool_tunable *tuna)
 {
 	switch (tuna->id) {
 	case ETHTOOL_PHY_DOWNSHIFT:
+	case ETHTOOL_PHY_LOOPBACK:
 		if (tuna->len != sizeof(u8) ||
 		    tuna->type_id != ETHTOOL_TUNABLE_U8)
 			return -EINVAL;
-- 
2.7.3
