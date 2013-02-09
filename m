From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 7/8] qlcnic: enhance MSIX allocation failure log message
Date: Sat,  9 Feb 2013 14:29:54 -0500
Message-ID: <1360438195-12667-8-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1644 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932528Ab3BITv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 14:51:26 -0500
In-Reply-To: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 30aa1f2..b745194 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -455,12 +455,13 @@ int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 
 			if (num_msix) {
 				dev_info(&pdev->dev,
-					 "Trying %d MSI-X interrupt vectors\n",
+					 "Trying to allocate %d MSI-X interrupt vectors\n",
 					 num_msix);
 				goto enable_msix;
 			}
 		} else {
-			dev_info(&pdev->dev, "Failed to get %d vectors\n",
+			dev_info(&pdev->dev,
+				 "Unable to allocate %d MSI-X interrupt vectors\n",
 				 num_msix);
 		}
 	}
-- 
1.7.1
