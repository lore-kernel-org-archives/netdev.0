From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/6] ip: add man pages for netconf
Date: Thu, 13 Dec 2012 14:42:49 +0100
Message-ID: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40564 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab2LMNpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the documentation about 'ip netconf' command.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/Makefile     |  2 +-
 man/man8/ip-netconf.8 | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/ip-netconf.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 4bad9d6..d208f3b 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -9,7 +9,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	ip-addrlabel.8 ip-l2tp.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
 	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
-	ip-tcp_metrics.8
+	ip-tcp_metrics.8 ip-netconf.8
 
 all: $(TARGETS)
 
diff --git a/man/man8/ip-netconf.8 b/man/man8/ip-netconf.8
new file mode 100644
index 0000000..8041ea2
--- /dev/null
+++ b/man/man8/ip-netconf.8
@@ -0,0 +1,36 @@
+.TH IP\-NETCONF 8 "13 Dec 2012" "iproute2" "Linux"
+.SH "NAME"
+ip-netconf \- network configuration monitoring
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.BR "ip " " [ ip-OPTIONS ] " "netconf show" " [ "
+.B dev
+.IR STRING " ]"
+
+.SH DESCRIPTION
+The
+.B ip netconf
+utility can monitor IPv4 and IPv6 parameters (see
+.BR "/proc/sys/net/ipv[4|6]/conf/[all|DEV]/" ")"
+like forwarding, rp_filter
+or mc_forwarding status.
+
+If no interface is specified, the entry
+.B all
+is displayed.
+
+.SS ip netconf show - display network parameters
+
+.TP
+.BI dev " STRING"
+the name of the device to display network parameters.
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Original Manpage by Nicolas Dichtel <nicolas.dichtel@6wind.com>
-- 
1.8.0.1
