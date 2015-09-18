From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/6] man: ip: add -h[uman-readable] option
Date: Fri, 18 Sep 2015 20:17:01 +0200
Message-ID: <1442600225-18355-3-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41031 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbbIRSRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:08 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 'ip help' lists it, it should be described in ip.8 as well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip.8 | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 9da086d..e6c2b32 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -27,6 +27,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
+\fB\-h\fR[\fIuman-readable\fR] |
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
@@ -46,6 +47,10 @@ Print the version of the
 utility and exit.
 
 .TP
+.BR "\-h", " \-human", " \-human-readable"
+output statistics with human readable values followed by suffix.
+
+.TP
 .BR "\-b", " \-batch " <FILENAME>
 Read commands from provided file or standard input and invoke them.
 First failure will cause termination of ip.
-- 
2.1.2
