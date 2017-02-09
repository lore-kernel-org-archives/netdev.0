From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 3/4] net: Fix checkpatch block comments warnings
Date: Thu,  9 Feb 2017 17:56:06 +1100
Message-ID: <1486623367-28861-4-git-send-email-me@tobin.cc>
References: <1486623367-28861-1-git-send-email-me@tobin.cc>
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Tobin C. Harding" <me@tobin.cc>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486623367-28861-1-git-send-email-me@tobin.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix multiple occurrences of checkpatch warning. WARNING: Block
comments use * on subsequent lines. Also make comment blocks
more uniform.

Signed-off-by: Tobin C. Harding <me@tobin.cc>
---
 net/core/dev.c | 65 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 32 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 471e41a..6a076a1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -353,10 +353,11 @@ static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
 #endif
 
 /*******************************************************************************
+ *
+ *		Protocol management and registration routines
+ *
+ *******************************************************************************/
 
-		Protocol management and registration routines
-
-*******************************************************************************/
 
 /*
  *	Add a protocol ID to the list. Now that the input handler is
@@ -539,10 +540,10 @@ void dev_remove_offload(struct packet_offload *po)
 EXPORT_SYMBOL(dev_remove_offload);
 
 /******************************************************************************
-
-		      Device Boot-time Settings Routines
-
-*******************************************************************************/
+ *
+ *		      Device Boot-time Settings Routines
+ *
+ ******************************************************************************/
 
 /* Boot time configuration table */
 static struct netdev_boot_setup dev_boot_setup[NETDEV_BOOT_SETUP_MAX];
@@ -664,10 +665,10 @@ int __init netdev_boot_setup(char *str)
 __setup("netdev=", netdev_boot_setup);
 
 /*******************************************************************************
-
-			    Device Interface Subroutines
-
-*******************************************************************************/
+ *
+ *			    Device Interface Subroutines
+ *
+ *******************************************************************************/
 
 /**
  *	dev_get_iflink	- get 'iflink' value of a interface
@@ -3343,16 +3344,16 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	}
 
 	/* The device has no queue. Common case for software devices:
-	   loopback, all the sorts of tunnels...
+	 * loopback, all the sorts of tunnels...
 
-	   Really, it is unlikely that netif_tx_lock protection is necessary
-	   here.  (f.e. loopback and IP tunnels are clean ignoring statistics
-	   counters.)
-	   However, it is possible, that they rely on protection
-	   made by us here.
+	 * Really, it is unlikely that netif_tx_lock protection is necessary
+	 * here.  (f.e. loopback and IP tunnels are clean ignoring statistics
+	 * counters.)
+	 * However, it is possible, that they rely on protection
+	 * made by us here.
 
-	   Check this and shot the lock. It is not prone from deadlocks.
-	   Either shot noqueue qdisc, it is even simpler 8)
+	 * Check this and shot the lock. It is not prone from deadlocks.
+	 *Either shot noqueue qdisc, it is even simpler 8)
 	 */
 	if (dev->flags & IFF_UP) {
 		int cpu = smp_processor_id(); /* ok because BHs are off */
@@ -3414,9 +3415,9 @@ int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv)
 EXPORT_SYMBOL(dev_queue_xmit_accel);
 
 
-/*=======================================================================
-			Receiver routines
-  =======================================================================*/
+/*************************************************************************
+ *			Receiver routines
+ *************************************************************************/
 
 int netdev_max_backlog __read_mostly = 1000;
 EXPORT_SYMBOL(netdev_max_backlog);
@@ -6448,8 +6449,8 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 	}
 
 	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
-	   is important. Some (broken) drivers set IFF_PROMISC, when
-	   IFF_ALLMULTI is requested not asking us and not reporting.
+	 * is important. Some (broken) drivers set IFF_PROMISC, when
+	 * IFF_ALLMULTI is requested not asking us and not reporting.
 	 */
 	if ((flags ^ dev->gflags) & IFF_ALLMULTI) {
 		int inc = (flags & IFF_ALLMULTI) ? 1 : -1;
@@ -6813,8 +6814,8 @@ static void rollback_registered_many(struct list_head *head)
 
 
 		/* Notify protocols, that we are about to destroy
-		   this device. They should clean all the things.
-		*/
+		 * this device. They should clean all the things.
+		 */
 		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 
 		if (!dev->rtnl_link_ops ||
@@ -7951,12 +7952,12 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_shutdown(dev);
 
 	/* Notify protocols, that we are about to destroy
-	   this device. They should clean all the things.
-
-	   Note that dev->reg_state stays at NETREG_REGISTERED.
-	   This is wanted because this way 8021q and macvlan know
-	   the device is just moving and can keep their slaves up.
-	*/
+	 * this device. They should clean all the things.
+	 *
+	 * Note that dev->reg_state stays at NETREG_REGISTERED.
+	 * This is wanted because this way 8021q and macvlan know
+	 * the device is just moving and can keep their slaves up.
+	 */
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	rcu_barrier();
 	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-- 
2.7.4
