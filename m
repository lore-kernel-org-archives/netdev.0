From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Thu,  8 Nov 2012 16:38:08 +0800
Message-ID: <1352363888-14068-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:45233 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab2KHIiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 03:38:20 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1091209dak.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 00:38:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/xfrm6_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f3ed8ca..93832e8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -332,10 +332,10 @@ int __init xfrm6_init(void)
 	/*
 	 * We need a good default value for the xfrm6 gc threshold.
 	 * In ipv4 we set it to the route hash table size * 8, which
-	 * is half the size of the maximaum route cache for ipv4.  It
+	 * is half the size of the maximum route cache for ipv4.  It
 	 * would be good to do the same thing for v6, except the table is
 	 * constructed differently here.  Here each table for a net namespace
-	 * can have FIB_TABLE_HASHSZ entries, so lets go with the same
+	 * can have FIB6_TABLE_HASHSZ entries, so lets go with the same
 	 * computation that we used for ipv4 here.  Also, lets keep the initial
 	 * gc_thresh to a minimum of 1024, since, the ipv6 route cache defaults
 	 * to that as a minimum as well
-- 
1.7.4.1
