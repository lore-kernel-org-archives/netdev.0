From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/9] rxrpc: Static arrays of strings should be const char
 *const[]
Date: Thu, 07 Apr 2016 17:23:23 +0100
Message-ID: <20160407162323.21283.76017.stgit@warthog.procyon.org.uk>
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

Static arrays of strings should be const char *const[].

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h  |    2 --
 net/rxrpc/ar-internal.h |    2 +-
 net/rxrpc/misc.c        |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 9ebab3a8cf0a..b2017440b765 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -68,8 +68,6 @@ struct rxrpc_wire_header {
 
 } __packed;
 
-extern const char *rxrpc_pkts[];
-
 #define RXRPC_SUPPORTED_PACKET_TYPES (			\
 		(1 << RXRPC_PACKET_TYPE_DATA) |		\
 		(1 << RXRPC_PACKET_TYPE_ACK) |		\
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 24126d954f38..eeb829e837e1 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -637,7 +637,7 @@ extern unsigned int rxrpc_rx_window_size;
 extern unsigned int rxrpc_rx_mtu;
 extern unsigned int rxrpc_rx_jumbo_max;
 
-extern const char *rxrpc_pkts[];
+extern const char *const rxrpc_pkts[];
 extern const s8 rxrpc_ack_priority[];
 
 extern const char *rxrpc_acks(u8 reason);
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 8ebeec3384e1..1afe9876e79f 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -58,7 +58,7 @@ unsigned int rxrpc_rx_mtu = 5692;
  */
 unsigned int rxrpc_rx_jumbo_max = 4;
 
-const char *rxrpc_pkts[] = {
+const char *const rxrpc_pkts[] = {
 	"?00",
 	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
 	"?09", "?10", "?11", "?12", "VERSION", "?14", "?15"
