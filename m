From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 2/2] Blackfin EMAC Driver: delete unused variables to fixup gcc warnings
Date: Wed, 26 Mar 2008 18:21:58 -0700
Message-ID: <1206580918-24720-3-git-send-email-cooloney@kernel.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:64665 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674AbYCZKV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 06:21:58 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>

Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c993a32..26b2dd5 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -575,7 +575,6 @@ adjust_head:
 static int bf537mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
 	unsigned int data;
 
 	current_tx_ptr->skb = skb;
@@ -634,7 +633,6 @@ out:
 static void bf537mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
-	struct bf537mac_local *lp = netdev_priv(dev);
 	unsigned short len;
 
 	/* allocate a new skb for next time receive */
-- 
1.5.4.3
