From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 7/8] qlcnic: make pci_error_handlers const
Date: Wed, 30 Jan 2013 17:47:18 -0500
Message-ID: <1359586039-19051-8-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23836 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757228Ab3A3XIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:31 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 987c46d..f3deef0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3395,7 +3395,7 @@ static struct notifier_block qlcnic_inetaddr_cb = {
 void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
-static struct pci_error_handlers qlcnic_err_handler = {
+static const struct pci_error_handlers qlcnic_err_handler = {
 	.error_detected = qlcnic_io_error_detected,
 	.slot_reset = qlcnic_io_slot_reset,
 	.resume = qlcnic_io_resume,
-- 
1.7.1
