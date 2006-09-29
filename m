From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/4] [SCTP]: Enable Nagle algorithm by default.
Date: Fri, 29 Sep 2006 13:00:03 -0700
Message-ID: <1159560003.29637.45.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47767 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422704AbWI2UAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 16:00:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8TK05go026522
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8TK05e9036214
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8TK04Hw030778
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:05 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider the following 4 SCTP patches for 2.6.19.

Thanks
Sridhar

[SCTP]: Enable Nagle algorithm by default.

This allows more aggressive bundling of chunks when sending small
messages.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 79c3e07..3fe906d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3084,8 +3084,8 @@ SCTP_STATIC int sctp_init_sock(struct so
 	 */
 	sp->disable_fragments = 0;
 
-	/* Turn on/off any Nagle-like algorithm.  */
-	sp->nodelay           = 1;
+	/* Enable Nagle algorithm by default.  */
+	sp->nodelay           = 0;
 
 	/* Enable by default. */
 	sp->v4mapped          = 1;


