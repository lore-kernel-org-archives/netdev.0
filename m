From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] iwlwifi: fix iwl1000 "RTS/CTS for HT" merge damage
Date: Wed, 11 Nov 2009 15:48:26 -0500
Message-ID: <1257972506-14524-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46632 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759030AbZKKVAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:00:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I may have botched my merge conflict resolution instructions for Dave...

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/iwlwifi/iwl-1000.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index 1e387b9..8f82537 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -170,6 +170,7 @@ struct iwl_cfg iwl1000_bgn_cfg = {
 	.shadow_ram_support = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.support_ct_kill_exit = true,
 };
-- 
1.6.2.5

