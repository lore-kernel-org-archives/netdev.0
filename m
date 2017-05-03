From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip.8: Document -brief flag
Date: Wed,  3 May 2017 11:07:58 +0200
Message-ID: <20170503090758.24179-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38895 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751751AbdECJIM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 05:08:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brief output is especially useful for new users, so at least mention
it's existence in ip man page.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip.8 | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1c5a7419e4fc2..ae018fdf11ac9 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -48,7 +48,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-ts\fR[\fIhort\fR] |
 \fB\-n\fR[\fIetns\fR] name |
 \fB\-a\fR[\fIll\fR] |
-\fB\-c\fR[\fIolor\fR] }
+\fB\-c\fR[\fIolor\fR]
+\fB\-br\fR[\fIief\fR] }
 
 
 .SH OPTIONS
@@ -206,6 +207,11 @@ Set the netlink socket receive buffer size, defaults to 1MB.
 .BR "\-iec"
 print human readable rates in IEC units (e.g. 1Ki = 1024).
 
+.TP
+.BR "\-br" , "\-brief"
+Print only basic information in a tabular format for better readability. This option is currently only supported by
+.BR "ip addr show " and " ip link show " commands.
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.11.0
