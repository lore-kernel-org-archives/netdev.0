From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH 2/2] net: Use MODULE_ALIAS_NET_PF_PROTO_TYPE where possible
Date: Tue, 16 Oct 2007 17:30:21 +0200
Message-ID: <200710161730.21393.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:36333 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933193AbXJPP2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 11:28:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have this new MODULE_ALIAS_NET_PF_PROTO_TYPE macro, use it
where possible.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ipv4.c |    4 ++--
 net/dccp/ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.23-rc0.orig/net/dccp/ipv4.c	2007-10-15 21:39:08.000000000 +0200
+++ linux-2.6.23-rc0/net/dccp/ipv4.c	2007-10-16 14:36:54.000000000 +0200
@@ -1037,8 +1037,8 @@ module_exit(dccp_v4_exit);
  * values directly, Also cover the case where the protocol is not specified,
  * i.e. net-pf-PF_INET-proto-0-type-SOCK_DCCP
  */
-MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-33-type-6");
-MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-0-type-6");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, 33, 6);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, 0, 6);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCP - Datagram Congestion Controlled Protocol");
--- linux-2.6.23-rc0.orig/net/dccp/ipv6.c	2007-10-15 21:39:08.000000000 +0200
+++ linux-2.6.23-rc0/net/dccp/ipv6.c	2007-10-16 14:37:06.000000000 +0200
@@ -1220,8 +1220,8 @@ module_exit(dccp_v6_exit);
  * values directly, Also cover the case where the protocol is not specified,
  * i.e. net-pf-PF_INET6-proto-0-type-SOCK_DCCP
  */
-MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-33-type-6");
-MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-0-type-6");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET6, 33, 6);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET6, 0, 6);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCPv6 - Datagram Congestion Controlled Protocol");

-- 
Jean Delvare
Suse L3
