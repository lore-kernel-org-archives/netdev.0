From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 04/30] mwl8k: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:12 +0200
Message-ID: <1405865801-18806-5-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/mwl8k.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 3c0a0a8..9a3d4d6 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1633,22 +1633,17 @@ static int mwl8k_tid_queue_mapping(u8 tid)
 	case 0:
 	case 3:
 		return IEEE80211_AC_BE;
-		break;
 	case 1:
 	case 2:
 		return IEEE80211_AC_BK;
-		break;
 	case 4:
 	case 5:
 		return IEEE80211_AC_VI;
-		break;
 	case 6:
 	case 7:
 		return IEEE80211_AC_VO;
-		break;
 	default:
 		return -1;
-		break;
 	}
 }
 
-- 
1.9.1
