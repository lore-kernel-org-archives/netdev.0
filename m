From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] ipvs: fixed spacing at for statements
Date: Thu, 11 Jul 2013 09:45:42 +0300
Message-ID: <1373525142-9099-1-git-send-email-dragos.foianu@gmail.com>
Cc: linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org, ja@ssi.bg, horms@verge.net.au,
	Dragos Foianu <dragos.foianu@gmail.com>
To: wensong@linux-vs.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

found using checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
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

