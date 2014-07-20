From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 14/30] ath6kl: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:25:15 +0200
Message-ID: <1405866332-24652-5-git-send-email-fabf@skynet.be>
References: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/ath/ath6kl/init.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index d5ef211..8ee7097 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -1187,7 +1187,6 @@ static int ath6kl_upload_board_file(struct ath6kl *ar)
 	default:
 		WARN_ON(1);
 		return -EINVAL;
-		break;
 	}
 
 	if (board_ext_address &&
-- 
1.9.1
