From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 9/9] slip: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:48 +0200
Message-ID: <1405188597-2815-10-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/slip/slhc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/slip/slhc.c b/drivers/net/slip/slhc.c
index 1252d9c..079f7ad 100644
--- a/drivers/net/slip/slhc.c
+++ b/drivers/net/slip/slhc.c
@@ -396,7 +396,6 @@ found:
 		   ntohs(cs->cs_ip.tot_len) == hlen)
 			break;
 		goto uncompressed;
-		break;
 	case SPECIAL_I:
 	case SPECIAL_D:
 		/* actual changes match one of our special case encodings --
-- 
1.9.1
