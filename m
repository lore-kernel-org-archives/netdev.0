From: pablo@netfilter.org
Subject: [PATCH 23/23] netfilter: xt_LOG: add __printf() to sb_add()
Date: Thu,  8 Mar 2012 02:01:12 +0100
Message-ID: <1331168472-5820-24-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Helps to find format mismatches at compile time

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/netfilter/xt_log.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.7.7.3

