From: Tingwei Liu <tingw.liu@gmail.com>
Subject: [PATCH] ipvs: Reduce checkpatch noise in ip_vs_lblc.c
Date: Tue, 11 Feb 2014 13:35:55 +0800
Message-ID: <1392096955-12967-1-git-send-email-tingw.liu@gmail.com>
Cc: Tingwei Liu <tingw.liu@gmail.com>, Tony <liutingwei@hisense.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60940 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaBKFgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 00:36:36 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so7187804pab.35
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 21:36:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add whitespace after operator and put open brace { on the previous line

Cc: Tony <liutingwei@hisense.com>
Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

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
1.6.0.2
