From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] e100: don't initialize int object to zero
Date: Sat,  2 May 2015 03:42:29 -0700
Message-ID: <1430563358-113833-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39277 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbbEBKmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:45 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

'err' will be overwritten so no need to initialize it to zero.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 1a450f4..35357ae 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -874,7 +874,7 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 {
 	struct cb *cb;
 	unsigned long flags;
-	int err = 0;
+	int err;
 
 	spin_lock_irqsave(&nic->cb_lock, flags);
 
-- 
2.1.0
