From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [iproute2 json PATCH] ip: ipaddress: fix missing space after prefixlen
Date: Wed, 20 Sep 2017 13:04:21 -0700
Message-ID: <20170920200421.94514-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, sd@queasysnail.net,
        Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:46090 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdITUEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:04:24 -0400
Received: by mail-pg0-f52.google.com with SMTP id i130so2280205pgc.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 13:04:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")

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
