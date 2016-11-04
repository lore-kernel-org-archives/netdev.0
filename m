From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 11:35:38 +0100
Message-ID: <1478255742-25693-2-git-send-email-allan.nielsen@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0053.outbound.protection.outlook.com ([104.47.37.53]:36525
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755134AbcKDKgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:36:16 -0400
In-Reply-To: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Defines a generic API to get/set phy tunables. The API is using the
existing ethtool_tunable/tunable_type_id types which is already being used
for mac level tunables.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 include/uapi/linux/ethtool.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 8e54723..fd0bd36 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -248,6 +248,10 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+enum phy_tunable_id {
+	ETHTOOL_PHY_ID_UNSPEC,
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -1313,7 +1317,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.7.3
