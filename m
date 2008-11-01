From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH/2] nets: fix problem of return value
Date: Sat, 1 Nov 2008 18:18:35 +0800
Message-ID: <20081101101835.GG6556@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753121AbYKAKSp@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


fix problem of return value

net/unix/af_unix.c: unix_net_init()
when error appears, it should return 'error', not always return 0.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/unix/af_unix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0b80634..7d2e4f8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2212,7 +2212,7 @@ static int unix_net_init(struct net *net)
 #endif
 	error = 0;
 out:
-	return 0;
+	return error;
 }
 
 static void unix_net_exit(struct net *net)
-- 
1.5.6.3
