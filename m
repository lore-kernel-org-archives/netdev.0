From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man tc: Add description for -graph option
Date: Sun, 28 Dec 2014 12:33:05 +0200
Message-ID: <1419762785-27916-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:48763 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaL1KnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 05:43:17 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so16917208wgh.8
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 02:43:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/tc.8 | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index d8f974f..a6aed0a 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -70,7 +70,8 @@ DEV
 \fB\-d\fR[\fIetails\fR] |
 \fB\-r\fR[\fIaw\fR] |
 \fB\-p\fR[\fIretty\fR] |
-\fB\-i\fR[\fIec\fR] }
+\fB\-i\fR[\fIec\fR] |
+\fB\-g\fR[\fIraph\fR] }
 
 .SH DESCRIPTION
 .B Tc
@@ -475,6 +476,25 @@ decode filter offset and mask values to equivalent filter commands based on TCP/
 .BR "\-iec"
 print rates in IEC units (ie. 1K = 1024).
 
+.TP
+.BR "\-g", " \-graph"
+shows classes as ASCII graph. Prints generic stats info under each class if
+.BR "-s"
+option was specified. Classes can be filtered only by
+.BR "dev"
+option.
+
+.SH "EXAMPLES"
+.PP
+tc -g class show dev eth0
+.RS 4
+Shows classes as ASCII graph on eth0 interface.
+.RE
+.PP
+tc -g -s class show dev eth0
+.RS 4
+Shows classes as ASCII graph with stats info under each class.
+
 .SH HISTORY
 .B tc
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
-- 
2.1.3
