From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 1/3] net: bcmgenet: set hw_params->rx_queues = 0
Date: Thu,  5 Mar 2015 17:40:10 -0800 (PST)
Message-ID: <20150306014010.D365B2214B6@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34477 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbbCFBkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 20:40:12 -0500
Received: by igqa13 with SMTP id a13so107640igq.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 17:40:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet driver doesn't yet support multiple Rx queues.
Set hw_params->rx_queues = 0 accordingly.
The default Rx queue (Q16) is still created and operational.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9137187..f56553b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2500,7 +2500,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	[GENET_V2] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
-		.rx_queues = 4,
+		.rx_queues = 0,
 		.bp_in_en_shift = 16,
 		.bp_in_mask = 0xffff,
 		.hfb_filter_cnt = 16,
@@ -2516,7 +2516,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	[GENET_V3] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
-		.rx_queues = 4,
+		.rx_queues = 0,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
@@ -2532,7 +2532,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	[GENET_V4] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
-		.rx_queues = 4,
+		.rx_queues = 0,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
-- 
2.2.0.rc0.207.ga3a616c
