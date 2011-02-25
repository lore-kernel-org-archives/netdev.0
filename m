From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 5/7] ipv6: variable next is never used in this function
Date: Fri, 25 Feb 2011 16:45:19 +0100
Message-ID: <1298648721-3026-5-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57595 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755594Ab1BYPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:25 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/route.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f786aed..7e9443f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1075,11 +1075,9 @@ out:
 
 int icmp6_dst_gc(void)
 {
-	struct dst_entry *dst, *next, **pprev;
+	struct dst_entry *dst, **pprev;
 	int more = 0;
 
-	next = NULL;
-
 	spin_lock_bh(&icmp6_dst_lock);
 	pprev = &icmp6_dst_gc_list;
 
-- 
1.7.2.3

