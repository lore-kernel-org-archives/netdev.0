From: Stewart Malik <mali0037@gmail.com>
Subject: [PATCH] DRIVER: Libertas: Fixed coding style in rx.c
Date: Thu, 11 Mar 2010 20:28:29 +1030
Message-ID: <1268301509-9247-1-git-send-email-mali0037@gmail.com>
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stewart Malik <mali0037@gmail.com>
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:60285 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564Ab0CKJ6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 04:58:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/wireless/libertas/rx.c |   50 ++++++++++++++++++------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 2daf8ff..7a867e3 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -38,10 +38,10 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
 	struct sk_buff *skb);
 
 /**
- *  @brief This function computes the avgSNR .
+ *  @brief	This function computes the avgSNR .
  *
- *  @param priv    A pointer to struct lbs_private structure
- *  @return 	   avgSNR
+ *  @param	priv	A pointer to struct lbs_private structure
+ *  @return	avgSNR
  */
 static u8 lbs_getavgsnr(struct lbs_private *priv)
 {
@@ -56,10 +56,10 @@ static u8 lbs_getavgsnr(struct lbs_private *priv)
 }
 
 /**
- *  @brief This function computes the AvgNF
+ *  @brief	This function computes the AvgNF
  *
- *  @param priv    A pointer to struct lbs_private structure
- *  @return 	   AvgNF
+ *  @param	priv	A pointer to struct lbs_private structure
+ *  @return	AvgNF
  */
 static u8 lbs_getavgnf(struct lbs_private *priv)
 {
@@ -74,11 +74,11 @@ static u8 lbs_getavgnf(struct lbs_private *priv)
 }
 
 /**
- *  @brief This function save the raw SNR/NF to our internel buffer
+ *  @brief	This function save the raw SNR/NF to our internel buffer
  *
- *  @param priv    A pointer to struct lbs_private structure
- *  @param prxpd   A pointer to rxpd structure of received packet
- *  @return 	   n/a
+ *  @param	priv	A pointer to struct lbs_private structure
+ *  @param	prxpd	A pointer to rxpd structure of received packet
+ *  @return	n/a
  */
 static void lbs_save_rawSNRNF(struct lbs_private *priv, struct rxpd *p_rx_pd)
 {
@@ -93,11 +93,11 @@ static void lbs_save_rawSNRNF(struct lbs_private *priv, struct rxpd *p_rx_pd)
 }
 
 /**
- *  @brief This function computes the RSSI in received packet.
+ *  @brief	This function computes the RSSI in received packet.
  *
- *  @param priv    A pointer to struct lbs_private structure
- *  @param prxpd   A pointer to rxpd structure of received packet
- *  @return 	   n/a
+ *  @param	priv	A pointer to struct lbs_private structure
+ *  @param	prxpd	A pointer to rxpd structure of received packet
+ *  @return	n/a
  */
 static void lbs_compute_rssi(struct lbs_private *priv, struct rxpd *p_rx_pd)
 {
@@ -134,9 +134,9 @@ static void lbs_compute_rssi(struct lbs_private *priv, struct rxpd *p_rx_pd)
  *  @brief This function processes received packet and forwards it
  *  to kernel/upper layer
  *
- *  @param priv    A pointer to struct lbs_private
- *  @param skb     A pointer to skb which includes the received packet
- *  @return 	   0 or -1
+ *  @param	priv	A pointer to struct lbs_private
+ *  @param	skb		A pointer to skb which includes the received packet
+ *  @return	0 or -1
  */
 int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 {
@@ -196,7 +196,7 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 		 *    before the snap_type.
 		 */
 		p_ethhdr = (struct ethhdr *)
-		    ((u8 *) & p_rx_pkt->eth803_hdr
+		    ((u8 *) &p_rx_pkt->eth803_hdr
 		     + sizeof(p_rx_pkt->eth803_hdr) + sizeof(p_rx_pkt->rfc1042_hdr)
 		     - sizeof(p_rx_pkt->eth803_hdr.dest_addr)
 		     - sizeof(p_rx_pkt->eth803_hdr.src_addr)
@@ -213,7 +213,7 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 		hdrchop = (u8 *)p_ethhdr - (u8 *)p_rx_pd;
 	} else {
 		lbs_deb_hex(LBS_DEB_RX, "RX Data: LLC/SNAP",
-			(u8 *) & p_rx_pkt->rfc1042_hdr,
+			(u8 *) &p_rx_pkt->rfc1042_hdr,
 			sizeof(p_rx_pkt->rfc1042_hdr));
 
 		/* Chop off the rxpd */
@@ -254,8 +254,8 @@ EXPORT_SYMBOL_GPL(lbs_process_rxed_packet);
  *  @brief This function converts Tx/Rx rates from the Marvell WLAN format
  *  (see Table 2 in Section 3.1) to IEEE80211_RADIOTAP_RATE units (500 Kb/s)
  *
- *  @param rate    Input rate
- *  @return 	   Output Rate (0 if invalid)
+ *  @param	rate	Input rate
+ *  @return	Output Rate (0 if invalid)
  */
 static u8 convert_mv_rate_to_radiotap(u8 rate)
 {
@@ -294,9 +294,9 @@ static u8 convert_mv_rate_to_radiotap(u8 rate)
  *  @brief This function processes a received 802.11 packet and forwards it
  *  to kernel/upper layer
  *
- *  @param priv    A pointer to struct lbs_private
- *  @param skb     A pointer to skb which includes the received packet
- *  @return 	   0 or -1
+ *  @param	priv	A pointer to struct lbs_private
+ *  @param	skb		A pointer to skb which includes the received packet
+ *  @return	0 or -1
  */
 static int process_rxed_802_11_packet(struct lbs_private *priv,
 	struct sk_buff *skb)
@@ -313,7 +313,7 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
 	p_rx_pkt = (struct rx80211packethdr *) skb->data;
 	prxpd = &p_rx_pkt->rx_pd;
 
-	// lbs_deb_hex(LBS_DEB_RX, "RX Data: Before chop rxpd", skb->data, min(skb->len, 100));
+	/* lbs_deb_hex(LBS_DEB_RX, "RX Data: Before chop rxpd", skb->data, min(skb->len, 100)); */
 
 	if (skb->len < (ETH_HLEN + 8 + sizeof(struct rxpd))) {
 		lbs_deb_rx("rx err: frame received with bad length\n");
-- 
1.6.0.4

