From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net PATCH 1/3] qlcnic: Fix internal loopback test for 82xx adapter
Date: Thu, 21 Feb 2013 16:09:46 -0500
Message-ID: <1361480988-12829-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361480988-12829-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48465 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752230Ab3BUVbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 16:31:33 -0500
In-Reply-To: <1361480988-12829-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Use correct function to clear loopback mode.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 11c3db6..474b479 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1755,7 +1755,7 @@ static inline int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 
 static inline int qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
-	return adapter->ahw->hw_ops->config_loopback(adapter, mode);
+	return adapter->ahw->hw_ops->clear_loopback(adapter, mode);
 }
 
 static inline int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter,
-- 
1.7.6.rc1.1.g2c162b
