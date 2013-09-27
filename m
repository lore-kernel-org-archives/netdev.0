From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 2/7] be2net: Fix the size of be_nic_res_desc structure
Date: Fri, 27 Sep 2013 15:17:31 -0500
Message-ID: <20130927201731.GA4531@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14690 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088Ab3I0URd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:17:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Size of be_nic_res_desc structure is incorrect. Fix it.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index d026226..51a93bd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1791,7 +1791,7 @@ struct be_nic_res_desc {
 	u8 acpi_params;
 	u8 wol_param;
 	u16 rsvd7;
-	u32 rsvd8[3];
+	u32 rsvd8[7];
 } __packed;
 
 struct be_cmd_req_get_func_config {
-- 
1.8.1.2
