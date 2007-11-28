From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] SET_NETDEV_DEV() in fec_mpc52xx.c
Date: Wed, 28 Nov 2007 18:04:31 +0000
Message-ID: <1196273071.30806.46.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Domen Puncer <domen.puncer@telargo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58581 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbXK1SEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 13:04:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This helps to allow the Fedora installer to use the built-in Ethernet on
the Efika for a network install.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -971,6 +971,8 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 
 	mpc52xx_fec_reset_stats(ndev);
 
+	SET_NETDEV_DEV(ndev, &op->dev);
+
 	/* Register the new network device */
 	rv = register_netdev(ndev);
 	if (rv < 0)

-- 
dwmw2

