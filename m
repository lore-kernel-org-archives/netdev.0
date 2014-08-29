From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Change wording to be more consistent
Date: Fri, 29 Aug 2014 02:30:08 -0700
Message-ID: <1409304620-23251-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006AbaH2JaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:25 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

Change "spoofck" to "spoofchk" to be consistent with as defined in netdev.

Change-ID: I9866d6284cb5f92c8d71dc0776c6d1e71dfb62a5
Signed-off-by: Serey Kong <serey.kong@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bd192b8..2fccd06 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7469,7 +7469,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_rate	= i40e_ndo_set_vf_bw,
 	.ndo_get_vf_config	= i40e_ndo_get_vf_config,
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
-	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofck,
+	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
 #ifdef CONFIG_I40E_VXLAN
 	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index da0f005..4d8fd22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2423,7 +2423,7 @@ error_out:
  *
  * Enable or disable VF spoof checking
  **/
-int i40e_ndo_set_vf_spoofck(struct net_device *netdev, int vf_id, bool enable)
+int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 63e7e0d..0adc61e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -122,7 +122,7 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 int i40e_ndo_get_vf_config(struct net_device *netdev,
 			   int vf_id, struct ifla_vf_info *ivi);
 int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link);
-int i40e_ndo_set_vf_spoofck(struct net_device *netdev, int vf_id, bool enable);
+int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable);
 
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
-- 
1.9.3
