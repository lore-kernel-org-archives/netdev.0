From: "Art Haas" <ahaas@airmail.net>
Subject: [PATCH] Add C99 initializers to ethtool.c
Date: Wed, 18 Feb 2004 18:16:33 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219001633.GC9704@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Here's a little patch adding C99 initializers to ethtool.c. The patch is
against the current BK, and the file has been recompiled with the
changes successfully.

This patch and the one I just sent for the netfilter file were changed
to make the code easier to read and to remove warnings if a '-W' flag is
added to the compile command.

Art Haas

===== net/core/ethtool.c 1.9 vs edited =====
--- 1.9/net/core/ethtool.c	Sun Oct 12 06:18:38 2003
+++ edited/net/core/ethtool.c	Wed Feb 18 17:22:52 2004
@@ -76,7 +76,7 @@
 
 static int ethtool_get_settings(struct net_device *dev, void *useraddr)
 {
-	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 	int err;
 
 	if (!dev->ethtool_ops->get_settings)
@@ -168,7 +168,7 @@
 
 static int ethtool_get_wol(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
+	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
 
 	if (!dev->ethtool_ops->get_wol)
 		return -EOPNOTSUPP;
@@ -195,7 +195,7 @@
 
 static int ethtool_get_msglevel(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GMSGLVL };
 
 	if (!dev->ethtool_ops->get_msglevel)
 		return -EOPNOTSUPP;
@@ -231,7 +231,7 @@
 
 static int ethtool_get_link(struct net_device *dev, void *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GLINK };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GLINK };
 
 	if (!dev->ethtool_ops->get_link)
 		return -EOPNOTSUPP;
@@ -331,7 +331,7 @@
 
 static int ethtool_get_coalesce(struct net_device *dev, void *useraddr)
 {
-	struct ethtool_coalesce coalesce = { ETHTOOL_GCOALESCE };
+	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
 
 	if (!dev->ethtool_ops->get_coalesce)
 		return -EOPNOTSUPP;
@@ -358,7 +358,7 @@
 
 static int ethtool_get_ringparam(struct net_device *dev, void *useraddr)
 {
-	struct ethtool_ringparam ringparam = { ETHTOOL_GRINGPARAM };
+	struct ethtool_ringparam ringparam = { .cmd = ETHTOOL_GRINGPARAM };
 
 	if (!dev->ethtool_ops->get_ringparam)
 		return -EOPNOTSUPP;
@@ -385,7 +385,7 @@
 
 static int ethtool_get_pauseparam(struct net_device *dev, void *useraddr)
 {
-	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
+	struct ethtool_pauseparam pauseparam = { .cmd = ETHTOOL_GPAUSEPARAM };
 
 	if (!dev->ethtool_ops->get_pauseparam)
 		return -EOPNOTSUPP;
@@ -412,7 +412,7 @@
 
 static int ethtool_get_rx_csum(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GRXCSUM };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GRXCSUM };
 
 	if (!dev->ethtool_ops->get_rx_csum)
 		return -EOPNOTSUPP;
@@ -440,7 +440,7 @@
 
 static int ethtool_get_tx_csum(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GTXCSUM };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GTXCSUM };
 
 	if (!dev->ethtool_ops->get_tx_csum)
 		return -EOPNOTSUPP;
@@ -467,7 +467,7 @@
 
 static int ethtool_get_sg(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GSG };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GSG };
 
 	if (!dev->ethtool_ops->get_sg)
 		return -EOPNOTSUPP;
@@ -494,7 +494,7 @@
 
 static int ethtool_get_tso(struct net_device *dev, char *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GTSO };
+	struct ethtool_value edata = { .cmd = ETHTOOL_GTSO };
 
 	if (!dev->ethtool_ops->get_tso)
 		return -EOPNOTSUPP;
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
