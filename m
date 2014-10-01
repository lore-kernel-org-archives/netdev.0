From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] tcp: add __init to tcp_init_mem
Date: Wed,  1 Oct 2014 18:27:50 +0200
Message-ID: <1412180870-7599-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp_init_mem is only called by __init tcp_init.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/tcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf5e508..5c17034 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3172,7 +3172,7 @@ static int __init set_thash_entries(char *str)
 }
 __setup("thash_entries=", set_thash_entries);
 
-static void tcp_init_mem(void)
+static void __init tcp_init_mem(void)
 {
 	unsigned long limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
-- 
1.9.3
