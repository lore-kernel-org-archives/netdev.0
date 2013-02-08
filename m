From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] igb: Fix for sparse warning in igb_get_i2c_client
Date: Fri,  8 Feb 2013 02:39:12 -0800
Message-ID: <1360319958-10497-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13075 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946187Ab3BHKje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 05:39:34 -0500
In-Reply-To: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes definition of i2c_client in igb_get_i2c_client to static
to prevent sparse warning.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c19a35c..ebf8384 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7732,7 +7732,7 @@ igb_get_i2c_client(struct igb_adapter *adapter, u8 dev_addr)
 {
 	ulong flags;
 	struct igb_i2c_client_list *client_list;
-	struct i2c_client *client = NULL;
+	static struct i2c_client *client;
 	struct i2c_board_info client_info = {
 		I2C_BOARD_INFO("igb", 0x00),
 	};
-- 
1.7.11.7
