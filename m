From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] ARM: dts: at91: VInCo: fix phy reset gpio flag
Date: Tue, 26 Apr 2016 12:24:32 +0200
Message-ID: <1461666272-10107-1-git-send-email-nicolas.ferre@atmel.com>
References: <570BF481.9070903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<netdev@vger.kernel.org>, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>
To: <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BF481.9070903@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix gpio active flag for the phy reset-gpios property. The line is
active low instead of active high.
Actually, this flags was never used by the macb driver.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Hi,

Thanks for having reported this bug to me.
I hope that we will be able to move forward for changing the phy
reset code in the macb driver.

I plan to queue this patch through arm-soc for 4.7.

Thanks, best regards,
  Nicolas

 arch/arm/boot/dts/at91-vinco.dts | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/at91-vinco.dts b/arch/arm/boot/dts/at91-vinco.dts
index 79aec55e1ebc..6a366ee952a8 100644
--- a/arch/arm/boot/dts/at91-vinco.dts
+++ b/arch/arm/boot/dts/at91-vinco.dts
@@ -118,7 +118,7 @@
 
 				ethernet-phy@1 {
 					reg = <0x1>;
-					reset-gpios = <&pioE 8 GPIO_ACTIVE_HIGH>;
+					reset-gpios = <&pioE 8 GPIO_ACTIVE_LOW>;
 					interrupt-parent = <&pioB>;
 					interrupts = <15 IRQ_TYPE_EDGE_FALLING>;
 				};
@@ -162,7 +162,7 @@
 					reg = <0x1>;
 					interrupt-parent = <&pioB>;
 					interrupts = <31 IRQ_TYPE_EDGE_FALLING>;
-					reset-gpios = <&pioE 6 GPIO_ACTIVE_HIGH>;
+					reset-gpios = <&pioE 6 GPIO_ACTIVE_LOW>;
 				};
 			};
 
-- 
2.1.3
