From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 12/15] net: wireless: brcm80211: Remove unneeded variable which return 0
Date: Wed, 21 Oct 2015 20:25:34 +0530
Message-ID: <1445439337-19055-13-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
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
