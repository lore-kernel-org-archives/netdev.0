From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb3: Set FATALPERREN.
Date: Thu,  2 Sep 2010 16:07:30 -0700
Message-ID: <1283468852-1010-2-git-send-email-leedom@chelsio.com>
References: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18929 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab0IBXHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:07:37 -0400
In-Reply-To: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb3/t3_hw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 427c451..14a5664 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3569,6 +3569,7 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 	t3_write_reg(adapter, A_PM1_TX_MODE, 0);
 	chan_init_hw(adapter, adapter->params.chan_map);
 	t3_sge_init(adapter, &adapter->params.sge);
+	t3_set_reg_field(adapter, A_PL_RST, 0, F_FATALPERREN);
 
 	t3_write_reg(adapter, A_T3DBG_GPIO_ACT_LOW, calc_gpio_intr(adapter));
 
-- 
1.7.0.4

