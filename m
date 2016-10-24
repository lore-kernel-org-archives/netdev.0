From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v2 3/3] ARM: dts: stm32f429: remove Ethernet wake on Lan support
Date: Mon, 24 Oct 2016 10:40:06 +0200
Message-ID: <1477298406-22805-4-git-send-email-alexandre.torgue@st.com>
References: <1477298406-22805-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <devicetree@vger.kernel.org>
To: <peppe.cavallaro@st.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>, <arnd@arndb.de>,
        <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:25456 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S935599AbcJXIk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 04:40:58 -0400
In-Reply-To: <1477298406-22805-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes WoL (Wake on Lan) support as it is not yet
fully supported and tested.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/arch/arm/boot/dts/stm32f429.dtsi b/arch/arm/boot/dts/stm32f429.dtsi
index 6350117b..ad0bc6a 100644
--- a/arch/arm/boot/dts/stm32f429.dtsi
+++ b/arch/arm/boot/dts/stm32f429.dtsi
@@ -377,8 +377,8 @@
 			compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
 			reg = <0x40028000 0x8000>;
 			reg-names = "stmmaceth";
-			interrupts = <61>, <62>;
-			interrupt-names = "macirq", "eth_wake_irq";
+			interrupts = <61>;
+			interrupt-names = "macirq";
 			clock-names = "stmmaceth", "mac-clk-tx", "mac-clk-rx";
 			clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
 			st,syscon = <&syscfg 0x4>;
-- 
1.9.1
