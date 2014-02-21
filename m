From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/7] qlcnic: Enhance driver message in failed state.
Date: Fri, 21 Feb 2014 13:20:12 -0500
Message-ID: <1393006816-20294-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:58643 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755269AbaBUSzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 13:55:46 -0500
In-Reply-To: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 964ba45..a335472 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2450,8 +2450,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		if (err) {
 			switch (err) {
 			case -ENOTRECOVERABLE:
-				dev_err(&pdev->dev, "Adapter initialization failed due to a faulty hardware. Please reboot\n");
-				dev_err(&pdev->dev, "If reboot doesn't help, please replace the adapter with new one and return the faulty adapter for repair\n");
+				dev_err(&pdev->dev, "Adapter initialization failed due to a faulty hardware\n");
+				dev_err(&pdev->dev, "Please replace the adapter with new one and return the faulty adapter for repair\n");
 				goto err_out_free_hw;
 			case -ENOMEM:
 				dev_err(&pdev->dev, "Adapter initialization failed. Please reboot\n");
-- 
1.8.1.4
