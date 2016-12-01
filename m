From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: updated man page to reflect handle-id use in filter GET command.
Date: Thu,  1 Dec 2016 15:20:44 -0500
Message-ID: <1480623644-27533-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36014 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755509AbcLAUVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:21:11 -0500
Received: by mail-io0-f194.google.com with SMTP id s82so3183163ioi.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:21:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/tc.8 | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 8a47a2b..d957ffa 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -32,7 +32,9 @@ class-id ] qdisc
 DEV
 .B [ parent
 qdisc-id
-.B | root ] protocol
+.B | root ] [ handle
+handle-id ]
+.B protocol
 protocol
 .B prio
 priority filtertype
@@ -577,7 +579,7 @@ it is created.
 
 .TP
 get
-Displays a single filter given the interface, parent ID, priority, protocol and handle ID.
+Displays a single filter given the interface, qdisc-id, priority, protocol and handle-id.
 
 .TP
 show
-- 
1.9.1
