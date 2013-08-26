From: Richard Godbee <richard@godbee.net>
Subject: [PATCH] iproute2: ip-route.8.in: minor fixes
Date: Sun, 25 Aug 2013 22:40:19 -0400
Message-ID: <1377484819-23743-2-git-send-email-richard@godbee.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa07-09.prod.phx3.secureserver.net ([173.201.192.238]:48292
	"EHLO p3plsmtpa07-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195Ab3HZCli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 22:41:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In SYNOPSIS section:

 - Add 'reordering'
 - Add missing '[' before 'quickack'

Signed-off-by: Richard Godbee <richard@godbee.net>
---
 man/man8/ip-route.8.in | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 7191bce..79bc7f1 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -97,6 +97,8 @@ replace " } "
 .IR TIME " ] [ "
 .B  rttvar
 .IR TIME " ] [ "
+.B  reordering
+.IR NUMBER " ] [ "
 .B  window
 .IR NUMBER " ] [ "
 .B  cwnd
@@ -110,7 +112,7 @@ replace " } "
 .B  initcwnd
 .IR NUMBER " ] [ "
 .B  initrwnd
-.IR NUMBER " ]"
+.IR NUMBER " ] [ "
 .B  quickack
 .IR BOOL " ]"
 
-- 
1.8.2.2
