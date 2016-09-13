From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/10] rxrpc: The IDLE ACK packet should use
 rxrpc_idle_ack_delay
Date: Tue, 13 Sep 2016 23:21:17 +0100
Message-ID: <147380527707.23135.8884709851761338836.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IDLE ACK packet should use the rxrpc_idle_ack_delay setting when the
timer is set for it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 2b976e789562..61432049869b 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -95,7 +95,7 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 		break;
 
 	case RXRPC_ACK_IDLE:
-		if (rxrpc_soft_ack_delay < expiry)
+		if (rxrpc_idle_ack_delay < expiry)
 			expiry = rxrpc_idle_ack_delay;
 		break;
 
