From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 09/10] net: wireless: brcm80211: Remove unneeded variable ret_code returning 0
Date: Wed, 28 Oct 2015 00:32:44 +0530
Message-ID: <1445972565-14963-9-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the brcmsmac/stf.c that fixes up warning caught by
coccicheck:

-Unneeded variable: "ret_code". Return "0" on line 328

Remove unneccesary variable ret_code created to return zero.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/stf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/stf.c b/drivers/net/wireless/brcm80211/brcmsmac/stf.c
index dd91627..71ddf42 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/stf.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/stf.c
@@ -306,7 +306,6 @@ int brcms_c_stf_txchain_set(struct brcms_c_info *wlc, s32 int_val, bool force)
  */
 int brcms_c_stf_ss_update(struct brcms_c_info *wlc, struct brcms_band *band)
 {
-	int ret_code = 0;
 	u8 prev_stf_ss;
 	u8 upd_stf_ss;
 
@@ -325,7 +324,7 @@ int brcms_c_stf_ss_update(struct brcms_c_info *wlc, struct brcms_band *band)
 				    PHY_TXC1_MODE_SISO : PHY_TXC1_MODE_CDD;
 	} else {
 		if (wlc->band != band)
-			return ret_code;
+			return 0;
 		upd_stf_ss = (wlc->stf->txstreams == 1) ?
 				PHY_TXC1_MODE_SISO : band->band_stf_ss_mode;
 	}
@@ -334,7 +333,7 @@ int brcms_c_stf_ss_update(struct brcms_c_info *wlc, struct brcms_band *band)
 		brcms_b_band_stf_ss_set(wlc->hw, upd_stf_ss);
 	}
 
-	return ret_code;
+	return 0;
 }
 
 int brcms_c_stf_attach(struct brcms_c_info *wlc)
-- 
2.5.3
