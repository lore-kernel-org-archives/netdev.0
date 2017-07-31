From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v3] MAINTAINERS: Add more files to the PHY LIBRARY section
Date: Mon, 31 Jul 2017 09:47:50 -0700
Message-ID: <20170731164750.16544-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, joe@perches.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33159 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdGaQsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 12:48:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so25456122wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 09:48:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include missing files that are provided by, used, or directly maintained
within the PHY LIBRARY, this include uapi header, header files used by
Device Tree code etc.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3:

- use wildcards suggested by Joe

Changes in v2:

- added the files Andrew identified and a few more
- sort by alphabetical order

 MAINTAINERS | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 297e610c9163..a7a392a74859 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5138,12 +5138,20 @@ M:	Andrew Lunn <andrew@lunn.ch>
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	include/linux/phy.h
-F:	include/linux/phy_fixed.h
-F:	drivers/net/phy/
+F:	Documentation/ABI/testing/sysfs-bus-mdio
+F:	Documentation/devicetree/bindings/net/mdio*
 F:	Documentation/networking/phy.txt
+F:	drivers/net/phy/
 F:	drivers/of/of_mdio.c
 F:	drivers/of/of_net.c
+F:	include/linux/*mdio*.h
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
