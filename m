From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] rxrpc: Trim line-terminal whitespace [ver #2]
Date: Fri, 10 Jun 2016 14:37:59 +0100
Message-ID: <146556587905.17482.14686239628937102032.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trim line-terminal whitespace in net/rxrpc/

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-input.c |    2 +-
 net/rxrpc/ar-local.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index d7c2a0bc839e..e0815a033999 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -734,7 +734,7 @@ void rxrpc_data_ready(struct sock *sk)
 		rxrpc_post_packet_to_local(local, skb);
 		goto out;
 	}
-	
+
 	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
 	    (sp->hdr.callNumber == 0 || sp->hdr.seq == 0))
 		goto bad_message;
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index 701c42b7050e..111f250b045f 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -388,7 +388,7 @@ static void rxrpc_process_local_events(struct work_struct *work)
 	_enter("");
 
 	atomic_inc(&local->usage);
-	
+
 	while ((skb = skb_dequeue(&local->event_queue))) {
 		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
