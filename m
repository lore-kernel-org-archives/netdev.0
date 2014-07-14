From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 06/16] pktgen: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:30:56 +0200
Message-ID: <1405355467-7350-7-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/pktgen.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fc17a9d..8d77f04 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -802,7 +802,6 @@ static int strn_len(const char __user * user_buffer, unsigned int maxlen)
 		case '\t':
 		case ' ':
 			goto done_str;
-			break;
 		default:
 			break;
 		}
-- 
1.8.4.5
