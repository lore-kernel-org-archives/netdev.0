From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/38] ipvs: Reduce checkpatch noise in ip_vs_lblc.c
Date: Mon, 17 Mar 2014 13:42:39 +0100
Message-ID: <1395060178-11833-20-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tingwei Liu <tingw.liu@gmail.com>

Add whitespace after operator and put open brace { on the previous line

Cc: Tingwei Liu <liutingwei@hisense.com>
Cc: lvs-devel@vger.kernel.org
Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index ca056a3..547ff33 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -238,7 +238,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 
 	spin_lock_bh(&svc->sched_lock);
 	tbl->dead = 1;
-	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblc_del(en);
 			atomic_dec(&tbl->entries);
@@ -265,7 +265,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 	unsigned long now = jiffies;
 	int i, j;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -321,7 +321,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	if (goal > tbl->max_size/2)
 		goal = tbl->max_size/2;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -340,7 +340,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	tbl->rover = j;
 
   out:
-	mod_timer(&tbl->periodic_timer, jiffies+CHECK_EXPIRE_INTERVAL);
+	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
 }
 
 
@@ -363,7 +363,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Initialize the hash buckets
 	 */
-	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		INIT_HLIST_HEAD(&tbl->bucket[i]);
 	}
 	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
@@ -536,8 +536,7 @@ out:
 /*
  *      IPVS LBLC Scheduler structure
  */
-static struct ip_vs_scheduler ip_vs_lblc_scheduler =
-{
+static struct ip_vs_scheduler ip_vs_lblc_scheduler = {
 	.name =			"lblc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-- 
1.7.10.4

