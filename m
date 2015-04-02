From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-netns: Fix shifted layout at bottom of 'ip netns del'
Date: Thu,  2 Apr 2015 18:08:03 +0300
Message-ID: <1427987283-26299-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37978 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbbDBPUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:20:06 -0400
Received: by wibgn9 with SMTP id gn9so109543975wib.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 08:20:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-netns.8 | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index d34cdfe..5985be0 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -116,12 +116,18 @@ $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
 $ ip netns del net0
 .RE
 
+.RS
 and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
 will exit or will be killed. To prevent this the processes running in net0
 should be killed before deleting the netns:
 
-    $ ip netns pids net0 | xargs kill
-    $ ip netns del net0
+.RE
+.RS 10
+$ ip netns pids net0 | xargs kill
+.RE
+.RS 10
+$ ip netns del net0
+.RE
 
 .TP
 .B ip netns set NAME NETNSID - assign an id to a peer network namespace
-- 
2.3.1
