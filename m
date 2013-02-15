From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/10] igb: Refix sparse warning in igb_get_i2c_client
Date: Fri, 15 Feb 2013 02:04:03 -0800
Message-ID: <1360922649-3388-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935526Ab3BOKEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:04:15 -0500
In-Reply-To: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch correctly resolves the sparse warnings found with this
function.

v2: revise the fix based on feedback from Ben Hutchings

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c19a35c..bf55972 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7727,7 +7727,7 @@ static DEFINE_SPINLOCK(i2c_clients_lock);
  *  @adapter: adapter struct
  *  @dev_addr: device address of i2c needed.
  */
-struct i2c_client *
+static struct i2c_client *
 igb_get_i2c_client(struct igb_adapter *adapter, u8 dev_addr)
 {
 	ulong flags;
-- 
1.7.11.7
