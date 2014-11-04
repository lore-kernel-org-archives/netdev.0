From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH  net-next v1  09/12] amd-xgbe: Fix a spelling error
Date: Tue, 4 Nov 2014 16:07:29 -0600
Message-ID: <20141104220729.24738.15936.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0140.outbound.protection.outlook.com ([157.56.110.140]:51729
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752263AbaKDWHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:07:34 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the spelling of the word "descriptor" in a couple
of locations.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 6c5a707..ced9f52 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1185,13 +1185,13 @@ static void xgbe_packet_info(struct xgbe_prv_data *pdata,
 	packet->rdesc_count = 0;
 
 	if (xgbe_is_tso(skb)) {
-		/* TSO requires an extra desriptor if mss is different */
+		/* TSO requires an extra descriptor if mss is different */
 		if (skb_shinfo(skb)->gso_size != ring->tx.cur_mss) {
 			context_desc = 1;
 			packet->rdesc_count++;
 		}
 
-		/* TSO requires an extra desriptor for TSO header */
+		/* TSO requires an extra descriptor for TSO header */
 		packet->rdesc_count++;
 
 		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
