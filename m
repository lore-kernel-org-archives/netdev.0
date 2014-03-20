From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e100: Convert uses of __constant_<foo> to <foo>
Date: Thu, 20 Mar 2014 01:32:52 -0700
Message-ID: <1395304385-6874-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8075 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487AbaCTIdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:47 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index bf7a01e..b56461c 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1778,9 +1778,9 @@ static int e100_xmit_prepare(struct nic *nic, struct cb *cb,
 	 * testing, ie sending frames with bad CRC.
 	 */
 	if (unlikely(skb->no_fcs))
-		cb->command |= __constant_cpu_to_le16(cb_tx_nc);
+		cb->command |= cpu_to_le16(cb_tx_nc);
 	else
-		cb->command &= ~__constant_cpu_to_le16(cb_tx_nc);
+		cb->command &= ~cpu_to_le16(cb_tx_nc);
 
 	/* interrupt every 16 packets regardless of delay */
 	if ((nic->cbs_avail & ~15) == nic->cbs_avail)
-- 
1.8.3.1
