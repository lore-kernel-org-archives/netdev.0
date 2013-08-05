From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] net/vmw_vsock/af_vsock.c: drop unneeded semicolon
Date: Mon,  5 Aug 2013 16:47:38 +0200
Message-ID: <1375714059-29567-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Drop the semicolon at the end of the list_for_each_entry loop header.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested, but I can't imagine how the current code could work, since vsk
should end up pointing to a dummy value.

 net/vmw_vsock/af_vsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 593071d..4d93346 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -347,7 +347,7 @@ void vsock_for_each_connected_socket(void (*fn)(struct sock *sk))
 	for (i = 0; i < ARRAY_SIZE(vsock_connected_table); i++) {
 		struct vsock_sock *vsk;
 		list_for_each_entry(vsk, &vsock_connected_table[i],
-				    connected_table);
+				    connected_table)
 			fn(sk_vsock(vsk));
 	}
 

