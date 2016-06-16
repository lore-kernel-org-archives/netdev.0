From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/8] wireless: brcmsmac: fix old-style declaration
Date: Thu, 16 Jun 2016 15:52:09 +0200
Message-ID: <20160616135245.3198419-2-arnd@arndb.de>
References: <20160616135020.3154461-1-arnd@arndb.de>
 <20160616135245.3198419-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Johannes Berg <johannes.berg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135245.3198419-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modern C standards expect the 'static' keyword to come first in a
declaration, and we get a warning for this with "make W=1":

drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c:3353:1: error: 'static' is not at beginning of declaration [-Werror=old-style-declaration]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
index e16ee60639f5..c2a938b59044 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
@@ -3349,8 +3349,8 @@ static void brcms_b_coreinit(struct brcms_c_info *wlc)
 	dma_rxfill(wlc_hw->di[RX_FIFO]);
 }
 
-void
-static brcms_b_init(struct brcms_hardware *wlc_hw, u16 chanspec) {
+static void brcms_b_init(struct brcms_hardware *wlc_hw, u16 chanspec)
+{
 	u32 macintmask;
 	bool fastclk;
 	struct brcms_c_info *wlc = wlc_hw->wlc;
-- 
2.9.0
