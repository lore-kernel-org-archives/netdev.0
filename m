From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 04/13] ARM: dts: dra7: Add syscon regmap for CORE CONTROL area
Date: Mon, 8 Sep 2014 17:10:33 +0300
Message-ID: <1410185442-907-5-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:58820 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186AbaIHOLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:11:17 -0400
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Display and DCAN drivers use syscon regmap to access some registers
in the CORE control area. Add the syscon regmap node for this
area.

Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: Nishanth Menon <nm@ti.com>
Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 arch/arm/boot/dts/dra7.dtsi | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index d678152..370009e 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -200,6 +200,11 @@
 			ti,hwmods = "counter_32k";
 		};
 
+		dra7_ctrl_core: ctrl_core@4a002000 {
+			compatible = "syscon";
+			reg = <0x4a002000 0x6d0>;
+		};
+
 		dra7_ctrl_general: tisyscon@4a002e00 {
 			compatible = "syscon";
 			reg = <0x4a002e00 0x7c>;
-- 
1.8.3.2
