From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH net-next 1/2] fs_enet: silence a build warning (unused variable)
Date: Thu, 22 Aug 2013 21:55:12 +0200
Message-ID: <1377201313-10420-1-git-send-email-agust@denx.de>
Cc: davem@davemloft.net, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, Gerhard Sittig <gsi@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45122 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438Ab3HVTzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Sittig <gsi@denx.de>

Since commit 720a43efd30f04a0a492c85fb997361c44fbae05
(drivers:net: Remove unnecessary OOM messages after netdev_alloc_skb)
there is a build warning:

drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c: In function 'tx_skb_align_workaround':
drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c:586:26: warning: unused variable 'fep'

Fix it.

Signed-off-by: Gerhard Sittig <gsi@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 8de53a1..c04eb3a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -583,7 +583,6 @@ static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
 					       struct sk_buff *skb)
 {
 	struct sk_buff *new_skb;
-	struct fs_enet_private *fep = netdev_priv(dev);
 
 	/* Alloc new skb */
 	new_skb = netdev_alloc_skb(dev, skb->len + 4);
-- 
1.7.9.5
