From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCHv2 1/2] net: arc_emac: annonce IFF_MULTICAST support
Date: Mon, 14 Nov 2016 16:32:52 +0300
Message-ID: <1479130373-28077-1-git-send-email-al.kochet@gmail.com>
References: <1479129627-27524-2-git-send-email-al.kochet@gmail.com>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, tremyfr@gmail.com, peter.chen@nxp.com,
        wxt@rock-chips.com, weiyj.lk@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479129627-27524-2-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multicast support was implemented by commit 775dd682e2b0ec7
('arc_emac: implement promiscuous mode and multicast filtering').

It can be enabled explicity using 'ifconfig eth0 multicast'.
The patch is needed in order to remove explicit configuration
as most devices has multicast mode enabled by default.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
---
Changes in v2:
Add Signed-off-by text.

 drivers/net/ethernet/arc/emac_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b0da969..2e4ee86 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -764,8 +764,6 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 	ndev->netdev_ops = &arc_emac_netdev_ops;
 	ndev->ethtool_ops = &arc_emac_ethtool_ops;
 	ndev->watchdog_timeo = TX_TIMEOUT;
-	/* FIXME :: no multicast support yet */
-	ndev->flags &= ~IFF_MULTICAST;
 
 	priv = netdev_priv(ndev);
 	priv->dev = dev;
-- 
1.7.9.5
