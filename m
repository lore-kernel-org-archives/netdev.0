From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] iputils: clockdiff: remove unused variable
Date: Mon, 12 Nov 2012 09:38:29 +0100
Message-ID: <50A0B585.4030603@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070704030707010107070705"
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab2KLIid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 03:38:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070704030707010107070705
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hello,

attached is a small patch that removes an unused variable.

Cheers,

-- 
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat

--------------070704030707010107070705
Content-Type: text/x-patch;
 name="0001-clockdiff-remove-unused-variable.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-clockdiff-remove-unused-variable.patch"

>From 43edd5f73b1c6d1d6c033076c3ebcd43bf169594 Mon Sep 17 00:00:00 2001
From: Jan Synacek <jsynacek@redhat.com>
Date: Mon, 12 Nov 2012 09:31:53 +0100
Subject: [PATCH] clockdiff: remove unused variable

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 clockdiff.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/clockdiff.c b/clockdiff.c
index 32590d7..7c1ea1b 100644
--- a/clockdiff.c
+++ b/clockdiff.c
@@ -129,7 +129,7 @@ measure(struct sockaddr_in * addr)
 	int msgcount;
 	int cc, count;
 	fd_set ready;
-	long sendtime, recvtime, histime,  histime1;
+	long sendtime, recvtime, histime;
 	long min1, min2, diff;
 	long delta1, delta2;
 	struct timeval tv1, tout;
@@ -243,7 +243,6 @@ empty:
 			  rtt_sigma = (rtt_sigma *3 + abs(diff-rtt))/4;
 			  msgcount++;
 			  histime = ntohl(((__u32*)(icp+1))[1]);
-			  histime1 = ntohl(((__u32*)(icp+1))[2]);
 		/*
 		 * a hosts using a time format different from
 		 * ms. since midnight UT (as per RFC792) should
-- 
1.7.11.7


--------------070704030707010107070705--
