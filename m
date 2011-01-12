From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next-2.6] netdev: ucc_geth: Use is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 10:31:01 +0100
Message-ID: <1294824661-10564-1-git-send-email-tklauser@distanz.ch>
Cc: linuxppc-dev@lists.ozlabs.org
To: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:38558 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab1ALJbC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 04:31:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 73a3e0d..715e7b4 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2032,7 +2032,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 			netdev_for_each_mc_addr(ha, dev) {
 				/* Only support group multicast for now.
 				 */
-				if (!(ha->addr[0] & 1))
+				if (!is_multicast_ether_addr(ha->addr))
 					continue;
 
 				/* Ask CPM to run CRC and set bit in
-- 
1.7.0.4

