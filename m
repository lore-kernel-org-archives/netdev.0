From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 1/1] qlcnic: fix build error
Date: Thu,  3 Jan 2013 04:10:15 -0500
Message-ID: <1357204215-17607-2-git-send-email-sony.chacko@qlogic.com>
References: <1357204215-17607-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16959 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750955Ab3ACJaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 04:30:04 -0500
In-Reply-To: <1357204215-17607-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix the following error reported by kbuild test robot.
static declaration of 'qlcnic_restore_indev_addr' follows
non-static declaration.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e1a3625..7d13aec 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3299,8 +3299,7 @@ static struct notifier_block qlcnic_inetaddr_cb = {
 	.notifier_call = qlcnic_inetaddr_event,
 };
 #else
-static void
-qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
+void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
 static struct pci_error_handlers qlcnic_err_handler = {
-- 
1.7.1
