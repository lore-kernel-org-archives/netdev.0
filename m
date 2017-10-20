From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: af_unix: mark expected switch fall-through
Date: Fri, 20 Oct 2017 12:05:30 -0500
Message-ID: <20171020170530.GA19922@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/unix/af_unix.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7f46bab..a9ee634 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -814,6 +814,7 @@ static int unix_create(struct net *net, struct socket *sock, int protocol,
 		 */
 	case SOCK_RAW:
 		sock->type = SOCK_DGRAM;
+		/* fall through */
 	case SOCK_DGRAM:
 		sock->ops = &unix_dgram_ops;
 		break;
-- 
2.7.4
