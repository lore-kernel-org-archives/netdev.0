From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/8] man: tc-skbedit.8: Elaborate a bit on TX queues
Date: Tue, 22 Mar 2016 15:48:37 +0100
Message-ID: <1458658119-25881-7-git-send-email-phil@nwl.cc>
References: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37347 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758835AbcCVOtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:49:43 -0400
In-Reply-To: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-skbedit.8 | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/man/man8/tc-skbedit.8 b/man/man8/tc-skbedit.8
index b585a4d4253ba..e6902960eee27 100644
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
-- 
2.7.2
