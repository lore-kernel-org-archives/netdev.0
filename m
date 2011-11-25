From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 4/4] NET: NETROM: Fix formatting.
Date: Fri, 25 Nov 2011 09:54:10 +0000
Message-ID: <0047a7876bd8f7b9bc5dbf87792785ce75010eab.1322214950.git.ralf@linux-mips.org>
References: <cover.1322214950.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Thomas Osterried <thomas@osterried.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux coding style wants the return statement on its own line.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 net/netrom/af_netrom.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 732152f..c329b47 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1244,7 +1244,8 @@ static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCADDRT:
 	case SIOCDELRT:
 	case SIOCNRDECOBS:
-		if (!capable(CAP_NET_ADMIN)) return -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		return nr_rt_ioctl(cmd, argp);
 
 	default:
-- 
1.7.4.4

