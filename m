From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipaddr: fix a typo in error msg about SIOCGIFTXQLEN
Date: Tue, 29 Jan 2013 17:37:08 +0100
Message-ID: <1359477428-8717-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:58927 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189Ab3A2Qqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 11:46:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The optname was wrong.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 0d988ae..43b43c4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -163,7 +163,7 @@ static void print_queuelen(FILE *f, struct rtattr *tb[IFLA_MAX + 1])
 		memset(&ifr, 0, sizeof(ifr));
 		strcpy(ifr.ifr_name, rta_getattr_str(tb[IFLA_IFNAME]));
 		if (ioctl(s, SIOCGIFTXQLEN, &ifr) < 0) {
-			fprintf(f, "ioctl(SIOCGIFXQLEN) failed: %s\n", strerror(errno));
+			fprintf(f, "ioctl(SIOCGIFTXQLEN) failed: %s\n", strerror(errno));
 			close(s);
 			return;
 		}
-- 
1.8.0.1
