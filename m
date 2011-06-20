From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][Trivial]: ipv4, ping: Remove duplicate icmp.h include
Date: Mon, 20 Jun 2011 10:31:20 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106201028340.18991@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the duplicate inclusion of net/icmp.h from net/ipv4/ping.c

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ping.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 9aaa671..39b403f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -41,7 +41,6 @@
 #include <linux/proc_fs.h>
 #include <net/sock.h>
 #include <net/ping.h>
-#include <net/icmp.h>
 #include <net/udp.h>
 #include <net/route.h>
 #include <net/inet_common.h>

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
