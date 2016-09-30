From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/7] rxrpc: Remove error from struct rxrpc_skb_priv
 as it is unused
Date: Fri, 30 Sep 2016 22:40:46 +0100
Message-ID: <147527164637.28826.8465450126479236164.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove error from struct rxrpc_skb_priv as it is no longer used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index fd64a2bd1072..141c1458e719 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -145,7 +145,6 @@ struct rxrpc_skb_priv {
 	};
 	union {
 		int		remain;		/* amount of space remaining for next write */
-		u32		error;		/* network error code */
 	};
 
 	struct rxrpc_host_header hdr;		/* RxRPC packet header from this packet */
