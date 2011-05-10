From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 2/5] be2net: Disable coalesce water mark mode of CQ for Lancer
Date: Tue, 10 May 2011 20:42:37 +0530
Message-ID: <383d86ea-327c-4028-bbba-7c20784c79fc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11252 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755667Ab1EJPNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:13:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable coalesce water mark mode of CQ for Lancer

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_cmds.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0fc06d3..77dc157 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -729,8 +729,6 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	if (lancer_chip(adapter)) {
 		req->hdr.version = 2;
 		req->page_size = 1; /* 1 for 4K */
-		AMAP_SET_BITS(struct amap_cq_context_lancer, coalescwm, ctxt,
-								coalesce_wm);
 		AMAP_SET_BITS(struct amap_cq_context_lancer, nodelay, ctxt,
 								no_delay);
 		AMAP_SET_BITS(struct amap_cq_context_lancer, count, ctxt,
-- 
1.6.0.2

