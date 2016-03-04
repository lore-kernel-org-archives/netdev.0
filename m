From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 02/12] man: Add a man page for the csum action.
Date: Fri,  4 Mar 2016 13:11:37 +0100
Message-ID: <1457093507-25601-3-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37082 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbcCDMMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:43 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 5FD836AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:42 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 454946894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:42 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Gregoire Baron <baronchon@n7mm.org>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-csum.8 | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)
 create mode 100644 man/man8/tc-csum.8

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
new file mode 100644
index 0000000000000..9d00aae346af0
--- /dev/null
+++ b/man/man8/tc-csum.8
@@ -0,0 +1,54 @@
+.TH "Checksum action in tc" 8 "11 Jan 2015" "iproute2" "Linux"
+
+.SH NAME
+csum - checksum update action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action csum"
+.I UPDATE
+
+.ti -8
+.IR UPDATE " := " TARGET " [ " UPDATE " ]"
+
+.ti -8
+.IR TARGET " := { "
+.BR ip4h " |"
+.BR icmp " |"
+.BR igmp " |"
+.BR tcp " |"
+.BR udp " |"
+.BR udplite " |"
+.IR SWEETS " }"
+
+.ti -8
+.IR SWEETS " := { "
+.BR and " | " or " | " + " }"
+.SH DESCRIPTION
+The
+.B csum
+action triggers checksum recalculation of specified packet headers. It is
+commonly used after packet editing using the
+.B pedit
+action to fix for then incorrect checksums.
+.SH OPTIONS
+.TP
+.I TARGET
+Specify which headers to update: IPv4 header
+.RB ( ip4h ),
+ICMP header
+.RB ( icmp ),
+IGMP header
+.RB ( igmp ),
+TCP header
+.RB ( tcp ),
+UDP header
+.RB ( udp ") or"
+UDPLite header
+.RB ( udplite ).
+.TP
+.B SWEETS
+These are merely syntactic sugar and ignored internally.
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-pedit (8)
-- 
2.7.2
