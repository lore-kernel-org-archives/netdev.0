From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: updated man page to reflect GET command to retrieve a single filter.
Date: Sun,  6 Nov 2016 21:27:38 -0500
Message-ID: <1478485658-14379-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        stephen@networkplumber.org, Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34462 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbcKGC2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 21:28:05 -0500
Received: by mail-it0-f66.google.com with SMTP id q124so6889285itd.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 18:28:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/tc.8 | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 4e99dca..3f4f8b5 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -28,7 +28,7 @@ class-id ] qdisc
 
 .B tc
 .RI "[ " OPTIONS " ]"
-.B filter [ add | change | replace | delete ] dev
+.B filter [ add | change | replace | delete | get ] dev
 DEV
 .B [ parent
 qdisc-id
@@ -571,6 +571,14 @@ Performs a nearly atomic remove/add on an existing node id. If the node does not
 it is created.
 
 .TP
+get
+Displays a single filter given the interface, parent ID, priority, protocol and handle ID.
+
+.TP
+show
+Displays all filters attached to the given interface. A valid parent ID must be passed.
+
+.TP
 link
 Only available for qdiscs and performs a replace where the node
 must exist already.
-- 
1.9.1
