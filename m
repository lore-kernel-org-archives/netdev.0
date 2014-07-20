From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 12/30] cw1200: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:25:13 +0200
Message-ID: <1405866332-24652-3-git-send-email-fabf@skynet.be>
References: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Solomon Peachy <pizza@shaftnet.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/cw1200/fwio.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/cw1200/fwio.c
index e23d67e..6f1b9aa 100644
--- a/drivers/net/wireless/cw1200/fwio.c
+++ b/drivers/net/wireless/cw1200/fwio.c
@@ -290,7 +290,6 @@ static int config_reg_write(struct cw1200_common *priv, u32 val)
 	case HIF_8601_SILICON:
 	default:
 		return cw1200_reg_write_32(priv, ST90TDS_CONFIG_REG_ID, val);
-		break;
 	}
 	return 0;
 }
-- 
1.9.1
