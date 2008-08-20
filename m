From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 24/24] IPVS: Add notes about IPv6 changes
Date: Wed, 20 Aug 2008 18:15:31 +0200
Message-ID: <1219248931-15064-25-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51616 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbYHTQQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 12:16:08 -0400
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add notes about the IPv6 changes to header comments in relevant files.

Signed-off-by: Julius Volz <juliusv@google.com>

 5 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 011d455..aa6f43b 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -19,6 +19,7 @@
  * and others. Many code here is taken from IP MASQ code of kernel 2.2.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 0f9a0a2..5bb53c0 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -21,6 +21,7 @@
  * Changes:
  *	Paul `Rusty' Russell		properly handle non-linear skbs
  *	Harald Welte			don't use nfcache
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index ba4d7c2..ec5e855 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -15,6 +15,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz, Vince Busam	add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 301b779..5c4b8f9 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 15c59aa..e1a3fde 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
-- 
1.5.4.5

