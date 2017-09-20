From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 v2] ip: ipaddress: fix missing space after prefixlen
Date: Wed, 20 Sep 2017 13:26:51 -0700
Message-ID: <20170920202651.95860-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, sd@queasysnail.net,
        Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:53304 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdITU0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:26:54 -0400
Received: by mail-pg0-f47.google.com with SMTP id j70so2300939pgc.10
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 13:26:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 97971450..fb496bbb 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1604,7 +1604,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 					   format_host_rta(ifa->ifa_family,
 							   rta_tb[IFA_ADDRESS]));
 		}
-		print_int(PRINT_ANY, "prefixlen", "/%d", ifa->ifa_prefixlen);
+		print_int(PRINT_ANY, "prefixlen", "/%d ", ifa->ifa_prefixlen);
 	}
 
 	if (brief)
-- 
2.14.1
