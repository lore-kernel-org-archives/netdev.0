From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] iputils: ping: Fix typo in echo reply
Date: Wed, 03 Oct 2012 10:26:59 +0200
Message-ID: <506BF6D3.7070206@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010402030207090909010703"
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab2JCI1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 04:27:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010402030207090909010703
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello,

here is a fix for a typo that's currently present in ping.

Cheers,
--
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat

--------------010402030207090909010703
Content-Type: text/x-patch;
 name="0001-ping-Fix-typo-in-echo-reply.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ping-Fix-typo-in-echo-reply.patch"

>From 3b5623a03279538ca9a6f3796626c1aad9ef5477 Mon Sep 17 00:00:00 2001
From: Jan Synacek <jsynacek@redhat.com>
Date: Wed, 3 Oct 2012 10:14:45 +0200
Subject: [PATCH] ping: Fix typo in echo reply

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ping.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ping.c b/ping.c
index 1425d1d..3ab2ae0 100644
--- a/ping.c
+++ b/ping.c
@@ -705,7 +705,7 @@ int send_probe()
 void pr_echo_reply(__u8 *_icp, int len)
 {
 	struct icmphdr *icp = (struct icmphdr *)_icp;
-	printf(" icmp_req=%u", ntohs(icp->un.echo.sequence));
+	printf(" icmp_seq=%u", ntohs(icp->un.echo.sequence));
 }
 
 int
-- 
1.7.11.4


--------------010402030207090909010703--
