From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH 2/3] PowerPC: ibm_newemac tah_ph typo fix
Date: Fri, 23 Nov 2007 22:11:52 +0300
Message-ID: <20071123191152.GA25720@ru.mvista.com>
References: <20071123190747.GA25654@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, jwboyer@linux.vnet.ibm.com
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:50750 "EHLO
	vaxon.spb.rtsoft.ru" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755218AbXKWTS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 14:18:57 -0500
Content-Disposition: inline
In-Reply-To: <20071123190747.GA25654@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a typo in ibm_newemac/core.c
(tah_port should be used instead of tah_ph)

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/ibm_newemac/core.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.c linux-2.6/drivers/net/ibm_newemac/core.c
--- linux-2.6.orig/drivers/net/ibm_newemac/core.c	2007-11-23 21:27:57.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.c	2007-11-23 21:36:00.000000000 +0300
@@ -2427,7 +2427,7 @@ static int __devinit emac_init_config(st
 	if (emac_read_uint_prop(np, "tah-device", &dev->tah_ph, 0))
 		dev->tah_ph = 0;
 	if (emac_read_uint_prop(np, "tah-channel", &dev->tah_port, 0))
-		dev->tah_ph = 0;
+		dev->tah_port = 0;
 	if (emac_read_uint_prop(np, "mdio-device", &dev->mdio_ph, 0))
 		dev->mdio_ph = 0;
 	if (emac_read_uint_prop(np, "zmii-device", &dev->zmii_ph, 0))
