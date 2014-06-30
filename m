From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 2/3] ARM: socfpga: Add socfpga Ethernet filter attributes entries
Date: Sun, 29 Jun 2014 20:35:09 -0500
Message-ID: <1404092110-18667-3-git-send-email-vbridgers2013@gmail.com>
References: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:35558 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbaF3BjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:06 -0400
In-Reply-To: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds socfpga Ethernet filter attributes for multicast
and unicast filters per Synopsys Ethernet IP configuration chosen
by Altera for the Cyclone 5 and Arria SOC FPGAs.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: None
---
 arch/arm/boot/dts/socfpga.dtsi |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 4676f25..70fdd20 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -486,6 +486,8 @@
 			clock-names = "stmmaceth";
 			resets = <&rst EMAC0_RESET>;
 			reset-names = "stmmaceth";
+			snps,multicast-filter-bins = <256>;
+			snps,perfect-filter-entries = <128>;
 			status = "disabled";
 		};
 
@@ -500,6 +502,8 @@
 			clock-names = "stmmaceth";
 			resets = <&rst EMAC1_RESET>;
 			reset-names = "stmmaceth";
+			snps,multicast-filter-bins = <256>;
+			snps,perfect-filter-entries = <128>;
 			status = "disabled";
 		};
 
-- 
1.7.9.5
