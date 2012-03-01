From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: ipt_LOG: add __printf() to sb_add()
Date: Thu, 01 Mar 2012 04:56:59 -0800
Message-ID: <1330606619.2465.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Helps to find format mismatches at compile time

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/netfilter/xt_log.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
index 0dfb34a..7e1544e 100644
--- a/include/net/netfilter/xt_log.h
+++ b/include/net/netfilter/xt_log.h
@@ -6,7 +6,7 @@ struct sbuff {
 };
 static struct sbuff emergency, *emergency_ptr = &emergency;
 
-static int sb_add(struct sbuff *m, const char *f, ...)
+static __printf(2, 3) int sb_add(struct sbuff *m, const char *f, ...)
 {
 	va_list args;
 	int len;


