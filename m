From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/7] chelsio: useless curly braces
Date: Wed, 6 Dec 2006 01:17:05 +0100
Message-ID: <20061206001705.GE2377@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39993 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758762AbWLFAVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:21:01 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/cxgb2.c     |    9 ++++-----
 drivers/net/chelsio/mv88e1xxx.c |    4 ++--
 drivers/net/chelsio/sge.c       |    3 +--
 drivers/net/chelsio/vsc7326.c   |    3 +--
 4 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 15be058..dc74fa2 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -771,11 +771,11 @@ static int set_coalesce(struct net_devic
 	if (adapter->open_device_map == 0)
 		adapter->params.sge.polling = c->use_adaptive_rx_coalesce;
 
-	if (adapter->params.sge.polling) {
+	if (adapter->params.sge.polling)
 		adapter->params.sge.rx_coalesce_usecs = 0;
-	} else {
+	else
 		adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
-	}
+
 	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
 	adapter->params.sge.sample_interval_usecs = c->rate_sample_interval;
 	t1_sge_set_coalesce_params(adapter->sge, &adapter->params.sge);
@@ -1299,9 +1299,8 @@ static int t1_clock(struct adapter *adap
 	if (!t1_is_T1B(adapter))
 		return -ENODEV;	/* Can't re-clock this chip. */
 
-	if (mode & 2) {
+	if (mode & 2)
 		return 0;	/* show current mode. */
-	}
 
 	if ((adapter->t1powersave & 1) == (mode & 1))
 		return -EALREADY;	/* ASIC already running in mode. */
diff --git a/drivers/net/chelsio/mv88e1xxx.c b/drivers/net/chelsio/mv88e1xxx.c
index c7c5854..5867e3b 100644
--- a/drivers/net/chelsio/mv88e1xxx.c
+++ b/drivers/net/chelsio/mv88e1xxx.c
@@ -312,9 +312,9 @@ static int mv88e1xxx_interrupt_handler(s
 			(void) simple_mdio_read(cphy,
 				MV88E1XXX_SPECIFIC_STATUS_REGISTER, &status);
 
-			if (status & MV88E1XXX_INTR_LINK_CHNG) {
+			if (status & MV88E1XXX_INTR_LINK_CHNG)
 				cphy->state |= PHY_LINK_UP;
-			} else {
+			else {
 				cphy->state &= ~PHY_LINK_UP;
 				if (cphy->state & PHY_AUTONEG_EN)
 					cphy->state &= ~PHY_AUTONEG_RDY;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index f61d671..f8b40b2 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -2211,9 +2211,8 @@ struct sge * __devinit t1_sge_create(str
 		if (adapter->params.nports > 1) {
 			tx_sched_init(sge);
 			sge->espibug_timer.function = espibug_workaround_t204;
-		} else {
+		} else
 			sge->espibug_timer.function = espibug_workaround;
-		}
 		sge->espibug_timer.data = (unsigned long)sge->adapter;
 
 		sge->espibug_timeout = 1;
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index bdd25c0..31a67f5 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -226,9 +226,8 @@ static void run_table(adapter_t *adapter
 		if (ib[i].addr == INITBLOCK_SLEEP) {
 			udelay( ib[i].data );
 			CH_ERR("sleep %d us\n",ib[i].data);
-		} else {
+		} else
 			vsc_write( adapter, ib[i].addr, ib[i].data );
-		}
 	}
 }
 
-- 
1.4.4.1

