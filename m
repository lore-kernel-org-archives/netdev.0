From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] warning in ethtool ixgb
Date: Mon, 9 Jun 2003 10:51:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609105106.0330bbec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Looks like ethtool now knows about 10G devices in 2.5.70 bk-latest, so ixgb genrates a warning.
This should fix that:

diff -Nru a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
--- a/drivers/net/ixgb/ixgb_ethtool.c	Mon Jun  9 10:49:01 2003
+++ b/drivers/net/ixgb/ixgb_ethtool.c	Mon Jun  9 10:49:01 2003
@@ -50,9 +50,6 @@
 	return (IXGB_EEPROM_SIZE << 1);
 }
 
-#define SUPPORTED_10000baseT_Full (1 << 11)
-#define SPEED_10000 10000
-
 static void
 ixgb_ethtool_gset(struct ixgb_adapter *adapter, struct ethtool_cmd *ecmd)
 {
