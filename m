From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/3] tg3: use netdev_priv
Date: Fri, 15 Oct 2004 13:48:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015134818.306d8d14@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

use netdev_priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-10-15 12:19:26 -07:00
+++ b/drivers/net/tg3.c	2004-10-15 12:19:26 -07:00
@@ -6323,7 +6323,7 @@
 						 u32 offset, u32 *val);
 static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct tg3 *tp = dev->priv;
+	struct tg3 *tp = netdev_priv(dev);
 	int ret;
 	u8  *pd;
 	u32 i, offset, len, val, b_offset, b_count;
@@ -6685,7 +6685,7 @@
 static void tg3_get_ethtool_stats (struct net_device *dev,
 				   struct ethtool_stats *estats, u64 *tmp_stats)
 {
-	struct tg3 *tp = dev->priv;
+	struct tg3 *tp = netdev_priv(dev);
 	memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
 }
 
