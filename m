From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 20/20] man: ip-*.8: drop any reference to generic ip options
Date: Wed, 24 Feb 2016 09:21:33 +0100
Message-ID: <1456302093-697-21-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52709 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757932AbcBXIWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:10 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Listing generic 'ip' options in subcommand man pages is redundant and
error-prone, as they won't be kept in sync anyway. Since many other man
pages don't list them either, drop references to them in the remaining
ones.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-addrlabel.8 | 14 +-------------
 man/man8/ip-link.8.in   | 15 +--------------
 man/man8/ip-monitor.8   |  4 +---
 man/man8/ip-mroute.8    |  2 +-
 4 files changed, 4 insertions(+), 31 deletions(-)

diff --git a/man/man8/ip-addrlabel.8 b/man/man8/ip-addrlabel.8
index 51ef5727a0db1..233d6067ab407 100644
--- a/man/man8/ip-addrlabel.8
+++ b/man/man8/ip-addrlabel.8
@@ -6,21 +6,9 @@ ip-addrlabel \- protocol address label management
 .ad l
 .in +8
 .ti -8
-.B ip
-.RI "[ " OPTIONS " ]"
-.B addrlabel
+.B ip addrlabel
 .RI " { " COMMAND " | "
 .BR help " }"
-.sp
-
-.ti -8
-.IR OPTIONS " := { "
-\fB\-V\fR[\fIersion\fR] |
-\fB\-s\fR[\fItatistics\fR] |
-\fB\-r\fR[\fIesolve\fR] |
-\fB\-f\fR[\fIamily\fR] {
-.BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
-\fB\-o\fR[\fIneline\fR] }
 
 .ti -8
 .BR "ip addrlabel" " { " add " | " del " } " prefix
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index cc0842f01ab59..82670bcd9a9c1 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -6,25 +6,12 @@ ip-link \- network device configuration
 .ad l
 .in +8
 .ti -8
-.B ip
-.RI "[ " OPTIONS " ]"
-.B link
+.B ip link
 .RI  " { " COMMAND " | "
 .BR help " }"
 .sp
 
 .ti -8
-.IR OPTIONS " := { "
-\fB\-V\fR[\fIersion\fR] |
-\fB\-h\fR[\fIuman-readable\fR] |
-\fB\-s\fR[\fItatistics\fR] |
-\fB\-r\fR[\fIesolve\fR] |
-\fB\-f\fR[\fIamily\fR] {
-.BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
-\fB\-o\fR[\fIneline\fR] |
-\fB\-br\fR[\fIief\fR] }
-
-.ti -8
 .BI "ip link add"
 .RB "[ " link
 .IR DEVICE " ]"
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index d2bd381a8c32e..86f8f9885fefe 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -6,9 +6,7 @@ ip-monitor, rtmon \- state monitoring
 .ad l
 .in +8
 .ti -8
-.BR "ip " " [ "
-.IR ip-OPTIONS " ]"
-.BR  "monitor" " [ " all " |"
+.BR "ip monitor" " [ " all " |"
 .IR OBJECT-LIST " ] ["
 .BI file " FILENAME "
 ] [
diff --git a/man/man8/ip-mroute.8 b/man/man8/ip-mroute.8
index e89b6b2d2cc56..b64e30d33d412 100644
--- a/man/man8/ip-mroute.8
+++ b/man/man8/ip-mroute.8
@@ -6,7 +6,7 @@ ip-mroute \- multicast routing cache management
 .ad l
 .in +8
 .ti -8
-.BR "ip " " [ ip-OPTIONS ] " "mroute show" " [ [ "
+.BR "ip mroute show" " [ [ "
 .BR " to " " ] "
 .IR PREFIX " ] [ "
 .B  from
-- 
2.6.4
