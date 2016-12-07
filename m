From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] net: mvneta: Indent some statements
Date: Wed, 7 Dec 2016 14:32:17 +0300
Message-ID: <20161207113217.GE5507@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44155 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcLGLkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 06:40:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two statements were not indented correctly so it's sort of
confusing.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5e5b259dd2cc..e05e22705cf7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3578,9 +3578,10 @@ static int mvneta_stop(struct net_device *dev)
 		mvneta_stop_dev(pp);
 		mvneta_mdio_remove(pp);
 
-	cpuhp_state_remove_instance_nocalls(online_hpstate, &pp->node_online);
-	cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
-					    &pp->node_dead);
+		cpuhp_state_remove_instance_nocalls(online_hpstate,
+						    &pp->node_online);
+		cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+						    &pp->node_dead);
 		on_each_cpu(mvneta_percpu_disable, pp, true);
 		free_percpu_irq(dev->irq, pp->ports);
 	} else {
