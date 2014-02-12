From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 02/10] net: phy: add MoCA PHY type
Date: Tue, 11 Feb 2014 20:07:25 -0800
Message-ID: <1392178053-3143-3-git-send-email-f.fainelli@gmail.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:58437 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaBLEIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:08:04 -0500
In-Reply-To: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet MACs are connected to a MoCA PHY which will handle the
low-level job of sending Ethernet frames on the coaxial cable, these
Ethernet MACs need to know about it to be properly configured.
Add a new PHY mode "moca" and update the Device Tree parsing logic to
look for it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_net.c | 1 +
 include/linux/phy.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index 729beba..e04f57b 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -32,6 +32,7 @@ static const char *phy_modes[] = {
 	[PHY_INTERFACE_MODE_SMII]	= "smii",
 	[PHY_INTERFACE_MODE_XGMII]	= "xgmii",
 	[PHY_INTERFACE_MODE_INTERNAL]	= "internal",
+	[PHY_INTERFACE_MODE_MOCA]	= "moca",
 };
 
 /**
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 463434b..0680261 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -75,6 +75,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
 	PHY_INTERFACE_MODE_INTERNAL,
+	PHY_INTERFACE_MODE_MOCA,
 } phy_interface_t;
 
 
-- 
1.8.3.2
