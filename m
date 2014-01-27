From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 3/3] net: ethoc: document OF bindings
Date: Mon, 27 Jan 2014 07:59:27 +0400
Message-ID: <1390795167-6677-4-git-send-email-jcmvbkbc@gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 .../devicetree/bindings/net/opencores-ethoc.txt    | 25 ++++++++++++++++++++++
 1 file changed, 25 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/opencores-ethoc.txt

diff --git a/Documentation/devicetree/bindings/net/opencores-ethoc.txt b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
new file mode 100644
index 0000000..f7c6c94
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
@@ -0,0 +1,25 @@
+* OpenCores MAC 10/100 Mbps
+
+Required properties:
+- compatible: Should be "opencores,ethoc".
+- reg: Address and length of the register set for the device and of its
+  descriptor memory.
+- interrupts: Should contain ethoc interrupt.
+
+Optional properties:
+- local-mac-address: 6 bytes, mac address
+- clock-frequency: basic MAC frequency.
+- mii-mgmt-clock-frequency: frequency of MII management bus. Together
+  with clock-frequency determines the value programmed into the CLKDIV
+  field of MIIMODER register.
+
+Examples:
+
+	enet0: ethoc@fd030000 {
+		compatible = "opencores,ethoc";
+		reg = <0xfd030000 0x4000 0xfd800000 0x4000>;
+		interrupts = <1>;
+		local-mac-address = [00 50 c2 13 6f 00];
+		clock-frequency = <50000000>;
+		mii-mgmt-clock-frequency = <5000000>;
+        };
-- 
1.8.1.4
