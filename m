From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: remove obsolete comments in route.c
Date: Mon, 12 Nov 2012 14:16:08 +0800
Message-ID: <1352700968-23728-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42109 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab2KLGQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 01:16:17 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so4123005pbb.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 22:16:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c1cfcb7..226aeda 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1385,12 +1385,6 @@ out:
 	return entries > rt_max_size;
 }
 
-/* Clean host part of a prefix. Not necessary in radix tree,
-   but results in cleaner routing tables.
-
-   Remove it only when all the things will work!
- */
-
 int ip6_dst_hoplimit(struct dst_entry *dst)
 {
 	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
-- 
1.7.4.1
