From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] igb: make sensor info static
Date: Tue, 26 Mar 2013 03:42:33 -0700
Message-ID: <1364294554-7967-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30723 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759698Ab3CZKmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:42:39 -0400
In-Reply-To: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Trivial sparse warning.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_hwmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 4623502..0478a1a 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -39,7 +39,7 @@
 #include <linux/pci.h>
 
 #ifdef CONFIG_IGB_HWMON
-struct i2c_board_info i350_sensor_info = {
+static struct i2c_board_info i350_sensor_info = {
 	I2C_BOARD_INFO("i350bb", (0Xf8 >> 1)),
 };
 
-- 
1.7.11.7
