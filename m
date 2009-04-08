From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [patch] Fix FEC driver compilation
Date: Wed, 8 Apr 2009 11:49:40 +0200
Message-ID: <20090408094940.GL14383@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Ungerer <gerg@uclinux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38425 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967AbZDHJtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 05:49:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Seems an #endif is missing currently in drivers/net/fec.c

Sascha


commit e023dc4defbae07ffdcb800b05c328a5cf28ab12
Author: Sascha Hauer <s.hauer@pengutronix.de>
Date:   Wed Apr 8 11:40:24 2009 +0200

    FEC driver: add missing #endif
    
    Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index a515acc..682e7f0 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1240,6 +1240,7 @@ static void __inline__ fec_phy_ack_intr(void)
 	icrp = (volatile unsigned long *) (MCF_MBAR + MCFSIM_ICR1);
 	*icrp = 0x0d000000;
 }
+#endif
 
 #ifdef CONFIG_M5272
 static void __inline__ fec_get_mac(struct net_device *dev)
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
