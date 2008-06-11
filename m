From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 26/26] IPVS: Add some blame/credits for IPv6 version.
Date: Wed, 11 Jun 2008 19:12:09 +0200
Message-ID: <1213204329-10973-27-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14474 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbYFKRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:34 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some blame for first IPv6 version of IPVS.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 7 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6b031a8..8bb4ee8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -21,6 +21,7 @@
  * and others. Many code here is taken from IP MASQ code of kernel 2.2.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ded862b..e1469d0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -23,6 +23,7 @@
  * Changes:
  *	Paul `Rusty' Russell		properly handle non-linear skbs
  *	Harald Welte			don't use nfcache
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c6b737c..06e5f74 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -17,6 +17,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz, Vince Busam	add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8b82400..7766426 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -12,6 +12,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 02bf859..c25d531 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -12,6 +12,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index ef0d921..c56bade 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -12,6 +12,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9d2c424..8fd8f9f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -12,6 +12,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
-- 
1.5.3.6

