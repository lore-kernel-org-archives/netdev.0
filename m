From: <Narendra_K@Dell.com>
Subject: [RFC PATCH net-next] mlx4_en: Do not set dev_id to port number
Date: Fri, 14 Jun 2013 08:06:54 -0700
Message-ID: <20130614150624.GA1316@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <ogerlitz@mellanox.com>, <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:28823 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab3FNPHT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 11:07:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port number should not be stored in dev_id. 'dev_id' field was
intended to be used to differentiate between multiple devices
which share the same MAC address.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index ade276c..ca618e0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2138,7 +2138,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_set_real_num_rx_queues(dev, prof->rx_ring_num);
 
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
-	dev->dev_id =  port - 1;
 
 	/*
 	 * Initialize driver private data
-- 
1.8.0.1

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
