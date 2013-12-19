From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] netfilter: ipvs: remove the unused variable
Date: Thu, 19 Dec 2013 10:23:37 +0800
Message-ID: <52B258A9.70002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <wensong@linux-vs.org>, <horms@verge.net.au>, <ja@ssi.bg>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:30640 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab3LSCYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:24:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when I built the netfilter, I got that:
net/netfilter/ipvs/ip_vs_sync.c: In function sync_thread_master=92:
net/netfilter/ipvs/ip_vs_sync.c:1640: warning: unused variable =91ret=92

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs=
_sync.c
index f63c238..d258125 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
 			continue;
 		}
 		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
-			int ret =3D __wait_event_interruptible(*sk_sleep(sk),
+			__wait_event_interruptible(*sk_sleep(sk),
 						   sock_writeable(sk) ||
 						   kthread_should_stop());
 			if (unlikely(kthread_should_stop()))
--=20
1.7.12
