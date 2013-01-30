From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 3/8] qlcnic: Free irq for mailbox interrupts
Date: Wed, 30 Jan 2013 17:47:14 -0500
Message-ID: <1359586039-19051-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40493 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932082Ab3A3XIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:20 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e6b363a..987c46d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3215,7 +3215,7 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
-	if (qlcnic_82xx_check(adapter)) {
+	if (qlcnic_83xx_check(adapter)) {
 		if (adapter->flags & QLCNIC_MSIX_ENABLED)
 			qlcnic_83xx_config_intrpt(adapter, 0);
 		qlcnic_83xx_free_mbx_intr(adapter);
-- 
1.7.1
