From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left
 enabled.
Date: Thu, 07 Apr 2016 17:23:09 +0100
Message-ID: <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable a debugging statement that has been left enabled

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 16d967075eaf..01a017a05f14 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -426,7 +426,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 	int tail = call->acks_tail, old_tail;
 	int win = CIRC_CNT(call->acks_head, tail, call->acks_winsz);
 
-	kenter("{%u,%u},%u", call->acks_hard, win, hard);
+	_enter("{%u,%u},%u", call->acks_hard, win, hard);
 
 	ASSERTCMP(hard - call->acks_hard, <=, win);
 
