From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/8] net: usb: Use eth_random_addr
Date: Thu, 12 Jul 2012 22:33:07 -0700
Message-ID: <2299c22a3ee8c8ed355b8488fb80aa886059de17.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
In-Reply-To: <cover.1342157022.git.joe@perches.com>
References: <cover.1342157022.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the existing uses of random_ether_addr to
the new eth_random_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc75xx.c |    2 +-
 drivers/net/usb/smsc95xx.c |    2 +-
 drivers/net/usb/usbnet.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1c6e515..6c0c5b7 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -616,7 +616,7 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	eth_hw_addr_random(dev->net);
-	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr");
+	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr");
 }
 
 static int smsc75xx_set_mac_address(struct usbnet *dev)
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index bd7cbaa..25cc3a1 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -647,7 +647,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	eth_hw_addr_random(dev->net);
-	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr\n");
+	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr\n");
 }
 
 static int smsc95xx_set_mac_address(struct usbnet *dev)
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e92c057..8531c1c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1593,7 +1593,7 @@ static int __init usbnet_init(void)
 	BUILD_BUG_ON(
 		FIELD_SIZEOF(struct sk_buff, cb) < sizeof(struct skb_data));
 
-	random_ether_addr(node_id);
+	eth_random_addr(node_id);
 	return 0;
 }
 module_init(usbnet_init);
-- 
1.7.8.111.gad25c.dirty
