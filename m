From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH] add ethtool TSO get/set
Date: Fri, 18 Jul 2003 20:17:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307182004250.2547-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davidm@hpl.hp.com, <netdev@oss.sgi.com>,
   "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add TSO get/set command to ethtool interface.  Applies to both 2.4/2.5.
  Ethtool application patch sent under separate cover.

---------------

--- linux-2.4.22-pre7/include/linux/ethtool.h.orig	2003-07-18 16:35:05.000000000 -0700
+++ linux-2.4.22-pre7/include/linux/ethtool.h	2003-07-18 16:37:35.000000000 -0700
@@ -281,6 +281,8 @@
 #define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
 #define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
+#define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
+#define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
