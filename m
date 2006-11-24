From: Masahide@neptune.linux-ipv6.org
Subject: [PATCH] [IP] ADDR: Fix print format for lifetimes.
Date: Fri, 24 Nov 2006 12:11:18 +0900
Message-ID: <44218.3561543517$1164338327@news.gmane.org>
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:50901 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S1757584AbWKXDQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 22:16:03 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipaddress.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cb164c0..592875a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -428,11 +428,12 @@ int print_addrinfo(const struct sockaddr
 		if (ci->ifa_valid == 0xFFFFFFFFU)
 			sprintf(buf, "valid_lft forever");
 		else
-			sprintf(buf, "valid_lft %dsec", ci->ifa_valid);
+			sprintf(buf, "valid_lft %usec", ci->ifa_valid);
 		if (ci->ifa_prefered == 0xFFFFFFFFU)
 			sprintf(buf+strlen(buf), " preferred_lft forever");
 		else
-			sprintf(buf+strlen(buf), " preferred_lft %dsec", ci->ifa_prefered);
+			sprintf(buf+strlen(buf), " preferred_lft %usec",
+				ci->ifa_prefered);
 		fprintf(fp, "       %s", buf);
 	}
 	fprintf(fp, "\n");
-- 
1.4.2

