From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH iproute 3/3] iproute2: add proxy_neigh attribute
Date: Tue, 17 Dec 2013 22:39:05 -0800
Message-ID: <20131217223905.0c5c55a2@nehalam.linuxnetplumber.net>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48092 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRGjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:39:18 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so7799072pdi.24
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 22:39:17 -0800 (PST)
In-Reply-To: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report changes to proxy_arp/proxy_ndp attribute.

Patch assumes updated netconf.h from net-next (earlier patches).
---
 ip/ipnetconf.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 9a77ecb..7353f59 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -114,6 +114,10 @@ int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "mc_forwarding %d ",
 			*(int *)RTA_DATA(tb[NETCONFA_MC_FORWARDING]));
 
+	if (tb[NETCONFA_PROXY_NEIGH])
+		fprintf(fp, "proxy_neigh %s ",
+			*(int *)RTA_DATA(tb[NETCONFA_PROXY_NEIGH])?"on":"off");
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
-- 
1.7.10.4
