From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] MAINTAINERS: add entry for the PHY library
Date: Tue, 18 Feb 2014 09:47:49 -0800
Message-ID: <1392745669-26645-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>,
	"Grant Likely" <grant.likely@linaro.org>,
	Shaohui Xie <shaohui.xie@freescale.com>,
	Andy Fleming <afleming@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51666 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbaBRRtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 12:49:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library has been subject to some changes, new drivers and DT
interactions over the past few months. Add myself as a maintainer for
the core PHY library parts and drivers. Make sure the PHY library entry
also covers the Device Tree files which have a close interaction with
the MDIO bus, PHY connection and Ethernet PHY mode parsing.

CC: Grant Likely <grant.likely@linaro.org>
CC: Shaohui Xie <shaohui.xie@freescale.com>
CC: Andy Fleming <afleming@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5a7b3ec..2bfdb79 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3330,6 +3330,17 @@ S:	Maintained
 F:	include/linux/netfilter_bridge/
 F:	net/bridge/
 
+ETHERNET PHY LIBRARY
+M:	Florian Fainelli <f.fainelli@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	include/linux/phy.h
+F:	include/linux/phy_fixed.h
+F:	drivers/net/phy/
+F:	Documentation/networking/phy.txt
+F:	drivers/of/of_mdio.c
+F:	drivers/of/of_net.c
+
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.cz>
 L:	linux-ext4@vger.kernel.org
-- 
1.8.3.2
