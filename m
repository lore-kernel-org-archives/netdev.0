From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: kill remnants of ulog targets
Date: Thu, 31 Jul 2014 21:27:05 +0200
Message-ID: <1406834828-8500-7-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35676 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796AbaGaT1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:18 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

The ulog targets were recently killed. A few references to the Kconfig
macros CONFIG_IP_NF_TARGET_ULOG and CONFIG_BRIDGE_EBT_ULOG were left
untouched. Kill these too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/x_tables.h  |    6 ------
 net/bridge/netfilter/Makefile |    1 -
 net/ipv4/netfilter/Makefile   |    1 -
 3 files changed, 8 deletions(-)

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index 02fe40f..c24060e 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -15,11 +15,5 @@ struct netns_xt {
 	struct ebt_table *frame_filter;
 	struct ebt_table *frame_nat;
 #endif
-#if IS_ENABLED(CONFIG_IP_NF_TARGET_ULOG)
-	bool ulog_warn_deprecated;
-#endif
-#if IS_ENABLED(CONFIG_BRIDGE_EBT_ULOG)
-	bool ebt_ulog_warn_deprecated;
-#endif
 };
 #endif
diff --git a/net/bridge/netfilter/Makefile b/net/bridge/netfilter/Makefile
index 061d121..be4d0ce 100644
--- a/net/bridge/netfilter/Makefile
+++ b/net/bridge/netfilter/Makefile
@@ -37,5 +37,4 @@ obj-$(CONFIG_BRIDGE_EBT_SNAT) += ebt_snat.o
 
 # watchers
 obj-$(CONFIG_BRIDGE_EBT_LOG) += ebt_log.o
-obj-$(CONFIG_BRIDGE_EBT_ULOG) += ebt_ulog.o
 obj-$(CONFIG_BRIDGE_EBT_NFLOG) += ebt_nflog.o
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 245db9d..3300162 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_IP_NF_TARGET_ECN) += ipt_ECN.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_SYNPROXY) += ipt_SYNPROXY.o
-obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
 
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) += arp_tables.o
-- 
1.7.10.4
