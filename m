From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 06/11] net: ipv6: set the length parameter of rawv6_send_hdrinc() to size_t
Date: Fri, 23 Oct 2015 14:10:31 +0200
Message-ID: <1445602236-24130-7-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

length is used in operation/function that wait for unsigned value.
Furthermore the only one call of rawv6_send_hdrinc() give a size_t as
length arguments.
So the parameter need to be set as size_t.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/ipv6/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fdbada156..5d9404b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -609,7 +609,7 @@ out:
 	return err;
 }
 
-static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
+static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, size_t length,
 			struct flowi6 *fl6, struct dst_entry **dstp,
 			unsigned int flags)
 {
-- 
2.4.10
