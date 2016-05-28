From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 5/5] bridge: update man page
Date: Fri, 27 May 2016 21:37:16 -0700
Message-ID: <1464410236-65044-6-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35381 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbcE1Eha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 00:37:30 -0400
Received: by mail-pa0-f47.google.com with SMTP id fy7so29136819pac.2
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 21:37:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 man/man8/bridge.8 | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 08e8a5b..abaee63 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -20,8 +20,9 @@ bridge \- show / manipulate bridge addresses and devices
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
 \fB\-s\fR[\fItatistics\fR] |
-\fB\-n\fR[\fIetns\fR] name }
-\fB\-b\fR[\fIatch\fR] filename }
+\fB\-n\fR[\fIetns\fR] name |
+\fB\-b\fR[\fIatch\fR] filename |
+\fB\-j\fR[\fIson\fR] }
 
 .ti -8
 .BR "bridge link set"
@@ -153,6 +154,10 @@ Don't terminate bridge command on errors in batch mode.
 If there were any errors during execution of the commands, the application
 return code will be non zero.
 
+.TP
+.BR "\-json"
+Display results in JSON format. Currently available for vlan and fdb.
+
 .SH BRIDGE - COMMAND SYNTAX
 
 .SS
-- 
1.9.1
