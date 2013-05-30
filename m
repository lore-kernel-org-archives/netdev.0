From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv4 3/6] ARM: sun4i: Add muxing options for the ethernet controller
Date: Thu, 30 May 2013 15:49:22 +0200
Message-ID: <1369921765-3367-4-git-send-email-maxime.ripard@free-electrons.com>
References: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:39051 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab3E3Ntm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:49:42 -0400
In-Reply-To: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC only has one pinset available for muxing, so hopefully, we
cover all cases.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Tested-by: Richard Genoud <richard.genoud@gmail.com>
---
 arch/arm/boot/dts/sun4i-a10.dtsi | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10.dtsi b/arch/arm/boot/dts/sun4i-a10.dtsi
index e7ef619..ff1f41f 100644
--- a/arch/arm/boot/dts/sun4i-a10.dtsi
+++ b/arch/arm/boot/dts/sun4i-a10.dtsi
@@ -199,6 +199,17 @@
 				allwinner,drive = <0>;
 				allwinner,pull = <0>;
 			};
+
+			emac_pins_a: emac0@0 {
+				allwinner,pins = "PA0", "PA1", "PA2",
+						"PA3", "PA4", "PA5", "PA6",
+						"PA7", "PA8", "PA9", "PA10",
+						"PA11", "PA12", "PA13", "PA14",
+						"PA15", "PA16";
+				allwinner,function = "emac";
+				allwinner,drive = <0>;
+				allwinner,pull = <0>;
+			};
 		};
 
 		timer@01c20c00 {
-- 
1.8.2.3
