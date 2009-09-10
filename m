From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/31: xtables: remove redirecting header files
Date: Thu, 10 Sep 2009 18:12:01 +0200 (MEST)
Message-ID: <20090910161156.31179.11499.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 93bb1e9d117bfc60306b2b8bd9e0fa7ba3c88636
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 19:47:21 2009 +0200

    netfilter: xtables: remove redirecting header files
    
    When IPv4 and IPv6 matches were unified approx. 3.5 years ago, they
    received new header filenames (e.g. xt_CLASSIFY.h). Let's remove the
    old ones now.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 5556d23..698e1e8 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -235,9 +235,6 @@ Who:	Thomas Gleixner <tglx@linutronix.de>
 ---------------------------
 
 What (Why):
-	- "forwarding" header files like ipt_mac.h in
-	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
-
 	- xt_recent: the old ipt_recent proc dir
 	  (superseded by /proc/net/xt_recent)
 
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index 5413005..431b407 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -1,42 +1,14 @@
-header-y += ipt_CLASSIFY.h
 header-y += ipt_CLUSTERIP.h
-header-y += ipt_CONNMARK.h
-header-y += ipt_DSCP.h
 header-y += ipt_ECN.h
 header-y += ipt_LOG.h
-header-y += ipt_MARK.h
-header-y += ipt_NFQUEUE.h
 header-y += ipt_REJECT.h
 header-y += ipt_SAME.h
-header-y += ipt_TCPMSS.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
 header-y += ipt_addrtype.h
 header-y += ipt_ah.h
-header-y += ipt_comment.h
-header-y += ipt_connbytes.h
-header-y += ipt_connmark.h
-header-y += ipt_conntrack.h
-header-y += ipt_dccp.h
-header-y += ipt_dscp.h
 header-y += ipt_ecn.h
-header-y += ipt_esp.h
-header-y += ipt_hashlimit.h
-header-y += ipt_helper.h
-header-y += ipt_length.h
-header-y += ipt_limit.h
-header-y += ipt_mac.h
-header-y += ipt_mark.h
-header-y += ipt_multiport.h
-header-y += ipt_physdev.h
-header-y += ipt_pkttype.h
-header-y += ipt_policy.h
 header-y += ipt_realm.h
-header-y += ipt_recent.h
-header-y += ipt_sctp.h
-header-y += ipt_state.h
-header-y += ipt_string.h
-header-y += ipt_tcpmss.h
 header-y += ipt_ttl.h
 
 unifdef-y += ip_queue.h
diff --git a/include/linux/netfilter_ipv4/ipt_CLASSIFY.h b/include/linux/netfilter_ipv4/ipt_CLASSIFY.h
deleted file mode 100644
index a46d511..0000000
--- a/include/linux/netfilter_ipv4/ipt_CLASSIFY.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_CLASSIFY_H
-#define _IPT_CLASSIFY_H
-
-#include <linux/netfilter/xt_CLASSIFY.h>
-#define ipt_classify_target_info xt_classify_target_info
-
-#endif /*_IPT_CLASSIFY_H */
diff --git a/include/linux/netfilter_ipv4/ipt_CONNMARK.h b/include/linux/netfilter_ipv4/ipt_CONNMARK.h
deleted file mode 100644
index 9ecfee0..0000000
--- a/include/linux/netfilter_ipv4/ipt_CONNMARK.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef _IPT_CONNMARK_H_target
-#define _IPT_CONNMARK_H_target
-
-/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
- * by Henrik Nordstrom <hno@marasystems.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-#include <linux/netfilter/xt_CONNMARK.h>
-#define IPT_CONNMARK_SET	XT_CONNMARK_SET
-#define IPT_CONNMARK_SAVE	XT_CONNMARK_SAVE
-#define	IPT_CONNMARK_RESTORE	XT_CONNMARK_RESTORE
-
-#define ipt_connmark_target_info xt_connmark_target_info
-
-#endif /*_IPT_CONNMARK_H_target*/
diff --git a/include/linux/netfilter_ipv4/ipt_DSCP.h b/include/linux/netfilter_ipv4/ipt_DSCP.h
deleted file mode 100644
index 3491e52..0000000
--- a/include/linux/netfilter_ipv4/ipt_DSCP.h
+++ /dev/null
@@ -1,18 +0,0 @@
-/* iptables module for setting the IPv4 DSCP field
- *
- * (C) 2002 Harald Welte <laforge@gnumonks.org>
- * based on ipt_FTOS.c (C) 2000 by Matthew G. Marsh <mgm@paktronix.com>
- * This software is distributed under GNU GPL v2, 1991
- * 
- * See RFC2474 for a description of the DSCP field within the IP Header.
- *
- * ipt_DSCP.h,v 1.7 2002/03/14 12:03:13 laforge Exp
-*/
-#ifndef _IPT_DSCP_TARGET_H
-#define _IPT_DSCP_TARGET_H
-#include <linux/netfilter_ipv4/ipt_dscp.h>
-#include <linux/netfilter/xt_DSCP.h>
-
-#define ipt_DSCP_info xt_DSCP_info
-
-#endif /* _IPT_DSCP_TARGET_H */
diff --git a/include/linux/netfilter_ipv4/ipt_ECN.h b/include/linux/netfilter_ipv4/ipt_ECN.h
index 94e0d98..7ca4591 100644
--- a/include/linux/netfilter_ipv4/ipt_ECN.h
+++ b/include/linux/netfilter_ipv4/ipt_ECN.h
@@ -8,9 +8,9 @@
 */
 #ifndef _IPT_ECN_TARGET_H
 #define _IPT_ECN_TARGET_H
