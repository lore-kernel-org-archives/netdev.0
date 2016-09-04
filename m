From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/3] rxrpc Move enum rxrpc_command to sendmsg.c
Date: Sun, 04 Sep 2016 22:04:34 +0100
Message-ID: <147302307395.28850.17458230830763106900.stgit@warthog.procyon.org.uk>
References: <147302305256.28850.16735273264737276926.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302305256.28850.16735273264737276926.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move enum rxrpc_command to sendmsg.c as it's now only used in that file.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 -------
 net/rxrpc/sendmsg.c     |    7 +++++++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 464dfda2a995..bb342f5fe7e4 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -131,13 +131,6 @@ struct rxrpc_skb_priv {
 
 #define rxrpc_skb(__skb) ((struct rxrpc_skb_priv *) &(__skb)->cb)
 
-enum rxrpc_command {
-	RXRPC_CMD_SEND_DATA,		/* send data message */
-	RXRPC_CMD_SEND_ABORT,		/* request abort generation */
-	RXRPC_CMD_ACCEPT,		/* [server] accept incoming call */
-	RXRPC_CMD_REJECT_BUSY,		/* [server] reject a call as busy */
-};
-
 /*
  * RxRPC security module interface
  */
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 17a9ebbc2346..7376794a0308 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -20,6 +20,13 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+enum rxrpc_command {
+	RXRPC_CMD_SEND_DATA,		/* send data message */
+	RXRPC_CMD_SEND_ABORT,		/* request abort generation */
+	RXRPC_CMD_ACCEPT,		/* [server] accept incoming call */
+	RXRPC_CMD_REJECT_BUSY,		/* [server] reject a call as busy */
+};
+
 /*
  * wait for space to appear in the transmit/ACK window
  * - caller holds the socket locked
