From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 05/14] replace __inline__ by inline in net/core
Date: Wed, 06 Feb 2008 10:14:10 +0100
Message-ID: <20080206092121.762016082@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:33625 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760567AbYBFJ1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:25 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169R6ZV454824
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:06 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169R6i84456652
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:06 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169R3Om026156
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:03 GMT
Content-Disposition: inline; filename=remove-__inline__-in-core.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/core

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/core/neighbour.c |    2 +-
 net/core/pktgen.c    |    2 +-
 net/core/scm.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6/net/core/neighbour.c
===================================================================
--- net-2.6.orig/net/core/neighbour.c
+++ net-2.6/net/core/neighbour.c
@@ -732,7 +732,7 @@ next_elt:
 	write_unlock(&tbl->lock);
 }
 
-static __inline__ int neigh_max_probes(struct neighbour *n)
+static inline int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
 	return (n->nud_state & NUD_PROBE ?
Index: net-2.6/net/core/pktgen.c
===================================================================
--- net-2.6.orig/net/core/pktgen.c
+++ net-2.6/net/core/pktgen.c
@@ -3259,7 +3259,7 @@ static void pktgen_rem_thread(struct pkt
 	mutex_unlock(&pktgen_thread_lock);
 }
 
-static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
+static inline void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
Index: net-2.6/net/core/scm.c
===================================================================
--- net-2.6.orig/net/core/scm.c
+++ net-2.6/net/core/scm.c
@@ -42,7 +42,7 @@
  *	setu(g)id.
  */
 
-static __inline__ int scm_check_creds(struct ucred *creds)
+static inline int scm_check_creds(struct ucred *creds)
 {
 	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
 	    ((creds->uid == current->uid || creds->uid == current->euid ||

-- 
