From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbe: Start temperature sensor attribute index with 1
Date: Tue, 17 Dec 2013 22:44:40 -0800
Message-ID: <1387349082-18506-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3472 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab3LRGpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:45:04 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Per hwmon ABI, temperature sensor attribute index starts with 1, not 0.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Jean Delvare <khali@linux-fr.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index 3081974..e74ae36 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -118,22 +118,22 @@ static int ixgbe_add_hwmon_attr(struct ixgbe_adapter *adapter,
 	case IXGBE_HWMON_TYPE_LOC:
 		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_location;
 		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
-			 "temp%u_label", offset);
+			 "temp%u_label", offset + 1);
 		break;
 	case IXGBE_HWMON_TYPE_TEMP:
 		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_temp;
 		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
-			 "temp%u_input", offset);
+			 "temp%u_input", offset + 1);
 		break;
 	case IXGBE_HWMON_TYPE_CAUTION:
 		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_cautionthresh;
 		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
-			 "temp%u_max", offset);
+			 "temp%u_max", offset + 1);
 		break;
 	case IXGBE_HWMON_TYPE_MAX:
 		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_maxopthresh;
 		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
-			 "temp%u_crit", offset);
+			 "temp%u_crit", offset + 1);
 		break;
 	default:
 		rc = -EPERM;
-- 
1.8.3.1
