From: Richard Godbee <richard@godbee.net>
Subject: [PATCH] iproute2: spelling: noptmudisc -> nopmtudisc
Date: Sun, 25 Aug 2013 22:40:18 -0400
Message-ID: <1377484819-23743-1-git-send-email-richard@godbee.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa07-09.prod.phx3.secureserver.net ([173.201.192.238]:48292
	"EHLO p3plsmtpa07-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195Ab3HZClM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 22:41:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Godbee <richard@godbee.net>
---
 ip/iptunnel.c   | 2 +-
 ip/link_iptnl.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 43f8585..40186d3 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -280,7 +280,7 @@ static int do_add(int cmd, int argc, char **argv)
 		return -1;
 
 	if (p.iph.ttl && p.iph.frag_off == 0) {
-		fprintf(stderr, "ttl != 0 and noptmudisc are incompatible\n");
+		fprintf(stderr, "ttl != 0 and nopmtudisc are incompatible\n");
 		return -1;
 	}
 
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 394254d..d5324f8 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -233,7 +233,7 @@ get_failed:
 	}
 
 	if (ttl && pmtudisc == 0) {
-		fprintf(stderr, "ttl != 0 and noptmudisc are incompatible\n");
+		fprintf(stderr, "ttl != 0 and nopmtudisc are incompatible\n");
 		exit(-1);
 	}
 
-- 
1.8.2.2
