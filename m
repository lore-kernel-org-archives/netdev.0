From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v2 4/4] ARM: dts: hix5hd2: add gmac generic compatible and clock names
Date: Mon, 5 Dec 2016 21:28:01 +0800
Message-ID: <1480944481-118803-5-git-send-email-lidongpo@hisilicon.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <mturquette@baylibre.com>, <sboyd@codeaurora.org>,
        <linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
        <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:2675 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcLENq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 08:46:57 -0500
In-Reply-To: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gmac generic compatible and clock names.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 arch/arm/boot/dts/hisi-x5hd2.dtsi | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/hisi-x5hd2.dtsi b/arch/arm/boot/dts/hisi-x5hd2.dtsi
index fdcc23d..0da76c5 100644
--- a/arch/arm/boot/dts/hisi-x5hd2.dtsi
+++ b/arch/arm/boot/dts/hisi-x5hd2.dtsi
@@ -436,18 +436,20 @@
 		};
 
 		gmac0: ethernet@1840000 {
-			compatible = "hisilicon,hix5hd2-gmac";
+			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
 			reg = <0x1840000 0x1000>,<0x184300c 0x4>;
 			interrupts = <0 71 4>;
 			clocks = <&clock HIX5HD2_MAC0_CLK>;
+			clock-names = "mac_core";
 			status = "disabled";
 		};
 
 		gmac1: ethernet@1841000 {
-			compatible = "hisilicon,hix5hd2-gmac";
+			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
 			reg = <0x1841000 0x1000>,<0x1843010 0x4>;
 			interrupts = <0 72 4>;
 			clocks = <&clock HIX5HD2_MAC1_CLK>;
+			clock-names = "mac_core";
 			status = "disabled";
 		};
 
-- 
2.8.2
