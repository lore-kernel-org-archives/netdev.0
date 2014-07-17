From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 04/14] be2net: return -ENOMEM for memory allocation failures
Date: Thu, 17 Jul 2014 16:20:22 +0530
Message-ID: <1405594232-30818-5-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756708AbaGQKsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:33 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 61632f8..bd0cadc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2931,7 +2931,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
 				     GFP_KERNEL);
 	if (cmd.va == NULL)
-		return -1;
+		return -ENOMEM;
 
 	if (enable) {
 		status = pci_write_config_dword(adapter->pdev,
@@ -4586,7 +4586,7 @@ static int be_stats_init(struct be_adapter *adapter)
 	cmd->va = dma_zalloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
 				      GFP_KERNEL);
 	if (cmd->va == NULL)
-		return -1;
+		return -ENOMEM;
 	return 0;
 }
 
-- 
1.7.1
