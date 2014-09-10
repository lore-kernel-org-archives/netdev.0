From: <yes@shlinux1.ap.freescale.net>
Subject: [Patch v3 net-next 12/12] ARM: dts: imx6sx: add multi-queue support enet
Date: Thu, 11 Sep 2014 02:30:13 +0800
Message-ID: <28260.2877043702$1410375402@news.gmane.org>
References: <1410373813-5731-1-git-send-email-yes>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0094.outbound.protection.outlook.com ([207.46.100.94]:7713
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752716AbaIJSyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 14:54:10 -0400
In-Reply-To: <1410373813-5731-1-git-send-email-yes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

Enable 3 queues suppport for ethernet

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 arch/arm/boot/dts/imx6sx.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/imx6sx.dtsi b/arch/arm/boot/dts/imx6sx.dtsi
index f4b9da6..0a03260 100644
--- a/arch/arm/boot/dts/imx6sx.dtsi
+++ b/arch/arm/boot/dts/imx6sx.dtsi
@@ -776,6 +776,8 @@
 					 <&clks IMX6SX_CLK_ENET_PTP>;
 				clock-names = "ipg", "ahb", "ptp",
 					      "enet_clk_ref", "enet_out";
+				fsl,num-tx-queues=<3>;
+				fsl,num-rx-queues=<3>;
 				status = "disabled";
                         };
 
-- 
1.9.1
