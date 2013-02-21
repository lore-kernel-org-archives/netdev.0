From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net PATCH 2/3] qlcnic: Fix configure interrupts for 83xx adapter types
Date: Thu, 21 Feb 2013 16:09:47 -0500
Message-ID: <1361480988-12829-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361480988-12829-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19207 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752230Ab3BUVbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 16:31:37 -0500
In-Reply-To: <1361480988-12829-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index c53832b..5c033f2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -589,13 +589,6 @@ static int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *adapter)
 	qlcnic_83xx_register_nic_idc_func(adapter, 1);
 
 	qlcnic_83xx_enable_mbx_intrpt(adapter);
-	if ((adapter->flags & QLCNIC_MSIX_ENABLED)) {
-		if (qlcnic_83xx_config_intrpt(adapter, 1)) {
-			netdev_err(adapter->netdev,
-				   "Failed to enable mbx intr\n");
-			return -EIO;
-		}
-	}
 
 	if (qlcnic_83xx_configure_opmode(adapter)) {
 		qlcnic_83xx_idc_enter_failed_state(adapter, 1);
-- 
1.7.6.rc1.1.g2c162b
