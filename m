From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 10/12] be2net: remove space after typecasts
Date: Fri, 19 Sep 2014 15:47:00 +0530
Message-ID: <1411121822-25842-11-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755585AbaISKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:31 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch removes unnecessary spaces after typecasts as per checkpatch warnings.
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9ec09a8..48f4be3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -316,7 +316,7 @@ static void be_async_dbg_evt_process(struct be_adapter *adapter,
 				     struct be_mcc_compl *cmp)
 {
 	u8 event_type = 0;
-	struct be_async_event_qnq *evt = (struct be_async_event_qnq *) cmp;
+	struct be_async_event_qnq *evt = (struct be_async_event_qnq *)cmp;
 
 	event_type = (cmp->flags >> ASYNC_EVENT_TYPE_SHIFT) &
 			ASYNC_EVENT_TYPE_MASK;
@@ -956,7 +956,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	if (permanent) {
 		req->permanent = 1;
 	} else {
-		req->if_id = cpu_to_le16((u16) if_handle);
+		req->if_id = cpu_to_le16((u16)if_handle);
 		req->pmac_id = cpu_to_le32(pmac_id);
 		req->permanent = 0;
 	}
@@ -3280,7 +3280,7 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 	if (!status) {
 		struct be_cmd_resp_acpi_wol_magic_config_v1 *resp;
 
-		resp = (struct be_cmd_resp_acpi_wol_magic_config_v1 *) cmd.va;
+		resp = (struct be_cmd_resp_acpi_wol_magic_config_v1 *)cmd.va;
 
 		adapter->wol_cap = resp->wol_settings;
 		if (adapter->wol_cap & BE_WOL_CAP)
@@ -4127,7 +4127,7 @@ int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 {
 	struct be_adapter *adapter = netdev_priv(netdev_handle);
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_hdr *hdr = (struct be_cmd_req_hdr *) wrb_payload;
+	struct be_cmd_req_hdr *hdr = (struct be_cmd_req_hdr *)wrb_payload;
 	struct be_cmd_req_hdr *req;
 	struct be_cmd_resp_hdr *resp;
 	int status;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7e80527..0bed42b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -918,7 +918,7 @@ static bool be_ipv6_exthdr_check(struct sk_buff *skb)
 		if (ip6h->nexthdr != NEXTHDR_TCP &&
 		    ip6h->nexthdr != NEXTHDR_UDP) {
 			struct ipv6_opt_hdr *ehdr =
-				(struct ipv6_opt_hdr *) (skb->data + offset);
+				(struct ipv6_opt_hdr *)(skb->data + offset);
 
 			/* offending pkt: 2nd byte following IPv6 hdr is 0xff */
 			if (ehdr->hdrlen == 0xff)
-- 
1.7.1
