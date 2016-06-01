From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ipaddress: Allow listing addresses by type
Date: Wed,  1 Jun 2016 21:57:27 +0200
Message-ID: <1464811047-18642-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33804 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbcFAT5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 15:57:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure why this was limited to ip-link before. It is semantically
equal to the 'master' keyword, which is not restricted at all.

Cc: Vadim Kochan <vadim4j@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index df363b070d5de..1b5ee838ef3fe 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1613,7 +1613,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (!ifindex)
 				invarg("Device does not exist\n", *argv);
 			filter.master = ifindex;
-		} else if (do_link && strcmp(*argv, "type") == 0) {
+		} else if (strcmp(*argv, "type") == 0) {
 			NEXT_ARG();
 			filter.kind = *argv;
 		} else {
-- 
2.8.2
