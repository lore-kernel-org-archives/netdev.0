From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Update comment for min_mtu
Date: Tue,  3 Oct 2017 11:43:05 +0530
Message-ID: <1507011185-7447-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Arjun Vynipadath <arjun@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:1815 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdJCGNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 02:13:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun Vynipadath <arjun@chelsio.com>

We have lost a comment for minimum mtu value set for netdevice with
'commit d894be57ca92 ("ethernet: use net core MTU range checking in
more drivers"). Updating it accordingly.

Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 13b636b..fe4cbe2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5024,7 +5024,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->priv_flags |= IFF_UNICAST_FLT;
 
 		/* MTU range: 81 - 9600 */
-		netdev->min_mtu = 81;
+		netdev->min_mtu = 81;              /* accommodate SACK */
 		netdev->max_mtu = MAX_MTU;
 
 		netdev->netdev_ops = &cxgb4_netdev_ops;
-- 
2.1.0
