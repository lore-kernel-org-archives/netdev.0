From: chavey@google.com
Subject: [PATCH 1/1] - fix ethtool coding style errors and warnings
Date: Wed, 07 Apr 2010 16:06:48 -0700
Message-ID: <pvmaateq2uv.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:57451 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048Ab0DGXHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:07:01 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o37N6xsp025983
	for <netdev@vger.kernel.org>; Wed, 7 Apr 2010 16:07:00 -0700
Received: from qw-out-2122.google.com (qwh8.prod.google.com [10.241.194.200])
	by kpbe14.cbf.corp.google.com with ESMTP id o37N6wbt005154
	for <netdev@vger.kernel.org>; Wed, 7 Apr 2010 16:06:59 -0700
Received: by qw-out-2122.google.com with SMTP id 8so719196qwh.35
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 16:06:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From dcdd5d730a5a0d72c11e5010c65ed3b827fc1b85 Mon Sep 17 00:00:00 2001
From: chavey <chavey@google.com>
Date: Wed, 7 Apr 2010 15:53:31 -0700

Fix coding style errors and warnings output while running checkpatch.pl
on the files net/core/ethtool.c and include/linux/ethtool.h

Signed-off-by: chavey <chavey@google.com>
---
 include/linux/ethtool.h |  115 +++++++++++++++++++++------------------
 net/core/ethtool.c      |  141 ++++++++++++++++++++++++----------------------
 2 files changed, 136 insertions(+), 120 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b33f316..5440972 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -490,12 +490,12 @@ void ethtool_ntuple_flush(struct net_device *dev);
  * get_ufo: Report whether UDP fragmentation offload is enabled
  * set_ufo: Turn UDP fragmentation offload on or off
  * self_test: Run specified self-tests
- * get_strings: Return a set of strings that describe the requested objects 
+ * get_strings: Return a set of strings that describe the requested objects
  * phys_id: Identify the device
  * get_stats: Return statistics about the device
  * get_flags: get 32-bit flags bitmap
  * set_flags: set 32-bit flags bitmap
- * 
+ *
  * Description:
  *
  * get_settings:
