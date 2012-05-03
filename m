From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2 ] Update man8 Makefile
Date: Thu,  3 May 2012 13:15:46 -0700
Message-ID: <1336076146-5464-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Christoph J. Thompson" <cjsthompson@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:63936 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317Ab2ECUPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:15:20 -0400
Received: by dady13 with SMTP id y13so2320504dad.5
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 13:15:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit (761a1e60 iproute2 - Split up manual page installation )
introduced man/man8/Makefile but did not add all the man pages.
This patch adds the missing man pages for installation.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/Makefile |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 5d64012..6873a4b 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -3,7 +3,11 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
 	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
-	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8
+	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
+	tc-sfb.8 tc-netem.8 tc-choke.8 ip-tunnel.8 ip-rule.8 ip-ntable.8 \
+	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
+	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8
+
 
 all: $(TARGETS)
 
-- 
1.7.0.4
