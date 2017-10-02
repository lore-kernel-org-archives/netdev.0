From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] fm10k: add missing fall through comment
Date: Mon,  2 Oct 2017 08:42:30 -0700
Message-ID: <20171002154236.84043-8-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3420 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751741AbdJBPnA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:43:00 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Newer versions of GCC starting with 7 now additionally warn when a case
statement may fall through without an explicit comment mentioning it.
Add such a comment to silence the warning, as this is expected.

Unfortunately the comment must come directly before the next case
statement, so we put it outside the #ifdef. Otherwise, the compiler
cannot properly detect it and thus the warning is displayed regardless.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 9dffaba85ae6..189d52a8a605 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -876,6 +876,7 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 	case IPPROTO_GRE:
 		if (skb->encapsulation)
 			break;
+		/* fall through */
 	default:
 		if (unlikely(net_ratelimit())) {
 			dev_warn(tx_ring->dev,
-- 
2.14.2
