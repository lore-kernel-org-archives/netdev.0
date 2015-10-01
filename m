From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] net: encx24j600_open() can be static
Date: Thu, 1 Oct 2015 15:36:19 +0800
Message-ID: <20151001073618.GA128136@xian>
References: <201510011559.luZbSEuj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jon Ringle <jringle@gridpoint.com>
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443681187-29505-2-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 encx24j600.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 27065ec..b7cb168 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -772,7 +772,7 @@ static int encx24j600_set_mac_address(struct net_device *dev, void *addr)
 	return encx24j600_set_hw_macaddr(dev);
 }
 
-int encx24j600_open(struct net_device *dev)
+static int encx24j600_open(struct net_device *dev)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
 
@@ -793,7 +793,7 @@ int encx24j600_open(struct net_device *dev)
 	return 0;
 }
 
-int encx24j600_stop(struct net_device *dev)
+static int encx24j600_stop(struct net_device *dev)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
 
@@ -894,7 +894,7 @@ static netdev_tx_t encx24j600_tx(struct sk_buff *skb, struct net_device *dev)
 }
 
 /* Deal with a transmit timeout */
-void encx24j600_tx_timeout(struct net_device *dev)
+static void encx24j600_tx_timeout(struct net_device *dev)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
 
