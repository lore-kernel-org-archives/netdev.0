From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 02/13] rxrpc: Fix duplicate const
Date: Thu, 06 Oct 2016 11:04:10 +0100
Message-ID: <147574825056.30350.16031428914524233220.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove a duplicate const keyword.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    2 +-
 net/rxrpc/misc.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index d38dffd78085..4954e6e25819 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -777,7 +777,7 @@ extern const char rxrpc_congest_modes[NR__RXRPC_CONGEST_MODES][10];
 extern const char rxrpc_congest_changes[rxrpc_congest__nr_change][9];
 
 extern const char *const rxrpc_pkts[];
-extern const char const rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4];
+extern const char rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4];
 
 #include <trace/events/rxrpc.h>
 
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 9d1c721bc4e8..804a88e28739 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -96,7 +96,7 @@ const s8 rxrpc_ack_priority[] = {
 	[RXRPC_ACK_PING]		= 9,
 };
 
-const char const rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4] = {
+const char rxrpc_ack_names[RXRPC_ACK__INVALID + 1][4] = {
 	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
 	"IDL", "-?-"
 };
