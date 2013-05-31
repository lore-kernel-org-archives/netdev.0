From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] snmp6: fix title of IPSTATS_MIB_CSUMERRORS
Date: Fri, 31 May 2013 15:29:40 +0200
Message-ID: <1370006980-27297-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47721 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3EaN3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 09:29:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow the same convention than other fields, prefix this stat by 'Ip6'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

In fact, I wonder if we cannot simply remove this stat for IPv6: there is no
checksum in IPv6, so it will always be 0 (and in fact, this stats is only
increased in net/ipv4/ip_input.c).

 net/ipv6/proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index f3c1ff4..33b97b0 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -90,7 +90,7 @@ static const struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
-	SNMP_MIB_ITEM("InCsumErrors", IPSTATS_MIB_CSUMERRORS),
+	SNMP_MIB_ITEM("Ip6InCsumErrors", IPSTATS_MIB_CSUMERRORS),
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.8.2.1
