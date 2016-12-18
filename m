From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: updated man page to reflect filter-id use in filter GET command.
Date: Sun, 18 Dec 2016 12:25:37 -0500
Message-ID: <1482081937-31218-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33281 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756176AbcLRRZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 12:25:47 -0500
Received: by mail-it0-f67.google.com with SMTP id c20so8046593itb.0
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 09:25:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/tc.8 | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 583b72f..f96911a 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -32,7 +32,8 @@ tc \- show / manipulate traffic control settings
 \fIDEV\fR
 .B [ parent
 \fIqdisc-id\fR
-.B | root ] protocol
+.B | root ] [ handle \fIfilter-id\fR ]
+.B protocol
 \fIprotocol\fR
 .B prio
 \fIpriority\fR filtertype
@@ -577,7 +578,8 @@ it is created.
 
 .TP
 get
-Displays a single filter given the interface, parent ID, priority, protocol and handle ID.
+Displays a single filter given the interface \fIDEV\fR, \fIqdisc-id\fR,
+\fIpriority\fR, \fIprotocol\fR and \fIfilter-id\fR.
 
 .TP
 show
-- 
1.9.1
