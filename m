From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] iproute2: document -timestamp option
Date: Tue,  6 Oct 2015 14:16:29 -0700
Message-ID: <1444166189-37072-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33150 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbbJFVQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:16:34 -0400
Received: by pacex6 with SMTP id ex6so221116660pac.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 14:16:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

This patch documents bridge and ip -timestamp option

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
---
 man/man8/bridge.8 | 3 +++
 man/man8/ip.8     | 4 ++++
 2 files changed, 7 insertions(+)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 5347a56..9f1051c 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -137,6 +137,9 @@ to
 .RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
 .BR help " }"
 
+.TP
+.BR "\-t" , " \-timestamp"
+display current time when using monitor option.
 
 .SH BRIDGE - COMMAND SYNTAX
 
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index e6c2b32..1bdee11 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -175,6 +175,10 @@ executes specified command over all objects, it depends if command supports this
 .BR "\-c" , " -color"
 Use color output.
 
+.TP
+.BR "\-t" , " \-timestamp"
+display current time when using monitor option.
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
1.9.1
