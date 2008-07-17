From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 1/1] ipv6: remove unused macros from net/ipv6.h
Date: Thu, 17 Jul 2008 14:12:44 +0400
Message-ID: <1216289564-7322-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2968 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755519AbYGQKLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 06:11:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c2222ee..c2c3649 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -131,7 +131,6 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 
 #define IP6_INC_STATS(idev,field)	_DEVINC(ipv6, , idev, field)
 #define IP6_INC_STATS_BH(idev,field)	_DEVINC(ipv6, _BH, idev, field)
-#define IP6_INC_STATS_USER(idev,field)	_DEVINC(ipv6, _USER, idev, field)
 #define IP6_ADD_STATS_BH(idev,field,val) _DEVADD(ipv6, _BH, idev, field, val)
 
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
@@ -139,20 +138,15 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 
 #define ICMP6_INC_STATS(idev, field)	_DEVINC(icmpv6, , idev, field)
 #define ICMP6_INC_STATS_BH(idev, field)	_DEVINC(icmpv6, _BH, idev, field)
-#define ICMP6_INC_STATS_USER(idev, field) _DEVINC(icmpv6, _USER, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(idev, field) \
 	_DEVINC(icmpv6msg, , idev, field +256)
 #define ICMP6MSGOUT_INC_STATS_BH(idev, field) \
 	_DEVINC(icmpv6msg, _BH, idev, field +256)
-#define ICMP6MSGOUT_INC_STATS_USER(idev, field) \
-	_DEVINC(icmpv6msg, _USER, idev, field +256)
 #define ICMP6MSGIN_INC_STATS(idev, field) \
 	 _DEVINC(icmpv6msg, , idev, field)
 #define ICMP6MSGIN_INC_STATS_BH(idev, field) \
 	_DEVINC(icmpv6msg, _BH, idev, field)
-#define ICMP6MSGIN_INC_STATS_USER(idev, field) \
-	_DEVINC(icmpv6msg, _USER, idev, field)
 
 struct ip6_ra_chain
 {
-- 
1.5.3.rc5

