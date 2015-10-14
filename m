From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 6/6] netfilter-ipv4: whitespace around operators
Date: Wed, 14 Oct 2015 23:17:08 +0100
Message-ID: <1444861028-21556-7-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleanses whitespace around arithmetical operators.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
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
index 8e3dffa..89be5c5 100644
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
1.9.1