-#include <linux/netfilter_ipv4/ipt_DSCP.h>
+#include <linux/netfilter/xt_DSCP.h>
 
-#define IPT_ECN_IP_MASK	(~IPT_DSCP_MASK)
+#define IPT_ECN_IP_MASK	(~XT_DSCP_MASK)
 
 #define IPT_ECN_OP_SET_IP	0x01	/* set ECN bits of IPv4 header */
 #define IPT_ECN_OP_SET_ECE	0x10	/* set ECE bit of TCP header */
diff --git a/include/linux/netfilter_ipv4/ipt_MARK.h b/include/linux/netfilter_ipv4/ipt_MARK.h
deleted file mode 100644
index 697a486..0000000
--- a/include/linux/netfilter_ipv4/ipt_MARK.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _IPT_MARK_H_target
-#define _IPT_MARK_H_target
-
-/* Backwards compatibility for old userspace */
-
-#include <linux/netfilter/xt_MARK.h>
-
-/* Version 0 */
-#define ipt_mark_target_info xt_mark_target_info
-
-/* Version 1 */
-#define IPT_MARK_SET	XT_MARK_SET
-#define IPT_MARK_AND	XT_MARK_AND
-#define	IPT_MARK_OR	XT_MARK_OR
-
-#define ipt_mark_target_info_v1 xt_mark_target_info_v1
-
-#endif /*_IPT_MARK_H_target*/
diff --git a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h b/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
deleted file mode 100644
index 97a2a75..0000000
--- a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
+++ /dev/null
@@ -1,16 +0,0 @@
-/* iptables module for using NFQUEUE mechanism
- *
- * (C) 2005 Harald Welte <laforge@netfilter.org>
- *
- * This software is distributed under GNU GPL v2, 1991
- * 
-*/
-#ifndef _IPT_NFQ_TARGET_H
-#define _IPT_NFQ_TARGET_H
-
-/* Backwards compatibility for old userspace */
-#include <linux/netfilter/xt_NFQUEUE.h>
-
-#define ipt_NFQ_info xt_NFQ_info
-
-#endif /* _IPT_DSCP_TARGET_H */
diff --git a/include/linux/netfilter_ipv4/ipt_TCPMSS.h b/include/linux/netfilter_ipv4/ipt_TCPMSS.h
deleted file mode 100644
index 7a850f9..0000000
--- a/include/linux/netfilter_ipv4/ipt_TCPMSS.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _IPT_TCPMSS_H
-#define _IPT_TCPMSS_H
-
-#include <linux/netfilter/xt_TCPMSS.h>
-
-#define ipt_tcpmss_info		xt_tcpmss_info
-#define IPT_TCPMSS_CLAMP_PMTU	XT_TCPMSS_CLAMP_PMTU
-
-#endif /*_IPT_TCPMSS_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_comment.h b/include/linux/netfilter_ipv4/ipt_comment.h
deleted file mode 100644
index ae2afc2..0000000
--- a/include/linux/netfilter_ipv4/ipt_comment.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _IPT_COMMENT_H
-#define _IPT_COMMENT_H
-
-#include <linux/netfilter/xt_comment.h>
-
-#define IPT_MAX_COMMENT_LEN XT_MAX_COMMENT_LEN
-
-#define ipt_comment_info xt_comment_info
-
-#endif /* _IPT_COMMENT_H */
diff --git a/include/linux/netfilter_ipv4/ipt_connbytes.h b/include/linux/netfilter_ipv4/ipt_connbytes.h
deleted file mode 100644
index f63e6ee..0000000
--- a/include/linux/netfilter_ipv4/ipt_connbytes.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _IPT_CONNBYTES_H
-#define _IPT_CONNBYTES_H
-
-#include <linux/netfilter/xt_connbytes.h>
-#define ipt_connbytes_what xt_connbytes_what
-
-#define IPT_CONNBYTES_PKTS	XT_CONNBYTES_PKTS
-#define IPT_CONNBYTES_BYTES	XT_CONNBYTES_BYTES
-#define IPT_CONNBYTES_AVGPKT	XT_CONNBYTES_AVGPKT
-
-#define ipt_connbytes_direction 	xt_connbytes_direction
-#define IPT_CONNBYTES_DIR_ORIGINAL 	XT_CONNBYTES_DIR_ORIGINAL
-#define IPT_CONNBYTES_DIR_REPLY 	XT_CONNBYTES_DIR_REPLY
-#define IPT_CONNBYTES_DIR_BOTH		XT_CONNBYTES_DIR_BOTH
-
-#define ipt_connbytes_info xt_connbytes_info
-
-#endif
diff --git a/include/linux/netfilter_ipv4/ipt_connmark.h b/include/linux/netfilter_ipv4/ipt_connmark.h
deleted file mode 100644
index c7ba656..0000000
--- a/include/linux/netfilter_ipv4/ipt_connmark.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_CONNMARK_H
-#define _IPT_CONNMARK_H
-
-#include <linux/netfilter/xt_connmark.h>
-#define ipt_connmark_info xt_connmark_info
-
-#endif /*_IPT_CONNMARK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_conntrack.h b/include/linux/netfilter_ipv4/ipt_conntrack.h
deleted file mode 100644
index cde6762..0000000
--- a/include/linux/netfilter_ipv4/ipt_conntrack.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/* Header file for kernel module to match connection tracking information.
- * GPL (C) 2001  Marc Boucher (marc@mbsi.ca).
- */
-
-#ifndef _IPT_CONNTRACK_H
-#define _IPT_CONNTRACK_H
-
-#include <linux/netfilter/xt_conntrack.h>
-
-#define IPT_CONNTRACK_STATE_BIT(ctinfo) XT_CONNTRACK_STATE_BIT(ctinfo)
-#define IPT_CONNTRACK_STATE_INVALID 	XT_CONNTRACK_STATE_INVALID
-
-#define IPT_CONNTRACK_STATE_SNAT 	XT_CONNTRACK_STATE_SNAT
-#define IPT_CONNTRACK_STATE_DNAT	XT_CONNTRACK_STATE_DNAT
-#define IPT_CONNTRACK_STATE_UNTRACKED	XT_CONNTRACK_STATE_UNTRACKED
-
-/* flags, invflags: */
-#define IPT_CONNTRACK_STATE		XT_CONNTRACK_STATE
-#define IPT_CONNTRACK_PROTO		XT_CONNTRACK_PROTO
-#define IPT_CONNTRACK_ORIGSRC		XT_CONNTRACK_ORIGSRC
-#define IPT_CONNTRACK_ORIGDST		XT_CONNTRACK_ORIGDST
-#define IPT_CONNTRACK_REPLSRC		XT_CONNTRACK_REPLSRC
-#define IPT_CONNTRACK_REPLDST		XT_CONNTRACK_REPLDST
-#define IPT_CONNTRACK_STATUS		XT_CONNTRACK_STATUS
-#define IPT_CONNTRACK_EXPIRES		XT_CONNTRACK_EXPIRES
-
-#define ipt_conntrack_info		xt_conntrack_info
-#endif /*_IPT_CONNTRACK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_dccp.h b/include/linux/netfilter_ipv4/ipt_dccp.h
deleted file mode 100644
index e70d11e..0000000
--- a/include/linux/netfilter_ipv4/ipt_dccp.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _IPT_DCCP_H_
-#define _IPT_DCCP_H_
-
-#include <linux/netfilter/xt_dccp.h>
-#define IPT_DCCP_SRC_PORTS	XT_DCCP_SRC_PORTS
-#define IPT_DCCP_DEST_PORTS	XT_DCCP_DEST_PORTS
-#define IPT_DCCP_TYPE		XT_DCCP_TYPE
-#define IPT_DCCP_OPTION		XT_DCCP_OPTION
-
-#define IPT_DCCP_VALID_FLAGS 	XT_DCCP_VALID_FLAGS
-
-#define ipt_dccp_info xt_dccp_info
-
-#endif /* _IPT_DCCP_H_ */
-
diff --git a/include/linux/netfilter_ipv4/ipt_dscp.h b/include/linux/netfilter_ipv4/ipt_dscp.h
deleted file mode 100644
index 4b82ca9..0000000
--- a/include/linux/netfilter_ipv4/ipt_dscp.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/* iptables module for matching the IPv4 DSCP field
- *
- * (C) 2002 Harald Welte <laforge@gnumonks.org>
- * This software is distributed under GNU GPL v2, 1991
- * 
- * See RFC2474 for a description of the DSCP field within the IP Header.
- *
- * ipt_dscp.h,v 1.3 2002/08/05 19:00:21 laforge Exp
-*/
-#ifndef _IPT_DSCP_H
-#define _IPT_DSCP_H
-
-#include <linux/netfilter/xt_dscp.h>
-
-#define IPT_DSCP_MASK	XT_DSCP_MASK
-#define IPT_DSCP_SHIFT	XT_DSCP_SHIFT
-#define IPT_DSCP_MAX	XT_DSCP_MAX
-
-#define ipt_dscp_info	xt_dscp_info
-
-#endif /* _IPT_DSCP_H */
diff --git a/include/linux/netfilter_ipv4/ipt_ecn.h b/include/linux/netfilter_ipv4/ipt_ecn.h
index 1f0d9a4..9945baa 100644
--- a/include/linux/netfilter_ipv4/ipt_ecn.h
+++ b/include/linux/netfilter_ipv4/ipt_ecn.h
@@ -8,9 +8,9 @@
 */
 #ifndef _IPT_ECN_H
 #define _IPT_ECN_H
