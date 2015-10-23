From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 9/9] tc: ship filter man pages and refer to them in tc.8
Date: Fri, 23 Oct 2015 19:47:16 +0200
Message-ID: <1445622436-6386-10-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Jiri Pirko <jiri@resnulli.us>,
	Patrick McHardy <kaber@trash.net>,
	Werner Almesberger <werner@almesberger.net>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45059 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932304AbbJWRrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:22 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cc: Thomas Graf <tgraf@suug.ch>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Werner Almesberger <werner@almesberger.net>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/Makefile |  4 +++-
 man/man8/tc.8     | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 1845987..2f77640 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -12,7 +12,9 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
 	ip-tcp_metrics.8 ip-netconf.8 ip-token.8 \
 	tipc.8 tipc-bearer.8 tipc-link.8 tipc-media.8 tipc-nametable.8 \
-	tipc-node.8 tipc-socket.8
+	tipc-node.8 tipc-socket.8 \
+	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
+	tc-tcindex.8 tc-u32.8
 
 all: $(TARGETS)
 
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 8735011..700b960 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -144,6 +144,50 @@ It is important to notice that filters reside
 .B within
 qdiscs - they are not masters of what happens.
 
+The available filters are:
+.TP
+basic
+Filter packets based on an ematch expression. See
+.BR tc-ematch (8)
+for details.
+.TP
+bpf
+Filter packets using (e)BPF, see
+.BR tc-bpf (8)
+for details.
+.TP
+cgroup
+Filter packets based on the control group of their process. See
+. BR tc-cgroup (8)
+for details.
+.TP
+flow, flower
+Flow-based classifiers, filtering packets based on their flow (identified by selectable keys). See
+.BR tc-flow "(8) and"
+.BR tc-flower (8)
+for details.
+.TP
+fw
+Filter based on fwmark. Directly maps fwmark value to traffic class. See
+.BR tc-fw (8).
+.TP
+route
+Filter packets based on routing table. See
+.BR tc-route (8)
+for details.
+.TP
+rsvp
+Match Resource Reservation Protocol (RSVP) packets.
+.TP
+tcindex
+Filter packets based on traffic control index. See
+.BR tc-index (8).
+.TP
+u32
+Generic filtering on arbitrary packet data, assisted by syntax to abstract common operations. See
+.BR tc-u32 (8)
+for details.
+
 .SH CLASSLESS QDISCS
 The classless qdiscs are:
 .TP
@@ -655,15 +699,20 @@ Shows classes as ASCII graph with stats info under each class.
 .B tc
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .SH SEE ALSO
+.BR tc-basic (8),
 .BR tc-bfifo (8),
 .BR tc-bpf (8),
 .BR tc-cbq (8),
+.BR tc-cgroup (8),
 .BR tc-choke (8),
 .BR tc-codel (8),
 .BR tc-drr (8),
 .BR tc-ematch (8),
+.BR tc-flow (8),
+.BR tc-flower (8),
 .BR tc-fq (8),
 .BR tc-fq_codel (8),
+.BR tc-fw (8),
 .BR tc-hfsc (7),
 .BR tc-hfsc (8),
 .BR tc-htb (8),
@@ -671,10 +720,13 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-pfifo (8),
 .BR tc-pfifo_fast (8),
 .BR tc-red (8),
+.BR tc-route (8),
 .BR tc-sfb (8),
 .BR tc-sfq (8),
 .BR tc-stab (8),
 .BR tc-tbf (8),
+.BR tc-tcindex (8),
+.BR tc-u32 (8),
 .br
 .RB "User documentation at " http://lartc.org/ ", but please direct bugreports and patches to: " <netdev@vger.kernel.org>
 
-- 
2.1.2
