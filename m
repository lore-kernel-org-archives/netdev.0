From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 11/28] net: wireless: ath: ath5k: drop owner assignment from platform_drivers
Date: Sun, 21 Dec 2014 22:14:32 +0100
Message-ID: <1419196495-9626-12-git-send-email-wsa@the-dreams.de>
References: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>, Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform_driver does not need to set an owner, it will be populated by the
driver core.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
Generated with coccinelle. SmPL file is in the introductory msg. The big
cleanup was pulled in this merge window. This series catches the bits fallen
through. The patches shall go in via the subsystem trees.

 drivers/net/wireless/ath/ath5k/ahb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
index 8f387cf67340..2ca88b593e4c 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -227,7 +227,6 @@ static struct platform_driver ath_ahb_driver = {
 	.remove     = ath_ahb_remove,
 	.driver		= {
 		.name	= "ar231x-wmac",
-		.owner	= THIS_MODULE,
 	},
 };
 
-- 
2.1.3
