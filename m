From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] net: update undefined ->ndo_change_mtu() comment
Date: Wed, 14 Jun 2017 16:15:24 +0900
Message-ID: <149742452429.31376.14849833346784081961.sendpatchset@little-apple>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-kernel@vger.kernel.org,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <damm+renesas@opensource.se>

Update ->ndo_change_mtu() callback comment to remove text
about returning error in case of undefined callback. This
change makes the comment match the existing code behavior.

Signed-off-by: Magnus Damm <damm+renesas@opensource.se>
---

 Applies on top of next-20170613

 include/linux/netdevice.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- 0002/include/linux/netdevice.h
+++ work/include/linux/netdevice.h	2017-04-29 16:23:13.980607110 +0900
@@ -910,8 +910,7 @@ struct netdev_xdp {
  *
  * int (*ndo_change_mtu)(struct net_device *dev, int new_mtu);
  *	Called when a user wants to change the Maximum Transfer Unit
- *	of a device. If not defined, any request to change MTU will
- *	will return an error.
+ *	of a device.
  *
  * void (*ndo_tx_timeout)(struct net_device *dev);
  *	Callback used when the transmitter has not made any progress
