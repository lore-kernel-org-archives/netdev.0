From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 3/7] ICMP: drop unused MIB accounting wrappers
Date: Mon, 07 Jul 2008 14:50:38 +0400
Message-ID: <4871F4FE.3050509@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44425 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbYGGKxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:53:11 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are ICMP_XXX_STATS that are not used in the kernel, so I remove
them, not to "just patch" them later. But if there's some sense in 
keeping them, kick me - I will remake this set keeping them.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/icmp.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 38ca2f3..e34e981 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -33,13 +33,8 @@ DECLARE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(field)		SNMP_INC_STATS(icmp_statistics, field)
 #define ICMP_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmp_statistics, field)
-#define ICMP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
-#define ICMPMSGOUT_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field+256)
-#define ICMPMSGOUT_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS(field)	SNMP_INC_STATS(icmpmsg_statistics, field)
 #define ICMPMSGIN_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
-#define ICMPMSGIN_INC_STATS_USER(field) SNMP_INC_STATS_USER(icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
-- 
1.5.3.4

