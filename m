From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/13] rxrpc: The protocol family should be set to PF_RXRPC
 not PF_UNIX
Date: Fri, 04 Mar 2016 16:37:40 +0000
Message-ID: <20160304163740.31057.57686.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the protocol family set in the proto_ops for rxrpc to be PF_RXRPC not
PF_UNIX.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 7bb5cca0ae32..5e810b83269f 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -748,7 +748,7 @@ static int rxrpc_release(struct socket *sock)
  * RxRPC network protocol
  */
 static const struct proto_ops rxrpc_rpc_ops = {
-	.family		= PF_UNIX,
+	.family		= PF_RXRPC,
 	.owner		= THIS_MODULE,
 	.release	= rxrpc_release,
 	.bind		= rxrpc_bind,
