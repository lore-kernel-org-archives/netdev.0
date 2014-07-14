From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 11/16] ipv6: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:36:34 +0200
Message-ID: <1405355799-7691-2-git-send-email-fabf@skynet.be>
References: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/ipv6_sockglue.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index edb58af..7666cfe 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1158,7 +1158,6 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EFAULT;
 
 		return 0;
-		break;
 	}
 
 	case IPV6_TRANSPARENT:
-- 
1.8.4.5
