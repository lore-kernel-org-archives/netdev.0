From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v5 4/4] ifstat: Add xstat to ifstat man page
Date: Thu, 26 Jan 2017 14:44:41 +0200
Message-ID: <1485434681-33947-5-git-send-email-nogahf@mellanox.com>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51775 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752055AbdAZMnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:43:07 -0500
In-Reply-To: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation about the extended statistics to the ifstat man page.
Add ifstat man age to the man8 Makefile

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 man/man8/Makefile |  3 ++-
 man/man8/ifstat.8 | 12 +++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 77d347c..bc2fc81 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -18,7 +18,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
 	tc-tunnel_key.8 \
-	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
+	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 \
+	ifstat.8
 
 all: $(TARGETS)
 
diff --git a/man/man8/ifstat.8 b/man/man8/ifstat.8
index e49d868..3ba0088 100644
--- a/man/man8/ifstat.8
+++ b/man/man8/ifstat.8
@@ -14,7 +14,8 @@ ifstat \- handy utility to read network interface statistics
 The utility keeps records of the previous data displayed in history files and
 by default only shows difference between the last and the current call.
 Location of the history files defaults to /tmp/.ifstat.u$UID but may be
-overridden with the IFSTAT_HISTORY environment variable.
+overridden with the IFSTAT_HISTORY environment variable. Similarly, the default
+location for xstat (extended stats) is /tmp/.<xstat name>_ifstat.u$UID.
 .SH OPTIONS
 .TP
 .B \-h, \-\-help
@@ -46,6 +47,15 @@ Report average over the last SECS seconds.
 .TP
 .B \-z, \-\-zeros
 Show entries with zero activity.
+.TP
+.B \-x, \-\-extended=TYPE
+Show extended stats of TYPE. Supported types are:
+
+.in +8
+.B cpu_hits
+- Counts only packets that went via the CPU.
+.in -8
+
 .SH ENVIRONMENT
 .TP
 .B IFSTAT_HISTORY
-- 
2.4.3
