From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 2/4] mfd: ptxpmb-ext-cpld: Add documentation for PTXPMB extended CPLD
Date: Fri,  7 Oct 2016 18:19:32 +0300
Message-ID: <1475853574-22339-3-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        JawaharBalaji Thirumalaisamy <jawaharb@juniper.net>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-watchdog@vger.kernel.org,
        netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Georgi Vlaev <gvlaev@juniper.net>

Add DT bindings document for the PTXPMB extended CPLD device.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 .../bindings/mfd/jnx-ptxpmb-ext-cpld.txt           | 35 ++++++++++++++++++++++
 1 file changed, 35 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt

diff --git a/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
new file mode 100644
index 0000000..098a548a
--- /dev/null
+++ b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
@@ -0,0 +1,35 @@
+* Device tree bindings for Juniper's PTXPMB Extended CPLD FPGA MFD driver
+
+The device supports a gpio block which is described in the
+jnx-gpio-ptxpmb-ext-cpld document.
+
+Required properties:
+
+- compatible:		"jnx,ptxpmb-ext-cpld"
+
+- reg:			contains offset/length value for device state control
+			registers space.
+
+Optional properties:
+
+- interrupts:		The interrupt line(s) the /IRQ signal(s) for the device is
+			connected to.
+
+- interrupt-parent:	The parent interrupt controller.
+
+Example:
+
+ext-cpld@1,0 {
+	compatible = "jnx,ptxpmb-ext-cpld";
+	reg = <0x1 0 0x1000>;
+	interrupt-parent = <&mpic>;
+	interrupts = <7 2>, <8 2>;
+
+	gpio_ext_cpld: cpld-ext-gpio {
+		compatible = "jnx,gpio-ptxpmb-ext-cpld";
+		#gpio-cells = <2>;
+		#interrupt-cells = <2>;
+		gpio-controller;
+		interrupt-controller;
+	};
+};
-- 
1.9.1
