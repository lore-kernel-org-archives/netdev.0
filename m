From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 08/10] net: wireless: brcm80211: Remove unneeded variable which return 0
Date: Wed, 28 Oct 2015 00:32:43 +0530
Message-ID: <1445972565-14963-8-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is patch to the brcmsmac/main.c that removes unnecessary variable
which was declared to return zero.

This patch fixes up warning reported by coccicheck:
-Unneeded variable: "err". Return "0" on line 3788

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 9728be0..9d717b6 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -3777,7 +3777,6 @@ static void brcms_c_set_ps_ctrl(struct brcms_c_info *wlc)
  */
 static int brcms_c_set_mac(struct brcms_bss_cfg *bsscfg)
 {
-	int err = 0;
 	struct brcms_c_info *wlc = bsscfg->wlc;
 
 	/* enter the MAC addr into the RXE match registers */
@@ -3785,7 +3784,7 @@ static int brcms_c_set_mac(struct brcms_bss_cfg *bsscfg)
 
 	brcms_c_ampdu_macaddr_upd(wlc);
 
-	return err;
+	return 0;
 }
 
 /* Write the BSS config's BSSID address to core (set_bssid in d11procs.tcl).
-- 
2.5.3
