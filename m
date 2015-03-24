From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3] man ip-netns: Fix syntax in default ns process, indent's
Date: Tue, 24 Mar 2015 11:41:52 +0200
Message-ID: <1427190112-14636-1-git-send-email-vadim4j@gmail.com>
Cc: simon.horman@netronome.com, ben@decadent.org.uk,
	Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:35362 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbbCXJxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 05:53:46 -0400
Received: by laae1 with SMTP id e1so22898967laa.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 02:53:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
v3:
    Added 'its' after 'By default a process inherits ...'
    -> suggested by Simon Horman <simon.horman@netronome.com>
v2:
    Deleted leading spaces
    -> suggested by Ben Hutchings <ben@decadent.org.uk>

 man/man8/ip-netns.8 | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index d496675..d34cdfe 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -46,7 +46,7 @@ ip-netns \- process network namespace management
 A network namespace is logically another copy of the network stack,
 with its own routes, firewall rules, and network devices.
 
-By default process inherits network namespace from its parent. Initially all
+By default a process inherits its network namespace from its parent. Initially all
 the processes share the same default network namespace from the init process.
 
 By convention a named network namespace is an object at
@@ -103,10 +103,18 @@ option was specified then all the network namespace names will be removed.
 It is possible to lose the physical device when it was moved to netns and
 then this netns was deleted with a running process:
 
-    $ ip netns add net0
-    $ ip link set dev eth0 netns net0
-    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
-    $ ip netns del net0
+.RS 10
+$ ip netns add net0
+.RE
+.RS 10
+$ ip link set dev eth0 netns net0
+.RE
+.RS 10
+$ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
+.RE
+.RS 10
+$ ip netns del net0
+.RE
 
 and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
 will exit or will be killed. To prevent this the processes running in net0
-- 
2.3.1
