From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v2 2/3] can: m_can: Update documentation to indicate that hclk may be optional
Date: Mon, 24 Jul 2017 17:51:41 -0500
Message-ID: <20170724225142.19975-3-fcooper@ti.com>
References: <20170724225142.19975-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170724225142.19975-1-fcooper@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the documentation to reflect that hclk is now an optional clock.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 Documentation/devicetree/bindings/net/can/m_can.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
index 9e33177..2a0fe5b 100644
--- a/Documentation/devicetree/bindings/net/can/m_can.txt
+++ b/Documentation/devicetree/bindings/net/can/m_can.txt
@@ -12,7 +12,8 @@ Required properties:
 - interrupt-names	: Should contain "int0" and "int1"
 - clocks		: Clocks used by controller, should be host clock
 			  and CAN clock.
-- clock-names		: Should contain "hclk" and "cclk"
+- clock-names		: Should contain "hclk" and "cclk". For some socs hclk
+			  may be optional.
 - pinctrl-<n>		: Pinctrl states as described in bindings/pinctrl/pinctrl-bindings.txt
 - pinctrl-names 	: Names corresponding to the numbered pinctrl states
 - bosch,mram-cfg	: Message RAM configuration data.
-- 
2.10.0

