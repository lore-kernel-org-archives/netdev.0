From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v3 5/5] bridge: update man page
Date: Mon, 20 Jun 2016 23:39:47 -0700
Message-ID: <1466491187-8536-6-git-send-email-roopa@cumulusnetworks.com>
References: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36263 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbcFUGjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 02:39:55 -0400
Received: by mail-pa0-f52.google.com with SMTP id wo6so3290977pac.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 23:39:55 -0700 (PDT)
In-Reply-To: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
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
