From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 5/5] be2net: modify log msg for lack of privilege error
Date: Wed, 29 Aug 2012 12:07:44 +0530
Message-ID: <64311971-1c45-4b28-9e9c-722f249436ba@exht1.ad.emulex.com>
References: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46269 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab2H2G5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:57:04 -0400
In-Reply-To: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7fac97b..fc68ca0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -120,7 +120,7 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 
 		if (compl_status == MCC_STATUS_UNAUTHORIZED_REQUEST) {
 			dev_warn(&adapter->pdev->dev,
-				 "opcode %d-%d is not permitted\n",
+				 "VF is not privileged to issue opcode %d-%d\n",
 				 opcode, subsystem);
 		} else {
 			extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
-- 
1.7.4
