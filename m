From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/6] man: rtpr: add minimal manpage
Date: Fri, 18 Sep 2015 20:17:05 +0200
Message-ID: <1442600225-18355-7-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53657 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbbIRSRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:09 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While there is not much to explain about this rather trivial shell
script, having a manpage for it serves as good point of reference for
users wondering what it might be for.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/Makefile |  2 +-
 man/man8/rtpr.8   | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/rtpr.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 3df9961..c97d816 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -1,6 +1,6 @@
 TARGETS = ip-address.8 ip-link.8 ip-route.8
 
-MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
+MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.8 \
 	tc.8 tc-bfifo.8 tc-bpf.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
 	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 \
 	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
diff --git a/man/man8/rtpr.8 b/man/man8/rtpr.8
new file mode 100644
index 0000000..5e32b2e
--- /dev/null
+++ b/man/man8/rtpr.8
@@ -0,0 +1,25 @@
+.TH RTPR 8 "18 September, 2015"
+
+.SH NAME
+rtpr \- replace backslashes with newlines.
+
+.SH DESCRIPTION
+.B rtpr
+is a trivial bash script which converts backslashes in standard input to newlines. It's sole purpose is to be fed with input from
+.B ip
+when executed with it's
+.B --oneline
+flag.
+
+.SH EXAMPLES
+.TP
+ip --onenline address show | rtpr
+Undo oneline converted
+.B ip-address
+output.
+
+.SH SEE ALSO
+.BR ip (8)
+
+.SH AUTHORS
+Stephen Hemminger <shemming@brocade.com>
-- 
2.1.2
