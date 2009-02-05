From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH] net: fix some trailing whitespaces
Date: Thu,  5 Feb 2009 16:05:44 +0800
Message-ID: <1233821144-8764-1-git-send-email-cooloney@kernel.org>
Cc: Graf Yang <graf.yang@analog.com>, Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757619AbZBEIEP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Graf Yang <graf.yang@analog.com>

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 include/linux/if_ether.h  |    8 ++++----
 include/linux/netdevice.h |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7f3c735..0216e1b 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -17,7 +17,7 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  */
- 
+
 #ifndef _LINUX_IF_ETHER_H
 #define _LINUX_IF_ETHER_H
 
@@ -25,7 +25,7 @@
 
 /*
  *	IEEE 802.3 Ethernet magic constants.  The frame sizes omit the preamble
- *	and FCS/CRC (frame check sequence). 
+ *	and FCS/CRC (frame check sequence).
  */
 
 #define ETH_ALEN	6		/* Octets in one ethernet addr	 */
@@ -83,7 +83,7 @@
 /*
  *	Non DIX types. Won't clash for 1500 types.
  */
- 
+
 #define ETH_P_802_3	0x0001		/* Dummy type for 802.3 frames  */
 #define ETH_P_AX25	0x0002		/* Dummy protocol id for AX.25  */
 #define ETH_P_ALL	0x0003		/* Every packet (be careful!!!) */
@@ -109,7 +109,7 @@
 /*
  *	This is an Ethernet frame header.
  */
- 
+
 struct ethhdr {
 	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
 	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec54785..2ddd625 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -96,7 +96,7 @@ struct wireless_dev;
  *	Compute the worst case header length according to the protocols
  *	used.
  */
- 
+
 #if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 # if defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
@@ -124,7 +124,7 @@ struct wireless_dev;
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
  */
- 
+
 struct net_device_stats
 {
 	unsigned long	rx_packets;		/* total packets received	*/
@@ -285,7 +285,7 @@ enum netdev_state_t
 
 /*
  * This structure holds at boot time configured netdevice settings. They
- * are then used in the device probing. 
+ * are then used in the device probing.
  */
 struct netdev_boot_setup {
 	char name[IFNAMSIZ];
@@ -740,7 +740,7 @@ struct net_device
 	void			*dsa_ptr;	/* dsa specific data */
 #endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
-	void			*ip_ptr;	/* IPv4 specific data	*/  
+	void			*ip_ptr;	/* IPv4 specific data	*/
 	void                    *dn_ptr;        /* DECnet specific data */
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
@@ -753,7 +753,7 @@ struct net_device
  */
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
-	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
+	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast
 							   because most packets are unicast) */
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
-- 
1.5.6.3
