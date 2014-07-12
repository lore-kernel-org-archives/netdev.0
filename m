From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 6/9] orinoco_usb: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:45 +0200
Message-ID: <1405188597-2815-7-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/orinoco/orinoco_usb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index c90939c..d3cf7c3 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -921,7 +921,6 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
 			retval = -EFAULT;
 		}
 		goto exit;
-		break;
 	}
 	if (ctx->in_rid) {
 		struct ezusb_packet *ans = ctx->buf;
-- 
1.9.1
