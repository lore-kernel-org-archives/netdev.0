From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 4/4] gpio: ptxpmb-ext-cpld: Document bindings of PTXPMB extended CPLD
Date: Fri,  7 Oct 2016 18:19:34 +0300
Message-ID: <1475853574-22339-5-git-send-email-pantelis.antoniou@konsulko.com>
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
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Georgi Vlaev <gvlaev@juniper.net>

Add device tree bindings document for the GPIO driver of
Juniper's PTXPMB extended CPLD.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 .../bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt     | 36 ++++++++++++++++++++++
 1 file changed, 36 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt

diff --git a/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
new file mode 100644
index 0000000..87f01b9
--- /dev/null
+++ b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
@@ -0,0 +1,36 @@
+Juniper PTXPMB extended CPLD GPIO block
+
+Required properties:
+
+- compatible:
+    Must be "jnx,gpio-ptxpmb-ext-cpld"
+
+- #gpio-cells:
+    Should be <2>.  The first cell is the pin number (within the controller's
+    pin space), and the second is used for the following flags:
+	bit[0]: direction (0 = out, 1 = in)
+	bit[1]: init high
+	bit[2]: active low
+
+- gpio-controller:
+    Specifies that the node is a GPIO controller.
+
+- interrupt-controller:
+    Specifies that the node is an interrupt controller.
+
+Optional properties:
+
+- reg:
+    Address and length of the register set for the device. Usually supplied
+    by the parent MFD device.
+
+
+Example:
+
+gpio_ext_cpld: cpld-ext-gpio {
+	compatible = "jnx,gpio-ptxpmb-ext-cpld";
+	#gpio-cells = <2>;
+	#interrupt-cells = <2>;
+	gpio-controller;
+	interrupt-controller;
+};
-- 
1.9.1

