From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 10/17] can: m_can: add .ndo_change_mtu function
Date: Tue, 18 Nov 2014 21:37:40 +0100
Message-ID: <1416343067-9810-11-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <b29396@freescale.com>

Use common can_change_mtu function.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 10d571eaed85..e61886bf1bb3 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -992,6 +992,7 @@ static const struct net_device_ops m_can_netdev_ops = {
 	.ndo_open = m_can_open,
 	.ndo_stop = m_can_close,
 	.ndo_start_xmit = m_can_start_xmit,
+	.ndo_change_mtu = can_change_mtu,
 };
 
 static int register_m_can_dev(struct net_device *dev)
-- 
2.1.3

