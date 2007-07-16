From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/7][ATM]: Eliminate dead config variable CONFIG_BR2684_FAST_TRANS.
Date: Mon, 16 Jul 2007 12:29:58 -0400
Message-ID: <200707161629.l6GGTwPf009267@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758192AbXGPREn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: Eliminate dead config variable CONFIG_BR2684_FAST_TRANS.

From: Robert P. J. Day <rpjday@mindspring.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit 6bab08f73e2c24665a523f15a4ebe4002be38a91
tree 2c6d28e064934b097f37b3b766900b7bb77264b4
parent ffc2850a65ef863fe52650e5e1bc7ac3e098bbb8
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 11 Jul 2007 12:19:31 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 11 Jul 2007 12:19:31 -0400

 net/atm/br2684.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index faa6aaf..c0f6861 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -460,11 +460,7 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	skb_pull(skb, plen);
 	skb_set_mac_header(skb, -ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
-#ifdef CONFIG_BR2684_FAST_TRANS
-	skb->protocol = ((u16 *) skb->data)[-1];
-#else				/* some protocols might require this: */
 	skb->protocol = br_type_trans(skb, net_dev);
-#endif /* CONFIG_BR2684_FAST_TRANS */
 #else
 	skb_pull(skb, plen - ETH_HLEN);
 	skb->protocol = eth_type_trans(skb, net_dev);
