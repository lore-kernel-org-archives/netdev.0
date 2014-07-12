From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 7/9] wcn36xx: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:46 +0200
Message-ID: <1405188597-2815-8-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 4ab5370..b71d2b3 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -488,7 +488,6 @@ static int wcn36xx_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		wcn36xx_err("Unsupported key cmd 0x%x\n", cmd);
 		ret = -EOPNOTSUPP;
 		goto out;
-		break;
 	}
 
 out:
-- 
1.9.1
