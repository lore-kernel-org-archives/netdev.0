From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 08/12] man: Add a man page for the skbedit action
Date: Fri,  4 Mar 2016 13:11:43 +0100
Message-ID: <1457093507-25601-9-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53702 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287AbcCDMMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:37 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 2060A6AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:36 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 05AEF6894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:35 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-skbedit.8 | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
 create mode 100644 man/man8/tc-skbedit.8

diff --git a/man/man8/tc-skbedit.8 b/man/man8/tc-skbedit.8
new file mode 100644
index 0000000000000..b585a4d4253ba
--- /dev/null
+++ b/man/man8/tc-skbedit.8
@@ -0,0 +1,45 @@
+.TH "SKB editing action in tc" 8 "12 Jan 2015" "iproute2" "Linux"
+
+.SH NAME
+skbedit - SKB editing action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action skbedit " [ " queue_mapping
+.IR QUEUE_MAPPING " ] ["
+.B priority
+.IR PRIORITY " ] ["
+.B mark
+.IR MARK " ]"
+.SH DESCRIPTION
+The
+.B skbedit
+action allows to change a packet's associated meta data. It complements the
+.B pedit
+action, which in turn allows to change parts of the packet data itself.
+.SH OPTIONS
+.TP
+.BI queue_mapping " QUEUE_MAPPING"
+Override the packet's transmit queue. Useful when applied to packets transmitted
+over MQ-capable network interfaces.
+.I QUEUE_MAPPING
+is an unsigned 16bit value in decimal format.
+.TP
+.BI priority " PRIORITY"
+Override the packet classification decision.
+.I PRIORITY
+is either
+.BR root ", " none
+or a hexadecimal major class ID optionally followed by a colon
+.RB ( : )
+and a hexadecimal minor class ID.
+.TP
+.BI mark " MARK"
+Change the packet's firewall mark value.
+.I MARK
+is an unsigned 32bit value in automatically detected format (i.e., prefix with
+.RB ' 0x '
+for hexadecimal interpretation, etc.).
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-pedit (8)
-- 
2.7.2
