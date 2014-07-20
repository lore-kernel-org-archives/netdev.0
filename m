From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 26/30] ucc_geth: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:51 +0200
Message-ID: <1405866475-24754-7-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 36fc429..8ceaf7a 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -2396,7 +2396,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			pr_err("Bad number of Rx threads value\n");
 		return -EINVAL;
-		break;
 	}
 
 	switch (ug_info->numThreadsTx) {
@@ -2419,7 +2418,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			pr_err("Bad number of Tx threads value\n");
 		return -EINVAL;
-		break;
 	}
 
 	/* Calculate rx_extended_features */
-- 
1.9.1
