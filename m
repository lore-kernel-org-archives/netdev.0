From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix incorrect PFVF CMASK
Date: Wed,  9 Jan 2013 23:12:49 +0530
Message-ID: <1357753369-26471-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20568 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148Ab3AIRru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:47:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With Hard-Wired firmware configuration it was incorrectly provisioning the VFs
Channel Access Rights Mask.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index aa63b66..424f8ed 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4016,8 +4016,7 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 						  VFRES_NEQ, VFRES_NETHCTRL,
 						  VFRES_NIQFLINT, VFRES_NIQ,
 						  VFRES_TC, VFRES_NVI,
-						  FW_PFVF_CMD_CMASK_GET(
-						  FW_PFVF_CMD_CMASK_MASK),
+						  FW_PFVF_CMD_CMASK_MASK,
 						  pfvfres_pmask(
 						  adapter, pf, vf),
 						  VFRES_NEXACTF,
-- 
1.7.1
