From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Fix queue allocation for 40G adapter
Date: Wed, 14 Jan 2015 17:58:10 +0530
Message-ID: <1421238490-26590-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22474 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752439AbbANMWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 07:22:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 2215d43..a936ee8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2430,7 +2430,7 @@ static void cfg_queues(struct adapter *adapter)
 	 */
 	n10g = 0;
 	for_each_port(adapter, pidx)
-		n10g += is_10g_port(&adap2pinfo(adapter, pidx)->link_cfg);
+		n10g += is_x_10g_port(&adap2pinfo(adapter, pidx)->link_cfg);
 
 	/*
 	 * We default to 1 queue per non-10G port and up to # of cores queues
-- 
1.7.1
