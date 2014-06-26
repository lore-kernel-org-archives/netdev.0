From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40evf: fix typo
Date: Thu, 26 Jun 2014 05:13:44 -0700
Message-ID: <1403784834-23301-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10401 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757580AbaFZMO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:29 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Correct a missing word in a log message.

Change-ID: Id94da7d9f842382d073b3947e0b616503e2f8e91
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 36b1ad7..7138ab4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2022,7 +2022,7 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		err = i40evf_send_vf_config_msg(adapter);
 		if (err) {
-			dev_err(&pdev->dev, "Unable send config request (%d)\n",
+			dev_err(&pdev->dev, "Unable to send config request (%d)\n",
 				err);
 			goto err;
 		}
-- 
1.9.3
