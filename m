From: Joe Perches <joe@perches.com>
Subject: [PATCH] include/net/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:25 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe__4197.58350258252$1197920711$gmane$org@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Samuel Ortiz <samuel@sortiz.org>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	linux-hams@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/ax25.h           |    2 +-
 include/net/ip6_tunnel.h     |    2 +-
 include/net/irda/discovery.h |    2 +-
 include/net/sctp/structs.h   |    6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 4e3cd93..32a57e1 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -35,7 +35,7 @@
 #define AX25_P_ATALK			0xca	/* Appletalk                  */
 #define AX25_P_ATALK_ARP		0xcb	/* Appletalk ARP              */
 #define AX25_P_IP			0xcc	/* ARPA Internet Protocol     */
-#define AX25_P_ARP			0xcd	/* ARPA Adress Resolution     */
+#define AX25_P_ARP			0xcd	/* ARPA Address Resolution    */
 #define AX25_P_FLEXNET			0xce	/* FlexNet                    */
 #define AX25_P_NETROM 			0xcf	/* NET/ROM                    */
 #define AX25_P_TEXT 			0xF0	/* No layer 3 protocol impl.  */
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 29c9da7..c17fa1f 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -23,7 +23,7 @@ struct ip6_tnl {
 	struct net_device *dev;	/* virtual device associated with tunnel */
 	struct net_device_stats stat;	/* statistics for tunnel device */
 	int recursion;		/* depth of hard_start_xmit recursion */
-	struct ip6_tnl_parm parms;	/* tunnel configuration paramters */
+	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
 	struct dst_entry *dst_cache;    /* cached dst */
 	u32 dst_cookie;
diff --git a/include/net/irda/discovery.h b/include/net/irda/discovery.h
index eb0f9de..e4efad1 100644
--- a/include/net/irda/discovery.h
+++ b/include/net/irda/discovery.h
@@ -80,7 +80,7 @@ typedef struct discovery_t {
 	irda_queue_t	q;		/* Must be first! */
 
 	discinfo_t	data;		/* Basic discovery information */
-	int		name_len;	/* Lenght of nickname */
+	int		name_len;	/* Length of nickname */
 
 	LAP_REASON	condition;	/* More info about the discovery */
 	int		gen_addr_bit;	/* Need to generate a new device
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 002a00a..bb96574 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -301,7 +301,7 @@ struct sctp_sock {
 	/* The default SACK delay timeout for new associations. */
 	__u32 sackdelay;
 
-	/* Flags controling Heartbeat, SACK delay, and Path MTU Discovery. */
+	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
 
 	struct sctp_initmsg initmsg;
@@ -955,7 +955,7 @@ struct sctp_transport {
 	/* PMTU	      : The current known path MTU.  */
 	__u32 pathmtu;
 
-	/* Flags controling Heartbeat, SACK delay, and Path MTU Discovery. */
+	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
 
 	/* The number of times INIT has been sent on this transport. */
@@ -1638,7 +1638,7 @@ struct sctp_association {
 	 */
 	__u32 pathmtu;
 
-	/* Flags controling Heartbeat, SACK delay, and Path MTU Discovery. */
+	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
 
 	/* SACK delay timeout */
-- 
1.5.3.7.949.g2221a6

