From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 11/11] ARM: dts: imx6sx: add multi-queue support enet
Date: Thu, 4 Sep 2014 04:34:46 +0800
Message-ID: <2102.80664400688$1409778667@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

Enable 3 queues suppport for ethernet

Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
