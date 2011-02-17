From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 15/14] net/fec: remove unused driver data
Date: Thu, 17 Feb 2011 23:32:25 +0100
Message-ID: <1297981945-28501-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33946 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab1BQWcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:32:33 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apart from not being used the first argument isn't even a struct
platform_device *.

Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

this patch is available at

	git://git.pengutronix.de/git/ukl/linux-2.6.git fec

based on the patches already merged into net-next.

Use whatever is easier for you.

Best regards
Uwe

 drivers/net/fec.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 74798be..634c0da 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -983,8 +983,6 @@ static int fec_enet_mii_init(struct platform_device=
 *pdev)
 	for (i =3D 0; i < PHY_MAX_ADDR; i++)
 		fep->mii_bus->irq[i] =3D PHY_POLL;
=20
-	platform_set_drvdata(ndev, fep->mii_bus);
-
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
=20
--=20
1.7.2.3