-#include <linux/netfilter_ipv4/ipt_dscp.h>
+#include <linux/netfilter/xt_dscp.h>
 
-#define IPT_ECN_IP_MASK	(~IPT_DSCP_MASK)
+#define IPT_ECN_IP_MASK	(~XT_DSCP_MASK)
 
 #define IPT_ECN_OP_MATCH_IP	0x01
 #define IPT_ECN_OP_MATCH_ECE	0x10
diff --git a/include/linux/netfilter_ipv4/ipt_esp.h b/include/linux/netfilter_ipv4/ipt_esp.h
deleted file mode 100644
index 78296e7..0000000
--- a/include/linux/netfilter_ipv4/ipt_esp.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _IPT_ESP_H
-#define _IPT_ESP_H
-
-#include <linux/netfilter/xt_esp.h>
-
-#define ipt_esp xt_esp
-#define IPT_ESP_INV_SPI		XT_ESP_INV_SPI
-#define IPT_ESP_INV_MASK	XT_ESP_INV_MASK
-
-#endif /*_IPT_ESP_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_hashlimit.h b/include/linux/netfilter_ipv4/ipt_hashlimit.h
deleted file mode 100644
index 5662120..0000000
--- a/include/linux/netfilter_ipv4/ipt_hashlimit.h
+++ /dev/null
@@ -1,14 +0,0 @@
-#ifndef _IPT_HASHLIMIT_H
-#define _IPT_HASHLIMIT_H
-
-#include <linux/netfilter/xt_hashlimit.h>
-
-#define IPT_HASHLIMIT_SCALE	XT_HASHLIMIT_SCALE
-#define IPT_HASHLIMIT_HASH_DIP	XT_HASHLIMIT_HASH_DIP
-#define IPT_HASHLIMIT_HASH_DPT	XT_HASHLIMIT_HASH_DPT
-#define IPT_HASHLIMIT_HASH_SIP	XT_HASHLIMIT_HASH_SIP
-#define IPT_HASHLIMIT_HASH_SPT	XT_HASHLIMIT_HASH_SPT
-
-#define ipt_hashlimit_info xt_hashlimit_info
-
-#endif /* _IPT_HASHLIMIT_H */
diff --git a/include/linux/netfilter_ipv4/ipt_helper.h b/include/linux/netfilter_ipv4/ipt_helper.h
deleted file mode 100644
index 80452c2..0000000
--- a/include/linux/netfilter_ipv4/ipt_helper.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_HELPER_H
-#define _IPT_HELPER_H
-
-#include <linux/netfilter/xt_helper.h>
-#define ipt_helper_info xt_helper_info
-
-#endif /* _IPT_HELPER_H */
diff --git a/include/linux/netfilter_ipv4/ipt_length.h b/include/linux/netfilter_ipv4/ipt_length.h
deleted file mode 100644
index 9b45206..0000000
--- a/include/linux/netfilter_ipv4/ipt_length.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_LENGTH_H
-#define _IPT_LENGTH_H
-
-#include <linux/netfilter/xt_length.h>
-#define ipt_length_info xt_length_info
-
-#endif /*_IPT_LENGTH_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_limit.h b/include/linux/netfilter_ipv4/ipt_limit.h
deleted file mode 100644
index 92f5cd0..0000000
--- a/include/linux/netfilter_ipv4/ipt_limit.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _IPT_RATE_H
-#define _IPT_RATE_H
-
-#include <linux/netfilter/xt_limit.h>
-#define IPT_LIMIT_SCALE XT_LIMIT_SCALE
-#define ipt_rateinfo xt_rateinfo
-
-#endif /*_IPT_RATE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_mac.h b/include/linux/netfilter_ipv4/ipt_mac.h
deleted file mode 100644
index b186008..0000000
--- a/include/linux/netfilter_ipv4/ipt_mac.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_MAC_H
-#define _IPT_MAC_H
-
-#include <linux/netfilter/xt_mac.h>
-#define ipt_mac_info xt_mac_info
-
-#endif /*_IPT_MAC_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_mark.h b/include/linux/netfilter_ipv4/ipt_mark.h
deleted file mode 100644
index bfde67c..0000000
--- a/include/linux/netfilter_ipv4/ipt_mark.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _IPT_MARK_H
-#define _IPT_MARK_H
-
-/* Backwards compatibility for old userspace */
-#include <linux/netfilter/xt_mark.h>
-
-#define ipt_mark_info xt_mark_info
-
-#endif /*_IPT_MARK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_multiport.h b/include/linux/netfilter_ipv4/ipt_multiport.h
deleted file mode 100644
index 55fe85e..0000000
--- a/include/linux/netfilter_ipv4/ipt_multiport.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _IPT_MULTIPORT_H
-#define _IPT_MULTIPORT_H
-
-#include <linux/netfilter/xt_multiport.h>
-
-#define IPT_MULTIPORT_SOURCE		XT_MULTIPORT_SOURCE
-#define IPT_MULTIPORT_DESTINATION	XT_MULTIPORT_DESTINATION
-#define IPT_MULTIPORT_EITHER		XT_MULTIPORT_EITHER
-
-#define IPT_MULTI_PORTS			XT_MULTI_PORTS
-
-#define ipt_multiport			xt_multiport
-#define ipt_multiport_v1		xt_multiport_v1
-
-#endif /*_IPT_MULTIPORT_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_physdev.h b/include/linux/netfilter_ipv4/ipt_physdev.h
deleted file mode 100644
index 2400e71..0000000
--- a/include/linux/netfilter_ipv4/ipt_physdev.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef _IPT_PHYSDEV_H
-#define _IPT_PHYSDEV_H
-
-/* Backwards compatibility for old userspace */
-
-#include <linux/netfilter/xt_physdev.h>
-
-#define IPT_PHYSDEV_OP_IN		XT_PHYSDEV_OP_IN
-#define IPT_PHYSDEV_OP_OUT		XT_PHYSDEV_OP_OUT
-#define IPT_PHYSDEV_OP_BRIDGED		XT_PHYSDEV_OP_BRIDGED
-#define IPT_PHYSDEV_OP_ISIN		XT_PHYSDEV_OP_ISIN
-#define IPT_PHYSDEV_OP_ISOUT		XT_PHYSDEV_OP_ISOUT
-#define IPT_PHYSDEV_OP_MASK		XT_PHYSDEV_OP_MASK
-
-#define ipt_physdev_info xt_physdev_info
-
-#endif /*_IPT_PHYSDEV_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_pkttype.h b/include/linux/netfilter_ipv4/ipt_pkttype.h
deleted file mode 100644
index ff1fbc9..0000000
--- a/include/linux/netfilter_ipv4/ipt_pkttype.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_PKTTYPE_H
-#define _IPT_PKTTYPE_H
-
-#include <linux/netfilter/xt_pkttype.h>
-#define ipt_pkttype_info xt_pkttype_info
-
-#endif /*_IPT_PKTTYPE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_policy.h b/include/linux/netfilter_ipv4/ipt_policy.h
deleted file mode 100644
index 1037fb2..0000000
--- a/include/linux/netfilter_ipv4/ipt_policy.h
+++ /dev/null
@@ -1,23 +0,0 @@
-#ifndef _IPT_POLICY_H
-#define _IPT_POLICY_H
-
-#include <linux/netfilter/xt_policy.h>
-
-#define IPT_POLICY_MAX_ELEM		XT_POLICY_MAX_ELEM
-
-/* ipt_policy_flags */
-#define IPT_POLICY_MATCH_IN		XT_POLICY_MATCH_IN
-#define IPT_POLICY_MATCH_OUT		XT_POLICY_MATCH_OUT
-#define IPT_POLICY_MATCH_NONE		XT_POLICY_MATCH_NONE
-#define IPT_POLICY_MATCH_STRICT		XT_POLICY_MATCH_STRICT
-
-/* ipt_policy_modes */
-#define IPT_POLICY_MODE_TRANSPORT	XT_POLICY_MODE_TRANSPORT
-#define IPT_POLICY_MODE_TUNNEL		XT_POLICY_MODE_TUNNEL
-
-#define ipt_policy_spec			xt_policy_spec
-#define ipt_policy_addr			xt_policy_addr
-#define ipt_policy_elem			xt_policy_elem
-#define ipt_policy_info			xt_policy_info
-
-#endif /* _IPT_POLICY_H */
diff --git a/include/linux/netfilter_ipv4/ipt_recent.h b/include/linux/netfilter_ipv4/ipt_recent.h
deleted file mode 100644
index d636cca..0000000
--- a/include/linux/netfilter_ipv4/ipt_recent.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef _IPT_RECENT_H
-#define _IPT_RECENT_H
-
-#include <linux/netfilter/xt_recent.h>
-
-#define ipt_recent_info xt_recent_mtinfo
-
-enum {
-	IPT_RECENT_CHECK    = XT_RECENT_CHECK,
-	IPT_RECENT_SET      = XT_RECENT_SET,
-	IPT_RECENT_UPDATE   = XT_RECENT_UPDATE,
-	IPT_RECENT_REMOVE   = XT_RECENT_REMOVE,
-	IPT_RECENT_TTL      = XT_RECENT_TTL,
-
-	IPT_RECENT_SOURCE   = XT_RECENT_SOURCE,
-	IPT_RECENT_DEST     = XT_RECENT_DEST,
-
-	IPT_RECENT_NAME_LEN = XT_RECENT_NAME_LEN,
-};
-
-#endif /*_IPT_RECENT_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_sctp.h b/include/linux/netfilter_ipv4/ipt_sctp.h
deleted file mode 100644
index 80b3dba..0000000
--- a/include/linux/netfilter_ipv4/ipt_sctp.h
+++ /dev/null
@@ -1,105 +0,0 @@
-#ifndef _IPT_SCTP_H_
-#define _IPT_SCTP_H_
-
-#define IPT_SCTP_SRC_PORTS	        0x01
-#define IPT_SCTP_DEST_PORTS	        0x02
-#define IPT_SCTP_CHUNK_TYPES		0x04
-
-#define IPT_SCTP_VALID_FLAGS		0x07
-
-
-struct ipt_sctp_flag_info {
-	u_int8_t chunktype;
-	u_int8_t flag;
-	u_int8_t flag_mask;
-};
-
-#define IPT_NUM_SCTP_FLAGS	4
-
-struct ipt_sctp_info {
-	u_int16_t dpts[2];  /* Min, Max */
-	u_int16_t spts[2];  /* Min, Max */
-
-	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
-
-#define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types are present */
-#define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types are present */
-#define SCTP_CHUNK_MATCH_ONLY  0x04  /* Match if these are the only chunk types present */
-
-	u_int32_t chunk_match_type;
-	struct ipt_sctp_flag_info flag_info[IPT_NUM_SCTP_FLAGS];
-	int flag_count;
-
-	u_int32_t flags;
-	u_int32_t invflags;
-};
-
-#define bytes(type) (sizeof(type) * 8)
-
-#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
-	do { 						\
-		chunkmap[type / bytes(u_int32_t)] |= 	\
-			1 << (type % bytes(u_int32_t));	\
-	} while (0)
-
-#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
-	do {							\
-		chunkmap[type / bytes(u_int32_t)] &= 		\
-			~(1 << (type % bytes(u_int32_t)));	\
-	} while (0)
-
-#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
-({								\
-	(chunkmap[type / bytes (u_int32_t)] & 			\
-		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
-})
-
-#define SCTP_CHUNKMAP_RESET(chunkmap) 				\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(chunkmap); i++)	\
-			chunkmap[i] = 0;			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_SET_ALL(chunkmap) 			\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(chunkmap); i++)	\
-			chunkmap[i] = ~0;			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_COPY(destmap, srcmap) 			\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(chunkmap); i++)	\
-			destmap[i] = srcmap[i];			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_IS_CLEAR(chunkmap) 		\
-({							\
-	int i; 						\
-	int flag = 1;					\
-	for (i = 0; i < ARRAY_SIZE(chunkmap); i++) {	\
-		if (chunkmap[i]) {			\
-			flag = 0;			\
-			break;				\
-		}					\
-	}						\
-        flag;						\
-})
-
-#define SCTP_CHUNKMAP_IS_ALL_SET(chunkmap) 		\
-({							\
-	int i; 						\
-	int flag = 1;					\
-	for (i = 0; i < ARRAY_SIZE(chunkmap); i++) {	\
-		if (chunkmap[i] != ~0) {		\
-			flag = 0;			\
-				break;			\
-		}					\
-	}						\
-        flag;						\
-})
-
-#endif /* _IPT_SCTP_H_ */
-
diff --git a/include/linux/netfilter_ipv4/ipt_state.h b/include/linux/netfilter_ipv4/ipt_state.h
deleted file mode 100644
index a44a99c..0000000
--- a/include/linux/netfilter_ipv4/ipt_state.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _IPT_STATE_H
-#define _IPT_STATE_H
-
-/* Backwards compatibility for old userspace */
-
-#include <linux/netfilter/xt_state.h>
-
-#define IPT_STATE_BIT		XT_STATE_BIT
-#define IPT_STATE_INVALID	XT_STATE_INVALID
-
-#define IPT_STATE_UNTRACKED	XT_STATE_UNTRACKED
-
-#define ipt_state_info		xt_state_info
-
-#endif /*_IPT_STATE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_string.h b/include/linux/netfilter_ipv4/ipt_string.h
deleted file mode 100644
index c26de30..0000000
--- a/include/linux/netfilter_ipv4/ipt_string.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _IPT_STRING_H
-#define _IPT_STRING_H
-
-#include <linux/netfilter/xt_string.h>
-
-#define IPT_STRING_MAX_PATTERN_SIZE XT_STRING_MAX_PATTERN_SIZE
-#define IPT_STRING_MAX_ALGO_NAME_SIZE XT_STRING_MAX_ALGO_NAME_SIZE
-#define ipt_string_info xt_string_info
-
-#endif /*_IPT_STRING_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_tcpmss.h b/include/linux/netfilter_ipv4/ipt_tcpmss.h
deleted file mode 100644
index 18bbc8e..0000000
--- a/include/linux/netfilter_ipv4/ipt_tcpmss.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IPT_TCPMSS_MATCH_H
-#define _IPT_TCPMSS_MATCH_H
-
-#include <linux/netfilter/xt_tcpmss.h>
-#define ipt_tcpmss_match_info xt_tcpmss_match_info
-
-#endif /*_IPT_TCPMSS_MATCH_H*/
diff --git a/include/linux/netfilter_ipv6/Kbuild b/include/linux/netfilter_ipv6/Kbuild
index 4610a16..e864eae 100644
--- a/include/linux/netfilter_ipv6/Kbuild
+++ b/include/linux/netfilter_ipv6/Kbuild
@@ -1,21 +1,12 @@
 header-y += ip6t_HL.h
 header-y += ip6t_LOG.h
