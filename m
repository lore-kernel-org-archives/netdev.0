From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: Initialize "status" in be_cmd_get_die_temperature()
Date: Tue, 6 Aug 2013 09:27:20 +0530
Message-ID: <1375761441-22343-7-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:17509 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462Ab3HFD4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:56:04 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Uninitialized value was being returned in the non-failure case.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9f04dac..1e0a05d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1532,7 +1532,7 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_cntl_addnl_attribs *req;
-	int status;
+	int status = 0;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
-- 
1.7.1
