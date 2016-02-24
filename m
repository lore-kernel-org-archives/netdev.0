From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 18/20] man: ip.8: Add missing flags and token subcommand description
Date: Wed, 24 Feb 2016 09:21:31 +0100
Message-ID: <1456302093-697-19-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60880 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757932AbcBXIVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:21:51 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip.8 | 29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index b1f6907367275..aa2bc68c81ab6 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -21,7 +21,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .IR OBJECT " := { "
 .BR link " | " address " | " addrlabel " | " route " | " rule " | " neigh " | "\
  ntable " | " tunnel " | " tuntap " | " maddress " | "  mroute " | " mrule " | "\
- monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " }"
+ monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " | " token " }"
 .sp
 
 .ti -8
@@ -29,10 +29,22 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-V\fR[\fIersion\fR] |
 \fB\-h\fR[\fIuman-readable\fR] |
 \fB\-s\fR[\fItatistics\fR] |
+\fB\-d\fR[\fIetails\fR] |
 \fB\-r\fR[\fIesolve\fR] |
+\fB\-iec\fR |
 \fB\-f\fR[\fIamily\fR] {
 .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
+\fB-4\fR |
+\fB-6\fR |
+\fB-I\fR |
+\fB-D\fR |
+\fB-B\fR |
+\fB-0\fR |
+\fB-l\fR[\fIoops\fR] { \fBmaximum-addr-flush-attempts\fR } |
 \fB\-o\fR[\fIneline\fR] |
+\fB\-rc\fR[\fIvbuf\fR] [\fBsize\fR] |
+\fB\-t\fR[\fIimestamp\fR] |
+\fB\-ts\fR[\fIhort\fR] |
 \fB\-n\fR[\fIetns\fR] name |
 \fB\-a\fR[\fIll\fR] |
 \fB\-c\fR[\fIolor\fR] }
@@ -179,6 +191,16 @@ Use color output.
 .BR "\-t" , " \-timestamp"
 display current time when using monitor option.
 
+.TP
+.BR "\-ts" , " \-tshort"
+Like
+.BR \-timestamp ,
+but use shorter format.
+
+.TP
+.BR "\-rc" , " \-rcvbuf" <SIZE>
+Set the netlink socket receive buffer size, defaults to 1MB.
+
 .SH IP - COMMAND SYNTAX
 
 .SS
@@ -241,6 +263,10 @@ display current time when using monitor option.
 - manage TCP Metrics
 
 .TP
+.B token
+- manage tokenized interface identifiers.
+
+.TP
 .B tunnel
 - tunnel over IP.
 
@@ -305,6 +331,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR ip-route (8),
 .BR ip-rule (8),
 .BR ip-tcp_metrics (8),
+.BR ip-token (8),
 .BR ip-tunnel (8),
 .BR ip-xfrm (8)
 .br
-- 
2.6.4
