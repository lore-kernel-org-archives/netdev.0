From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH 2/4] MCS7830 USB-Ether: Spelling corrections
Date: Sun, 31 Jan 2010 13:58:26 +0100
Message-ID: <20100131125826.GB13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	David Hollis <dhollis@davehollis.com>,
	Phil Chang <pchang23@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:60157 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab0AaM61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 07:58:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChangeLog:
- spelling corrections / whitespace

Signed-off-by: Andreas Mohr <andi@lisas.de>


Index: linux-2.6.33-rc4/drivers/net/usb/mcs7830.c
===================================================================
--- linux-2.6.33-rc4.orig/drivers/net/usb/mcs7830.c	2010-01-31 12:34:39.000000000 +0100
+++ linux-2.6.33-rc4/drivers/net/usb/mcs7830.c	2010-01-31 12:34:45.000000000 +0100
@@ -1,5 +1,5 @@
 /*
- * MosChips MCS7830 based USB 2.0 Ethernet Devices
+ * MOSCHIP MCS7830 based USB 2.0 Ethernet Devices
  *
  * based on usbnet.c, asix.c and the vendor provided mcs7830 driver
  *
@@ -71,7 +71,7 @@
 				 ADVERTISE_100HALF | ADVERTISE_10FULL | \
 				 ADVERTISE_10HALF | ADVERTISE_CSMA)
 
-/* HIF_REG_XX coressponding index value */
+/* HIF_REG_XX corresponding index value */
 enum {
 	HIF_REG_MULTICAST_HASH			= 0x00,
 	HIF_REG_PACKET_GAP1			= 0x08,
@@ -92,7 +92,7 @@
 	   HIF_REG_CONFIG_TXENABLE		= 0x08,
 	   HIF_REG_CONFIG_SLEEPMODE		= 0x04,
 	   HIF_REG_CONFIG_ALLMULTICAST		= 0x02,
-	   HIF_REG_CONFIG_PROMISCIOUS		= 0x01,
+	   HIF_REG_CONFIG_PROMISCUOUS		= 0x01,
 	HIF_REG_ETHERNET_ADDR			= 0x0f,
 	HIF_REG_22				= 0x15,
 	HIF_REG_PAUSE_THRESHOLD			= 0x16,
@@ -417,7 +417,7 @@
 	data->config |= HIF_REG_CONFIG_ALLMULTICAST;
 
 	if (net->flags & IFF_PROMISC) {
-		data->config |= HIF_REG_CONFIG_PROMISCIOUS;
+		data->config |= HIF_REG_CONFIG_PROMISCUOUS;
 	} else if (net->flags & IFF_ALLMULTI ||
 		   net->mc_count > MCS7830_MAX_MCAST) {
 		data->config |= HIF_REG_CONFIG_ALLMULTICAST;
@@ -522,7 +522,7 @@
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= mcs7830_ioctl,
 	.ndo_set_multicast_list = mcs7830_set_multicast,
-	.ndo_set_mac_address	 = mcs7830_set_mac_address,
+	.ndo_set_mac_address	= mcs7830_set_mac_address,
 };
 
 static int mcs7830_bind(struct usbnet *dev, struct usb_interface *udev)
@@ -553,7 +553,7 @@
 	return ret;
 }
 
-/* The chip always appends a status bytes that we need to strip */
+/* The chip always appends a status byte that we need to strip */
 static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	u8 status;
