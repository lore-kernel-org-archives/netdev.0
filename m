From: akpm@linux-foundation.org
Subject: [patch 4/9] ehea: make things static
Date: Fri, 18 Apr 2008 13:50:39 -0700
Message-ID: <200804182050.m3IKodYj014830@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	osstklei@de.ibm.com, tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50806 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756406AbYDRUvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

ehea_flush_sq() and ehea_purge_sq() should be static.

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Thomas Klein <osstklei@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ehea/ehea_main.c~ehea-fix-dlpar-memory-add-support-fix drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~ehea-fix-dlpar-memory-add-support-fix
+++ a/drivers/net/ehea/ehea_main.c
@@ -2611,7 +2611,7 @@ static int ehea_stop(struct net_device *
 	return ret;
 }
 
-void ehea_purge_sq(struct ehea_qp *orig_qp)
+static void ehea_purge_sq(struct ehea_qp *orig_qp)
 {
 	struct ehea_qp qp = *orig_qp;
 	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
@@ -2625,7 +2625,7 @@ void ehea_purge_sq(struct ehea_qp *orig_
 	}
 }
 
-void ehea_flush_sq(struct ehea_port *port)
+static void ehea_flush_sq(struct ehea_port *port)
 {
 	int i;
 
_
