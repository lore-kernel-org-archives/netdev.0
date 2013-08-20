From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/19] ipvs: fixed spacing at for statements
Date: Tue, 20 Aug 2013 12:54:45 +0200
Message-ID: <1376996091-3964-14-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dragos Foianu <dragos.foianu@gmail.com>

found using checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblcr.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 3cd85b2..5199448 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -414,7 +414,7 @@ static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
 
 	spin_lock_bh(&svc->sched_lock);
 	tbl->dead = 1;
-	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLCR_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
 		}
@@ -440,7 +440,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 	struct ip_vs_lblcr_entry *en;
 	struct hlist_node *next;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -495,7 +495,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 	if (goal > tbl->max_size/2)
 		goal = tbl->max_size/2;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -536,7 +536,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Initialize the hash buckets
 	 */
-	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLCR_TAB_SIZE; i++) {
 		INIT_HLIST_HEAD(&tbl->bucket[i]);
 	}
 	tbl->max_size = IP_VS_LBLCR_TAB_SIZE*16;
-- 
1.7.10.4

