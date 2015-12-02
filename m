From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: fix confusing message
Date: Wed,  2 Dec 2015 00:25:28 -0800
Message-ID: <1449044735-68599-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757565AbbLBIZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:42 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch fixes the confusing kernel message of enabled RSS size,
by reporting it together with the hardware maximum RSS size.

Change-ID: I64864dbfbc13beccc180a7871680def1f3d5a339
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 508cf9a..4e9d6e5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8110,7 +8110,8 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 
 		i40e_pf_config_rss(pf);
 	}
-	dev_info(&pf->pdev->dev, "RSS count:  %d\n", pf->alloc_rss_size);
+	dev_info(&pf->pdev->dev, "RSS count/HW max RSS count:  %d/%d\n",
+		 pf->alloc_rss_size, pf->rss_size_max);
 	return pf->alloc_rss_size;
 }
 
-- 
2.5.0
