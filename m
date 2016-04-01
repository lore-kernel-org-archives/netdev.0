From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] iplink: display IFLA_PHYS_PORT_NAME
Date: Fri,  1 Apr 2016 16:22:01 +0200
Message-ID: <1459520521-1013-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:60939 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbcDAOWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 10:22:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipaddress.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3998d8cec4ab..b21c69a7d6ea 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -813,6 +813,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "master %s ", ll_idx_n2a(*(int *)RTA_DATA(tb[IFLA_MASTER]), b1));
 	}
 
+	if (tb[IFLA_PHYS_PORT_NAME])
+		fprintf(fp, "portname %s ",
+			rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
+
 	if (tb[IFLA_PHYS_PORT_ID]) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "portid %s ",
-- 
2.4.2
