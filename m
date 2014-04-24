From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] igb: Cleanups to fix static initialization
Date: Thu, 24 Apr 2014 03:30:56 -0700
Message-ID: <1398335460-4283-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24170 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755864AbaDXKbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:09 -0400
In-Reply-To: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes ERROR:INITIALISED_STATIC from checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 562637a..1926ca1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -213,7 +213,7 @@ static struct notifier_block dca_notifier = {
 static void igb_netpoll(struct net_device *);
 #endif
 #ifdef CONFIG_PCI_IOV
-static unsigned int max_vfs = 0;
+static unsigned int max_vfs;
 module_param(max_vfs, uint, 0);
 MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate per physical function");
 #endif /* CONFIG_PCI_IOV */
-- 
1.9.0
