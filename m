From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next-26 5/5] cxgb4vf: Mark "UDP [RSS Hash] Enable" as a 1-bit field.
Date: Thu, 11 Nov 2010 11:30:44 -0800
Message-ID: <1289503844-18059-6-git-send-email-leedom@chelsio.com>
References: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28485 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644Ab0KKTax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:30:53 -0500
In-Reply-To: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark the UDP RSS Hash Enable field as 1-bit in length.  Also clean up
formatting from previous changeset which changed the RSS 1-bit fields from
"int" to "unsigned int".

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/t4vf_common.h |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_common.h b/drivers/net/cxgb4vf/t4vf_common.h
index a65c80a..7541a60 100644
--- a/drivers/net/cxgb4vf/t4vf_common.h
+++ b/drivers/net/cxgb4vf/t4vf_common.h
@@ -132,15 +132,15 @@ struct rss_params {
 	unsigned int mode;		/* RSS mode */
 	union {
 	    struct {
-		unsigned int synmapen:1;	/* SYN Map Enable */
-		unsigned int syn4tupenipv6:1;	/* enable hashing 4-tuple IPv6 SYNs */
-		unsigned int syn2tupenipv6:1;	/* enable hashing 2-tuple IPv6 SYNs */
-		unsigned int syn4tupenipv4:1;	/* enable hashing 4-tuple IPv4 SYNs */
-		unsigned int syn2tupenipv4:1;	/* enable hashing 2-tuple IPv4 SYNs */
-		unsigned int ofdmapen:1;	/* Offload Map Enable */
-		unsigned int tnlmapen:1;	/* Tunnel Map Enable */
-		unsigned int tnlalllookup:1;	/* Tunnel All Lookup */
-		unsigned int hashtoeplitz:1;	/* use Toeplitz hash */
+		uint synmapen:1;	/* SYN Map Enable */
+		uint syn4tupenipv6:1;	/* enable hashing 4-tuple IPv6 SYNs */
+		uint syn2tupenipv6:1;	/* enable hashing 2-tuple IPv6 SYNs */
+		uint syn4tupenipv4:1;	/* enable hashing 4-tuple IPv4 SYNs */
+		uint syn2tupenipv4:1;	/* enable hashing 2-tuple IPv4 SYNs */
+		uint ofdmapen:1;	/* Offload Map Enable */
+		uint tnlmapen:1;	/* Tunnel Map Enable */
+		uint tnlalllookup:1;	/* Tunnel All Lookup */
+		uint hashtoeplitz:1;	/* use Toeplitz hash */
 	    } basicvirtual;
 	} u;
 };
@@ -151,11 +151,11 @@ struct rss_params {
 union rss_vi_config {
     struct {
 	u16 defaultq;			/* Ingress Queue ID for !tnlalllookup */
-	unsigned int ip6fourtupen:1;	/* hash 4-tuple IPv6 ingress packets */
-	unsigned int ip6twotupen:1;	/* hash 2-tuple IPv6 ingress packets */
-	unsigned int ip4fourtupen:1;	/* hash 4-tuple IPv4 ingress packets */
-	unsigned int ip4twotupen:1;	/* hash 2-tuple IPv4 ingress packets */
-	int udpen;			/* hash 4-tuple UDP ingress packets */
+	uint ip6fourtupen:1;		/* hash 4-tuple IPv6 ingress packets */
+	uint ip6twotupen:1;		/* hash 2-tuple IPv6 ingress packets */
+	uint ip4fourtupen:1;		/* hash 4-tuple IPv4 ingress packets */
+	uint ip4twotupen:1;		/* hash 2-tuple IPv4 ingress packets */
+	uint udpen:1;			/* hash 4-tuple UDP ingress packets */
     } basicvirtual;
 };
 
-- 
1.7.0.4

