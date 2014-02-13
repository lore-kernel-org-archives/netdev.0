From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 02/10] net: phy: add MoCA PHY type
Date: Wed, 12 Feb 2014 21:29:47 -0800
Message-ID: <1392269395-23513-3-git-send-email-f.fainelli@gmail.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:36719 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbaBMFa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 00:30:26 -0500
In-Reply-To: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet MACs are connected to a MoCA PHY which will handle the
low-level job of sending Ethernet frames on the coaxial cable, these
Ethernet MACs need to know about it to be properly configured.
Add a new PHY mode "moca" and update the Device Tree parsing logic to
look for it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since v1:
- rebased against the latest net-next master branch

 include/linux/phy.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 743c90e..950d2c9 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -75,6 +75,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
 	PHY_INTERFACE_MODE_INTERNAL,
+	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -116,6 +117,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "xgmii";
 	case PHY_INTERFACE_MODE_INTERNAL:
 		return "internal";
+	case PHY_INTERFACE_MODE_MOCA:
+		return "moca";
 	default:
 		return "unknown";
 	}
-- 
1.8.3.2
