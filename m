From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 9/11] ibm_newemac: Fix typo reading TAH channel info
Date: Fri, 30 Nov 2007 16:40:32 +1100
Message-ID: <20071130054135.BA959DDEC0@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48409 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569AbXK3Flg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:36 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
