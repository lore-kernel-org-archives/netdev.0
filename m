From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] sock.h: Remove unused NETDEBUG macro
Date: Wed, 05 Nov 2014 15:42:09 -0800
Message-ID: <1415230929.6634.38.camel@perches.com>
References: <1415230568.6634.36.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415230568.6634.36.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's unused now, just delete it.

Signed-off-by: Joe Perches <joe@perches.com>
---

Assuming the 2 NETDEBUG conversion deletion patches are applied...

 include/net/sock.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7db3db1..6767d75 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2280,9 +2280,6 @@ bool sk_net_capable(const struct sock *sk, int cap);
  *	Enable debug/info messages
  */
 extern int net_msg_warn;
-#define NETDEBUG(fmt, args...) \
-	do { if (net_msg_warn) printk(fmt,##args); } while (0)
-
 #define LIMIT_NETDEBUG(fmt, args...) \
 	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)
 
