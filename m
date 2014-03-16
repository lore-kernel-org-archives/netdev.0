From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] i40e: fix function kernel doc description
Date: Sun, 16 Mar 2014 15:41:15 -0600
Message-ID: <1395006075-10919-1-git-send-email-sakiwit@gmail.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:59570 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbaCPVoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 17:44:46 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so4749256pdj.37
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 14:44:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit c7d05ca89f8e ("i40e: driver ethtool core") introduced the
new function i40e_add_del_fdir_sctpv4() with the kernel doc
description a little bit off. The trivial error was copied over to a
different file by the commit 17a73f6b1401 ("i40e: Flow Director
sideband accounting") most recently. Fix the kernel doc with the
correct description for clarity.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 88666adb0743..a53c4bcada79 100644
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
