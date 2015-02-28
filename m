From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] i40e: Add safety net for switch calling
Date: Sat, 28 Feb 2015 03:29:37 -0800
Message-ID: <1425122989-354-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbbB1L3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:55 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch adds default case to handle unmatched switch calls.

Change-ID: Icd203570a1dc5322c1038f68b98a83195e8ad28c
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 309bd1c..8a9d6a2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1413,6 +1413,8 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 			data += ETH_GSTRING_LEN;
 		}
 		break;
+	default:
+		break;
 	}
 }
 
@@ -1654,6 +1656,8 @@ static int i40e_set_phys_id(struct net_device *netdev,
 	case ETHTOOL_ID_INACTIVE:
 		i40e_led_set(hw, pf->led_status, false);
 		break;
+	default:
+		break;
 	}
 
 	return 0;
-- 
1.9.3
