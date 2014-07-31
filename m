From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v4 4/5] ARM: socfpga: Add socfpga Ethernet filter attributes entries
Date: Thu, 31 Jul 2014 15:49:16 -0500
Message-ID: <1406839757-10905-5-git-send-email-vbridgers2013@gmail.com>
References: <1406839757-10905-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, vbridgers2013@gmail.com, vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:40047 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbaGaUxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:53:06 -0400
In-Reply-To: <1406839757-10905-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds socfpga Ethernet filter attributes for multicast
and unicast filters per Synopsys Ethernet IP configuration chosen
by Altera for the Cyclone 5 and Arria SOC FPGAs.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V4: No changes from V3->V4
V3: No changes
V2: No changes
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
