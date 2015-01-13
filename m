From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH] tcp: Fix RFC reference in comment
Date: Tue, 13 Jan 2015 16:10:31 -0500
Message-ID: <1421183431-29915-1-git-send-email-dbanerje@akamai.com>
Cc: linux-kernel@vger.kernel.org,
	Debabrata Banerjee <dbanerje@akamai.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comment in tcp_cwnd_restart() was referencing the wrong RFC for the algorithm
it's implementing.

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 65caf8b..0c13f88 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -139,7 +139,7 @@ static __u16 tcp_advertise_mss(struct sock *sk)
 	return (__u16)mss;
 }
 
-/* RFC2861. Reset CWND after idle period longer RTO to "restart window".
+/* RFC2581 4.1. Reset CWND after idle period longer RTO to "restart window".
  * This is the first part of cwnd validation mechanism. */
 static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
 {
-- 
2.2.1
