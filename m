From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 4/8] qlcnic: Removed adapter series name from warning messages.
Date: Fri, 2 Aug 2013 23:15:57 -0400
Message-ID: <1375499761-21141-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60074 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713Ab3HCEDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 00:03:24 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index cc78d39..a849446 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2141,7 +2141,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_83xx_check(adapter) && !qlcnic_use_msi_x &&
 	    !!qlcnic_use_msi)
 		dev_warn(&pdev->dev,
-			 "83xx adapter do not support MSI interrupts\n");
+			 "Device does not support MSI interrupts\n");
 
 	err = qlcnic_setup_intr(adapter, 0);
 	if (err) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 56e85f9..5d40045 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -562,7 +562,7 @@ static int qlcnic_sriov_setup_vf(struct qlcnic_adapter *adapter,
 	INIT_LIST_HEAD(&adapter->vf_mc_list);
 	if (!qlcnic_use_msi_x && !!qlcnic_use_msi)
 		dev_warn(&adapter->pdev->dev,
-			 "83xx adapter do not support MSI interrupts\n");
+			 "Device does not support MSI interrupts\n");
 
 	err = qlcnic_setup_intr(adapter, 1);
 	if (err) {
-- 
1.5.6
