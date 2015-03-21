From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-netns: Fix syntax in default ns process, indent's
Date: Sat, 21 Mar 2015 07:32:42 +0200
Message-ID: <1426915962-17112-1-git-send-email-vadim4j@gmail.com>
Cc: ben@decadent.org.uk, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:35159 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbCUFo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:44:29 -0400
Received: by webcq43 with SMTP id cq43so97023939web.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:44:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-netns.8 | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index d496675..fe885db 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -46,7 +46,7 @@ ip-netns \- process network namespace management
 A network namespace is logically another copy of the network stack,
 with its own routes, firewall rules, and network devices.
 
-By default process inherits network namespace from its parent. Initially all
+By default a process inherits network namespace from its parent. Initially all
 the processes share the same default network namespace from the init process.
 
 By convention a named network namespace is an object at
@@ -103,10 +103,12 @@ option was specified then all the network namespace names will be removed.
 It is possible to lose the physical device when it was moved to netns and
 then this netns was deleted with a running process:
 
+.RS
     $ ip netns add net0
     $ ip link set dev eth0 netns net0
     $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
     $ ip netns del net0
+.RE
 
 and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
 will exit or will be killed. To prevent this the processes running in net0
-- 
2.3.1
