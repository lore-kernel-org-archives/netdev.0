From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 13/30] airo: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:25:14 +0200
Message-ID: <1405866332-24652-4-git-send-email-fabf@skynet.be>
References: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/airo.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 64747d4..c26359d 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -7817,7 +7817,6 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 	case AIRORRID:      ridcode = comp->ridnum;     break;
 	default:
 		return -EINVAL;
-		break;
 	}
 
 	if ((iobuf = kmalloc(RIDSIZE, GFP_KERNEL)) == NULL)
-- 
1.9.1
