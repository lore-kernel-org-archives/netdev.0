From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/1] qlcnic: Fix sparse warning.
Date: Tue, 3 Sep 2013 05:07:37 -0400
Message-ID: <1378199257-9514-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:12155 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932313Ab3ICJgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 05:36:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes warning "warning: symbol 'qlcnic_set_dcb_ops' was
not declared. Should it be static?"

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index 2e10e79..d62d5ce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -248,7 +248,7 @@ static inline void __qlcnic_init_dcbnl_ops(struct qlcnic_adapter *adapter)
 		adapter->netdev->dcbnl_ops = &qlcnic_dcbnl_ops;
 }
 
-void qlcnic_set_dcb_ops(struct qlcnic_adapter *adapter)
+static void qlcnic_set_dcb_ops(struct qlcnic_adapter *adapter)
 {
 	if (qlcnic_82xx_check(adapter))
 		adapter->dcb->ops = &qlcnic_82xx_dcb_ops;
-- 
1.8.1.4
