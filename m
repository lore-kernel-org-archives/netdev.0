From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH 2.5 1/2] remove ethtool privileged references
Date: Thu, 29 May 2003 22:11:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0305292202150.29745-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Feldman, Scott" <scott.feldman@intel.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dev_ioctl already checks capable(CAP_NET_ADMIN) for SOICETHTOOL, so
privileged reference are not necessary.

--- linux-2.5/include/linux/ethtool.h.orig	2003-05-29 21:49:36.000000000 -0700
+++ linux-2.5/include/linux/ethtool.h	2003-05-29 21:52:34.000000000 -0700
@@ -252,23 +252,23 @@
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
-#define ETHTOOL_SSET		0x00000002 /* Set settings, privileged. */
+#define ETHTOOL_SSET		0x00000002 /* Set settings. */
 #define ETHTOOL_GDRVINFO	0x00000003 /* Get driver info. */
-#define ETHTOOL_GREGS		0x00000004 /* Get NIC registers, privileged. */
+#define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
-#define ETHTOOL_SWOL		0x00000006 /* Set wake-on-lan options, priv. */
+#define ETHTOOL_SWOL		0x00000006 /* Set wake-on-lan options. */
 #define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
-#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level, priv. */
-#define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation, priv. */
+#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
+#define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
 #define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) */
 #define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
-#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data, priv. */
+#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
-#define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config, priv. */
+#define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config. */
 #define ETHTOOL_GRINGPARAM	0x00000010 /* Get ring parameters */
-#define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters, priv. */
+#define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters. */
 #define ETHTOOL_GPAUSEPARAM	0x00000012 /* Get pause parameters */
-#define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters, priv. */
+#define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters. */
 #define ETHTOOL_GRXCSUM		0x00000014 /* Get RX hw csum enable (ethtool_value) */
 #define ETHTOOL_SRXCSUM		0x00000015 /* Set RX hw csum enable (ethtool_value) */
 #define ETHTOOL_GTXCSUM		0x00000016 /* Get TX hw csum enable (ethtool_value) */
@@ -276,8 +276,8 @@
 #define ETHTOOL_GSG		0x00000018 /* Get scatter-gather enable
 					    * (ethtool_value) */
 #define ETHTOOL_SSG		0x00000019 /* Set scatter-gather enable
-					    * (ethtool_value), priv. */
-#define ETHTOOL_TEST		0x0000001a /* execute NIC self-test, priv. */
+					    * (ethtool_value). */
+#define ETHTOOL_TEST		0x0000001a /* execute NIC self-test. */
 #define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
 #define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
