From: Paul Cercueil <paul@crapouillou.net>
Subject: [PATCH 1/2] Documentation: devicetree: Add bindings info for rfkill-regulator
Date: Tue,  1 Nov 2016 11:58:39 +0100
Message-ID: <20161101105840.24313-1-paul@crapouillou.net>
Cc: Maarten ter Huurne <maarten@treewalker.org>,
        Paul Cercueil <paul@crapouillou.net>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This document gives information about how to write a devicetree
node that corresponds to the rfkill-regulator driver.

Signed-off-by: Paul Cercueil <paul@crapouillou.net>
---
 .../devicetree/bindings/net/rfkill-regulator.txt       | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/rfkill-regulator.txt

diff --git a/Documentation/devicetree/bindings/net/rfkill-regulator.txt b/Documentation/devicetree/bindings/net/rfkill-regulator.txt
new file mode 100644
index 0000000..aac2fe1
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/rfkill-regulator.txt
@@ -0,0 +1,18 @@
+Device tree bindings for the rfkill-regulator driver
+
+Required properties:
+  - compatible:	should be "rfkill-regulator"
+  - rfkill-name:	the name of this rfkill device
+  - rfkill-type:	the type of this rfkill device;
+			must correspond to a valid rfkill_type from <uapi/linux/rfkill.h>
+  - vrfkill-supply:	phandle to a regulator
+
+Example:
+
+	wlan-rfkill {
+		compatible = "rfkill-regulator";
+		rfkill-name = "WLAN power switch";
+		rfkill-type = <1>;
+
+		vrfkill-supply = <&wlan_power>;
+	};
-- 
2.9.3
