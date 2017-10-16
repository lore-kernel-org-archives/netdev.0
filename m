From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: ipx: mark expected switch fall-through
Date: Mon, 16 Oct 2017 16:53:16 -0500
Message-ID: <20171016215316.GA12885@embeddedor.com>
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

 net/ipx/af_ipx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index ac598ec..d21a9d1 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1867,6 +1867,7 @@ static int ipx_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		rc = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
+		/* fall through */
 	case SIOCGIFADDR:
 		rc = ipxitf_ioctl(cmd, argp);
 		break;
-- 
2.7.4
