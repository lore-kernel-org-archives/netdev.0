From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 1/4] net: Fix checkpatch WARNING: please, no space before tabs
Date: Thu,  9 Feb 2017 17:56:04 +1100
Message-ID: <1486623367-28861-2-git-send-email-me@tobin.cc>
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

This patch fixes multiple occurrences of space before tabs warnings.
More lines of code were moved than required to keep kernel-doc
comments uniform.

Signed-off-by: Tobin C. Harding <me@tobin.cc>
---
 net/core/dev.c | 142 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 71 insertions(+), 71 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 29101c9..2753690 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1,5 +1,5 @@
 /*
- * 	NET3	Protocol independent device support routines.
+ *      NET3    Protocol independent device support routines.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -7,7 +7,7 @@
  *		2 of the License, or (at your option) any later version.
  *
  *	Derived from the non IP parts of dev.c 1.0.19
- * 		Authors:	Ross Biro
+ *              Authors:	Ross Biro
  *				Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *				Mark Evans, <evansmp@uhura.aston.ac.uk>
  *
@@ -21,9 +21,9 @@
  *
  *	Changes:
  *              D.J. Barrow     :       Fixed bug where dev->refcnt gets set
- *              			to 2 if register_netdev gets called
- *              			before net_dev_init & also removed a
- *              			few lines of code in the process.
+ *                                      to 2 if register_netdev gets called
+ *                                      before net_dev_init & also removed a
+ *                                      few lines of code in the process.
  *		Alan Cox	:	device private ioctl copies fields back.
  *		Alan Cox	:	Transmit queue code does relevant
  *					stunts to keep the queue safe.
@@ -36,7 +36,7 @@
  *		Alan Cox	:	100 backlog just doesn't cut it when
  *					you start doing multicast video 8)
  *		Alan Cox	:	Rewrote net_bh and list manager.
- *		Alan Cox	: 	Fix ETH_P_ALL echoback lengths.
+ *              Alan Cox        :       Fix ETH_P_ALL echoback lengths.
  *		Alan Cox	:	Took out transmit every packet pass
  *					Saved a few bytes in the ioctl handler
  *		Alan Cox	:	Network driver sets packet type before
@@ -46,7 +46,7 @@
  *		Richard Kooijman:	Timestamp fixes.
  *		Alan Cox	:	Wrong field in SIOCGIFDSTADDR
  *		Alan Cox	:	Device lock protection.
- *		Alan Cox	: 	Fixed nasty side effect of device close
+ *              Alan Cox        :       Fixed nasty side effect of device close
  *					changes.
  *		Rudi Cilibrasi	:	Pass the right thing to
  *					set_mac_address()
@@ -67,8 +67,8 @@
  *	Paul Rusty Russell	:	SIOCSIFNAME
  *              Pekka Riikonen  :	Netdev boot-time settings code
  *              Andrew Morton   :       Make unregister_netdevice wait
- *              			indefinitely on dev->refcnt
- * 		J Hadi Salim	:	- Backlog queue sampling
+ *                                      indefinitely on dev->refcnt
+ *              J Hadi Salim    :       - Backlog queue sampling
  *				        - netif_rx() feedback
  */
 
@@ -574,13 +574,13 @@ static int netdev_boot_setup_add(char *name, struct ifmap *map)
 }
 
 /**
- *	netdev_boot_setup_check	- check boot time settings
- *	@dev: the netdevice
+ * netdev_boot_setup_check	- check boot time settings
+ * @dev: the netdevice
  *
- * 	Check boot time settings for the device.
- *	The found settings are set for the device to be used
- *	later in the device probing.
- *	Returns 0 if no settings found, 1 if they are.
+ * Check boot time settings for the device.
+ * The found settings are set for the device to be used
+ * later in the device probing.
+ * Returns 0 if no settings found, 1 if they are.
  */
 int netdev_boot_setup_check(struct net_device *dev)
 {
@@ -590,10 +590,10 @@ int netdev_boot_setup_check(struct net_device *dev)
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
 		if (s[i].name[0] != '\0' && s[i].name[0] != ' ' &&
 		    !strcmp(dev->name, s[i].name)) {
-			dev->irq 	= s[i].map.irq;
-			dev->base_addr 	= s[i].map.base_addr;
-			dev->mem_start 	= s[i].map.mem_start;
-			dev->mem_end 	= s[i].map.mem_end;
+			dev->irq = s[i].map.irq;
+			dev->base_addr = s[i].map.base_addr;
+			dev->mem_start = s[i].map.mem_start;
+			dev->mem_end = s[i].map.mem_end;
 			return 1;
 		}
 	}
