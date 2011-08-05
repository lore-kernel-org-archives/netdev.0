From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/6] be2net: set wrb.hdr.domain in
 be_cmd_link_status_query
Date: Fri, 5 Aug 2011 14:59:38 -0500
Message-ID: <20110805195938.GA13516@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2931 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756084Ab1HEUAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:00:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 4278595..8d178d2 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1282,6 +1282,8 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
 
+	req->hdr.domain = dom;
+
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
-- 
1.7.4.1

