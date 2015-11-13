From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: [PATCH] net: hisilicon: fix binding document of mdio
Date: Fri, 13 Nov 2015 10:23:44 +0800
Message-ID: <1447381424-107248-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes explain the occasion of "hisilcon,mdio" according to
Arnd's comments. specify it is only used for hip04.

First, please give your commnents.

Signed-off-by: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
---
 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
index 9c23fdf..f650e78 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
@@ -1,7 +1,9 @@
 Hisilicon MDIO bus controller
 
 Properties:
-- compatible: "hisilicon,mdio","hisilicon,hns-mdio".
+- compatible: can be one of "hisilicon,hns-mdio","hisilicon,mdio",
+  for hip04 board, please use "hisilicon,mdio",
+  other boards, "hisilicon,hns-mdio" is OK.
 - reg: The base address of the MDIO bus controller register bank.
 - #address-cells: Must be <1>.
 - #size-cells: Must be <0>.  MDIO addresses have no size component.
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
