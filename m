From: David Howells <dhowells@redhat.com>
Subject: [PATCH] rxrpc: Replace all unsigned with unsigned int
Date: Wed, 09 Mar 2016 23:22:56 +0000
Message-ID: <20160309232256.18612.76458.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace all "unsigned" types with "unsigned int" types.

Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c      |    2 +-
 net/rxrpc/ar-ack.c        |   12 ++++++------
 net/rxrpc/ar-call.c       |    4 ++--
 net/rxrpc/ar-connection.c |    2 +-
 net/rxrpc/ar-internal.h   |   22 +++++++++++-----------
 net/rxrpc/ar-output.c     |    2 +-
 net/rxrpc/ar-transport.c  |    2 +-
 net/rxrpc/sysctl.c        |   32 ++++++++++++++++----------------
 8 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index a76501757b59..9d935fa5a2a9 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -81,7 +81,7 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 				  struct sockaddr_rxrpc *srx,
 				  int len)
 {
-	unsigned tail;
+	unsigned int tail;
 
 	if (len < sizeof(struct sockaddr_rxrpc))
 		return -EINVAL;
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 20f3f001694e..16d967075eaf 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -23,7 +23,7 @@
  * How long to wait before scheduling ACK generation after seeing a
  * packet with RXRPC_REQUEST_ACK set (in jiffies).
  */
-unsigned rxrpc_requested_ack_delay = 1;
+unsigned int rxrpc_requested_ack_delay = 1;
 
 /*
  * How long to wait before scheduling an ACK with subtype DELAY (in jiffies).
@@ -32,7 +32,7 @@ unsigned rxrpc_requested_ack_delay = 1;
  * all consumed within this time we will send a DELAY ACK if an ACK was not
  * requested to let the sender know it doesn't need to resend.
  */
-unsigned rxrpc_soft_ack_delay = 1 * HZ;
+unsigned int rxrpc_soft_ack_delay = 1 * HZ;
 
 /*
  * How long to wait before scheduling an ACK with subtype IDLE (in jiffies).
@@ -41,7 +41,7 @@ unsigned rxrpc_soft_ack_delay = 1 * HZ;
  * further packets aren't immediately received to decide when to send an IDLE
  * ACK let the other end know that it can free up its Tx buffer space.
  */
-unsigned rxrpc_idle_ack_delay = 0.5 * HZ;
+unsigned int rxrpc_idle_ack_delay = 0.5 * HZ;
 
 /*
  * Receive window size in packets.  This indicates the maximum number of
@@ -49,19 +49,19 @@ unsigned rxrpc_idle_ack_delay = 0.5 * HZ;
  * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
  * packets.
  */
-unsigned rxrpc_rx_window_size = 32;
+unsigned int rxrpc_rx_window_size = 32;
 
 /*
  * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
  * made by gluing normal packets together that we're willing to handle.
  */
-unsigned rxrpc_rx_mtu = 5692;
+unsigned int rxrpc_rx_mtu = 5692;
 
 /*
  * The maximum number of fragments in a received jumbo packet that we tell the
  * sender that we're willing to handle.
  */
-unsigned rxrpc_rx_jumbo_max = 4;
+unsigned int rxrpc_rx_jumbo_max = 4;
 
 static const char *rxrpc_acks(u8 reason)
 {
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 4a499e0100f1..7c8d300ade9b 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -21,12 +21,12 @@
 /*
  * Maximum lifetime of a call (in jiffies).
  */
-unsigned rxrpc_max_call_lifetime = 60 * HZ;
+unsigned int rxrpc_max_call_lifetime = 60 * HZ;
 
 /*
  * Time till dead call expires after last use (in jiffies).
  */
-unsigned rxrpc_dead_call_expiry = 2 * HZ;
+unsigned int rxrpc_dead_call_expiry = 2 * HZ;
 
 const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 53df14cb8d25..9942da1edbf6 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -21,7 +21,7 @@
 /*
  * Time till a connection expires after last use (in seconds).
  */
-unsigned rxrpc_connection_expiry = 10 * 60;
+unsigned int rxrpc_connection_expiry = 10 * 60;
 
 static void rxrpc_connection_reaper(struct work_struct *work);
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8b495aed517d..a3002f4ddc90 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -478,12 +478,12 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * ar-ack.c
  */
-extern unsigned rxrpc_requested_ack_delay;
-extern unsigned rxrpc_soft_ack_delay;
-extern unsigned rxrpc_idle_ack_delay;
-extern unsigned rxrpc_rx_window_size;
-extern unsigned rxrpc_rx_mtu;
-extern unsigned rxrpc_rx_jumbo_max;
+extern unsigned int rxrpc_requested_ack_delay;
+extern unsigned int rxrpc_soft_ack_delay;
+extern unsigned int rxrpc_idle_ack_delay;
+extern unsigned int rxrpc_rx_window_size;
+extern unsigned int rxrpc_rx_mtu;
+extern unsigned int rxrpc_rx_jumbo_max;
 
 void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
@@ -492,8 +492,8 @@ void rxrpc_process_call(struct work_struct *);
 /*
  * ar-call.c
  */
-extern unsigned rxrpc_max_call_lifetime;
-extern unsigned rxrpc_dead_call_expiry;
+extern unsigned int rxrpc_max_call_lifetime;
+extern unsigned int rxrpc_dead_call_expiry;
 extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
@@ -516,7 +516,7 @@ void __exit rxrpc_destroy_all_calls(void);
 /*
  * ar-connection.c
  */
-extern unsigned rxrpc_connection_expiry;
+extern unsigned int rxrpc_connection_expiry;
 extern struct list_head rxrpc_connections;
 extern rwlock_t rxrpc_connection_lock;
 
@@ -579,7 +579,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 /*
  * ar-output.c
  */
-extern unsigned rxrpc_resend_timeout;
+extern unsigned int rxrpc_resend_timeout;
 
 int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
 int rxrpc_client_sendmsg(struct rxrpc_sock *, struct rxrpc_transport *,
@@ -627,7 +627,7 @@ void rxrpc_packet_destructor(struct sk_buff *);
 /*
  * ar-transport.c
  */
-extern unsigned rxrpc_transport_expiry;
+extern unsigned int rxrpc_transport_expiry;
 
 struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
 					    struct rxrpc_peer *, gfp_t);
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 14c8df6b7f41..d36fb6e1a29c 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -21,7 +21,7 @@
 /*
  * Time till packet resend (in jiffies).
  */
-unsigned rxrpc_resend_timeout = 4 * HZ;
+unsigned int rxrpc_resend_timeout = 4 * HZ;
 
 static int rxrpc_send_data(struct rxrpc_sock *rx,
 			   struct rxrpc_call *call,
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 5f9b9d462f53..66a1a5676446 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -20,7 +20,7 @@
 /*
  * Time after last use at which transport record is cleaned up.
  */
-unsigned rxrpc_transport_expiry = 3600 * 24;
+unsigned int rxrpc_transport_expiry = 3600 * 24;
 
 static void rxrpc_transport_reaper(struct work_struct *work);
 
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index 093547ac2bcd..d20ed575acf4 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -15,11 +15,11 @@
 #include "ar-internal.h"
 
 static struct ctl_table_header *rxrpc_sysctl_reg_table;
-static const unsigned zero = 0;
-static const unsigned one = 1;
-static const unsigned four = 4;
-static const unsigned n_65535 = 65535;
-static const unsigned n_max_acks = RXRPC_MAXACKS;
+static const unsigned int zero = 0;
+static const unsigned int one = 1;
+static const unsigned int four = 4;
+static const unsigned int n_65535 = 65535;
+static const unsigned int n_max_acks = RXRPC_MAXACKS;
 
 /*
  * RxRPC operating parameters.
@@ -32,7 +32,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "req_ack_delay",
 		.data		= &rxrpc_requested_ack_delay,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
 		.extra1		= (void *)&zero,
@@ -40,7 +40,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "soft_ack_delay",
 		.data		= &rxrpc_soft_ack_delay,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
 		.extra1		= (void *)&one,
@@ -48,7 +48,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "idle_ack_delay",
 		.data		= &rxrpc_idle_ack_delay,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
 		.extra1		= (void *)&one,
@@ -56,7 +56,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "resend_timeout",
 		.data		= &rxrpc_resend_timeout,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
 		.extra1		= (void *)&one,
@@ -66,7 +66,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "max_call_lifetime",
 		.data		= &rxrpc_max_call_lifetime,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 		.extra1		= (void *)&one,
@@ -74,7 +74,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "dead_call_expiry",
 		.data		= &rxrpc_dead_call_expiry,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 		.extra1		= (void *)&one,
@@ -84,7 +84,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "connection_expiry",
 		.data		= &rxrpc_connection_expiry,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
@@ -92,7 +92,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "transport_expiry",
 		.data		= &rxrpc_transport_expiry,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
@@ -102,7 +102,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "rx_window_size",
 		.data		= &rxrpc_rx_window_size,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
@@ -111,7 +111,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "rx_mtu",
 		.data		= &rxrpc_rx_mtu,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
@@ -120,7 +120,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 	{
 		.procname	= "rx_jumbo_max",
 		.data		= &rxrpc_rx_jumbo_max,
-		.maxlen		= sizeof(unsigned),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
