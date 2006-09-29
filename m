From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/4] [SCTP]: Use correct mask when disabling PMTUD.
Date: Fri, 29 Sep 2006 13:00:29 -0700
Message-ID: <1159560030.29637.51.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:53148 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422699AbWI2UAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 16:00:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8TK0VE6027091
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8TK0VsU285608
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8TK0U96032560
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:31 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Use correct mask when disabling PMTUD.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 03f65de..4714882 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -388,7 +388,7 @@ void sctp_icmp_frag_needed(struct sock *
 			 * pmtu discovery on this transport.
 			 */
 			t->pathmtu = SCTP_DEFAULT_MINSEGMENT;
-			t->param_flags = (t->param_flags & ~SPP_HB) |
+			t->param_flags = (t->param_flags & ~SPP_PMTUD) |
 				SPP_PMTUD_DISABLE;
 		} else {
 			t->pathmtu = pmtu;


