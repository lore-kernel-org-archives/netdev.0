From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 07/18] bnx2x: Missing module parameter description
Date: Mon, 02 Mar 2009 19:59:48 +0200
Message-ID: <1236016788.7723.78.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755824AbZCBSAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 07/18] bnx2x: Missing module parameter description

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e0851a7..46e2492 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -72,6 +72,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int multi_mode = 1;
 module_param(multi_mode, int, 0);
+MODULE_PARM_DESC(multi_mode, " Use per-CPU queues");
 
 static int disable_tpa;
 module_param(disable_tpa, int, 0);
-- 
1.5.4.3




