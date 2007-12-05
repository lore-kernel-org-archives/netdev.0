From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 9/11] ibm_newemac: Fix typo reading TAH channel info
Date: Wed, 05 Dec 2007 11:14:31 +1100
Message-ID: <20071205001541.3BEBEDE0DA@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51563 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbXLEAQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 19:16:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentine Barshak <vbarshak@ru.mvista.com>

This patch fixes a typo in ibm_newemac/core.c
(tah_port should be used instead of tah_ph)

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-26 09:43:04.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-26 09:43:05.000000000 +1100
@@ -2442,7 +2442,7 @@ static int __devinit emac_init_config(st
 	if (emac_read_uint_prop(np, "tah-device", &dev->tah_ph, 0))
 		dev->tah_ph = 0;
 	if (emac_read_uint_prop(np, "tah-channel", &dev->tah_port, 0))
-		dev->tah_ph = 0;
+		dev->tah_port = 0;
 	if (emac_read_uint_prop(np, "mdio-device", &dev->mdio_ph, 0))
 		dev->mdio_ph = 0;
 	if (emac_read_uint_prop(np, "zmii-device", &dev->zmii_ph, 0))
