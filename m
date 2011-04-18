From: David Miller <davem@davemloft.net>
Subject: [PATCH 28/42] isdn: i4l: isdn_net: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:56 -0700 (PDT)
Message-ID: <20110417.173356.02269787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754020Ab1DRAeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A037024C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'unused' is set but unused in
isdn_net_ciscohdlck_slarp_in().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/i4l/isdn_net.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 2a7d17c..9798811 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1678,7 +1678,6 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 	u32 your_seq;
 	__be32 local;
 	__be32 *addr, *mask;
-	u16 unused;
 
 	if (skb->len < 14)
 		return;
@@ -1722,7 +1721,6 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 		lp->cisco_last_slarp_in = jiffies;
 		my_seq = be32_to_cpup((__be32 *)(p + 0));
 		your_seq = be32_to_cpup((__be32 *)(p + 4));
-		unused = be16_to_cpup((__be16 *)(p + 8));
 		p += 10;
 		lp->cisco_yourseq = my_seq;
 		lp->cisco_mineseen = your_seq;
-- 
1.7.4.3

