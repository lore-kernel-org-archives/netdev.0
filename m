From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] brcmfmac: Remove useless #ifdef DEBUG
Date: Sun, 15 Jan 2012 00:38:41 -0800
Message-ID: <4697932e92a7b100a896e9d9f1d9616ecbec5b94.1326616556.git.joe@perches.com>
References: <cover.1326616556.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1326616556.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This doesn't do anything anymore.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 4ab1023..79230e7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -2039,13 +2039,11 @@ deliver:
 		down(&bus->sdsem);
 	}
 	rxcount = maxframes - rxleft;
-#ifdef DEBUG
 	/* Message if we hit the limit */
 	if (!rxleft)
 		brcmf_dbg(DATA, "hit rx limit of %d frames\n",
 			  maxframes);
 	else
-#endif				/* DEBUG */
 		brcmf_dbg(DATA, "processed %d frames\n", rxcount);
 	/* Back off rxseq if awaiting rtx, update rx_seq */
 	if (bus->rxskip)
-- 
1.7.8.111.gad25c.dirty
