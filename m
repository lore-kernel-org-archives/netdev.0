From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] net: Add linux/sysctl.h includes where needed.
Date: Thu, 26 May 2011 16:43:25 -0400 (EDT)
Message-ID: <20110526.164325.1232739432775901698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779Ab1EZUnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 16:43:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several networking headers were depending upon the implicit
linux/sysctl.h include they get when including linux/net.h

Add explicit includes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter.h   |    1 +
 include/net/net_namespace.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 7fa95df..857f502 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -13,6 +13,7 @@
 #endif
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/sysctl.h>
 
 /* Responses from hook functions. */
 #define NF_DROP 0
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3ae4919..07a60e8 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -7,6 +7,7 @@
 #include <asm/atomic.h>
 #include <linux/workqueue.h>
 #include <linux/list.h>
+#include <linux/sysctl.h>
 
 #include <net/netns/core.h>
 #include <net/netns/mib.h>
-- 
1.7.4.4

