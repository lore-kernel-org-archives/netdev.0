From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/20] mib: drop unused IP_INC_STATS_USER
Date: Wed, 16 Jul 2008 12:09:23 +0400
Message-ID: <487DACB3.1040205@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38311 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbYGPIJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:09:29 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 3b40bc2..673ecdb 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -159,7 +159,6 @@ extern struct ipv4_config ipv4_config;
 DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 #define IP_INC_STATS(field)		SNMP_INC_STATS(ip_statistics, field)
 #define IP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ip_statistics, field)
-#define IP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(ip_statistics, field)
 #define IP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(field)		SNMP_INC_STATS(net_statistics, field)
-- 
1.5.5.1

