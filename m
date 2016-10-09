From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 5/5] be2net: Enable VF link state setting for BE3
Date: Sun,  9 Oct 2016 09:58:53 +0530
Message-ID: <20161009042853.20601-6-sriharsha.basavapatna@broadcom.com>
References: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1200 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752742AbcJIE3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 00:29:36 -0400
In-Reply-To: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>

The VF link state setting feature now works on BE3 chips too from
FW ver 11.1.192.0 onwards.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7e9be9f4..1fb5d72 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4977,7 +4977,7 @@ int be_cmd_set_logical_link_config(struct be_adapter *adapter,
 {
 	int status;
 
-	if (BEx_chip(adapter))
+	if (BE2_chip(adapter))
 		return -EOPNOTSUPP;
 
 	status = __be_cmd_set_logical_link_config(adapter, link_state,
-- 
2.10.0.478.g3ef7618
