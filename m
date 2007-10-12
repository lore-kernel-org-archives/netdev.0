From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] Also do tc_core_time2big argument (long->unsigned).
Date: Fri, 12 Oct 2007 14:37:09 +0200
Message-ID: <1192192629-23966-1-git-send-email-andreas@fatal.se>
References: <470F6264.5090808@trash.net>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38770 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbXJLMht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:37:49 -0400
In-Reply-To: <470F6264.5090808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tc_core_time2big only used in tc/q_netem.c where it gets passed an unsigned.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/tc_core.c |    2 +-
 tc/tc_core.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 8c3a2ac..1365e08 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -26,7 +26,7 @@
 static double tick_in_usec = 1;
 static double clock_factor = 1;
 
-int tc_core_time2big(long time)
+int tc_core_time2big(unsigned time)
 {
 	__u64 t = time;
 
diff --git a/tc/tc_core.h b/tc/tc_core.h
index b1ede1e..3a0ed7c 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -6,7 +6,7 @@
 
 #define TIME_UNITS_PER_SEC	1000000
 
-int  tc_core_time2big(long time);
+int  tc_core_time2big(unsigned time);
 unsigned tc_core_time2tick(unsigned time);
 unsigned tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
-- 
1.5.3.4

