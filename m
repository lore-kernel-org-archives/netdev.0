From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH iproute] ipaddress: support printing the stable-privacy flag
Date: Fri,  7 Jul 2017 16:12:28 +0900
Message-ID: <20170707071228.61594-1-lorenzo@google.com>
Cc: stephen@networkplumber.org, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35267 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751927AbdGGHMk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 03:12:40 -0400
Received: by mail-pg0-f42.google.com with SMTP id j186so12914729pge.2
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 00:12:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, this flag is only shown as "flags 800".

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 ip/ipaddress.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4900dce09d..8fe2bacde8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1166,6 +1166,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		ifa_flags &= ~IFA_F_DADFAILED;
 		fprintf(fp, "dadfailed ");
 	}
+	if (ifa_flags & IFA_F_STABLE_PRIVACY) {
+		ifa_flags &= ~IFA_F_STABLE_PRIVACY;
+		fprintf(fp, "stable-privacy ");
+	}
 	if (ifa_flags)
 		fprintf(fp, "flags %02x ", ifa_flags);
 	if (rta_tb[IFA_LABEL])
-- 
2.13.2.725.g09c95d1e9-goog
