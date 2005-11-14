From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH] - Fixes sparse warning in ipv6/ipv6_sockglue.c
Date: Mon, 14 Nov 2005 09:54:22 -0200
Message-ID: <20051114095422.5cc4727f.lcapitulino__46890.183518599$1131969693$gmane$org@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The patch below fixes the following sparse warning:

net/ipv6/ipv6_sockglue.c:291:13: warning: Using plain integer as NULL pointer

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

 net/ipv6/ipv6_sockglue.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -287,7 +287,7 @@ int ipv6_setsockopt(struct sock *sk, int
 	{
 		struct ipv6_txoptions *opt;
 		if (optlen == 0)
-			optval = 0;
+			optval = NULL;
 
 		/* hop-by-hop / destination options are privileged option */
 		retv = -EPERM;


-- 
Luiz Fernando N. Capitulino
