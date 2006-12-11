From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/7] chelsio: useless curly braces
Date: Tue, 12 Dec 2006 00:21:11 +0100
Message-ID: <20061211232111.GE8568@electric-eye.fr.zoreil.com>
References: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40061 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbWLKXVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 18:21:39 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/cxgb2.c     |    3 +--
 drivers/net/chelsio/mv88e1xxx.c |    4 ++--
 drivers/net/chelsio/sge.c       |    3 +--
 drivers/net/chelsio/vsc7326.c   |    3 +--
 4 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index bb11b11..689b91c 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1292,9 +1292,8 @@ static int t1_clock(struct adapter *adap
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
index 6b1e857..ac7c46b 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -2195,9 +2195,8 @@ struct sge * __devinit t1_sge_create(str
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
1.4.2.3

