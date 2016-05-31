From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2 5/5] bridge: update man page
Date: Mon, 30 May 2016 19:17:16 -0700
Message-ID: <1464661036-35532-6-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34828 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422983AbcEaCRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 22:17:25 -0400
Received: by mail-pf0-f171.google.com with SMTP id g64so69387824pfb.2
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 19:17:25 -0700 (PDT)
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
