From: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Subject: [PATCH v4 2/2] dt-bindings: net: Add Cortina device tree bindings
Date: Mon, 29 May 2017 09:11:31 +0000
Message-ID: <1496049091-4637-3-git-send-email-bogdan.purcareata@nxp.com>
References: <1496049091-4637-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew-g2DYL2Zd6BY@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1496049091-4637-1-git-send-email-bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add device tree description info for Cortina 10G phy devices.

Signed-off-by: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
---
v3 -> v4:
- Consistency nit between phy label and reg value.
- Add CORTINNA trademark info.

Patch introduced in v3 of the patchset.

 Documentation/devicetree/bindings/net/cortina.txt | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/cortina.txt

diff --git a/Documentation/devicetree/bindings/net/cortina.txt b/Documentation/devicetree/bindings/net/cortina.txt
new file mode 100644
index 0000000..40d0bd9
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/cortina.txt
@@ -0,0 +1,21 @@
+Cortina Phy Driver Device Tree Bindings
+---------------------------------------
+
+CORTINA is a registered trademark of Cortina Systems, Inc.
+
+The driver supports the Cortina Electronic Dispersion Compensation (EDC)
+devices, equipped with clock and data recovery (CDR) circuits. These
+devices make use of registers that are not compatible with Clause 45 or
+Clause 22, therefore they need to be described using the
+"ethernet-phy-id" compatible.
+
+Since the driver only implements  polling mode support, interrupts info
+can be skipped.
+
+Example (CS4340 phy):
+	mdio {
+		cs4340_phy@10 {
+			compatible = "ethernet-phy-id13e5.1002";
+			reg = <0x10>;
+		};
+	};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
