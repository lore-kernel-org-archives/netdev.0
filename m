From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC iproute v1 4/4] afnetns: only show afnetns when show_details
Date: Mon, 13 Mar 2017 00:01:38 +0100
Message-ID: <20170312230138.5096-5-hannes@stressinduktion.org>
References: <20170312230138.5096-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41348 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935560AbdCLXBx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:53 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 712E02060A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:46 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id CF39C240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:45 -0400 (EDT)
In-Reply-To: <20170312230138.5096-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only show afnetns details when details are requested.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d954f3ea5bff40..cfb58e70e4f29f 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1219,7 +1219,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				fprintf(fp, "%usec", ci->ifa_prefered);
 		}
 	}
-	if (rta_tb[IFA_AFNETNS_INODE]) {
+	if (show_details && rta_tb[IFA_AFNETNS_INODE]) {
 		ino_t inode;
 		char *name;
 
-- 
2.9.3
