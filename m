From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 24/24] Add linux,mdio-nop support for testing
Date: Mon,  4 Jan 2016 18:37:02 +0100
Message-ID: <1451929022-5580-25-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34955 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbcADRhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:37:46 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 6e657a9312ce..044e213f5809 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -68,6 +68,11 @@
 			reg = <8>;
 			#address-cells = <1>;
 			#size-cells = <0>;
+
+			nop: nop@4 {
+			     compatible = "linux,mdio-nop";
+			     reg = <4>;
+			};
 		};
 	};
 
-- 
2.6.4
