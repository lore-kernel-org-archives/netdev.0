From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/2] ARM: VF610: ZII devel b: Add switch eeprom-length properties
Date: Fri, 26 May 2017 01:44:44 +0200
Message-ID: <1495755884-31341-3-git-send-email-andrew@lunn.ch>
References: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        linux ARM <linux-arm-kernel@lists.infradead.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>, shawnguo@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45150 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935436AbdEYXpN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:45:13 -0400
In-Reply-To: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two of the Ethernet switches on this board have EEPROMs connected.
Add the eeprom-length property to the device tree, making it possible
to access the EEPROM using ethtool -e.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 37f95427616f..acdf12ad0622 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -78,6 +78,7 @@
 				interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
 				interrupt-controller;
 				#interrupt-cells = <2>;
+				eeprom-length = <512>;
 
 				ports {
 					#address-cells = <1>;
@@ -163,6 +164,7 @@
 				interrupts = <26 IRQ_TYPE_LEVEL_LOW>;
 				interrupt-controller;
 				#interrupt-cells = <2>;
+				eeprom-length = <512>;
 
 				ports {
 					#address-cells = <1>;
-- 
2.11.0
