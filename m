From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40evf/virtchnl: whitespace cleanups
Date: Thu,  1 Jun 2017 14:38:34 -0700
Message-ID: <20170601213840.36286-9-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:62051 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751196AbdFAVjC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:39:02 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch fixes up a bunch of whitespace issues introduced
by the previous automated change of name from i40e to virtchnl.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 12 ++++--------
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c |  3 +--
 include/linux/avf/virtchnl.h                        |  6 +++---
 3 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 61f948c587ad..422cccf0de86 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1485,8 +1485,7 @@ static int i40e_vc_get_version_msg(struct i40e_vf *vf, u8 *msg)
 		info.minor = VIRTCHNL_VERSION_MINOR_NO_VF_CAPS;
 	return i40e_vc_send_msg_to_vf(vf, VIRTCHNL_OP_VERSION,
 				      I40E_SUCCESS, (u8 *)&info,
-				      sizeof(struct
-					     virtchnl_version_info));
+				      sizeof(struct virtchnl_version_info));
 }
 
 /**
@@ -1544,11 +1543,9 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	} else {
 		if ((pf->flags & I40E_FLAG_RSS_AQ_CAPABLE) &&
 		    (vf->driver_caps & VIRTCHNL_VF_OFFLOAD_RSS_AQ))
-			vfres->vf_offload_flags |=
-					VIRTCHNL_VF_OFFLOAD_RSS_AQ;
+			vfres->vf_offload_flags |= VIRTCHNL_VF_OFFLOAD_RSS_AQ;
 		else
-			vfres->vf_offload_flags |=
-					VIRTCHNL_VF_OFFLOAD_RSS_REG;
+			vfres->vf_offload_flags |= VIRTCHNL_VF_OFFLOAD_RSS_REG;
 	}
 
 	if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE) {
@@ -2530,8 +2527,7 @@ static int i40e_vc_set_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	/* send the response to the VF */
 err:
-	return i40e_vc_send_resp_to_vf(vf, VIRTCHNL_OP_SET_RSS_HENA,
-				       aq_ret);
+	return i40e_vc_send_resp_to_vf(vf, VIRTCHNL_OP_SET_RSS_HENA, aq_ret);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 90a17b0347b9..d9f040900373 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -1018,8 +1018,7 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				~(BIT(VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP));
 		break;
 	case VIRTCHNL_OP_GET_RSS_HENA_CAPS: {
-		struct virtchnl_rss_hena *vrh =
-			(struct virtchnl_rss_hena *)msg;
+		struct virtchnl_rss_hena *vrh = (struct virtchnl_rss_hena *)msg;
 		if (msglen == sizeof(*vrh))
 			adapter->hena = vrh->hena;
 		else
diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index f1cc1f02036e..73970bd439fe 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -175,10 +175,10 @@ struct virtchnl_vsi_resource {
 #define VIRTCHNL_VF_OFFLOAD_IWARP		0x00000002
 #define VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
 #define VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
-#define VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
-#define VIRTCHNL_VF_OFFLOAD_WB_ON_ITR	0x00000020
+#define VIRTCHNL_VF_OFFLOAD_RSS_REG		0x00000010
+#define VIRTCHNL_VF_OFFLOAD_WB_ON_ITR		0x00000020
 #define VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
-#define VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
+#define VIRTCHNL_VF_OFFLOAD_RX_POLLING		0x00020000
 #define VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
 #define VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
 #define VIRTCHNL_VF_OFFLOAD_ENCAP		0X00100000
-- 
2.12.2