-header-y += ip6t_MARK.h
 header-y += ip6t_REJECT.h
 header-y += ip6t_ah.h
-header-y += ip6t_esp.h
 header-y += ip6t_frag.h
-header-y += ip6t_hl.h
 header-y += ip6t_ipv6header.h
-header-y += ip6t_length.h
-header-y += ip6t_limit.h
-header-y += ip6t_mac.h
-header-y += ip6t_mark.h
+header-y += ip6t_hl.h
 header-y += ip6t_mh.h
-header-y += ip6t_multiport.h
 header-y += ip6t_opts.h
-header-y += ip6t_physdev.h
-header-y += ip6t_policy.h
 header-y += ip6t_rt.h
 
 unifdef-y += ip6_tables.h
diff --git a/include/linux/netfilter_ipv6/ip6t_MARK.h b/include/linux/netfilter_ipv6/ip6t_MARK.h
deleted file mode 100644
index 7cf629a..0000000
--- a/include/linux/netfilter_ipv6/ip6t_MARK.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _IP6T_MARK_H_target
-#define _IP6T_MARK_H_target
-
-/* Backwards compatibility for old userspace */
-#include <linux/netfilter/xt_MARK.h>
-
-#define ip6t_mark_target_info xt_mark_target_info
-
-#endif /*_IP6T_MARK_H_target*/
diff --git a/include/linux/netfilter_ipv6/ip6t_esp.h b/include/linux/netfilter_ipv6/ip6t_esp.h
deleted file mode 100644
index f62eaf5..0000000
--- a/include/linux/netfilter_ipv6/ip6t_esp.h
+++ /dev/null
@@ -1,10 +0,0 @@
-#ifndef _IP6T_ESP_H
-#define _IP6T_ESP_H
-
-#include <linux/netfilter/xt_esp.h>
-
-#define ip6t_esp xt_esp
-#define IP6T_ESP_INV_SPI	XT_ESP_INV_SPI
-#define IP6T_ESP_INV_MASK	XT_ESP_INV_MASK
-
-#endif /*_IP6T_ESP_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_length.h b/include/linux/netfilter_ipv6/ip6t_length.h
deleted file mode 100644
index 9e9689d..0000000
--- a/include/linux/netfilter_ipv6/ip6t_length.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _IP6T_LENGTH_H
-#define _IP6T_LENGTH_H
-
-#include <linux/netfilter/xt_length.h>
-#define ip6t_length_info xt_length_info
-
-#endif /*_IP6T_LENGTH_H*/
-	
diff --git a/include/linux/netfilter_ipv6/ip6t_limit.h b/include/linux/netfilter_ipv6/ip6t_limit.h
deleted file mode 100644
index 487e5ea..0000000
--- a/include/linux/netfilter_ipv6/ip6t_limit.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _IP6T_RATE_H
-#define _IP6T_RATE_H
-
-#include <linux/netfilter/xt_limit.h>
-#define IP6T_LIMIT_SCALE XT_LIMIT_SCALE
-#define ip6t_rateinfo xt_rateinfo
-
-#endif /*_IP6T_RATE_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_mac.h b/include/linux/netfilter_ipv6/ip6t_mac.h
deleted file mode 100644
index ac58e83..0000000
--- a/include/linux/netfilter_ipv6/ip6t_mac.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _IP6T_MAC_H
-#define _IP6T_MAC_H
-
-#include <linux/netfilter/xt_mac.h>
-#define ip6t_mac_info xt_mac_info
-
-#endif /*_IP6T_MAC_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_mark.h b/include/linux/netfilter_ipv6/ip6t_mark.h
deleted file mode 100644
index ff20495..0000000
--- a/include/linux/netfilter_ipv6/ip6t_mark.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _IP6T_MARK_H
-#define _IP6T_MARK_H
-
-/* Backwards compatibility for old userspace */
-#include <linux/netfilter/xt_mark.h>
-
-#define ip6t_mark_info xt_mark_info
-
-#endif /*_IPT_MARK_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_multiport.h b/include/linux/netfilter_ipv6/ip6t_multiport.h
deleted file mode 100644
index 042c926..0000000
--- a/include/linux/netfilter_ipv6/ip6t_multiport.h
+++ /dev/null
@@ -1,14 +0,0 @@
-#ifndef _IP6T_MULTIPORT_H
-#define _IP6T_MULTIPORT_H
-
-#include <linux/netfilter/xt_multiport.h>
-
-#define IP6T_MULTIPORT_SOURCE		XT_MULTIPORT_SOURCE
-#define IP6T_MULTIPORT_DESTINATION	XT_MULTIPORT_DESTINATION
-#define IP6T_MULTIPORT_EITHER		XT_MULTIPORT_EITHER
-
-#define IP6T_MULTI_PORTS		XT_MULTI_PORTS
-
-#define ip6t_multiport			xt_multiport
-
-#endif /*_IP6T_MULTIPORT_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_physdev.h b/include/linux/netfilter_ipv6/ip6t_physdev.h
deleted file mode 100644
index c161c0a..0000000
--- a/include/linux/netfilter_ipv6/ip6t_physdev.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef _IP6T_PHYSDEV_H
-#define _IP6T_PHYSDEV_H
-
-/* Backwards compatibility for old userspace */
-
-#include <linux/netfilter/xt_physdev.h>
-
-#define IP6T_PHYSDEV_OP_IN		XT_PHYSDEV_OP_IN
-#define IP6T_PHYSDEV_OP_OUT		XT_PHYSDEV_OP_OUT
-#define IP6T_PHYSDEV_OP_BRIDGED		XT_PHYSDEV_OP_BRIDGED
-#define IP6T_PHYSDEV_OP_ISIN		XT_PHYSDEV_OP_ISIN
-#define IP6T_PHYSDEV_OP_ISOUT		XT_PHYSDEV_OP_ISOUT
-#define IP6T_PHYSDEV_OP_MASK		XT_PHYSDEV_OP_MASK
-
-#define ip6t_physdev_info xt_physdev_info
-
-#endif /*_IP6T_PHYSDEV_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_policy.h b/include/linux/netfilter_ipv6/ip6t_policy.h
deleted file mode 100644
index b1c449d..0000000
--- a/include/linux/netfilter_ipv6/ip6t_policy.h
+++ /dev/null
@@ -1,23 +0,0 @@
-#ifndef _IP6T_POLICY_H
-#define _IP6T_POLICY_H
-
-#include <linux/netfilter/xt_policy.h>
-
-#define IP6T_POLICY_MAX_ELEM		XT_POLICY_MAX_ELEM
-
-/* ip6t_policy_flags */
-#define IP6T_POLICY_MATCH_IN		XT_POLICY_MATCH_IN
-#define IP6T_POLICY_MATCH_OUT		XT_POLICY_MATCH_OUT
-#define IP6T_POLICY_MATCH_NONE		XT_POLICY_MATCH_NONE
-#define IP6T_POLICY_MATCH_STRICT	XT_POLICY_MATCH_STRICT
-
-/* ip6t_policy_modes */
-#define IP6T_POLICY_MODE_TRANSPORT	XT_POLICY_MODE_TRANSPORT
-#define IP6T_POLICY_MODE_TUNNEL		XT_POLICY_MODE_TUNNEL
-
-#define ip6t_policy_spec		xt_policy_spec
-#define ip6t_policy_addr		xt_policy_addr
-#define ip6t_policy_elem		xt_policy_elem
-#define ip6t_policy_info		xt_policy_info
-
-#endif /* _IP6T_POLICY_H */
