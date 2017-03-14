From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40evf: fix client warnings
Date: Tue, 14 Mar 2017 15:32:56 -0700
Message-ID: <20170314223308.53451-2-jeffrey.t.kirsher@intel.com>
References: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
Cc: Faisal Latif <faisal.latif@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:12644 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751934AbdCNWdR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 18:33:17 -0400
In-Reply-To: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Faisal Latif <faisal.latif@intel.com>

The function prototype in i40evf_client.h are giving warnings while
compiling i40iwvf module. Move these function prototypes to i40evf.h.
Also fix return code from u32 to int and this return code is
consistent with i40e_client.h

Change-Id: Ie3757f844993aabc27654aaf02ec14fb985ad2c4
Signed-off-by: Faisal Latif <faisal.latif@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 00c42d803276..f16d9d1ec403 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -337,4 +337,11 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				enum i40e_virtchnl_ops v_opcode,
 				i40e_status v_retval, u8 *msg, u16 msglen);
 int i40evf_config_rss(struct i40evf_adapter *adapter);
+int i40evf_lan_add_device(struct i40evf_adapter *adapter);
+int i40evf_lan_del_device(struct i40evf_adapter *adapter);
+void i40evf_client_subtask(struct i40evf_adapter *adapter);
+void i40evf_notify_client_message(struct i40e_vsi *vsi, u8 *msg, u16 len);
+void i40evf_notify_client_l2_params(struct i40e_vsi *vsi);
+void i40evf_notify_client_open(struct i40e_vsi *vsi);
+void i40evf_notify_client_close(struct i40e_vsi *vsi);
 #endif /* _I40EVF_H_ */
-- 
2.12.0
