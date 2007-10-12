From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] Also do tc_core_time2big argument (long->unsigned).
Date: Fri, 12 Oct 2007 13:56:33 +0200
Message-ID: <1192190193-23653-1-git-send-email-andreas@fatal.se>
References: <1192189789-23538-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:51806 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556AbXJLL5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 07:57:12 -0400
In-Reply-To: <1192189789-23538-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tc_core_time2big only used in tc/q_netem.c where it gets passed an unsigned.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/tc_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
 
-- 
1.5.3.4

