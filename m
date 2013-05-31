From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3] snmp6: remove IPSTATS_MIB_CSUMERRORS
Date: Fri, 31 May 2013 17:37:57 +0200
Message-ID: <1370014677-4626-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1370013236.5109.100.camel@edumazet-glaptop>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48110 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab3EaPh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 11:37:57 -0400
In-Reply-To: <1370013236.5109.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stat is not relevant in IPv6, there is no checksum in IPv6 header.
Just leave a comment to explain the hole.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v3: remove the stat, not relevant in IPv6
    remove spotted-by because it was only for the 'wrong' stat name (missing
    prefix 'Ip6')

v2: add Spotted-by line

 net/ipv6/proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index f3c1ff4..51c3285 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -90,7 +90,7 @@ static const struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
-	SNMP_MIB_ITEM("InCsumErrors", IPSTATS_MIB_CSUMERRORS),
+	/* IPSTATS_MIB_CSUMERRORS is not relevant in IPv6 (no checksum) */
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.8.2.1
