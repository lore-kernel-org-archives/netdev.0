From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: tc.8: mention Fair Queue scheduler
Date: Wed,  9 Sep 2015 15:41:08 +0200
Message-ID: <1441806068-14585-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47402 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753678AbbIINlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 09:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is rather a placeholder to let users know fq exists at all.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc.8 | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index feafa05..0081625 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -151,6 +151,10 @@ The classless qdiscs are:
 Simplest usable qdisc, pure First In, First Out behaviour. Limited in
 packets or in bytes.
 .TP
+fq
+Fair Queue Scheduler realises TCP pacing and scales to millions of concurrent
+flows per qdisc.
+.TP
 pfifo_fast
 Standard qdisc for 'Advanced Router' enabled kernels. Consists of a three-band
 queue which honors Type of Service flags, as well as the priority that may be
-- 
2.1.2
