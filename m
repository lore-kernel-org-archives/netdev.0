From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 01/33] arcnet: fix indentation of if_arcnet.h
Date: Tue, 22 Sep 2015 11:01:42 +0200
Message-ID: <1442912534-10821-2-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45309 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Standardized spacing is easier to read.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 include/uapi/linux/if_arcnet.h | 55 ++++++++++++++++++++----------------------
 1 file changed, 26 insertions(+), 29 deletions(-)

diff --git a/include/uapi/linux/if_arcnet.h b/include/uapi/linux/if_arcnet.h
index 46e34bd..cfb642f 100644
--- a/include/uapi/linux/if_arcnet.h
+++ b/include/uapi/linux/if_arcnet.h
@@ -19,7 +19,6 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
-
 /*
  *    These are the defined ARCnet Protocol ID's.
  */
@@ -57,42 +56,40 @@
  * The RFC1201-specific components of an arcnet packet header.
  */
 struct arc_rfc1201 {
-    __u8  proto;		/* protocol ID field - varies		*/
-    __u8  split_flag;	/* for use with split packets		*/
-    __be16   sequence;		/* sequence number			*/
-    __u8  payload[0];	/* space remaining in packet (504 bytes)*/
+	__u8  proto;		/* protocol ID field - varies		*/
+	__u8  split_flag;	/* for use with split packets		*/
+	__be16   sequence;	/* sequence number			*/
+	__u8  payload[0];	/* space remaining in packet (504 bytes)*/
 };
 #define RFC1201_HDR_SIZE 4
 
-
 /*
  * The RFC1051-specific components.
  */
 struct arc_rfc1051 {
-    __u8 proto;		/* ARC_P_RFC1051_ARP/RFC1051_IP	*/
-    __u8 payload[0];		/* 507 bytes			*/
+	__u8 proto;		/* ARC_P_RFC1051_ARP/RFC1051_IP	*/
+	__u8 payload[0];	/* 507 bytes			*/
 };
 #define RFC1051_HDR_SIZE 1
 
-
 /*
  * The ethernet-encap-specific components.  We have a real ethernet header
  * and some data.
  */
 struct arc_eth_encap {
-    __u8 proto;		/* Always ARC_P_ETHER			*/
-    struct ethhdr eth;		/* standard ethernet header (yuck!)	*/
-    __u8 payload[0];		/* 493 bytes				*/
+	__u8 proto;		/* Always ARC_P_ETHER			*/
+	struct ethhdr eth;	/* standard ethernet header (yuck!)	*/
+	__u8 payload[0];	/* 493 bytes				*/
 };
 #define ETH_ENCAP_HDR_SIZE 14
 
-
 struct arc_cap {
 	__u8 proto;
-	__u8 cookie[sizeof(int)];   /* Actually NOT sent over the network */
+	__u8 cookie[sizeof(int)];
+				/* Actually NOT sent over the network */
 	union {
 		__u8 ack;
-		__u8 raw[0];		/* 507 bytes */
+		__u8 raw[0];	/* 507 bytes */
 	} mes;
 };
 
@@ -105,9 +102,9 @@ struct arc_cap {
  * driver.
  */
 struct arc_hardware {
-    __u8  source,		/* source ARCnet - filled in automagically */
-             dest,		/* destination ARCnet - 0 for broadcast    */
-    	     offset[2];		/* offset bytes (some weird semantics)     */
+	__u8 source;		/* source ARCnet - filled in automagically */
+	__u8 dest;		/* destination ARCnet - 0 for broadcast    */
+	__u8 offset[2];		/* offset bytes (some weird semantics)     */
 };
 #define ARC_HDR_SIZE 4
 
@@ -116,17 +113,17 @@ struct arc_hardware {
  * when you do a raw packet capture).
  */
 struct archdr {
-    /* hardware requirements */
-    struct arc_hardware hard;
-     
-    /* arcnet encapsulation-specific bits */
-    union {
-	struct arc_rfc1201   rfc1201;
-	struct arc_rfc1051   rfc1051;
-	struct arc_eth_encap eth_encap;
-	struct arc_cap       cap;
-	__u8 raw[0];		/* 508 bytes				*/
-    } soft;
+	/* hardware requirements */
+	struct arc_hardware hard;
+
+	/* arcnet encapsulation-specific bits */
+	union {
+		struct arc_rfc1201   rfc1201;
+		struct arc_rfc1051   rfc1051;
+		struct arc_eth_encap eth_encap;
+		struct arc_cap       cap;
+		__u8 raw[0];	/* 508 bytes				*/
+	} soft;
 };
 
 #endif				/* _LINUX_IF_ARCNET_H */
-- 
2.5.1
