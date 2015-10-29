From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/4] ifcfg: add manpage
Date: Thu, 29 Oct 2015 10:55:21 +0100
Message-ID: <1446112524-6986-2-git-send-email-phil@nwl.cc>
References: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35796 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbbJ2Jz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:55:26 -0400
In-Reply-To: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ifcfg.8 | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)
 create mode 100644 man/man8/ifcfg.8

diff --git a/man/man8/ifcfg.8 b/man/man8/ifcfg.8
new file mode 100644
index 0000000..79033bd
--- /dev/null
+++ b/man/man8/ifcfg.8
@@ -0,0 +1,48 @@
+.TH IFCFG 8 "September 24 2009" "iproute2" "Linux"
+.SH NAME
+ifcfg \- simplistic script which replaces ifconfig IP managment
+.SH SYNOPSIS
+.ad l
+.in +8
+.ti -8
+.B ifcfg
+.RI "[ " DEVICE " ] [ " command " ] " ADDRESS " [ " PEER " ] "
+.sp
+
+.SH DESCRIPTION
+This manual page documents briefly the
+.B ifcfg
+command.
+.PP
+This is a simplistic script replacing one option of
+.B ifconfig
+, namely, IP address management. It not only adds
+addresses, but also carries out Duplicate Address Detection RFC-DHCP,
+sends unsolicited ARP to update the caches of other hosts sharing
+the interface, adds some control routes and restarts Router Discovery
+when it is necessary.
+
+.SH IFCONFIG - COMMAND SYNTAX
+
+.SS
+.TP
+.B DEVICE
+- it may have alias, suffix, separated by colon.
+
+.TP
+.B command
+- add, delete or stop.
+
+.TP
+.B ADDRESS
+- optionally followed by prefix length.
+
+.TP
+.B peer
+- optional peer address for pointpoint interfaces.
+
+.SH NOTES
+This script is not suitable for use with IPv6.
+
+.SH SEE ALSO
+.RB "IP Command reference " ip-cref.ps
-- 
2.1.2
