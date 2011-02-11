From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 10/14] net/fec: some whitespace cleanup
Date: Fri, 11 Feb 2011 11:32:18 +0100
Message-ID: <1297420342-17739-10-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52449 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291Ab1BKKc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:29 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few of these were found and reported by Lothar Wa=C3=9Fmann.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index c70503a..4c888f1 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -182,7 +182,7 @@ struct fec_enet_private {
 	struct bufdesc	*rx_bd_base;
 	struct bufdesc	*tx_bd_base;
 	/* The next free ring entry */
-	struct bufdesc	*cur_rx, *cur_tx;=20
+	struct bufdesc	*cur_rx, *cur_tx;
 	/* The ring entries to be free()ed */
 	struct bufdesc	*dirty_tx;
=20
@@ -190,15 +190,15 @@ struct fec_enet_private {
 	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC =
*/
 	spinlock_t hw_lock;
=20
-	struct  platform_device *pdev;
+	struct	platform_device *pdev;
=20
 	int	opened;
=20
 	/* Phylib and MDIO interface */
-	struct  mii_bus *mii_bus;
-	struct  phy_device *phy_dev;
-	int     mii_timeout;
-	uint    phy_speed;
+	struct	mii_bus *mii_bus;
+	struct	phy_device *phy_dev;
+	int	mii_timeout;
+	uint	phy_speed;
 	phy_interface_t	phy_interface;
 	int	link;
 	int	full_duplex;
@@ -525,8 +525,8 @@ fec_enet_rx(struct net_device *ndev)
 		ndev->stats.rx_bytes +=3D pkt_len;
 		data =3D (__u8*)__va(bdp->cbd_bufaddr);
=20
-	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
-        			DMA_FROM_DEVICE);
+		dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
+				DMA_FROM_DEVICE);
=20
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
@@ -550,7 +550,7 @@ fec_enet_rx(struct net_device *ndev)
 			netif_rx(skb);
 		}
=20
-        	bdp->cbd_bufaddr =3D dma_map_single(NULL, data, bdp->cbd_datl=
en,
+		bdp->cbd_bufaddr =3D dma_map_single(NULL, data, bdp->cbd_datlen,
 			DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
@@ -1034,7 +1034,7 @@ fec_enet_close(struct net_device *ndev)
 		phy_disconnect(fep->phy_dev);
 	}
=20
-        fec_enet_free_buffers(ndev);
+	fec_enet_free_buffers(ndev);
=20
 	return 0;
 }
@@ -1147,7 +1147,7 @@ static const struct net_device_ops fec_netdev_ops=
 =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D fec_timeout,
 	.ndo_set_mac_address	=3D fec_set_mac_address,
-	.ndo_do_ioctl           =3D fec_enet_ioctl,
+	.ndo_do_ioctl		=3D fec_enet_ioctl,
 };
=20
  /*
--=20
1.7.2.3

