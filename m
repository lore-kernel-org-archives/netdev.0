From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 3/4] be2net: Modified PCI MaxReadReq size to 4096 bytes
Date: Fri, 30 Sep 2011 22:54:28 +0530
Message-ID: <6470f296-1002-4943-bb9d-b398f31f00b1@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:10230 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758448Ab1I3MBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:01:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1a7b24c..816ce56 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2529,6 +2529,8 @@ static int be_setup(struct be_adapter *adapter)
 	adapter->link_speed = -1;
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
+
+	pcie_set_readrq(adapter->pdev, 4096);
 	return 0;
 
 rx_qs_destroy:
-- 
1.5.6.1