@@ -603,14 +603,14 @@ EXPORT_SYMBOL(netdev_boot_setup_check);
 
 
 /**
- *	netdev_boot_base	- get address from boot time settings
- *	@prefix: prefix for network device
- *	@unit: id for network device
+ * netdev_boot_base	- get address from boot time settings
+ * @prefix: prefix for network device
+ * @unit: id for network device
  *
- * 	Check boot time settings for the base address of device.
- *	The found settings are set for the device to be used
- *	later in the device probing.
- *	Returns 0 if no settings found.
+ * Check boot time settings for the base address of device.
+ * The found settings are set for the device to be used
+ * later in the device probing.
+ * Returns 0 if no settings found.
  */
 unsigned long netdev_boot_base(const char *prefix, int unit)
 {
@@ -737,15 +737,15 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name)
 EXPORT_SYMBOL(__dev_get_by_name);
 
 /**
- *	dev_get_by_name_rcu	- find a device by its name
- *	@net: the applicable net namespace
- *	@name: name to find
+ * dev_get_by_name_rcu	- find a device by its name
+ * @net: the applicable net namespace
+ * @name: name to find
  *
- *	Find an interface by name.
- *	If the name is found a pointer to the device is returned.
- * 	If the name is not found then %NULL is returned.
- *	The reference counters are not incremented so the caller must be
- *	careful with locks. The caller must hold RCU lock.
+ * Find an interface by name.
+ * If the name is found a pointer to the device is returned.
+ * If the name is not found then %NULL is returned.
+ * The reference counters are not incremented so the caller must be
+ * careful with locks. The caller must hold RCU lock.
  */
 
 struct net_device *dev_get_by_name_rcu(struct net *net, const char *name)
@@ -1289,8 +1289,8 @@ void netdev_state_change(struct net_device *dev)
 EXPORT_SYMBOL(netdev_state_change);
 
 /**
- * 	netdev_notify_peers - notify network peers about existence of @dev
- * 	@dev: network device
+ * netdev_notify_peers - notify network peers about existence of @dev
+ * @dev: network device
  *
  * Generate traffic such that interested network peers are aware of
  * @dev, such as by generating a gratuitous ARP. This may be used when
@@ -1518,17 +1518,17 @@ static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
 static int dev_boot_phase = 1;
 
 /**
- *	register_netdevice_notifier - register a network notifier block
- *	@nb: notifier
+ * register_netdevice_notifier - register a network notifier block
+ * @nb: notifier
  *
- *	Register a notifier to be called when network device events occur.
- *	The notifier passed is linked into the kernel structures and must
- *	not be reused until it has been unregistered. A negative errno code
- *	is returned on a failure.
+ * Register a notifier to be called when network device events occur.
+ * The notifier passed is linked into the kernel structures and must
+ * not be reused until it has been unregistered. A negative errno code
+ * is returned on a failure.
  *
- * 	When registered all registration and up events are replayed
- *	to the new notifier to allow device to have a race free
- *	view of the network device list.
+ * When registered all registration and up events are replayed
+ * to the new notifier to allow device to have a race free
+ * view of the network device list.
  */
 
 int register_netdevice_notifier(struct notifier_block *nb)
@@ -1585,17 +1585,17 @@ int register_netdevice_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL(register_netdevice_notifier);
 
 /**
- *	unregister_netdevice_notifier - unregister a network notifier block
- *	@nb: notifier
+ * unregister_netdevice_notifier - unregister a network notifier block
+ * @nb: notifier
  *
- *	Unregister a notifier previously registered by
- *	register_netdevice_notifier(). The notifier is unlinked into the
- *	kernel structures and may then be reused. A negative errno code
- *	is returned on a failure.
+ * Unregister a notifier previously registered by
+ * register_netdevice_notifier(). The notifier is unlinked into the
+ * kernel structures and may then be reused. A negative errno code
+ * is returned on a failure.
  *
- * 	After unregistering unregister and down device events are synthesized
- *	for all devices on the device list to the removed notifier to remove
- *	the need for special case cleanup code.
+ * After unregistering unregister and down device events are synthesized
+ * for all devices on the device list to the removed notifier to remove
+ * the need for special case cleanup code.
  */
 
 int unregister_netdevice_notifier(struct notifier_block *nb)
@@ -7640,17 +7640,17 @@ void netdev_freemem(struct net_device *dev)
 }
 
 /**
- *	alloc_netdev_mqs - allocate network device
- *	@sizeof_priv:		size of private data to allocate space for
- *	@name:			device name format string
- *	@name_assign_type: 	origin of device name
- *	@setup:			callback to initialize device
- *	@txqs:			the number of TX subqueues to allocate
- *	@rxqs:			the number of RX subqueues to allocate
- *
- *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subqueue structs
- *	for each queue on the device.
+ * alloc_netdev_mqs - allocate network device
+ * @sizeof_priv: size of private data to allocate space for
+ * @name: device name format string
+ * @name_assign_type: origin of device name
+ * @setup: callback to initialize device
+ * @txqs: the number of TX subqueues to allocate
+ * @rxqs: the number of RX subqueues to allocate
+ *
+ * Allocates a struct net_device with private data area for driver use
+ * and performs basic initialization.  Also allocates subqueue structs
+ * for each queue on the device.
  */
 struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		unsigned char name_assign_type,
@@ -7762,13 +7762,13 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 EXPORT_SYMBOL(alloc_netdev_mqs);
 
 /**
- *	free_netdev - free network device
- *	@dev: device
+ * free_netdev - free network device
+ * @dev: device
  *
- *	This function does the last stage of destroying an allocated device
- * 	interface. The reference to the device object is released.
- *	If this is the last reference then it will be freed.
- *	Must be called in process context.
+ * This function does the last stage of destroying an allocated device
+ * interface. The reference to the device object is released. If this
+ * is the last reference then it will be freed.Must be called in process
+ * context.
  */
 void free_netdev(struct net_device *dev)
 {
-- 
2.7.4
