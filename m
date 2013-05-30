From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 6/7] qlcnic: remove redundant D0 power state set
Date: Thu, 30 May 2013 18:26:09 +0800
Message-ID: <1369909569-33096-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-driver@qlogic.com>,
	<netdev@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pci_enable_device() will set device power state to D0,
so it's no need to do it again in qlcnic_attach_func().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index aeb26a8..3585c2c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3219,7 +3219,6 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (err)
 		return err;
 
-	pci_set_power_state(pdev, PCI_D0);
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 
-- 
1.7.1
