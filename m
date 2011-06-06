From: Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
Subject: [PATCH] iwlwifi: remove unecessary if statement
Date: Sun,  5 Jun 2011 19:30:11 -0500
Message-ID: <1307320211-31371-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

the code always returns ret regardless, so if(ret) check is unecessary.

Signed-off-by: Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index a95ad84..e40ad23 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -163,9 +163,6 @@ static int iwlagn_send_rxon_assoc(struct iwl_priv *priv,
 
 	ret = iwl_send_cmd_pdu_async(priv, ctx->rxon_assoc_cmd,
 				     sizeof(rxon_assoc), &rxon_assoc, NULL);
-	if (ret)
-		return ret;
