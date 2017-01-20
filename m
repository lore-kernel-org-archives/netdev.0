From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/8] net: phy: Add 2000base-x, 2500base-x and rxaui modes
Date: Sat, 21 Jan 2017 00:30:56 +0100
Message-ID: <1484955062-26718-3-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40348 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752481AbdATXd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:33:56 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 ports 9 and 10 supports some additional PHY modes. Add
these modes to the PHY core so they can be used in the binding.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 3 +++
 include/linux/phy.h                                | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 05150957ecfd..3a6916909d90 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -29,6 +29,9 @@ The following properties are common to the Ethernet controllers:
   * "smii"
   * "xgmii"
   * "trgmii"
+  * "2000base-x",
+  * "2500base-x",
+  * "rxaui"
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5c9d2529685f..2252ce88efdd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -82,6 +82,9 @@ typedef enum {
 	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_QSGMII,
 	PHY_INTERFACE_MODE_TRGMII,
+	PHY_INTERFACE_MODE_1000BASEX,
+	PHY_INTERFACE_MODE_2500BASEX,
+	PHY_INTERFACE_MODE_RXAUI,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -142,6 +145,12 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "qsgmii";
 	case PHY_INTERFACE_MODE_TRGMII:
 		return "trgmii";
+	case PHY_INTERFACE_MODE_1000BASEX:
+		return "1000base-x";
+	case PHY_INTERFACE_MODE_2500BASEX:
+		return "2500base-x";
+	case PHY_INTERFACE_MODE_RXAUI:
+		return "rxaui";
 	default:
 		return "unknown";
 	}
-- 
2.11.0
