From: Michal Soltys <soltys@ziu.info>
Subject: [iproute PATCH 1/1] man/man8/tc-flow.8: minor corrections
Date: Sun, 24 Jul 2016 02:00:29 +0200
Message-ID: <1469318429-19082-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:33440 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbcGXAAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 20:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- baseclass: major handle must match that of class's, Y defaults to 1
- flow map example: maps to 1-256, not 1-257

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 man/man8/tc-flow.8 | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-flow.8 b/man/man8/tc-flow.8
index f1b7e2a..54f6bf7 100644
--- a/man/man8/tc-flow.8
+++ b/man/man8/tc-flow.8
@@ -73,8 +73,10 @@ An offset for the resulting class ID.
 .I ID
 may be
 .BR root ", " none
-or a hexadecimal class ID in the form [\fIX\fB:\fR]\fIY\fR. If \fIX\fR is
-omitted, it is assumed to be zero.
+or a hexadecimal class ID in the form [\fIX\fB:\fR]\fIY\fR. \fIX\fR must
+match qdisc's/class's major handle (if omitted, the correct value is chosen
+automatically). If the whole \fBbaseclass\fR is omitted, \fIY\fR defaults
+to 1.
 .TP
 .BI divisor " NUM"
 Number of buckets to use for sorting into. Keys are calculated modulo
@@ -239,7 +241,7 @@ tc filter add ... flow hash \\
 	divisor 1024
 .EE
 .TP
-Map destination IPs of 192.168.0.0/24 to classids 1-257:
+Map destination IPs of 192.168.0.0/24 to classids 1-256:
 
 .EX
 tc filter add ... flow map \\
-- 
2.1.3
