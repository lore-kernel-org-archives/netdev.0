From: Lukas Braun <koomi@moshbit.net>
Subject: [PATCH] man: ip-route.8: Mention that lower metric means higher priority
Date: Wed, 21 Jun 2017 21:59:45 +0200
Message-ID: <1498075185-19228-1-git-send-email-koomi@moshbit.net>
Cc: netdev@vger.kernel.org, Lukas Braun <koomi@moshbit.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moshbit.net ([62.210.136.156]:49054 "EHLO mail.lukas-braun.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751093AbdFUUI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 16:08:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is quite counter-intuitive when using the 'preference' keyword.

Signed-off-by: Lukas Braun <koomi@moshbit.net>
---
 man/man8/ip-route.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index c8eb38a..d74e2a8 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -380,7 +380,7 @@ from
 .BI preference " NUMBER"
 the preference value of the route.
 .I NUMBER
-is an arbitrary 32bit number.
+is an arbitrary 32bit number, where routes with lower values are preferred.
 
 .TP
 .BI table " TABLEID"
-- 
2.1.4
