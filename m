From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] igb: Start temperature sensor attribute index with 1
Date: Tue, 10 Dec 2013 02:22:41 -0800
Message-ID: <1386670961-20392-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37547 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800Ab3LJKXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:14 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Per hwmon ABI, temperature sensor attribute index starts with 1, not 0.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Jean Delvare <khali@linux-fr.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_hwmon.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 2e7ef2d..e0af5bc 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -124,22 +124,22 @@ static int igb_add_hwmon_attr(struct igb_adapter *adapter,
 	case IGB_HWMON_TYPE_LOC:
 		igb_attr->dev_attr.show = igb_hwmon_show_location;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_label", offset);
+			 "temp%u_label", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_TEMP:
 		igb_attr->dev_attr.show = igb_hwmon_show_temp;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_input", offset);
+			 "temp%u_input", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_CAUTION:
 		igb_attr->dev_attr.show = igb_hwmon_show_cautionthresh;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_max", offset);
+			 "temp%u_max", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_MAX:
 		igb_attr->dev_attr.show = igb_hwmon_show_maxopthresh;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_crit", offset);
+			 "temp%u_crit", offset + 1);
 		break;
 	default:
 		rc = -EPERM;
-- 
1.8.3.1
