From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/7] via-rhine: remove useless forward declarations.
Date: Sat, 7 Jan 2012 23:50:40 +0100
Message-ID: <20120107225040.GC25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50366 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab2AGXAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:00:00 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 716fd42..d17ca32 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -488,15 +488,8 @@ static struct net_device_stats *rhine_get_stats(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
-static void rhine_shutdown (struct pci_dev *pdev);
 static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
-static void rhine_set_cam(void __iomem *ioaddr, int idx, u8 *addr);
-static void rhine_set_vlan_cam(void __iomem *ioaddr, int idx, u8 *addr);
-static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask);
-static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
-static void rhine_init_cam_filter(struct net_device *dev);
-static void rhine_update_vcam(struct net_device *dev);
 
 #define RHINE_WAIT_FOR(condition)				\
 do {								\
-- 
1.7.6.4
