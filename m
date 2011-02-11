From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 05/14] net/fec: no need to memzero private data
Date: Fri, 11 Feb 2011 11:32:13 +0100
Message-ID: <1297420342-17739-5-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52470 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab1BKKcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:32 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_etherdev internally uses kzalloc, so the private data is already
zerod out.

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 8026a16..9a25e1e 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1386,7 +1386,6 @@ fec_probe(struct platform_device *pdev)
=20
 	/* setup board info structure */
 	fep =3D netdev_priv(ndev);
-	memset(fep, 0, sizeof(*fep));
=20
 	ndev->base_addr =3D (unsigned long)ioremap(r->start, resource_size(r)=
);
 	fep->pdev =3D pdev;
--=20
1.7.2.3

