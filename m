From: <yes-KgLukfWpBlCctlrPMvKcciBecyulp+rMXqFh9Ls21Oc@public.gmane.org>
Subject: [Patch v3 net-next 08/12] net:fec: Add fsl,imx6sx-fec  compatible strings
Date: Thu, 11 Sep 2014 02:30:09 +0800
Message-ID: <13089.2262365252$1410375427@news.gmane.org>
References: <1410373813-5731-1-git-send-email-yes>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410373813-5731-1-git-send-email-yes>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

Add compatible string "fsl,imx6sx-fec" for i.MX6SX.

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 658b0b3..0cc7313 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -157,6 +157,7 @@ enum imx_fec_type {
 	IMX28_FEC,
 	IMX6Q_FEC,
 	MVF600_FEC,
+	IMX6SX_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
@@ -165,6 +166,7 @@ static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },
 	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
 	{ .compatible = "fsl,mvf600-fec", .data = &fec_devtype[MVF600_FEC], },
+	{ .compatible = "fsl,imx6sx-fec", .data = &fec_devtype[IMX6SX_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
