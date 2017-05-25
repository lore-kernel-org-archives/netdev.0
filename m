From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/3] net: sysfs: Document PHY device sysfs attributes
Date: Thu, 25 May 2017 09:21:43 -0700
Message-ID: <20170525162143.18319-4-f.fainelli@gmail.com>
References: <20170525162143.18319-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:32843 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165404AbdEYQVw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:21:52 -0400
Received: by mail-qt0-f195.google.com with SMTP id a46so30750227qte.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:21:51 -0700 (PDT)
In-Reply-To: <20170525162143.18319-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the different sysfs attributes that exist for PHY devices:
attached_dev, phy_has_fixups, phy_id and phy_interface.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net-phydev | 36 ++++++++++++++++++++++++
 1 file changed, 36 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-phydev

diff --git a/Documentation/ABI/testing/sysfs-class-net-phydev b/Documentation/ABI/testing/sysfs-class-net-phydev
new file mode 100644
index 000000000000..c768d5fd8496
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-phydev
@@ -0,0 +1,36 @@
+What:		/sys/class/mdio_bus/<bus>/<device>/attached_dev
+Date:		May 2017
+KernelVersion:	4.13
+Contact:	netdev@vger.kernel.org
+Description:
+		Symbolic link to the network device this PHY device is
+		attached to.
+
+What:		/sys/class/mdio_bus/<bus>/<device>/phy_has_fixups
+Date:		February 2014
+KernelVersion:	3.15
+Contact:	netdev@vger.kernel.org
+Description:
+		Boolean value indicating whether the PHY device has
+		any fixups registered against it (phy_register_fixup)
+
+What:		/sys/class/mdio_bus/<bus>/<device>/phy_id
+Date:		November 2012
+KernelVersion:	3.8
+Contact:	netdev@vger.kernel.org
+Description:
+		32-bit hexadecimal value corresponding to the PHY device's OUI,
+		model and revision number.
+
+What:		/sys/class/mdio_bus/<bus>/<device>/phy_interface
+Date:		February 2014
+KernelVersion:	3.15
+Contact:	netdev@vger.kernel.org
+Description:
+		String value indicating the PHY interface, possible
+		values are:.
+		<empty> (not available), mii, gmii, sgmii, tbi, rev-mii,
+		rmii, rgmii, rgmii-id, rgmii-rxid, rgmii-txid, rtbi, smii
+		xgmii, moca, qsgmii, trgmii, 1000base-x, 2500base-x, rxaui,
+		unknown
+
-- 
2.9.3
