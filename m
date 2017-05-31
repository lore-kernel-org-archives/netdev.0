From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/9] nfp: add missing fall through statements
Date: Wed, 31 May 2017 08:06:44 -0700
Message-ID: <20170531150651.16873-3-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33612 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaPLt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:49 -0400
Received: by mail-pg0-f43.google.com with SMTP id u187so9295450pgb.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:49 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GCC 7 checks for fall through comments, add the two missing ones.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c9a140376621..2bcf3e8330ea 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1687,8 +1687,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 				continue;
 			default:
 				bpf_warn_invalid_xdp_action(act);
+				/* fall through */
 			case XDP_ABORTED:
 				trace_xdp_exception(dp->netdev, xdp_prog, act);
+				/* fall through */
 			case XDP_DROP:
 				nfp_net_rx_give_one(dp, rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
-- 
2.11.0
