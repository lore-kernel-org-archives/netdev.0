From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: fix function kernel doc description
Date: Mon, 31 Mar 2014 16:34:53 -0700
Message-ID: <1396308899-20926-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6652 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbaCaXgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:31 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit c7d05ca89f8e ("i40e: driver ethtool core") introduced the
new function i40e_add_del_fdir_sctpv4() with the kernel doc
description a little bit off. The trivial error was copied over to a
different file by the commit 17a73f6b1401 ("i40e: Flow Director
sideband accounting") most recently. Fix the kernel doc with the
correct description for clarity.

Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a329aac..0f5d96a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -299,7 +299,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
  * @raw_packet: the pre-allocated packet buffer for FDir
  * @add: true adds a filter, false removes it
  *
- * Returns 0 if the filters were successfully added or removed
+ * Always returns -EOPNOTSUPP
  **/
 static int i40e_add_del_fdir_sctpv4(struct i40e_vsi *vsi,
 				    struct i40e_fdir_filter *fd_data,
-- 
1.9.0
