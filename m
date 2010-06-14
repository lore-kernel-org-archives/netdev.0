From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Revert incorrect indentation changes
Date: Mon, 14 Jun 2010 19:53:26 +0100
Message-ID: <1276541606.2074.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: laurent chavey <chavey@google.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30544 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab0FNSxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 14:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 97f8aefbbfb5aa5c9944e5fa8149f1fdaf71c7b6 "net: fix ethtool
coding style errors and warnings" changed the indentation of several
macro definitions in ethtool.h.  These definitions line up in the diff
where there is an extra character at the start of each line, but not
in the resulting file.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 276b40a..2c8af09 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -586,29 +586,29 @@ struct ethtool_ops {
 #define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
 #define ETHTOOL_SWOL		0x00000006 /* Set wake-on-lan options. */
-#define ETHTOOL_GMSGLVL	0x00000007 /* Get driver message level */
-#define ETHTOOL_SMSGLVL	0x00000008 /* Set driver msg level. */
+#define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
+#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
 #define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) */
-#define ETHTOOL_GEEPROM	0x0000000b /* Get EEPROM data */
-#define ETHTOOL_SEEPROM	0x0000000c /* Set EEPROM data. */
+#define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
+#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
 #define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config. */
 #define ETHTOOL_GRINGPARAM	0x00000010 /* Get ring parameters */
 #define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters. */
 #define ETHTOOL_GPAUSEPARAM	0x00000012 /* Get pause parameters */
 #define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters. */
-#define ETHTOOL_GRXCSUM	0x00000014 /* Get RX hw csum enable (ethtool_value) */
-#define ETHTOOL_SRXCSUM	0x00000015 /* Set RX hw csum enable (ethtool_value) */
-#define ETHTOOL_GTXCSUM	0x00000016 /* Get TX hw csum enable (ethtool_value) */
-#define ETHTOOL_STXCSUM	0x00000017 /* Set TX hw csum enable (ethtool_value) */
+#define ETHTOOL_GRXCSUM		0x00000014 /* Get RX hw csum enable (ethtool_value) */
+#define ETHTOOL_SRXCSUM		0x00000015 /* Set RX hw csum enable (ethtool_value) */
+#define ETHTOOL_GTXCSUM		0x00000016 /* Get TX hw csum enable (ethtool_value) */
+#define ETHTOOL_STXCSUM		0x00000017 /* Set TX hw csum enable (ethtool_value) */
 #define ETHTOOL_GSG		0x00000018 /* Get scatter-gather enable
 					    * (ethtool_value) */
 #define ETHTOOL_SSG		0x00000019 /* Set scatter-gather enable
 					    * (ethtool_value). */
 #define ETHTOOL_TEST		0x0000001a /* execute NIC self-test. */
 #define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
-#define ETHTOOL_PHYS_ID	0x0000001c /* identify the NIC */
+#define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
@@ -619,8 +619,8 @@ struct ethtool_ops {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GFLAGS		0x00000025 /* Get flags bitmap(ethtool_value) */
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
-#define ETHTOOL_GPFLAGS	0x00000027 /* Get driver-private flags bitmap */
-#define ETHTOOL_SPFLAGS	0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
+#define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
 
 #define ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
 #define ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
@@ -645,18 +645,18 @@ struct ethtool_ops {
 /* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
-#define SUPPORTED_100baseT_Half	(1 << 2)
-#define SUPPORTED_100baseT_Full	(1 << 3)
+#define SUPPORTED_100baseT_Half		(1 << 2)
+#define SUPPORTED_100baseT_Full		(1 << 3)
 #define SUPPORTED_1000baseT_Half	(1 << 4)
 #define SUPPORTED_1000baseT_Full	(1 << 5)
 #define SUPPORTED_Autoneg		(1 << 6)
 #define SUPPORTED_TP			(1 << 7)
 #define SUPPORTED_AUI			(1 << 8)
 #define SUPPORTED_MII			(1 << 9)
-#define SUPPORTED_FIBRE		(1 << 10)
+#define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
-#define SUPPORTED_Pause		(1 << 13)
+#define SUPPORTED_Pause			(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
 #define SUPPORTED_2500baseX_Full	(1 << 15)
 #define SUPPORTED_Backplane		(1 << 16)
@@ -666,8 +666,8 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 
 /* Indicates what features are advertised by the interface. */
-#define ADVERTISED_10baseT_Half	(1 << 0)
-#define ADVERTISED_10baseT_Full	(1 << 1)
+#define ADVERTISED_10baseT_Half		(1 << 0)
+#define ADVERTISED_10baseT_Full		(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
 #define ADVERTISED_100baseT_Full	(1 << 3)
 #define ADVERTISED_1000baseT_Half	(1 << 4)
@@ -706,12 +706,12 @@ struct ethtool_ops {
 #define DUPLEX_FULL		0x01
 
 /* Which connector port. */
-#define PORT_TP		0x00
+#define PORT_TP			0x00
 #define PORT_AUI		0x01
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
-#define PORT_DA		0x05
+#define PORT_DA			0x05
 #define PORT_NONE		0xef
 #define PORT_OTHER		0xff
 
@@ -725,7 +725,7 @@ struct ethtool_ops {
 /* Enable or disable autonegotiation.  If this is set to enable,
  * the forced link modes above are completely ignored.
  */
-#define AUTONEG_DISABLE	0x00
+#define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
 /* Mode MDI or MDI-X */
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

