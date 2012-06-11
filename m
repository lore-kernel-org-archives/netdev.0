From: pablo@netfilter.org
Subject: [PATCH 01/25] netfilter: remove include/linux/netfilter_ipv4/ipt_addrtype.h
Date: Mon, 11 Jun 2012 16:43:37 +0200
Message-ID: <1339425841-24171-2-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32791 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab2FKOop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:44:45 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

It was scheduled to be removed.

Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/feature-removal-schedule.txt  |    8 --------
 include/linux/netfilter_ipv4/Kbuild         |    1 -
 include/linux/netfilter_ipv4/ipt_addrtype.h |   27 ---------------------------
 3 files changed, 36 deletions(-)
 delete mode 100644 include/linux/netfilter_ipv4/ipt_addrtype.h

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 56000b3..08e7e71 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -421,14 +421,6 @@ Files:	net/netfilter/xt_connlimit.c
 
 ----------------------------
 
-What:	ipt_addrtype match include file
-When:	2012
-Why:	superseded by xt_addrtype
-Who:	Florian Westphal <fw@strlen.de>
-Files:	include/linux/netfilter_ipv4/ipt_addrtype.h
-
-----------------------------
-
 What:	i2c_driver.attach_adapter
 	i2c_driver.detach_adapter
 When:	September 2011
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index c61b8fb..8ba0c5b 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -5,7 +5,6 @@ header-y += ipt_LOG.h
 header-y += ipt_REJECT.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
-header-y += ipt_addrtype.h
 header-y += ipt_ah.h
 header-y += ipt_ecn.h
 header-y += ipt_ttl.h
diff --git a/include/linux/netfilter_ipv4/ipt_addrtype.h b/include/linux/netfilter_ipv4/ipt_addrtype.h
deleted file mode 100644
index 0da4223..0000000
--- a/include/linux/netfilter_ipv4/ipt_addrtype.h
+++ /dev/null
@@ -1,27 +0,0 @@
-#ifndef _IPT_ADDRTYPE_H
-#define _IPT_ADDRTYPE_H
-
-#include <linux/types.h>
-
-enum {
-	IPT_ADDRTYPE_INVERT_SOURCE	= 0x0001,
-	IPT_ADDRTYPE_INVERT_DEST	= 0x0002,
-	IPT_ADDRTYPE_LIMIT_IFACE_IN	= 0x0004,
-	IPT_ADDRTYPE_LIMIT_IFACE_OUT	= 0x0008,
-};
-
-struct ipt_addrtype_info_v1 {
-	__u16	source;		/* source-type mask */
-	__u16	dest;		/* dest-type mask */
-	__u32	flags;
-};
-
-/* revision 0 */
-struct ipt_addrtype_info {
-	__u16	source;		/* source-type mask */
-	__u16	dest;		/* dest-type mask */
-	__u32	invert_source;
-	__u32	invert_dest;
-};
-
-#endif
-- 
1.7.10
