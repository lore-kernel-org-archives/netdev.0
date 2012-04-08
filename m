From: Florian Westphal <fw@strlen.de>
Subject: [PATCH iproute2] tc: man: choke counts packets, not bytes
Date: Mon,  9 Apr 2012 00:34:14 +0200
Message-ID: <1333924454-2754-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:53111 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756182Ab2DHWiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2012 18:38:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/tc-choke.8 |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/man/man8/tc-choke.8 b/man/man8/tc-choke.8
index 7b213be..620c7f6 100644
--- a/man/man8/tc-choke.8
+++ b/man/man8/tc-choke.8
@@ -4,11 +4,11 @@ choke \- choose and keep scheduler
 .SH SYNOPSIS
 .B tc qdisc ... choke
 .B limit
-bytes
+packets
 .B min
-bytes
+packets
 .B max
-bytes
+packets
 .B avpkt
 bytes
 .B burst
@@ -22,7 +22,7 @@ chance
 
 CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for unresponsive flows)
 is a classless qdisc designed to both identify and penalize flows that monopolize the
-queue.  CHOKe is a variation of RED, and the configuration is the same as RED.
+queue.  CHOKe is a variation of RED, and the configuration is similar to RED.
 
 .SH ALGORITHM
 Once the queue hits a certain average length, a random packet is drawn from the
@@ -39,7 +39,8 @@ If the queue length exceeds
 The marking probability computation is the same as used by the RED qdisc.
 
 .SH PARAMETERS
-The parameters are the same as for RED, see
+The parameters are the same as for RED, except that RED uses bytes whereas choke
+counts packets. See
 .BR tc-red (8)
 for a description.
 
-- 
1.7.3.4
