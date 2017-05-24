From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: sysfs: Document PHY device sysfs attributes
Date: Wed, 24 May 2017 12:33:54 -0700
Message-ID: <20170524193354.10739-4-f.fainelli@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34022 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031273AbdEXTeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:34:10 -0400
Received: by mail-wr0-f195.google.com with SMTP id 6so10681655wrb.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 12:34:09 -0700 (PDT)
In-Reply-To: <20170524193354.10739-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the different sysfs attributes that exist for PHY devices:
attached_dev, phy_has_fixups, phy_id and phy_interface.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net-phydev | 32 ++++++++++++++++++++++++
 1 file changed, 32 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-phydev

diff --git a/Documentation/ABI/testing/sysfs-class-net-phydev b/Documentation/ABI/testing/sysfs-class-net-phydev
new file mode 100644
index 000000000000..a05831667c3d
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-phydev
@@ -0,0 +1,32 @@
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
+		values are in include/linux/phy.h function phy_modes.
+
-- 
2.9.3
