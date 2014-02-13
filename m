From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 01/10] net: phy: add MoCA PHY type
Date: Thu, 13 Feb 2014 15:30:26 -0800
Message-ID: <1392334235-2167-2-git-send-email-f.fainelli@gmail.com>
References: <1392334235-2167-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:32252 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbaBMXa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:30:56 -0500
In-Reply-To: <1392334235-2167-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet MACs are connected to a MoCA PHY which will handle the
low-level job of sending Ethernet frames on the coaxial cable, these
Ethernet MACs need to know about it to be properly configured.
Add a new PHY mode "moca" and update the Device Tree parsing logic to
look for it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v4:
- respin due to the Kconfig dependency fix

Changes in v3:
- rebased after dropping the "internal" PHY mode patch

Changes in v2:
- rebased against latest net-next/master

 include/linux/phy.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 42f1bc7..f7fe546 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -74,6 +74,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
+	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -113,6 +114,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "smii";
 	case PHY_INTERFACE_MODE_XGMII:
 		return "xgmii";
+	case PHY_INTERFACE_MODE_MOCA:
+		return "moca";
 	default:
 		return "unknown";
 	}
-- 
1.8.3.2
