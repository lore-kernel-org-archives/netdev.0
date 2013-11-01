From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] vxlan: Use ERR_CAST inlined function instead of
 ERR_PTR(PTR_ERR(...))
Date: Fri, 01 Nov 2013 13:09:43 +0800
Message-ID: <52733797.3010305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:22144 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab3KAFLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 01:11:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


trivial patch converting ERR_PTR(PTR_ERR()) into ERR_CAST().
No functional changes.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 24260ce..78df8f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2285,7 +2285,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 		sock = create_v4_sock(net, port);
 	if (IS_ERR(sock)) {
 		kfree(vs);
-		return ERR_PTR(PTR_ERR(sock));
+		return ERR_CAST(sock);
 	}
 
 	vs->sock = sock;
-- 
1.8.3.1
