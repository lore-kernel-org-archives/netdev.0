From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Explicitly clear the reserved field in the Tx Descriptor
Date: Mon, 25 Jun 2012 11:10:55 +0530
Message-ID: <2e516a7a-4f2f-4c4e-bb42-ff14f0088e26@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:53043 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab2FYFpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 01:45:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5a34503..21e0b5b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -558,6 +558,7 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 	wrb->frag_pa_hi = upper_32_bits(addr);
 	wrb->frag_pa_lo = addr & 0xFFFFFFFF;
 	wrb->frag_len = len & ETH_WRB_FRAG_LEN_MASK;
+	wrb->rsvd0 = 0;
 }
 
 static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
-- 
1.5.6.1
