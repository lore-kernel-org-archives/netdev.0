From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 11/11] ARM: dts: imx6sx: add multi-queue support enet
Date: Thu, 4 Sep 2014 04:34:46 +0800
Message-ID: <27690.8531123356$1409778664@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0059.outbound.protection.outlook.com ([157.56.110.59]:6176
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751167AbaICVKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:10:50 -0400
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

Enable 3 queues suppport for ethernet

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 arch/arm/boot/dts/imx6sx.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/imx6sx.dtsi b/arch/arm/boot/dts/imx6sx.dtsi
index f4b9da6..1722748 100644
--- a/arch/arm/boot/dts/imx6sx.dtsi
+++ b/arch/arm/boot/dts/imx6sx.dtsi
@@ -776,6 +776,8 @@
 					 <&clks IMX6SX_CLK_ENET_PTP>;
 				clock-names = "ipg", "ahb", "ptp",
 					      "enet_clk_ref", "enet_out";
+				fsl,num_tx_queues=<3>;
+				fsl,num_rx_queues=<3>;
 				status = "disabled";
                         };
 
-- 
1.9.1
