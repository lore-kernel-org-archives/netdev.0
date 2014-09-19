From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 01/12] be2net: fix a sparse warning in be_cmd_modify_eqd()
Date: Fri, 19 Sep 2014 15:46:51 +0530
Message-ID: <1411121822-25842-2-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaISKO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:29 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch fixes a sparse warning about missing static declaration that was
introduced by the following commit:

fixes: 936767039cdf ("be2net: send a max of 8 EQs to be_cmd_modify_eqd() on Lancer")

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index cd213d9..2874c0b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1783,8 +1783,8 @@ err:
 /* set the EQ delay interval of an EQ to specified value
  * Uses async mcc
  */
-int __be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
-			int num)
+static int __be_cmd_modify_eqd(struct be_adapter *adapter,
+			       struct be_set_eqd *set_eqd, int num)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_modify_eq_delay *req;
-- 
1.7.1
