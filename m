From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 09/14] be2net: remove unused structures in be_cmds.h
Date: Thu, 17 Jul 2014 16:20:27 +0530
Message-ID: <1405594232-30818-10-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9070 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795AbaGQKsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:38 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |   29 ---------------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index a9219a9..03e8a15 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1081,11 +1081,6 @@ struct be_cmd_req_modify_eq_delay {
 	struct be_set_eqd set_eqd[MAX_EVT_QS];
 } __packed;
 
-struct be_cmd_resp_modify_eq_delay {
-	struct be_cmd_resp_hdr hdr;
-	u32 rsvd0;
-} __packed;
-
 /******************** Get FW Config *******************/
 /* The HW can come up in either of the following multi-channel modes
  * based on the skew/IPL.
@@ -1156,11 +1151,6 @@ struct be_cmd_req_enable_disable_beacon {
 	u8  status_duration;
 } __packed;
 
-struct be_cmd_resp_enable_disable_beacon {
-	struct be_cmd_resp_hdr resp_hdr;
-	u32 rsvd0;
-} __packed;
-
 struct be_cmd_req_get_beacon_state {
 	struct be_cmd_req_hdr hdr;
 	u8  port_num;
@@ -1326,11 +1316,6 @@ struct be_cmd_req_set_lmode {
 	u8 loopback_state;
 };
 
-struct be_cmd_resp_set_lmode {
-	struct be_cmd_resp_hdr resp_hdr;
-	u8 rsvd0[4];
-};
-
 /********************** DDR DMA test *********************/
 struct be_cmd_req_ddrdma_test {
 	struct be_cmd_req_hdr hdr;
@@ -1434,11 +1419,6 @@ struct be_cmd_req_set_qos {
 	u32 rsvd[7];
 };
 
-struct be_cmd_resp_set_qos {
-	struct be_cmd_resp_hdr hdr;
-	u32 rsvd;
-};
-
 /*********************** Controller Attributes ***********************/
 struct be_cmd_req_cntl_attribs {
 	struct be_cmd_req_hdr hdr;
@@ -1572,11 +1552,6 @@ struct be_cmd_req_set_hsw_config {
 	u8 context[sizeof(struct amap_set_hsw_context) / 8];
 } __packed;
 
-struct be_cmd_resp_set_hsw_config {
-	struct be_cmd_resp_hdr hdr;
-	u32 rsvd;
-};
-
 struct amap_get_hsw_req_context {
 	u8 interface_id[16];
 	u8 rsvd0[14];
@@ -1966,10 +1941,6 @@ struct be_cmd_req_set_profile_config {
 	u8 desc[2 * RESOURCE_DESC_SIZE_V1];
 } __packed;
 
-struct be_cmd_resp_set_profile_config {
-	struct be_cmd_resp_hdr hdr;
-};
-
 struct be_cmd_req_get_active_profile {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd;
-- 
1.7.1
