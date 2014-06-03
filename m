From: Luca Ellero <luca.ellero@brickedbrain.com>
Subject: [PATCH] netfilter: nf_conntrack: fix checkpatch errors
Date: Tue,  3 Jun 2014 16:45:02 +0200
Message-ID: <1401806702-3251-1-git-send-email-luca.ellero@brickedbrain.com>
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, coreteam@netfilter.org,
	netdev@vger.kernel.org, Luca Ellero <luca.ellero@brickedbrain.com>
To: netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add parenthesis around complex macros

Signed-off-by: Luca Ellero <luca.ellero@brickedbrain.com>
---
 net/netfilter/nf_conntrack_pptp.c       |    6 +++---
 net/netfilter/nf_conntrack_proto_sctp.c |    8 ++++----
 net/netfilter/nf_conntrack_proto_tcp.c  |    8 ++++----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 825c3e3..a505263 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -92,9 +92,9 @@ const char *const pptp_msg_name[] = {
 EXPORT_SYMBOL(pptp_msg_name);
 #endif
 
-#define SECS *HZ
-#define MINS * 60 SECS
-#define HOURS * 60 MINS
+#define SECS  (*HZ)
+#define MINS  (*60 SECS)
+#define HOURS (*60 MINS)
 
 #define PPTP_GRE_TIMEOUT 		(10 MINS)
 #define PPTP_GRE_STREAM_TIMEOUT 	(5 HOURS)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1314d33..387cda5 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -44,10 +44,10 @@ static const char *const sctp_conntrack_names[] = {
 	"SHUTDOWN_ACK_SENT",
 };
 
-#define SECS  * HZ
-#define MINS  * 60 SECS
-#define HOURS * 60 MINS
-#define DAYS  * 24 HOURS
+#define SECS  (*HZ)
+#define MINS  (*60 SECS)
+#define HOURS (*60 MINS)
+#define DAYS  (*24 HOURS)
 
 static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
 	[SCTP_CONNTRACK_CLOSED]			= 10 SECS,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44d1ea3..6a7d6f8 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -63,10 +63,10 @@ static const char *const tcp_conntrack_names[] = {
 	"SYN_SENT2",
 };
 
-#define SECS * HZ
-#define MINS * 60 SECS
-#define HOURS * 60 MINS
-#define DAYS * 24 HOURS
+#define SECS  (*HZ)
+#define MINS  (*60 SECS)
+#define HOURS (*60 MINS)
+#define DAYS  (*24 HOURS)
 
 static unsigned int tcp_timeouts[TCP_CONNTRACK_TIMEOUT_MAX] __read_mostly = {
 	[TCP_CONNTRACK_SYN_SENT]	= 2 MINS,
-- 
1.7.10.4

