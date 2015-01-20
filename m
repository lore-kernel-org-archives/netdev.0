From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/7] be2net: fail VF link config change via ndo_set_vf_link_state() on BE3/Lancer
Date: Tue, 20 Jan 2015 03:51:45 -0500
Message-ID: <1421743909-14716-4-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:11712 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbbATItH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:07 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

The support for this exists only in skyhawk FW.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fead5c6..9772f49 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4092,7 +4092,7 @@ int be_cmd_set_logical_link_config(struct be_adapter *adapter,
 	int status;
 
 	if (BEx_chip(adapter) || lancer_chip(adapter))
-		return 0;
+		return -EOPNOTSUPP;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
-- 
2.2.0
