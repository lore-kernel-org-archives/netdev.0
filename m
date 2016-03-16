From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/8] man: tc-skbedit.8: Elaborate a bit on TX queues
Date: Wed, 16 Mar 2016 22:56:22 +0100
Message-ID: <1458165384-900-7-git-send-email-phil@nwl.cc>
References: <1458165384-900-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34464 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656AbcCPV4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:56:43 -0400
In-Reply-To: <1458165384-900-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-skbedit.8 | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/man/man8/tc-skbedit.8 b/man/man8/tc-skbedit.8
index b585a4d4253ba..c75d082148ac3 100644
--- a/man/man8/tc-skbedit.8
+++ b/man/man8/tc-skbedit.8
@@ -17,6 +17,18 @@ The
 action allows to change a packet's associated meta data. It complements the
 .B pedit
 action, which in turn allows to change parts of the packet data itself.
+
+The most unique feature of
+.B skbedit
+is it's ability to decide over which queue of an interface with multiple
+transmit queues the packet is to be sent out. The number of available transmit
+queues is reflected by sysfs entries within
+.I /sys/class/net/<interface>/queues
+with name
+.I tx-N
+(where
+.I N
+is the actual queue number).
 .SH OPTIONS
 .TP
 .BI queue_mapping " QUEUE_MAPPING"
@@ -40,6 +52,8 @@ Change the packet's firewall mark value.
 is an unsigned 32bit value in automatically detected format (i.e., prefix with
 .RB ' 0x '
 for hexadecimal interpretation, etc.).
+.SH EXAMPLES
+XXX: write me
 .SH SEE ALSO
 .BR tc (8),
 .BR tc-pedit (8)
-- 
2.7.2
