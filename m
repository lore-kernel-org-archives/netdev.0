From: weiyj_lk-9Onoh4P/yGk@public.gmane.org
Subject: [PATCH -next] RDS: TCP: Fix non static symbol warnings
Date: Fri, 17 Jun 2016 18:12:46 +0000
Message-ID: <1466187166-2549-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Fixes the following sparse warnings:

net/rds/tcp.c:59:5: warning:
 symbol 'rds_tcp_min_sndbuf' was not declared. Should it be static?
net/rds/tcp.c:60:5: warning:
 symbol 'rds_tcp_min_rcvbuf' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 net/rds/tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 86187da..49fab0c 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -56,8 +56,8 @@ static int rds_tcp_skbuf_handler(struct ctl_table *ctl, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *fpos);
 
-int rds_tcp_min_sndbuf = SOCK_MIN_SNDBUF;
-int rds_tcp_min_rcvbuf = SOCK_MIN_RCVBUF;
+static int rds_tcp_min_sndbuf = SOCK_MIN_SNDBUF;
+static int rds_tcp_min_rcvbuf = SOCK_MIN_RCVBUF;
 
 static struct ctl_table rds_tcp_sysctl_table[] = {
 #define	RDS_TCP_SNDBUF	0



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