@@ -531,14 +531,20 @@ struct ethtool_ops {
 	int	(*nway_reset)(struct net_device *);
 	u32	(*get_link)(struct net_device *);
 	int	(*get_eeprom_len)(struct net_device *);
-	int	(*get_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
-	int	(*set_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
+	int	(*get_eeprom)(struct net_device *,
+			      struct ethtool_eeprom *, u8 *);
+	int	(*set_eeprom)(struct net_device *,
+			      struct ethtool_eeprom *, u8 *);
 	int	(*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
 	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
-	void	(*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
-	int	(*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
-	void	(*get_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
-	int	(*set_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
+	void	(*get_ringparam)(struct net_device *,
+				 struct ethtool_ringparam *);
+	int	(*set_ringparam)(struct net_device *,
+				 struct ethtool_ringparam *);
+	void	(*get_pauseparam)(struct net_device *,
+				  struct ethtool_pauseparam*);
+	int	(*set_pauseparam)(struct net_device *,
+				  struct ethtool_pauseparam*);
 	u32	(*get_rx_csum)(struct net_device *);
 	int	(*set_rx_csum)(struct net_device *, u32);
 	u32	(*get_tx_csum)(struct net_device *);
@@ -550,21 +556,24 @@ struct ethtool_ops {
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*phys_id)(struct net_device *, u32);
-	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+	void	(*get_ethtool_stats)(struct net_device *,
+				     struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
-	u32     (*get_ufo)(struct net_device *);
-	int     (*set_ufo)(struct net_device *, u32);
-	u32     (*get_flags)(struct net_device *);
-	int     (*set_flags)(struct net_device *, u32);
-	u32     (*get_priv_flags)(struct net_device *);
-	int     (*set_priv_flags)(struct net_device *, u32);
+	u32	(*get_ufo)(struct net_device *);
+	int	(*set_ufo)(struct net_device *, u32);
+	u32	(*get_flags)(struct net_device *);
+	int	(*set_flags)(struct net_device *, u32);
+	u32	(*get_priv_flags)(struct net_device *);
+	int	(*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
-	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
+	int	(*get_rxnfc)(struct net_device *,
+			     struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
-	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
+	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
-	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
+	int	(*set_rx_ntuple)(struct net_device *,
+				 struct ethtool_rx_ntuple *);
 	int	(*get_rx_ntuple)(struct net_device *, u32 stringset, void *);
 };
 #endif /* __KERNEL__ */
@@ -576,29 +585,29 @@ struct ethtool_ops {
 #define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
 #define ETHTOOL_SWOL		0x00000006 /* Set wake-on-lan options. */
-#define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
-#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
+#define ETHTOOL_GMSGLVL	0x00000007 /* Get driver message level */
+#define ETHTOOL_SMSGLVL	0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
 #define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) */
-#define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
-#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
+#define ETHTOOL_GEEPROM	0x0000000b /* Get EEPROM data */
+#define ETHTOOL_SEEPROM	0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
 #define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config. */
 #define ETHTOOL_GRINGPARAM	0x00000010 /* Get ring parameters */
 #define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters. */
 #define ETHTOOL_GPAUSEPARAM	0x00000012 /* Get pause parameters */
 #define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters. */
-#define ETHTOOL_GRXCSUM		0x00000014 /* Get RX hw csum enable (ethtool_value) */
-#define ETHTOOL_SRXCSUM		0x00000015 /* Set RX hw csum enable (ethtool_value) */
-#define ETHTOOL_GTXCSUM		0x00000016 /* Get TX hw csum enable (ethtool_value) */
-#define ETHTOOL_STXCSUM		0x00000017 /* Set TX hw csum enable (ethtool_value) */
+#define ETHTOOL_GRXCSUM	0x00000014 /* Get RX hw csum enable (ethtool_value) */
+#define ETHTOOL_SRXCSUM	0x00000015 /* Set RX hw csum enable (ethtool_value) */
+#define ETHTOOL_GTXCSUM	0x00000016 /* Get TX hw csum enable (ethtool_value) */
+#define ETHTOOL_STXCSUM	0x00000017 /* Set TX hw csum enable (ethtool_value) */
 #define ETHTOOL_GSG		0x00000018 /* Get scatter-gather enable
 					    * (ethtool_value) */
 #define ETHTOOL_SSG		0x00000019 /* Set scatter-gather enable
 					    * (ethtool_value). */
 #define ETHTOOL_TEST		0x0000001a /* execute NIC self-test. */
 #define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
-#define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
+#define ETHTOOL_PHYS_ID	0x0000001c /* identify the NIC */
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
@@ -609,24 +618,24 @@ struct ethtool_ops {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GFLAGS		0x00000025 /* Get flags bitmap(ethtool_value) */
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
-#define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
-#define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_GPFLAGS	0x00000027 /* Get driver-private flags bitmap */
+#define ETHTOOL_SPFLAGS	0x00000028 /* Set driver-private flags bitmap */
 
-#define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
-#define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+#define ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
+#define ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
-#define	ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
-#define	ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
-#define	ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
-#define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
-#define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
-#define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
-#define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
-#define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
-#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
+#define ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
+#define ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
+#define ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
+#define ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
+#define ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
+#define ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
+#define ETHTOOL_RESET		0x00000034 /* Reset hardware */
+#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -635,18 +644,18 @@ struct ethtool_ops {
 /* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
-#define SUPPORTED_100baseT_Half		(1 << 2)
-#define SUPPORTED_100baseT_Full		(1 << 3)
+#define SUPPORTED_100baseT_Half	(1 << 2)
+#define SUPPORTED_100baseT_Full	(1 << 3)
 #define SUPPORTED_1000baseT_Half	(1 << 4)
 #define SUPPORTED_1000baseT_Full	(1 << 5)
 #define SUPPORTED_Autoneg		(1 << 6)
 #define SUPPORTED_TP			(1 << 7)
 #define SUPPORTED_AUI			(1 << 8)
 #define SUPPORTED_MII			(1 << 9)
-#define SUPPORTED_FIBRE			(1 << 10)
+#define SUPPORTED_FIBRE		(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
-#define SUPPORTED_Pause			(1 << 13)
+#define SUPPORTED_Pause		(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
 #define SUPPORTED_2500baseX_Full	(1 << 15)
 #define SUPPORTED_Backplane		(1 << 16)
@@ -656,8 +665,8 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 
 /* Indicates what features are advertised by the interface. */
-#define ADVERTISED_10baseT_Half		(1 << 0)
-#define ADVERTISED_10baseT_Full		(1 << 1)
+#define ADVERTISED_10baseT_Half	(1 << 0)
+#define ADVERTISED_10baseT_Full	(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
 #define ADVERTISED_100baseT_Full	(1 << 3)
 #define ADVERTISED_1000baseT_Half	(1 << 4)
@@ -696,12 +705,12 @@ struct ethtool_ops {
 #define DUPLEX_FULL		0x01
 
 /* Which connector port. */
-#define PORT_TP			0x00
+#define PORT_TP		0x00
 #define PORT_AUI		0x01
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
-#define PORT_DA			0x05
+#define PORT_DA		0x05
 #define PORT_NONE		0xef
 #define PORT_OTHER		0xff
 
@@ -715,7 +724,7 @@ struct ethtool_ops {
 /* Enable or disable autonegotiation.  If this is set to enable,
  * the forced link modes above are completely ignored.
  */
-#define AUTONEG_DISABLE		0x00
+#define AUTONEG_DISABLE	0x00
 #define AUTONEG_ENABLE		0x01
 
 /* Mode MDI or MDI-X */
@@ -746,8 +755,8 @@ struct ethtool_ops {
 #define	AH_V6_FLOW	0x0b
 #define	ESP_V6_FLOW	0x0c
 #define	IP_USER_FLOW	0x0d
-#define IPV4_FLOW       0x10
-#define IPV6_FLOW       0x11
+#define	IPV4_FLOW	0x10
+#define	IPV6_FLOW	0x11
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f4cb6b6..567cf5f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -18,7 +18,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/bitops.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -30,6 +30,7 @@ u32 ethtool_op_get_link(struct net_device *dev)
 {
 	return netif_carrier_ok(dev) ? 1 : 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_link);
 
 u32 ethtool_op_get_rx_csum(struct net_device *dev)
 {
@@ -62,6 +63,7 @@ int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
 
 int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
 {
@@ -72,11 +74,13 @@ int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
 
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 
 u32 ethtool_op_get_sg(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_SG) != 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_sg);
 
 int ethtool_op_set_sg(struct net_device *dev, u32 data)
 {
@@ -87,11 +91,13 @@ int ethtool_op_set_sg(struct net_device *dev, u32 data)
 
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_sg);
 
 u32 ethtool_op_get_tso(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_TSO) != 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_tso);
 
 int ethtool_op_set_tso(struct net_device *dev, u32 data)
 {
@@ -102,11 +108,13 @@ int ethtool_op_set_tso(struct net_device *dev, u32 data)
 
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tso);
 
 u32 ethtool_op_get_ufo(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_UFO) != 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_ufo);
 
 int ethtool_op_set_ufo(struct net_device *dev, u32 data)
 {
@@ -116,6 +124,7 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
 		dev->features &= ~NETIF_F_UFO;
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_ufo);
 
 /* the following list of flags are the same as their associated
  * NETIF_F_xxx values in include/linux/netdevice.h
@@ -132,6 +141,7 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 
 	return dev->features & flags_dup_features;
 }
+EXPORT_SYMBOL(ethtool_op_get_flags);
 
 int ethtool_op_set_flags(struct net_device *dev, u32 data)
 {
@@ -155,6 +165,7 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data)
 	dev->features = features;
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_flags);
 
 void ethtool_ntuple_flush(struct net_device *dev)
 {
@@ -200,7 +211,8 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
-static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
+						  void __user *useraddr)
 {
 	struct ethtool_drvinfo info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -240,7 +252,7 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev, void _
 }
 
 static noinline_for_stack int ethtool_get_sset_info(struct net_device *dev,
-                                          void __user *useraddr)
+						    void __user *useraddr)
 {
 	struct ethtool_sset_info info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -299,7 +311,8 @@ out:
 	return ret;
 }
 
-static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
+						void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
 
@@ -312,7 +325,8 @@ static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev, void __u
 	return dev->ethtool_ops->set_rxnfc(dev, &cmd);
 }
 
-static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
+						void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -357,8 +371,8 @@ err_out:
 }
 
 static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
-                              struct ethtool_rx_ntuple_flow_spec *spec,
-                              struct ethtool_rx_ntuple_flow_spec_container *fsc)
+			struct ethtool_rx_ntuple_flow_spec *spec,
+			struct ethtool_rx_ntuple_flow_spec_container *fsc)
 {
 
 	/* don't add filters forever */
@@ -384,7 +398,8 @@ static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 	list->count++;
 }
 
-static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
+						    void __user *useraddr)
 {
 	struct ethtool_rx_ntuple cmd;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -509,125 +524,125 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 		case UDP_V4_FLOW:
 		case SCTP_V4_FLOW:
 			sprintf(p, "\tSrc IP addr: 0x%x\n",
-			        fsc->fs.h_u.tcp_ip4_spec.ip4src);
+				fsc->fs.h_u.tcp_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc IP mask: 0x%x\n",
-			        fsc->fs.m_u.tcp_ip4_spec.ip4src);
+				fsc->fs.m_u.tcp_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP addr: 0x%x\n",
-			        fsc->fs.h_u.tcp_ip4_spec.ip4dst);
+				fsc->fs.h_u.tcp_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP mask: 0x%x\n",
-			        fsc->fs.m_u.tcp_ip4_spec.ip4dst);
+				fsc->fs.m_u.tcp_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc Port: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.tcp_ip4_spec.psrc,
-			        fsc->fs.m_u.tcp_ip4_spec.psrc);
+				fsc->fs.h_u.tcp_ip4_spec.psrc,
+				fsc->fs.m_u.tcp_ip4_spec.psrc);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest Port: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.tcp_ip4_spec.pdst,
-			        fsc->fs.m_u.tcp_ip4_spec.pdst);
+				fsc->fs.h_u.tcp_ip4_spec.pdst,
+				fsc->fs.m_u.tcp_ip4_spec.pdst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.tcp_ip4_spec.tos,
-			        fsc->fs.m_u.tcp_ip4_spec.tos);
+				fsc->fs.h_u.tcp_ip4_spec.tos,
+				fsc->fs.m_u.tcp_ip4_spec.tos);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
 		case AH_ESP_V4_FLOW:
 		case ESP_V4_FLOW:
 			sprintf(p, "\tSrc IP addr: 0x%x\n",
-			        fsc->fs.h_u.ah_ip4_spec.ip4src);
+				fsc->fs.h_u.ah_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc IP mask: 0x%x\n",
-			        fsc->fs.m_u.ah_ip4_spec.ip4src);
+				fsc->fs.m_u.ah_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP addr: 0x%x\n",
-			        fsc->fs.h_u.ah_ip4_spec.ip4dst);
+				fsc->fs.h_u.ah_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP mask: 0x%x\n",
-			        fsc->fs.m_u.ah_ip4_spec.ip4dst);
+				fsc->fs.m_u.ah_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSPI: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.ah_ip4_spec.spi,
-			        fsc->fs.m_u.ah_ip4_spec.spi);
+				fsc->fs.h_u.ah_ip4_spec.spi,
+				fsc->fs.m_u.ah_ip4_spec.spi);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.ah_ip4_spec.tos,
-			        fsc->fs.m_u.ah_ip4_spec.tos);
+				fsc->fs.h_u.ah_ip4_spec.tos,
+				fsc->fs.m_u.ah_ip4_spec.tos);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
 		case IP_USER_FLOW:
 			sprintf(p, "\tSrc IP addr: 0x%x\n",
-			        fsc->fs.h_u.raw_ip4_spec.ip4src);
+				fsc->fs.h_u.raw_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc IP mask: 0x%x\n",
-			        fsc->fs.m_u.raw_ip4_spec.ip4src);
+				fsc->fs.m_u.raw_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP addr: 0x%x\n",
-			        fsc->fs.h_u.raw_ip4_spec.ip4dst);
+				fsc->fs.h_u.raw_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP mask: 0x%x\n",
-			        fsc->fs.m_u.raw_ip4_spec.ip4dst);
+				fsc->fs.m_u.raw_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
 		case IPV4_FLOW:
 			sprintf(p, "\tSrc IP addr: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.ip4src);
+				fsc->fs.h_u.usr_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc IP mask: 0x%x\n",
-			        fsc->fs.m_u.usr_ip4_spec.ip4src);
+				fsc->fs.m_u.usr_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP addr: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.ip4dst);
+				fsc->fs.h_u.usr_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP mask: 0x%x\n",
-			        fsc->fs.m_u.usr_ip4_spec.ip4dst);
+				fsc->fs.m_u.usr_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tL4 bytes: 0x%x, mask: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.l4_4_bytes,
-			        fsc->fs.m_u.usr_ip4_spec.l4_4_bytes);
+				fsc->fs.h_u.usr_ip4_spec.l4_4_bytes,
+				fsc->fs.m_u.usr_ip4_spec.l4_4_bytes);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.tos,
-			        fsc->fs.m_u.usr_ip4_spec.tos);
+				fsc->fs.h_u.usr_ip4_spec.tos,
+				fsc->fs.m_u.usr_ip4_spec.tos);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tIP Version: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.ip_ver,
-			        fsc->fs.m_u.usr_ip4_spec.ip_ver);
+				fsc->fs.h_u.usr_ip4_spec.ip_ver,
+				fsc->fs.m_u.usr_ip4_spec.ip_ver);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tProtocol: %d, mask: 0x%x\n",
-			        fsc->fs.h_u.usr_ip4_spec.proto,
-			        fsc->fs.m_u.usr_ip4_spec.proto);
+				fsc->fs.h_u.usr_ip4_spec.proto,
+				fsc->fs.m_u.usr_ip4_spec.proto);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
 		};
 		sprintf(p, "\tVLAN: %d, mask: 0x%x\n",
-		        fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
+			fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
 		p += ETH_GSTRING_LEN;
 		num_strings++;
 		sprintf(p, "\tUser-defined: 0x%Lx\n", fsc->fs.data);
@@ -640,7 +655,7 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 			sprintf(p, "\tAction: Drop\n");
 		else
 			sprintf(p, "\tAction: Direct to queue %d\n",
-			        fsc->fs.action);
+				fsc->fs.action);
 		p += ETH_GSTRING_LEN;
 		num_strings++;
 unknown_filter:
@@ -852,7 +867,8 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
-static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev,
+						   void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
 
@@ -866,7 +882,8 @@ static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev, void
 	return 0;
 }
 
-static noinline_for_stack int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_coalesce(struct net_device *dev,
+						   void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce;
 
@@ -970,6 +987,7 @@ static int ethtool_set_tx_csum(struct net_device *dev, char __user *useraddr)
 
 	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_csum);
 
 static int ethtool_set_rx_csum(struct net_device *dev, char __user *useraddr)
 {
@@ -1041,7 +1059,7 @@ static int ethtool_get_gso(struct net_device *dev, char __user *useraddr)
 
 	edata.data = dev->features & NETIF_F_GSO;
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		 return -EFAULT;
+		return -EFAULT;
 	return 0;
 }
 
@@ -1064,7 +1082,7 @@ static int ethtool_get_gro(struct net_device *dev, char __user *useraddr)
 
 	edata.data = dev->features & NETIF_F_GRO;
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		 return -EFAULT;
+		return -EFAULT;
 	return 0;
 }
 
@@ -1276,7 +1294,8 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
-static noinline_for_stack int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
+static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
+						   char __user *useraddr)
 {
 	struct ethtool_flash efl;
 
@@ -1305,11 +1324,11 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	if (!dev->ethtool_ops)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
+	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
 
 	/* Allow some commands to be done by anyone */
-	switch(ethcmd) {
+	switch (ethcmd) {
 	case ETHTOOL_GDRVINFO:
 	case ETHTOOL_GMSGLVL:
 	case ETHTOOL_GCOALESCE:
@@ -1337,10 +1356,11 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 			return -EPERM;
 	}
 
-	if (dev->ethtool_ops->begin)
-		if ((rc = dev->ethtool_ops->begin(dev)) < 0)
+	if (dev->ethtool_ops->begin) {
+		rc = dev->ethtool_ops->begin(dev);
+		if (rc  < 0)
 			return rc;
-
+	}
 	old_features = dev->features;
 
 	switch (ethcmd) {
@@ -1530,16 +1550,3 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 
 	return rc;
 }
-
-EXPORT_SYMBOL(ethtool_op_get_link);
-EXPORT_SYMBOL(ethtool_op_get_sg);
-EXPORT_SYMBOL(ethtool_op_get_tso);
-EXPORT_SYMBOL(ethtool_op_set_sg);
-EXPORT_SYMBOL(ethtool_op_set_tso);
-EXPORT_SYMBOL(ethtool_op_set_tx_csum);
-EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
-EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
-EXPORT_SYMBOL(ethtool_op_set_ufo);
-EXPORT_SYMBOL(ethtool_op_get_ufo);
-EXPORT_SYMBOL(ethtool_op_set_flags);
-EXPORT_SYMBOL(ethtool_op_get_flags);
-- 
1.7.0.1

