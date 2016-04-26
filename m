From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/8] cxgb4: Add llseek operation for flash debugfs entry
Date: Tue, 26 Apr 2016 20:10:23 +0530
Message-ID: <1461681629-28275-3-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38224 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751919AbcDZOg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:26 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0bb41e9b9b1c..9506c5cd11b9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1572,6 +1572,7 @@ static const struct file_operations flash_debugfs_fops = {
 	.owner   = THIS_MODULE,
 	.open    = mem_open,
 	.read    = flash_read,
+	.llseek  = default_llseek,
 };
 
 static inline void tcamxy2valmask(u64 x, u64 y, u8 *addr, u64 *mask)
-- 
2.3.4
