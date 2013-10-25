From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/2] net/benet: Make lancer_wait_ready() static
Date: Fri, 25 Oct 2013 16:02:45 +0800
Message-ID: <1382688165-20957-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1382688165-20957-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: sathya.perla@emulex.com, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:55087 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab3JYICz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 04:02:55 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 25 Oct 2013 02:02:54 -0600
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 60527C90042
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 04:02:51 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9P82qei58196184
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 08:02:52 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9P82pqb029625
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 06:02:52 -0200
In-Reply-To: <1382688165-20957-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function needn't to be public, so to make it as static.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index c08fd32..c30ab8f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -522,7 +522,7 @@ static u16 be_POST_stage_get(struct be_adapter *adapter)
 	return sem & POST_STAGE_MASK;
 }
 
-int lancer_wait_ready(struct be_adapter *adapter)
+static int lancer_wait_ready(struct be_adapter *adapter)
 {
 #define SLIPORT_READY_TIMEOUT 30
 	u32 sliport_status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 108ca8a..dd522b0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1983,7 +1983,6 @@ extern int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 					  struct be_dma_mem *cmd,
 					  struct be_fat_conf_params *cfgs);
-extern int lancer_wait_ready(struct be_adapter *adapter);
 extern int lancer_physdev_ctrl(struct be_adapter *adapter, u32 mask);
 extern int lancer_initiate_dump(struct be_adapter *adapter);
 extern bool dump_present(struct be_adapter *adapter);
-- 
1.7.9.5
