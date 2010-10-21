From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/10] can: at91_can: fix section mismatch warning
Date: Thu, 21 Oct 2010 13:01:17 +0200
Message-ID: <1287658882-26914-6-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34919 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757267Ab0JULB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:27 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=2E..by adding the correct annotation "__devinit" to the driver's probe
function.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/can/at91_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 1954ab0..6187813 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1027,7 +1027,7 @@ static const struct net_device_ops at91_netdev_op=
s =3D {
 	.ndo_start_xmit	=3D at91_start_xmit,
 };
=20
-static int __init at91_can_probe(struct platform_device *pdev)
+static int __devinit at91_can_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct at91_priv *priv;
--=20
1.7.0.4

