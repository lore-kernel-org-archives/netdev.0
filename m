From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] typo in vlan debug code
Date: Mon, 28 Jul 2003 15:17:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728151745.54123f45.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux 802.1Q VLAN" <vlan@wanfear.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

VLAN won't build with debug enabled.

diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	Mon Jul 28 15:05:34 2003
+++ b/net/8021q/vlan_dev.c	Mon Jul 28 15:05:34 2003
@@ -170,7 +170,7 @@
 
 #ifdef VLAN_DEBUG
 		printk(VLAN_DBG "%s: dropping skb: %p because came in on wrong device, dev: %s  real_dev: %s, skb_dev: %s\n",
-			__FUNCTION__ skb, dev->name, 
+			__FUNCTION__, skb, dev->name, 
 			VLAN_DEV_INFO(skb->dev)->real_dev->name, 
 			skb->dev->name);
 #endif
