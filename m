From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] IPV6: RFC 2011 compatibility broken
Date: Mon, 21 Jan 2008 17:46:44 +0800
Message-ID: <47946A04.3080702@cn.fujitsu.com>
References: <478DD57B.6020503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David L Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62699 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758261AbYAUJsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 04:48:04 -0500
In-Reply-To: <478DD57B.6020503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPV6]: RFC 2011 compatibility broken

The snmp6 entry name was changed, and it broke compatibility
to RFC 2011.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

--- linux-2.6.24.rc8.org/net/ipv6/proc.c	2008-01-16 17:45:03.000000000 +0800
+++ linux-2.6.24.rc8/net/ipv6/proc.c	2008-01-21 15:48:52.000000000 +0800
@@ -88,7 +88,7 @@ static char *icmp6type2name[256] = {
 	[ICMPV6_PKT_TOOBIG] = "PktTooBigs",
 	[ICMPV6_TIME_EXCEED] = "TimeExcds",
 	[ICMPV6_PARAMPROB] = "ParmProblems",
-	[ICMPV6_ECHO_REQUEST] = "EchoRequest",
+	[ICMPV6_ECHO_REQUEST] = "Echos",
 	[ICMPV6_ECHO_REPLY] = "EchoReplies",
 	[ICMPV6_MGM_QUERY] = "GroupMembQueries",
 	[ICMPV6_MGM_REPORT] = "GroupMembResponses",
@@ -98,7 +98,7 @@ static char *icmp6type2name[256] = {
 	[NDISC_ROUTER_SOLICITATION] = "RouterSolicits",
 	[NDISC_NEIGHBOUR_ADVERTISEMENT] = "NeighborAdvertisements",
 	[NDISC_NEIGHBOUR_SOLICITATION] = "NeighborSolicits",
-	[NDISC_REDIRECT] = "NeighborRedirects",
+	[NDISC_REDIRECT] = "Redirects",
 };
 
 


