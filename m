From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 5/5] be2net: remove one useless line
Date: Tue, 22 Mar 2011 12:19:29 +0530
Message-ID: <20602d10-e29e-464d-9995-5668e510d874@exht1.ad.emulex.com>
References: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-2-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-3-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-4-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-5-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5041 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754710Ab1CVGvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:51:11 -0400
In-Reply-To: <1300776569-15586-5-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 8638913..a24fb45 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2330,7 +2330,6 @@ static int be_setup(struct be_adapter *adapter)
 
 	return 0;
 
-	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
-- 
1.6.5.2

