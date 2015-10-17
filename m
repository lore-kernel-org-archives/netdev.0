From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/35] netfilter: ipv4: whitespace around operators
Date: Sat, 17 Oct 2015 13:33:10 +0200
Message-ID: <1445081590-2924-36-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48471 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833AbbJQL0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:35 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

This patch cleanses whitespace around arithmetical operators.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c     | 8 ++++----
 net/ipv4/netfilter/ipt_ah.c            | 2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 3f32c03..4a9e6db 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -492,14 +492,14 @@ static void arp_print(struct arp_payload *payload)
 {
 #define HBUFFERLEN 30
 	char hbuffer[HBUFFERLEN];
-	int j,k;
+	int j, k;
 
-	for (k=0, j=0; k < HBUFFERLEN-3 && j < ETH_ALEN; j++) {
+	for (k = 0, j = 0; k < HBUFFERLEN - 3 && j < ETH_ALEN; j++) {
 		hbuffer[k++] = hex_asc_hi(payload->src_hw[j]);
 		hbuffer[k++] = hex_asc_lo(payload->src_hw[j]);
-		hbuffer[k++]=':';
+		hbuffer[k++] = ':';
 	}
-	hbuffer[--k]='\0';
+	hbuffer[--k] = '\0';
 
 	pr_debug("src %pI4@%s, dst %pI4\n",
 		 &payload->src_ip, hbuffer, &payload->dst_ip);
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 14a2aa8..a787d07 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -25,7 +25,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	bool r;
 	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
 		 invert ? '!' : ' ', min, spi, max);
-	r=(spi >= min && spi <= max) ^ invert;
+	r = (spi >= min && spi <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
 	return r;
 }
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 7c67667..ddb894a 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1156,7 +1156,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 		}
 
 		if (obj->type == SNMP_IPADDR)
-			mangle_address(ctx.begin, ctx.pointer - 4 , map, check);
+			mangle_address(ctx.begin, ctx.pointer - 4, map, check);
 
 		kfree(obj->id);
 		kfree(obj);
-- 
2.1.4
