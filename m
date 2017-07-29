From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] MAINTAINERS: Add more files to the PHY LIBRARY section
Date: Fri, 28 Jul 2017 17:43:17 -0700
Message-ID: <20170729004317.31525-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36063 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753248AbdG2AnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 20:43:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id d40so67697wma.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 17:43:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include missing files that are provided by, used, or directly maintained
within the PHY LIBRARY, this include uapi header, header files used by
Device Tree code etc.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- added the files Andrew identified and a few more
- sort by alphabetical order

 MAINTAINERS | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 297e610c9163..8e44a637c490 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5138,12 +5138,26 @@ M:	Andrew Lunn <andrew@lunn.ch>
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	include/linux/phy.h
-F:	include/linux/phy_fixed.h
-F:	drivers/net/phy/
+F:	Documentation/ABI/testing/sysfs-bus-mdio
+F:	Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
+F:	Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
+F:	Documentation/devicetree/bindings/net/mdio-mux.txt
+F:	Documentation/devicetree/bindings/net/mdio.txt
 F:	Documentation/networking/phy.txt
+F:	drivers/net/phy/
 F:	drivers/of/of_mdio.c
 F:	drivers/of/of_net.c
+F:	include/linux/mdio-bitbang.h
+F:	include/linux/mdio-mux.h
+F:	include/linux/mdio.h
+F:	include/linux/of_mdio.h
+F:	include/linux/of_net.h
+F:	include/linux/phy.h
+F:	include/linux/phy_fixed.h
+F:	include/linux/platform_data/mdio-gpio.h
+F:	include/trace/events/mdio.h
+F:	include/uapi/linux/mdio.h
+F:	include/uapi/linux/mii.h
 
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.com>
-- 
2.9.3
