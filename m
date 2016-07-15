From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: cpsw: make TI_CPSW_PHY_SEL invisible
Date: Fri, 15 Jul 2016 10:12:15 +0200
Message-ID: <1468570335-16305-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:51274 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbcGOIMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 04:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TI_CPSW_PHY_SEL depended on TI_CPSW and was selected by the latter. So
there is no reason to have this symbol visible.

A further optimisation would be to put the code for both symbols into a
single module which would allow to not export at least cpsw_phy_sel()
and simplify the module load process.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/ti/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/=
Kconfig
index e7f0b7d95b65..9904d740d528 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -48,8 +48,7 @@ config TI_DAVINCI_CPDMA
 	  will be called davinci_cpdma.  This is recommended.
=20
 config TI_CPSW_PHY_SEL
-	bool "TI CPSW Switch Phy sel Support"
-	depends on TI_CPSW
+	bool
 	---help---
 	  This driver supports configuring of the phy mode connected to
 	  the CPSW.
--=20
2.8.1
