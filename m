From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v5 4/4] can: m_can: Add call to of_can_transceiver
Date: Fri, 18 Aug 2017 15:21:37 -0500
Message-ID: <20170818202137.29816-5-fcooper@ti.com>
References: <20170818202137.29816-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818202137.29816-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add call to new generic functions that provides support via a binding
to limit the arbitration rate and/or data rate imposed by the physical
transceiver connected to the MCAN peripheral.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 drivers/net/can/m_can/m_can.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index f4947a7..f72116e 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1649,6 +1649,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
 
 	devm_can_led_init(dev);
 
+	of_can_transceiver(dev);
+
 	dev_info(&pdev->dev, "%s device registered (irq=%d, version=%d)\n",
 		 KBUILD_MODNAME, dev->irq, priv->version);
 
-- 
2.9.4.dirty
