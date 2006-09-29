From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/8][ATM]: [lec] old_close is no longer used
Date: Fri, 29 Sep 2006 12:43:43 -0400
Message-ID: <200609291643.k8TGhh3S025607@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:64988 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161222AbWI2QoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:44:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] old_close is no longer used

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 693b186c2a764f62e017db4b7ed39298831d99e8
tree d054ccd10917693803070634a21481b09361b126
parent cf14c654bcb812dae6ed85075777a19e1e02bee1
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:54:09 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:54:09 -0400

 net/atm/lec_arpc.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
index 3cc2eba..69aeb07 100644
--- a/net/atm/lec_arpc.h
+++ b/net/atm/lec_arpc.h
@@ -24,9 +24,6 @@ struct lec_arp_table {
 	void (*old_recv_push) (struct atm_vcc *vcc, struct sk_buff *skb);
 					/* Push that leads to daemon */
 
-	void (*old_close) (struct atm_vcc *vcc);
-					/* We want to see when this vcc gets closed */
-
 	unsigned long last_used;	/* For expiry */
 	unsigned long timestamp;	/* Used for various timestamping things:
 					 * 1. FLUSH started 
