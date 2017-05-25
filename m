From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/2] net: dsa: mv88e6xxx: Add eeprom-length to binding
Date: Fri, 26 May 2017 01:44:43 +0200
Message-ID: <1495755884-31341-2-git-send-email-andrew@lunn.ch>
References: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        linux ARM <linux-arm-kernel@lists.infradead.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>, shawnguo@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45156 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933514AbdEYXp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:45:29 -0400
In-Reply-To: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The binding documentation for the mv88e6xxx switch is missing the
eeprom-length property, which has been implemented since May 2016,
commit f8cd8753def0 ("dsa: mv88e6xxx: Handle eeprom-length property")

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/marvell.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 7ef9dbb08957..1d4d0f49c9d0 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -26,6 +26,10 @@ Optional properties:
 - interrupt-controller	: Indicates the switch is itself an interrupt
 			  controller. This is used for the PHY interrupts.
 #interrupt-cells = <2>	: Controller uses two cells, number and flag
+- eeprom-length		: Set to the length of an EEPROM connected to the
+			  switch. Must be set if the switch can not detect
+			  the presence and/or size of a connected EEPROM,
+			  otherwise optional.
 - mdio			: Container of PHY and devices on the switches MDIO
 			  bus.
 - mdio?		: Container of PHYs and devices on the external MDIO
-- 
2.11.0
