From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH iproute2] man: fix documentation for range of route table ID
Date: Thu, 21 Sep 2017 20:14:11 +0200
Message-ID: <20170921181411.17720-1-thaller@redhat.com>
Cc: Thomas Haller <thaller@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63259 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbdIUSOW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 14:14:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 man/man8/ip-route.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 803de3b9..9717b959 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -322,7 +322,7 @@ normal routing tables.
 .P
 .B Route tables:
 Linux-2.x can pack routes into several routing tables identified
-by a number in the range from 1 to 2^31 or by name from the file
+by a number in the range from 0 to 2^32-1 or by name from the file
 .B @SYSCONFDIR@/rt_tables
 By default all normal routes are inserted into the
 .B main
-- 
2.13.5
