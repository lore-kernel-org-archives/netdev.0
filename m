From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/09]: sch_ingress: return proper error code in ingress_graft()
Date: Sun, 20 Jan 2008 15:32:36 +0100 (MET)
Message-ID: <20080120143137.27801.45824.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbYATOch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:37 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e039da57d244f15d4b920de63a20ab516a76ed5b
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:07 2008 +0100

    [NET_SCHED]: sch_ingress: return proper error code in ingress_graft()
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index d803cd1..1bbc648 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -35,7 +35,7 @@ struct ingress_qdisc_data {
 static int ingress_graft(struct Qdisc *sch, unsigned long arg,
 			 struct Qdisc *new, struct Qdisc **old)
 {
-	return 1;
+	return -EOPNOTSUPP;
 }
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
