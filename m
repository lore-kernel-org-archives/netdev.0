From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH] include/linux/if_tr.h clean-up
Date: Fri, 20 May 2005 17:10:19 -0500
Message-ID: <20050520221019.GA26211@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I removed the ethernet definitions (which were commented out) and
cleaned up the tabs.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- include/linux/if_tr.h.orig	2005-05-20 15:24:46.723707576 -0500
+++ include/linux/if_tr.h	2005-05-20 15:31:44.657172032 -0500
@@ -9,7 +9,7 @@
  *
  * Author:	Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
- *    Peter De Schrijver, <stud11@cc4.kuleuven.ac.be>
+ *		Peter De Schrijver, <stud11@cc4.kuleuven.ac.be>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -19,24 +19,16 @@
 #ifndef _LINUX_IF_TR_H
 #define _LINUX_IF_TR_H
 
-
 /* IEEE 802.5 Token-Ring magic constants.  The frame sizes omit the preamble
    and FCS/CRC (frame check sequence). */
-#define TR_ALEN	6		/* Octets in one ethernet addr	 */
-#define TR_HLEN   (sizeof(struct trh_hdr)+sizeof(struct trllc))
-#define AC			0x10
-#define LLC_FRAME 0x40
-#if 0
-#define ETH_HLEN	14		/* Total octets in header.	 */
-#define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
-#define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
-#define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
-#endif
-
+#define TR_ALEN		6		/* Octets in one token-ring addr */
+#define TR_HLEN 	(sizeof(struct trh_hdr)+sizeof(struct trllc))
+#define AC		0x10
+#define LLC_FRAME 	0x40
 
 /* LLC and SNAP constants */
-#define EXTENDED_SAP 0xAA
-#define UI_CMD       0x03
+#define EXTENDED_SAP 	0xAA
+#define UI_CMD       	0x03
 
 /* This is an Token-Ring frame header. */
 struct trh_hdr {
@@ -96,14 +88,13 @@ struct tr_statistics {
 };
 
 /* source routing stuff */
-
-#define TR_RII 0x80
-#define TR_RCF_DIR_BIT 0x80
-#define TR_RCF_LEN_MASK 0x1f00
-#define TR_RCF_BROADCAST 0x8000         /* all-routes broadcast */
-#define TR_RCF_LIMITED_BROADCAST 0xC000 /* single-route broadcast */
-#define TR_RCF_FRAME2K 0x20
-#define TR_RCF_BROADCAST_MASK 0xC000
-#define TR_MAXRIFLEN 18
+#define TR_RII 			0x80
+#define TR_RCF_DIR_BIT 		0x80
+#define TR_RCF_LEN_MASK 	0x1f00
+#define TR_RCF_BROADCAST 	0x8000	/* all-routes broadcast */
+#define TR_RCF_LIMITED_BROADCAST 0xC000	/* single-route broadcast */
+#define TR_RCF_FRAME2K 		0x20
+#define TR_RCF_BROADCAST_MASK 	0xC000
+#define TR_MAXRIFLEN 		18
 
 #endif	/* _LINUX_IF_TR_H */
