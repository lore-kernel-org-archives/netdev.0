From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH][NET]: Finish removing unused "mibalign" argument for
	snmp_mib_init().
Date: Sat, 8 Dec 2007 15:55:34 -0200
Message-ID: <20071208175532.GE3180@ghostprotocols.net>
References: <20071208.004128.44758266.yoshfuji@linux-ipv6.org> <20071208.004147.99843986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbXLHRzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 12:55:42 -0500
Content-Disposition: inline
In-Reply-To: <20071208.004147.99843986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 5ab8ba7..90d2f72 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -714,20 +714,19 @@ EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
 static int __init init_ipv6_mibs(void)
 {
-	if (snmp_mib_init((void **)ipv6_statistics, sizeof (struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+	if (snmp_mib_init((void **)ipv6_statistics,
+			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
-	if (snmp_mib_init((void **)icmpv6_statistics, sizeof (struct icmpv6_mib),
-			  __alignof__(struct icmpv6_mib)) < 0)
+	if (snmp_mib_init((void **)icmpv6_statistics,
+			  sizeof(struct icmpv6_mib)) < 0)
 		goto err_icmp_mib;
 	if (snmp_mib_init((void **)icmpv6msg_statistics,
-	    sizeof (struct icmpv6msg_mib), __alignof__(struct icmpv6_mib)) < 0)
+			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	if (snmp_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib)) < 0)
 		goto err_udp_mib;
-	if (snmp_mib_init((void **)udplite_stats_in6, sizeof (struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	if (snmp_mib_init((void **)udplite_stats_in6,
+			  sizeof (struct udp_mib)) < 0)
 		goto err_udplite_mib;
 	return 0;
 
