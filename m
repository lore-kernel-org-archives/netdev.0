From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 02/12] be2net: fix sparse warnings in be_cmd_req_port_type{}
Date: Fri, 19 Sep 2014 15:46:52 +0530
Message-ID: <1411121822-25842-3-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbaISKO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:29 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

This patch fixes a sprase warnings regarding endian declarations introduced
by the following commit:

fixes: e36edd9 ("be2net: add ethtool "-m" option support")

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index e86a5ef..b064c50 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1005,8 +1005,8 @@ struct be_cmd_resp_link_status {
 /*    Identifies the type of port attached to NIC     */
 struct be_cmd_req_port_type {
 	struct be_cmd_req_hdr hdr;
-	u32 page_num;
-	u32 port;
+	__le32 page_num;
+	__le32 port;
 };
 
 enum {
-- 
1.7.1
