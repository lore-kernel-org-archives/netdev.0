From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next 2/2] ptp: Fix compiler warnings in the testptp utility
Date: Tue, 25 Mar 2014 12:24:06 +0100
Message-ID: <a2330f7d-0abf-4ee0-9288-1e881b2b5368@mary.at.omicron.at>
References: <1395746646-28299-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Cochran <richardcochran@gmail.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	Dong Zhu <bluezhudong@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:52893 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbaCYLYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 07:24:33 -0400
In-Reply-To: <1395746646-28299-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Dong Zhu <bluezhudong@gmail.com>
---
 Documentation/ptp/testptp.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index 13bddd5..14bf19e 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -496,14 +496,14 @@ int main(int argc, char *argv[])
 			interval = t2 - t1;
 			offset = (t2 + t1) / 2 - tp;
 
-			printf("system time: %ld.%ld\n",
+			printf("system time: %lld.%u\n",
 				(pct+2*i)->sec, (pct+2*i)->nsec);
-			printf("phc    time: %ld.%ld\n",
+			printf("phc    time: %lld.%u\n",
 				(pct+2*i+1)->sec, (pct+2*i+1)->nsec);
-			printf("system time: %ld.%ld\n",
+			printf("system time: %lld.%u\n",
 				(pct+2*i+2)->sec, (pct+2*i+2)->nsec);
-			printf("system/phc clock time offset is %ld ns\n"
-				"system     clock time delay  is %ld ns\n",
+			printf("system/phc clock time offset is %lld ns\n"
+				"system     clock time delay  is %lld ns\n",
 				offset, interval);
 		}
 
-- 
1.7.9.5
