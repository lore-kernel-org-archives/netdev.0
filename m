From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/netrom/: make some code static
Date: Wed, 15 Dec 2004 02:21:07 +0100
Message-ID: <20041215012107.GE12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below makes some needlessly global code static.


diffstat output:
 net/netrom/af_netrom.c |    2 +-
 net/netrom/nr_route.c  |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc3-mm1-full/net/netrom/af_netrom.c.old	2004-12-14 21:45:43.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/netrom/af_netrom.c	2004-12-14 21:45:51.000000000 +0100
@@ -43,7 +43,7 @@
 #include <net/arp.h>
 #include <linux/init.h>
 
-int nr_ndevs = 4;
+static int nr_ndevs = 4;
 
 int sysctl_netrom_default_path_quality            = NR_DEFAULT_QUAL;
 int sysctl_netrom_obsolescence_count_initialiser  = NR_DEFAULT_OBS;
--- linux-2.6.10-rc3-mm1-full/net/netrom/nr_route.c.old	2004-12-14 21:46:05.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/netrom/nr_route.c	2004-12-14 21:46:40.000000000 +0100
@@ -45,7 +45,7 @@
 static HLIST_HEAD(nr_neigh_list);
 static spinlock_t nr_neigh_list_lock = SPIN_LOCK_UNLOCKED;
 
-struct nr_node *nr_node_get(ax25_address *callsign)
+static struct nr_node *nr_node_get(ax25_address *callsign)
 {
 	struct nr_node *found = NULL;
 	struct nr_node *nr_node;
@@ -62,7 +62,8 @@
 	return found;
 }
 
-struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign, struct net_device *dev)
+static struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign,
+					 struct net_device *dev)
 {
 	struct nr_neigh *found = NULL;
 	struct nr_neigh *nr_neigh;
