From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH] iwlwifi: RS small compile warnings without CONFIG_IWLWIFI_DEBUG
Date: Mon, 21 Jul 2008 15:12:26 +0300
Message-ID: <1216642348-26826-1-git-send-email-tomas.winkler@intel.com>
References: <20080721083654.GA19849@elte.hu>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14728 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbYGUMMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 08:12:37 -0400
In-Reply-To: <20080721083654.GA19849@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis V. Lunev <den@openvz.org>

iwl-agn-rs.c: In function 'rs_clear':
iwl-agn-rs.c:2405: warning: unused variable 'priv

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 6a4b229..7ddd07d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -2396,6 +2396,7 @@ static void rs_free(void *priv_rate)
 
 static void rs_clear(void *priv_rate)
 {
+#ifdef CONFIG_IWLWIFI_DEBUG
 	struct iwl_priv *priv = (struct iwl_priv *) priv_rate;
 
 	IWL_DEBUG_RATE("enter\n");
@@ -2403,6 +2404,7 @@ static void rs_clear(void *priv_rate)
 	/* TODO - add rate scale state reset */
 
 	IWL_DEBUG_RATE("leave\n");
+#endif /* CONFIG_IWLWIFI_DEBUG */
 }
 
 static void rs_free_sta(void *priv_rate, void *priv_sta)
-- 
1.5.4.1

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

