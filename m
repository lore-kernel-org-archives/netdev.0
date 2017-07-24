From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 4/4] can: m_can: Add call to of_can_transceiver_fixed
Date: Mon, 24 Jul 2017 18:05:21 -0500
Message-ID: <20170724230521.1436-5-fcooper@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>, <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170724230521.1436-1-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add call to new generic functions that provides support via a binding
to limit the arbitration rate and/or data rate imposed by the physical
transceiver connected to the MCAN peripheral.

Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
---
 drivers/net/can/m_can/m_can.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index f4947a7..bd75df1 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1649,6 +1649,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
 
 	devm_can_led_init(dev);
 
+	of_can_transceiver_fixed(dev);
+
 	dev_info(&pdev->dev, "%s device registered (irq=%d, version=%d)\n",
 		 KBUILD_MODNAME, dev->irq, priv->version);
 
-- 
2.10.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
