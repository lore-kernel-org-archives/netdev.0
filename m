From: Krzysztof Kozlowski <krzk@kernel.org>
Subject: [PATCH] dt-bindings: net: sms911x: Add missing optional VDD regulators
Date: Mon, 19 Jun 2017 18:05:41 +0200
Message-ID: <20170619160541.5155-1-krzk@kernel.org>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Krzysztof Kozlowski <krzk@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The lan911x family of devices require supplying from 3.3 V power
supplies (connected to VDD_IO, VDD_A and VREG_3.3 pins).  The existing
driver however obtains only VDD_IO and VDD_A regulators in an optional
way so document this in bindings.

Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
---
 Documentation/devicetree/bindings/net/smsc911x.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
index 16c3a9501f5d..acfafc8e143c 100644
--- a/Documentation/devicetree/bindings/net/smsc911x.txt
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -27,6 +27,7 @@ Optional properties:
   of the device. On many systems this is wired high so the device goes
   out of reset at power-on, but if it is under program control, this
   optional GPIO can wake up in response to it.
+- vdd33a-supply, vddvario-supply : 3.3V analog and IO logic power supplies
 
 Examples:
 
-- 
2.9.3
