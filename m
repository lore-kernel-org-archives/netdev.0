From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/7] chelsio: the return statement is not a function
Date: Tue, 12 Dec 2006 00:20:56 +0100
Message-ID: <20061211232056.GC8568@electric-eye.fr.zoreil.com>
References: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40050 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbWLKXVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 18:21:03 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/my3126.c  |   16 ++++++++--------
 drivers/net/chelsio/vsc7326.c |   12 ++++++------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/chelsio/my3126.c b/drivers/net/chelsio/my3126.c
index c7731b6..3e4e57f 100644
--- a/drivers/net/chelsio/my3126.c
+++ b/drivers/net/chelsio/my3126.c
@@ -10,25 +10,25 @@ static int my3126_reset(struct cphy *cph
 	 * This can be done through registers.  It is not required since
 	 * a full chip reset is used.
 	 */
-	return (0);
+	return 0;
 }
 
 static int my3126_interrupt_enable(struct cphy *cphy)
 {
 	schedule_delayed_work(&cphy->phy_update, HZ/30);
 	t1_tpi_read(cphy->adapter, A_ELMER0_GPO, &cphy->elmer_gpo);
-	return (0);
+	return 0;
 }
 
 static int my3126_interrupt_disable(struct cphy *cphy)
 {
 	cancel_rearming_delayed_work(&cphy->phy_update);
-	return (0);
+	return 0;
 }
 
 static int my3126_interrupt_clear(struct cphy *cphy)
 {
-	return (0);
+	return 0;
 }
 
 #define OFFSET(REG_ADDR)    (REG_ADDR << 2)
@@ -102,7 +102,7 @@ static void my3216_poll(struct work_stru
 
 static int my3126_set_loopback(struct cphy *cphy, int on)
 {
-	return (0);
+	return 0;
 }
 
 /* To check the activity LED */
@@ -146,7 +146,7 @@ static int my3126_get_link_status(struct
 	if (fc)
 		*fc = PAUSE_RX | PAUSE_TX;
 
-	return (0);
+	return 0;
 }
 
 static void my3126_destroy(struct cphy *cphy)
@@ -176,7 +176,7 @@ static struct cphy *my3126_phy_create(ad
 	INIT_DELAYED_WORK(&cphy->phy_update, my3216_poll);
 	cphy->bmsr = 0;
 
-	return (cphy);
+	return cphy;
 }
 
 /* Chip Reset */
@@ -197,7 +197,7 @@ static int my3126_phy_reset(adapter_t * 
 	val |= 0x8000;
 	t1_tpi_write(adapter, A_ELMER0_GPO, val);
 	udelay(100);
-	return (0);
+	return 0;
 }
 
 struct gphy t1_my3126_ops = {
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index 3355441..8c4a31e 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -256,7 +256,7 @@ static int bist_rd(adapter_t *adapter, i
 	else if((result & (1<<8)) != 0x0)
 		CH_ERR("bist read error: 0x%x\n", result);
 
-	return(result & 0xff);
+	return (result & 0xff);
 }
 
 static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
@@ -286,7 +286,7 @@ static int bist_wr(adapter_t *adapter, i
 	else if((result & (1<<26)) != 0x0)
 		CH_ERR("bist write error: 0x%x\n", result);
 
-	return(0);
+	return 0;
 }
 
 static int run_bist(adapter_t *adapter, int moduleid)
@@ -295,7 +295,7 @@ static int run_bist(adapter_t *adapter, 
 	(void) bist_wr(adapter,moduleid, 0x00, 0x02);
 	(void) bist_wr(adapter,moduleid, 0x01, 0x01);
 
-	return(0);
+	return 0;
 }
 
 static int check_bist(adapter_t *adapter, int moduleid)
@@ -309,14 +309,14 @@ static int check_bist(adapter_t *adapter
 	if ((result & 3) != 0x3)
 		CH_ERR("Result: 0x%x  BIST error in ram %d, column: 0x%04x\n",
 			result, moduleid, column);
-	return(0);
+	return 0;
 }
 
 static int enable_mem(adapter_t *adapter, int moduleid)
 {
 	/*enable mem*/
 	(void) bist_wr(adapter,moduleid, 0x00, 0x00);
-	return(0);
+	return 0;
 }
 
 static int run_bist_all(adapter_t *adapter)
@@ -358,7 +358,7 @@ static int run_bist_all(adapter_t *adapt
 	udelay(300);
 	vsc_write(adapter, REG_MEM_BIST, 0x0);
 	mdelay(10);
-	return(0);
+	return 0;
 }
 
 static int mac_intr_handler(struct cmac *mac)
-- 
1.4.2.3

