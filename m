From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next,iproute2] netconf: add support for ignore route attribute
Date: Mon, 14 Mar 2016 04:55:36 +0000
Message-ID: <1457931336-30205-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2873 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932730AbcCNEvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 00:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ignore_routes_with_linkdown attribute.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ipnetconf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index eca6eee..6fec818 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -119,6 +119,10 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 		fprintf(fp, "proxy_neigh %s ",
 			*(int *)RTA_DATA(tb[NETCONFA_PROXY_NEIGH])?"on":"off");
 
+	if (tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])
+		fprintf(fp, "ignore_routes_with_linkdown %s ",
+			*(int *)RTA_DATA(tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])?"on":"off");
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
-- 
1.8.3.1
