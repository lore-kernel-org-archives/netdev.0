From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH v2 net-next 2/2] ptp: Fix compiler warnings in the testptp utility
Date: Wed, 26 Mar 2014 08:16:03 +0100
Message-ID: <35ec3d13-e8a8-4cf4-b5ce-91c4dbe2ac0b@mary.at.omicron.at>
References: <1395818163-31672-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Cochran <richardcochran@gmail.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	Dong Zhu <bluezhudong@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:57014 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbaCZHQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 03:16:49 -0400
In-Reply-To: <1395818163-31672-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Dong Zhu <bluezhudong@gmail.com>
---

Changes for v2:
- Use PRI64d macro for __s64 in printf

 Documentation/ptp/testptp.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index 13bddd5..f1ac2da 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -19,6 +19,7 @@
  */
 #include <errno.h>
 #include <fcntl.h>
+#include <inttypes.h>
 #include <math.h>
 #include <signal.h>
 #include <stdio.h>
@@ -496,14 +497,14 @@ int main(int argc, char *argv[])
 			interval = t2 - t1;
 			offset = (t2 + t1) / 2 - tp;
 
-			printf("system time: %ld.%ld\n",
+			printf("system time: %" PRId64 ".%u\n",
 				(pct+2*i)->sec, (pct+2*i)->nsec);
-			printf("phc    time: %ld.%ld\n",
+			printf("phc    time: %" PRId64 ".%u\n",
 				(pct+2*i+1)->sec, (pct+2*i+1)->nsec);
-			printf("system time: %ld.%ld\n",
+			printf("system time: %" PRId64 ".%u\n",
 				(pct+2*i+2)->sec, (pct+2*i+2)->nsec);
-			printf("system/phc clock time offset is %ld ns\n"
-				"system     clock time delay  is %ld ns\n",
+			printf("system/phc clock time offset is %" PRId64 " ns\n"
+			       "system     clock time delay  is %" PRId64 " ns\n",
 				offset, interval);
 		}
 
-- 
1.7.9.5
