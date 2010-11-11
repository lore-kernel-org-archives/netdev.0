From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 06/10] cxgb4vf: fix up "Section Mismatch" compiler warning.
Date: Wed, 10 Nov 2010 18:04:08 -0800
Message-ID: <1289441052-4925-6-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29495 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253Ab0KKCEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:21 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up "Section Mismatch" compiler warning and mark another routine as
__devinit.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 75b85ca..b5c0bff 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2032,7 +2032,7 @@ static int __devinit setup_debugfs(struct adapter *adapter)
  * Tear down the /sys/kernel/debug/cxgb4vf sub-nodes created above.  We leave
  * it to our caller to tear down the directory (debugfs_root).
  */
-static void __devexit cleanup_debugfs(struct adapter *adapter)
+static void cleanup_debugfs(struct adapter *adapter)
 {
 	BUG_ON(adapter->debugfs_root == NULL);
 
@@ -2050,7 +2050,7 @@ static void __devexit cleanup_debugfs(struct adapter *adapter)
  * adapter parameters we're going to be using and initialize basic adapter
  * hardware support.
  */
-static int adap_init0(struct adapter *adapter)
+static int __devinit adap_init0(struct adapter *adapter)
 {
 	struct vf_resources *vfres = &adapter->params.vfres;
 	struct sge_params *sge_params = &adapter->params.sge;
-- 
1.7.0.4

