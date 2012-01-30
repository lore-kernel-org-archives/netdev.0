From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 11/16] ath5k: make ath5k_modparam_no_hw_rfkill_switch real
Date: Mon, 30 Jan 2012 23:00:15 +0100
Message-ID: <1327960820-11867-12-git-send-email-danny.kukawka@bisect.de>
References: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de>
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ath5k-devel@lists.ath5k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make ath5k_modparam_no_hw_rfkill_switch real bool to fix:
'warning: return from incompatible pointer type' compiler warning.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/wireless/ath/ath5k/base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index d366dad..ad2f115 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -80,7 +80,7 @@ static bool modparam_fastchanswitch;
 module_param_named(fastchanswitch, modparam_fastchanswitch, bool, S_IRUGO);
 MODULE_PARM_DESC(fastchanswitch, "Enable fast channel switching for AR2413/AR5413 radios.");
 
-static int ath5k_modparam_no_hw_rfkill_switch;
+static bool ath5k_modparam_no_hw_rfkill_switch;
 module_param_named(no_hw_rfkill_switch, ath5k_modparam_no_hw_rfkill_switch,
 								bool, S_IRUGO);
 MODULE_PARM_DESC(no_hw_rfkill_switch, "Ignore the GPIO RFKill switch state");
-- 
1.7.7.3
