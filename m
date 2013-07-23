From: Joe Stringer <joe@wand.net.nz>
Subject: [net-next] net: Add NEXTHDR_SCTP to ipv6.h
Date: Tue, 23 Jul 2013 13:37:45 +0900
Message-ID: <1374554265-10611-1-git-send-email-joe@wand.net.nz>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	horms@verge.net.au, jesse@nicira.com,
	Joe Stringer <joe@wand.net.nz>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:38338 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab3GWEh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 00:37:59 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so1066739pab.40
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 21:37:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Stringer <joe@wand.net.nz>
---
 include/net/ipv6.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5fe5649..7bdff04 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -41,6 +41,7 @@
 #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
 #define NEXTHDR_NONE		59	/* No next header */
 #define NEXTHDR_DEST		60	/* Destination options header. */
+#define NEXTHDR_SCTP		132	/* SCTP message. */
 #define NEXTHDR_MOBILITY	135	/* Mobility header. */
 
 #define NEXTHDR_MAX		255
-- 
1.7.10.4
