From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] i40e,igb,ixgbe: remove usless return statements
Date: Wed, 14 May 2014 01:54:23 -0700
Message-ID: <1400057663-4578-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6717 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbaENIyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:46 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Remove cases where useless bare return is left at end of function.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 4 ----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ----
 drivers/net/ethernet/intel/igb/igb_main.c       | 1 -
 drivers/net/ethernet/intel/igbvf/ethtool.c      | 1 -
 4 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e399f9b..7e3ad52 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6832,7 +6832,6 @@ static void i40e_vsi_delete(struct i40e_vsi *vsi)
 		return;
 
 	i40e_aq_delete_element(&vsi->back->hw, vsi->seid, NULL);
-	return;
 }
 
 /**
@@ -7572,8 +7571,6 @@ void i40e_veb_release(struct i40e_veb *veb)
 
 	i40e_aq_delete_element(&pf->hw, veb->seid, NULL);
 	i40e_veb_clear(veb);
-
-	return;
 }
 
 /**
@@ -8054,7 +8051,6 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 	}
 
 	pf->queues_left = queues_left;
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6edd581..713aa98 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -690,7 +690,6 @@ static void i40evf_del_vlan(struct i40evf_adapter *adapter, u16 vlan)
 		f->remove = true;
 		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 	}
-	return;
 }
 
 /**
@@ -1238,8 +1237,6 @@ void i40evf_reset_interrupt_capability(struct i40evf_adapter *adapter)
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-
-	return;
 }
 
 /**
@@ -2162,7 +2159,6 @@ err:
 		return; /* do not reschedule */
 	}
 	schedule_delayed_work(&adapter->init_task, HZ * 3);
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bfcda8a..0fbab80 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2139,7 +2139,6 @@ void igb_set_fw_version(struct igb_adapter *adapter)
 		}
 		break;
 	}
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index f58170b..7d4e855 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -119,7 +119,6 @@ static int igbvf_set_settings(struct net_device *netdev,
 static void igbvf_get_pauseparam(struct net_device *netdev,
                                  struct ethtool_pauseparam *pause)
 {
-	return;
 }
 
 static int igbvf_set_pauseparam(struct net_device *netdev,
-- 
1.9.0
