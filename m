From: Ivan Vecera <ivecera@redhat.com>
Subject: [net-next PATCH] be2net: remove unused variable 'sge'
Date: Thu, 11 Apr 2013 16:29:11 +0200
Message-ID: <1365690551-14843-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935155Ab3DKO3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 10:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f286ad2..cf9408f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2343,7 +2343,6 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_seeprom_read *req;
-	struct be_sge *sge;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -2354,7 +2353,6 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 		goto err;
 	}
 	req = nonemb_cmd->va;
-	sge = nonembedded_sgl(wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			OPCODE_COMMON_SEEPROM_READ, sizeof(*req), wrb,
-- 
1.8.1.5
