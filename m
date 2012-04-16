From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH net-next] atl1: remove unused member from atl1_adapter structure
Date: Mon, 16 Apr 2012 11:27:29 +0400
Message-ID: <1334561249-84277-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:50422 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab2DPH1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 03:27:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index b1fb209..3bf79a5 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -763,7 +763,6 @@ struct atl1_adapter {
 	u16 link_duplex;
 	spinlock_t lock;
 	struct napi_struct napi;
-	struct work_struct tx_timeout_task;
 	struct work_struct reset_dev_task;
 	struct work_struct link_chg_task;
 
-- 
1.7.1
