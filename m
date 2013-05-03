From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ip: add missing help about mode argument
Date: Fri,  3 May 2013 17:17:42 +0200
Message-ID: <1367594262-5136-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37574 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932459Ab3ECPST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 11:18:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is three possibilities: only IPv6, only IPv4 or both.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/link_ip6tnl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 2947364..f5b1245 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -33,6 +33,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
 	fprintf(stderr, "          type ip6tnl [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
-- 
1.8.2.1
