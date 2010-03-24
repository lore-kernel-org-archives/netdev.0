From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 4/9] net/ps3_gelic: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:31 +0100
Message-ID: <1269453456-13599-4-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frans Pop <elendil@planet.nl>, linuxppc-dev@ozlabs.org
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

ps3_gelic_wireless.c: also remove a stray "p" after a newline.

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev@ozlabs.org
---
 drivers/net/ps3_gelic_net.c      |    4 ++--
 drivers/net/ps3_gelic_wireless.c |   34 +++++++++++++++++-----------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index a849f6f..a602da6 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -326,7 +326,7 @@ static int gelic_descr_prepare_rx(struct gelic_card *card,
 	unsigned int bufsize;
 
 	if (gelic_descr_get_status(descr) !=  GELIC_DESCR_DMA_NOT_IN_USE)
-		dev_info(ctodev(card), "%s: ERROR status \n", __func__);
+		dev_info(ctodev(card), "%s: ERROR status\n", __func__);
 	/* we need to round up the buffer size to a multiple of 128 */
 	bufsize = ALIGN(GELIC_NET_MAX_MTU, GELIC_NET_RXBUF_ALIGN);
 
@@ -1434,7 +1434,7 @@ static void gelic_net_tx_timeout_task(struct work_struct *work)
 		container_of(work, struct gelic_card, tx_timeout_task);
 	struct net_device *netdev = card->netdev[GELIC_PORT_ETHERNET_0];
 
-	dev_info(ctodev(card), "%s:Timed out. Restarting... \n", __func__);
+	dev_info(ctodev(card), "%s:Timed out. Restarting...\n", __func__);
 
 	if (!(netdev->flags & IFF_UP))
 		goto out;
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 2663b2f..505f9a1 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -527,7 +527,7 @@ static void gelic_wl_parse_ie(u8 *data, size_t len,
 	u8 item_len;
 	u8 item_id;
 
-	pr_debug("%s: data=%p len=%ld \n", __func__,
+	pr_debug("%s: data=%p len=%ld\n", __func__,
 		 data, len);
 	memset(ie_info, 0, sizeof(struct ie_info));
 
@@ -978,7 +978,7 @@ static int gelic_wl_set_essid(struct net_device *netdev,
 		pr_debug("%s: essid = '%s'\n", __func__, extra);
 		set_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat);
 	} else {
-		pr_debug("%s: ESSID any \n", __func__);
+		pr_debug("%s: ESSID any\n", __func__);
 		clear_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat);
 	}
 	set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
@@ -986,7 +986,7 @@ static int gelic_wl_set_essid(struct net_device *netdev,
 
 
 	gelic_wl_try_associate(netdev); /* FIXME */
-	pr_debug("%s: -> \n", __func__);
+	pr_debug("%s: ->\n", __func__);
 	return 0;
 }
 
@@ -997,7 +997,7 @@ static int gelic_wl_get_essid(struct net_device *netdev,
 	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
 	unsigned long irqflag;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	mutex_lock(&wl->assoc_stat_lock);
 	spin_lock_irqsave(&wl->lock, irqflag);
 	if (test_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat) ||
@@ -1010,7 +1010,7 @@ static int gelic_wl_get_essid(struct net_device *netdev,
 
 	mutex_unlock(&wl->assoc_stat_lock);
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	pr_debug("%s: -> len=%d \n", __func__, data->essid.length);
+	pr_debug("%s: -> len=%d\n", __func__, data->essid.length);
 
 	return 0;
 }
@@ -1027,7 +1027,7 @@ static int gelic_wl_set_encode(struct net_device *netdev,
 	int key_index, index_specified;
 	int ret = 0;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	flags = enc->flags & IW_ENCODE_FLAGS;
 	key_index = enc->flags & IW_ENCODE_INDEX;
 
@@ -1086,7 +1086,7 @@ static int gelic_wl_set_encode(struct net_device *netdev,
 	set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
 done:
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	pr_debug("%s: -> \n", __func__);
+	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
 
@@ -1100,7 +1100,7 @@ static int gelic_wl_get_encode(struct net_device *netdev,
 	unsigned int key_index, index_specified;
 	int ret = 0;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	key_index = enc->flags & IW_ENCODE_INDEX;
 	pr_debug("%s: flag=%#x point=%p len=%d extra=%p\n", __func__,
 		 enc->flags, enc->pointer, enc->length, extra);
@@ -1214,7 +1214,7 @@ static int gelic_wl_set_encodeext(struct net_device *netdev,
 	int key_index;
 	int ret = 0;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	flags = enc->flags & IW_ENCODE_FLAGS;
 	alg = ext->alg;
 	key_index = enc->flags & IW_ENCODE_INDEX;
@@ -1287,7 +1287,7 @@ static int gelic_wl_set_encodeext(struct net_device *netdev,
 	}
 done:
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	pr_debug("%s: -> \n", __func__);
+	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
 
@@ -1303,7 +1303,7 @@ static int gelic_wl_get_encodeext(struct net_device *netdev,
 	int ret = 0;
 	int max_key_len;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 
 	max_key_len = enc->length - sizeof(struct iw_encode_ext);
 	if (max_key_len < 0)
@@ -1358,7 +1358,7 @@ static int gelic_wl_get_encodeext(struct net_device *netdev,
 	}
 out:
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	pr_debug("%s: -> \n", __func__);
+	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
 /* SIOC{S,G}IWMODE */
@@ -1369,7 +1369,7 @@ static int gelic_wl_set_mode(struct net_device *netdev,
 	__u32 mode = data->mode;
 	int ret;
 
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	if (mode == IW_MODE_INFRA)
 		ret = 0;
 	else
@@ -1383,7 +1383,7 @@ static int gelic_wl_get_mode(struct net_device *netdev,
 			     union iwreq_data *data, char *extra)
 {
 	__u32 *mode = &data->mode;
-	pr_debug("%s: <- \n", __func__);
+	pr_debug("%s: <-\n", __func__);
 	*mode = IW_MODE_INFRA;
 	pr_debug("%s: ->\n", __func__);
 	return 0;
@@ -2021,7 +2021,7 @@ static int gelic_wl_associate_bss(struct gelic_wl_info *wl,
 
 	if (!rc) {
 		/* timeouted.  Maybe key or cyrpt mode is wrong */
-		pr_info("%s: connect timeout \n", __func__);
+		pr_info("%s: connect timeout\n", __func__);
 		cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_DISASSOC,
 					   NULL, 0);
 		kfree(cmd);
@@ -2062,7 +2062,7 @@ static void gelic_wl_connected_event(struct gelic_wl_info *wl,
 	}
 
 	if (desired_event == event) {
-		pr_debug("%s: completed \n", __func__);
+		pr_debug("%s: completed\n", __func__);
 		complete(&wl->assoc_done);
 		netif_carrier_on(port_to_netdev(wl_port(wl)));
 	} else
@@ -2317,7 +2317,7 @@ static struct net_device * __devinit gelic_wl_alloc(struct gelic_card *card)
 	pr_debug("%s:start\n", __func__);
 	netdev = alloc_etherdev(sizeof(struct gelic_port) +
 				sizeof(struct gelic_wl_info));
-	pr_debug("%s: netdev =%p card=%p \np", __func__, netdev, card);
+	pr_debug("%s: netdev =%p card=%p\n", __func__, netdev, card);
 	if (!netdev)
 		return NULL;
 
-- 
1.6.6.1
