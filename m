From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 8/8] treewide: Remove unnecessary casts from skb_push
Date: Mon,  4 May 2015 13:05:52 -0700
Message-ID: <9819471e5373b3bf335d001acdead162b4d066fc.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0046.hostedemail.com ([216.40.44.46]:47598 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751763AbbEDUG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:26 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id A2F0AC2132
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:25 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:23 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that skb_push returns a void *, remove the unnecessary casts.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/solos-pci.c                        |  2 +-
 drivers/firewire/net.c                         |  8 +++-----
 drivers/infiniband/hw/cxgb3/iwch_cm.c          |  6 +++---
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |  2 +-
 drivers/isdn/act2000/module.c                  |  2 +-
 drivers/net/arcnet/arc-rawmode.c               |  2 +-
 drivers/net/arcnet/capmode.c                   |  2 +-
 drivers/net/arcnet/rfc1051.c                   |  2 +-
 drivers/net/arcnet/rfc1201.c                   |  2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c     |  2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c        |  2 +-
 drivers/net/ethernet/freescale/gianfar.c       |  2 +-
 drivers/net/ethernet/sun/niu.c                 |  2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c   |  2 +-
 drivers/net/hippi/rrunner.c                    |  2 +-
 drivers/net/usb/gl620a.c                       |  2 +-
 drivers/net/usb/lg-vl600.c                     |  2 +-
 drivers/net/usb/net1080.c                      |  2 +-
 drivers/net/wimax/i2400m/netdev.c              |  2 +-
 drivers/net/wireless/adm8211.c                 |  2 +-
 drivers/net/wireless/ath/ar5523/ar5523.c       |  4 ++--
 drivers/net/wireless/ath/ath6kl/htc_pipe.c     |  3 +--
 drivers/net/wireless/ath/ath9k/hif_usb.c       |  2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c       |  3 +--
 drivers/net/wireless/ath/ath9k/wmi.c           |  2 +-
 drivers/net/wireless/ath/carl9170/tx.c         |  2 +-
 drivers/net/wireless/ath/wil6210/txrx.c        |  2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c |  2 +-
 drivers/net/wireless/cw1200/txrx.c             |  2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c  |  8 +++-----
 drivers/net/wireless/libertas/rx.c             |  2 +-
 drivers/net/wireless/libertas_tf/main.c        |  2 +-
 drivers/net/wireless/mac80211_hwsim.c          |  4 ++--
 drivers/net/wireless/orinoco/main.c            |  7 +++----
 drivers/net/wireless/p54/txrx.c                |  4 ++--
 drivers/net/wireless/prism54/islpci_eth.c      |  5 +----
 drivers/net/wireless/rtl818x/rtl8187/dev.c     |  6 ++----
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c   |  2 +-
 drivers/net/wireless/ti/wl1251/tx.c            |  3 +--
 drivers/net/wireless/ti/wlcore/cmd.c           |  2 +-
 drivers/net/wireless/ti/wlcore/tx.c            |  3 +--
 drivers/net/wireless/zd1211rw/zd_mac.c         |  3 +--
 drivers/s390/net/qeth_l2_main.c                |  3 +--
 drivers/s390/net/qeth_l3_main.c                |  6 ++----
 drivers/scsi/fcoe/fcoe_ctlr.c                  |  2 +-
 drivers/scsi/fnic/fnic_fcs.c                   |  7 +++----
 drivers/staging/wlan-ng/p80211conv.c           | 14 +++++---------
 drivers/usb/gadget/function/rndis.c            |  2 +-
 include/linux/if_vlan.h                        |  2 +-
 net/802/fc.c                                   |  4 ++--
 net/802/fddi.c                                 |  2 +-
 net/802/hippi.c                                |  2 +-
 net/8021q/vlan_dev.c                           |  2 +-
 net/appletalk/ddp.c                            |  2 +-
 net/bluetooth/hci_sock.c                       |  4 ++--
 net/bluetooth/rfcomm/core.c                    |  4 ++--
 net/bridge/netfilter/nft_reject_bridge.c       |  2 +-
 net/core/netpoll.c                             |  4 ++--
 net/core/pktgen.c                              |  6 +++---
 net/decnet/dn_dev.c                            |  4 ++--
 net/ethernet/eth.c                             |  2 +-
 net/ipv4/ip_gre.c                              |  2 +-
 net/ipv6/exthdrs.c                             |  4 ++--
 net/ipv6/ip6_gre.c                             |  2 +-
 net/ipv6/tcp_ipv6.c                            |  2 +-
 net/iucv/af_iucv.c                             |  3 +--
 net/mac80211/rx.c                              |  2 +-
 net/mac80211/status.c                          |  2 +-
 net/mac80211/tx.c                              |  2 +-
 net/nfc/nci/data.c                             |  2 +-
 net/sctp/output.c                              |  2 +-
 net/sctp/sm_statefuns.c                        |  4 ++--
 net/sctp/ulpevent.c                            |  8 +++-----
 net/wireless/util.c                            |  2 +-
 74 files changed, 104 insertions(+), 130 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index d762ee9..aa4b7b1 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1160,7 +1160,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 		}
 	}
 
-	header = (void *)skb_push(skb, sizeof(*header));
+	header = skb_push(skb, sizeof(*header));
 
 	/* This does _not_ include the size of the header */
 	header->size = cpu_to_le16(pktlen);
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index f4ea80d..8ec4fb7 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -219,7 +219,7 @@ static int fwnet_header_create(struct sk_buff *skb, struct net_device *net,
 {
 	struct fwnet_header *h;
 
-	h = (struct fwnet_header *)skb_push(skb, sizeof(*h));
+	h = skb_push(skb, sizeof(*h));
 	put_unaligned_be16(type, &h->h_proto);
 
 	if (net->flags & (IFF_LOOPBACK | IFF_NOARP)) {
@@ -942,16 +942,14 @@ static int fwnet_send_packet(struct fwnet_packet_task *ptask)
 	tx_len = ptask->max_payload;
 	switch (fwnet_get_hdr_lf(&ptask->hdr)) {
 	case RFC2374_HDR_UNFRAG:
-		bufhdr = (struct rfc2734_header *)
-				skb_push(ptask->skb, RFC2374_UNFRAG_HDR_SIZE);
+		bufhdr = skb_push(ptask->skb, RFC2374_UNFRAG_HDR_SIZE);
 		put_unaligned_be32(ptask->hdr.w0, &bufhdr->w0);
 		break;
 
 	case RFC2374_HDR_FIRSTFRAG:
 	case RFC2374_HDR_INTFRAG:
 	case RFC2374_HDR_LASTFRAG:
-		bufhdr = (struct rfc2734_header *)
-				skb_push(ptask->skb, RFC2374_FRAG_HDR_SIZE);
+		bufhdr = skb_push(ptask->skb, RFC2374_FRAG_HDR_SIZE);
 		put_unaligned_be32(ptask->hdr.w0, &bufhdr->w0);
 		put_unaligned_be32(ptask->hdr.w1, &bufhdr->w1);
 		break;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index b115582..20f1a80 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -515,7 +515,7 @@ static void send_mpa_req(struct iwch_ep *ep, struct sk_buff *skb)
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
 	len = skb->len;
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(len);
@@ -566,7 +566,7 @@ static int send_mpa_reject(struct iwch_ep *ep, const void *pdata, u8 plen)
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(mpalen);
@@ -617,7 +617,7 @@ static int send_mpa_reply(struct iwch_ep *ep, const void *pdata, u8 plen)
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
 	len = skb->len;
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(len);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 9e1b203..c3fe271 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -822,7 +822,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	struct ipoib_header *header;
 	struct ipoib_cb *cb = ipoib_skb_cb(skb);
 
-	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
+	header = skb_push(skb, sizeof *header);
 
 	header->proto = htons(type);
 	header->reserved = 0;
diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index c3a1b06..9b13831 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -451,7 +451,7 @@ act2000_sendbuf(act2000_card *card, int channel, int ack, struct sk_buff *skb)
 		}
 	}
 	dev_kfree_skb(skb);
-	msg = (actcapi_msg *)skb_push(xmit_skb, 19);
+	msg = skb_push(xmit_skb, 19);
 	msg->hdr.len = 19 + len;
 	msg->hdr.applicationID = 1;
 	msg->hdr.cmd.cmd = 0x86;
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 705e6ce..dcb905c 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -136,7 +136,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 
 	/*
 	 * Set the source hardware address.
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 42fce91..72bfa03 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -101,7 +101,7 @@ static int build_header(struct sk_buff *skb,
 			uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 
 	BUGMSG(D_PROTO, "Preparing header for cap packet %x.\n",
 	       *((int*)&pkt->soft.cap.cookie[0]));
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index f81db40..67e5853 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -169,7 +169,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 
 	/* set the protocol ID according to RFC1051 */
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index b71431a..14046ec 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -376,7 +376,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
 
 	/* set the protocol ID according to RFC1201 */
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 783543a..d1f9797 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -890,7 +890,7 @@ static struct sk_buff *bcm_sysport_insert_tsb(struct sk_buff *skb,
 		skb = nskb;
 	}
 
-	tsb = (struct bcm_tsb *)skb_push(skb, sizeof(*tsb));
+	tsb = skb_push(skb, sizeof(*tsb));
 	/* Zero-out TSB by default */
 	memset(tsb, 0, sizeof(*tsb));
 
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 526ea74..7a152d9 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1802,7 +1802,7 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		eth_type = skb_network_offset(skb) == ETH_HLEN ?
 			CPL_ETH_II : CPL_ETH_II_VLAN;
 
-		hdr = (struct cpl_tx_pkt_lso *)skb_push(skb, sizeof(*hdr));
+		hdr = skb_push(skb, sizeof(*hdr));
 		hdr->opcode = CPL_TX_PKT_LSO;
 		hdr->ip_csum_dis = hdr->l4_csum_dis = 0;
 		hdr->ip_hdr_words = ip_hdr(skb)->ihl;
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4ee080d..f5a0abb 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2165,7 +2165,7 @@ static int gfar_enet_open(struct net_device *dev)
 
 static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 {
-	struct txfcb *fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
+	struct txfcb *fcb = skb_push(skb, GMAC_FCB_LEN);
 
 	memset(fcb, 0, GMAC_FCB_LEN);
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 0c5842a..de31e04 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6671,7 +6671,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 	headroom = align + sizeof(struct tx_pkt_hdr);
 
 	ehdr = (struct ethhdr *) skb->data;
-	tp = (struct tx_pkt_hdr *) skb_push(skb, headroom);
+	tp = skb_push(skb, headroom);
 
 	len = skb->len - sizeof(struct tx_pkt_hdr);
 	tp->flags = cpu_to_le64(niu_compute_tx_flags(skb, ehdr, align, len));
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index ac62a5e..2fea1a1 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -754,7 +754,7 @@ static struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
 			return NULL;
 		dev_kfree_skb_any(sk_tmp);
 	}
-	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+	veth = skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the top of buffer */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 95c0b45..93023d5 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1422,7 +1422,7 @@ static netdev_tx_t rr_start_xmit(struct sk_buff *skb,
 		skb = new_skb;
 	}
 
-	ifield = (u32 *)skb_push(skb, 8);
+	ifield = skb_push(skb, 8);
 
 	ifield[0] = 0;
 	ifield[1] = hcb->ifield;
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index 1cc24e6..cbb5512 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -175,7 +175,7 @@ genelink_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	}
 
 	// attach the packet count to the header
-	packet_count = (__le32 *) skb_push(skb, (4 + 4*1));
+	packet_count = skb_push(skb, (4 + 4 * 1));
 	packet_len = packet_count + 1;
 
 	*packet_count = cpu_to_le32(1);
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index 5714107..809e658 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -304,7 +304,7 @@ encapsulate:
 	memset(&packet->dummy, 0, sizeof(packet->dummy));
 	packet->len = cpu_to_le32(orig_len);
 
-	frame = (struct vl600_frame_hdr *) skb_push(skb, sizeof(*frame));
+	frame = skb_push(skb, sizeof(*frame));
 	memset(frame, 0, sizeof(*frame));
 	frame->len = cpu_to_le32(full_len);
 	frame->serial = cpu_to_le32(serial++);
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index c8936d0..d6d6ce2 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -475,7 +475,7 @@ net1080_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 
 encapsulate:
 	/* header first */
-	header = (struct nc_header *) skb_push(skb, sizeof *header);
+	header = skb_push(skb, sizeof *header);
 	header->hdr_len = cpu_to_le16(sizeof (*header));
 	header->packet_len = cpu_to_le16(len);
 	header->packet_id = cpu_to_le16((u16)dev->xid++);
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index a9970f1..fc7b90f 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -221,7 +221,7 @@ void i2400m_tx_prep_header(struct sk_buff *skb)
 {
 	struct i2400m_pl_data_hdr *pl_hdr;
 	skb_pull(skb, ETH_HLEN);
-	pl_hdr = (struct i2400m_pl_data_hdr *) skb_push(skb, sizeof(*pl_hdr));
+	pl_hdr = skb_push(skb, sizeof(*pl_hdr));
 	pl_hdr->reserved = 0;
 }
 
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f07a618..ea4c2a0 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1684,7 +1684,7 @@ static void adm8211_tx(struct ieee80211_hw *dev,
 	skb_pull(skb, hdrlen);
 	payload_len = skb->len;
 
-	txhdr = (struct adm8211_tx_hdr *) skb_push(skb, sizeof(*txhdr));
+	txhdr = skb_push(skb, sizeof(*txhdr));
 	memset(txhdr, 0, sizeof(*txhdr));
 	memcpy(txhdr->da, ieee80211_get_DA(hdr), ETH_ALEN);
 	txhdr->signal = plcp_signal;
diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index 5147ebe..f5cdab3 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -832,8 +832,8 @@ static void ar5523_tx_work_locked(struct ar5523 *ar)
 		data->ar = ar;
 		data->urb = urb;
 
-		desc = (struct ar5523_tx_desc *)skb_push(skb, sizeof(*desc));
-		chunk = (struct ar5523_chunk *)skb_push(skb, sizeof(*chunk));
+		desc = skb_push(skb, sizeof(*desc));
+		chunk = skb_push(skb, sizeof(*chunk));
 
 		chunk->seqnum = 0;
 		chunk->flags = UATH_CFLAGS_FINAL;
diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index 75c02a0..dae4d04 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -228,8 +228,7 @@ static int htc_issue_packets(struct htc_target *target,
 		payload_len = packet->act_len;
 
 		/* setup HTC frame header */
-		htc_hdr = (struct htc_frame_hdr *) skb_push(skb,
-							    sizeof(*htc_hdr));
+		htc_hdr = skb_push(skb, sizeof(*htc_hdr));
 		if (!htc_hdr) {
 			WARN_ON_ONCE(1);
 			status = -EINVAL;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 10c02f5..540eda6 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -200,7 +200,7 @@ static int hif_usb_send_mgmt(struct hif_device_usb *hif_dev,
 	cmd->skb = skb;
 	cmd->hif_dev = hif_dev;
 
-	hdr = (__le16 *) skb_push(skb, 4);
+	hdr = skb_push(skb, 4);
 	*hdr++ = cpu_to_le16(skb->len - 4);
 	*hdr++ = cpu_to_le16(ATH_USB_TX_STREAM_MODE_TAG);
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 3d046c1..2919aa3 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -26,8 +26,7 @@ static int htc_issue_send(struct htc_target *target, struct sk_buff* skb,
 	struct htc_endpoint *endpoint = &target->endpoint[epid];
 	int status;
 
-	hdr = (struct htc_frame_hdr *)
-		skb_push(skb, sizeof(struct htc_frame_hdr));
+	hdr = skb_push(skb, sizeof(struct htc_frame_hdr));
 	hdr->endpoint_id = epid;
 	hdr->flags = flags;
 	hdr->payload_len = cpu_to_be16(len);
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 51cec61..d5881ea 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -277,7 +277,7 @@ static int ath9k_wmi_cmd_issue(struct wmi *wmi,
 	struct wmi_cmd_hdr *hdr;
 	unsigned long flags;
 
-	hdr = (struct wmi_cmd_hdr *) skb_push(skb, sizeof(struct wmi_cmd_hdr));
+	hdr = skb_push(skb, sizeof(struct wmi_cmd_hdr));
 	hdr->command_id = cpu_to_be16(cmd);
 	hdr->seq_no = cpu_to_be16(++wmi->tx_seq_id);
 
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/ath/carl9170/tx.c
index ae86a600..4c86487 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -991,7 +991,7 @@ static int carl9170_tx_prepare(struct ar9170 *ar,
 	else
 		cvif = NULL;
 
-	txc = (void *)skb_push(skb, sizeof(*txc));
+	txc = skb_push(skb, sizeof(*txc));
 	memset(txc, 0, sizeof(*txc));
 
 	SET_VAL(CARL9170_TX_SUPER_MISC_QUEUE, txc->s.misc, hw_queue);
diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wireless/ath/wil6210/txrx.c
index e8bd512..3260ad3 100644
--- a/drivers/net/wireless/ath/wil6210/txrx.c
+++ b/drivers/net/wireless/ath/wil6210/txrx.c
@@ -322,7 +322,7 @@ static void wil_rx_add_radiotap_header(struct wil6210_priv *wil,
 		return;
 	}
 
-	rtap_vendor = (void *)skb_push(skb, rtap_len);
+	rtap_vendor = skb_push(skb, rtap_len);
 	memset(rtap_vendor, 0, rtap_len);
 
 	rtap_vendor->rtap.rthdr.it_version = PKTHDR_RADIOTAP_VERSION;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 369527e..a41ff6a 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -6269,7 +6269,7 @@ brcms_c_d11hdrs_mac80211(struct brcms_c_info *wlc, struct ieee80211_hw *hw,
 	plcp = skb_push(p, D11_PHY_HDR_LEN);
 
 	/* add Broadcom tx descriptor header */
-	txh = (struct d11txh *) skb_push(p, D11_TXH_LEN);
+	txh = skb_push(p, D11_TXH_LEN);
 	memset(txh, 0, D11_TXH_LEN);
 
 	/* setup frameid */
diff --git a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/cw1200/txrx.c
index d28bd49..3889a04 100644
--- a/drivers/net/wireless/cw1200/txrx.c
+++ b/drivers/net/wireless/cw1200/txrx.c
@@ -574,7 +574,7 @@ cw1200_tx_h_wsm(struct cw1200_common *priv,
 		return NULL;
 	}
 
-	wsm = (struct wsm_tx *)skb_push(t->skb, sizeof(struct wsm_tx));
+	wsm = skb_push(t->skb, sizeof(struct wsm_tx));
 	t->txpriv.offset += sizeof(struct wsm_tx);
 	memset(wsm, 0, sizeof(*wsm));
 	wsm->hdr.len = __cpu_to_le16(t->skb->len);
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 599f30f..bdb6b4f 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -131,8 +131,7 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 
 	if (prism_header == 1) {
 		struct linux_wlan_ng_prism_hdr *hdr;
-		hdr = (struct linux_wlan_ng_prism_hdr *)
-			skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->msgcode = LWNG_CAP_DID_BASE;
 		hdr->msglen = sizeof(*hdr);
@@ -153,8 +152,7 @@ hdr->f.status = s; hdr->f.len = l; hdr->f.data = d
 #undef LWNG_SETVAL
 	} else if (prism_header == 2) {
 		struct linux_wlan_ng_cap_hdr *hdr;
-		hdr = (struct linux_wlan_ng_cap_hdr *)
-			skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->version    = htonl(LWNG_CAPHDR_VERSION);
 		hdr->length     = htonl(phdrlen);
@@ -172,7 +170,7 @@ hdr->f.status = s; hdr->f.len = l; hdr->f.data = d
 		hdr->encoding   = htonl(1); /* cck */
 	} else if (prism_header == 3) {
 		struct hostap_radiotap_rx *hdr;
-		hdr = (struct hostap_radiotap_rx *)skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->hdr.it_len = cpu_to_le16(phdrlen);
 		hdr->hdr.it_present =
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index e446fed..46582f2 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -262,7 +262,7 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
 		goto done;
 	}
 
-	pradiotap_hdr = (void *)skb_push(skb, sizeof(struct rx_radiotap_hdr));
+	pradiotap_hdr = skb_push(skb, sizeof(struct rx_radiotap_hdr));
 	memcpy(pradiotap_hdr, &radiotap_hdr, sizeof(struct rx_radiotap_hdr));
 
 	priv->cur_rate = lbs_fw_index_to_data_rate(prxpd->rx_rate);
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index ed02e4b..5b6cd2f5 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -267,7 +267,7 @@ static void lbtf_tx_work(struct work_struct *work)
 
 	len = skb->len;
 	info  = IEEE80211_SKB_CB(skb);
-	txpd = (struct txpd *)  skb_push(skb, sizeof(struct txpd));
+	txpd = skb_push(skb, sizeof(struct txpd));
 
 	if (priv->surpriseremoved) {
 		dev_kfree_skb_any(skb);
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index fc597dd..c958778 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -817,7 +817,7 @@ static void mac80211_hwsim_monitor_rx(struct ieee80211_hw *hw,
 	if (skb == NULL)
 		return;
 
-	hdr = (struct hwsim_radiotap_hdr *) skb_push(skb, sizeof(*hdr));
+	hdr = skb_push(skb, sizeof(*hdr));
 	hdr->hdr.it_version = PKTHDR_RADIOTAP_VERSION;
 	hdr->hdr.it_pad = 0;
 	hdr->hdr.it_len = cpu_to_le16(sizeof(*hdr));
@@ -1087,7 +1087,7 @@ static void mac80211_hwsim_add_vendor_rtap(struct sk_buff *skb)
 	 * Note that this code requires the headroom in the SKB
 	 * that was allocated earlier.
 	 */
-	rtap = (void *)skb_push(skb, sizeof(*rtap) + 8 + 4);
+	rtap = skb_push(skb, sizeof(*rtap) + 8 + 4);
 	rtap->oui[0] = HWSIM_RADIOTAP_OUI[0];
 	rtap->oui[1] = HWSIM_RADIOTAP_OUI[1];
 	rtap->oui[2] = HWSIM_RADIOTAP_OUI[2];
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index c410180..c69d04e 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -407,7 +407,7 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 		memcpy(hdr.encap, encaps_hdr, sizeof(encaps_hdr));
 
 		/* Make room for the new header, and copy it in */
-		eh = (struct ethhdr *) skb_push(skb, ENCAPS_OVERHEAD);
+		eh = skb_push(skb, ENCAPS_OVERHEAD);
 		memcpy(eh, &hdr, sizeof(hdr));
 	}
 
@@ -1044,11 +1044,10 @@ static void orinoco_rx(struct net_device *dev,
 		/* These indicate a SNAP within 802.2 LLC within
 		   802.11 frame which we'll need to de-encapsulate to
 		   the original EthernetII frame. */
-		hdr = (struct ethhdr *)skb_push(skb,
-						ETH_HLEN - ENCAPS_OVERHEAD);
+		hdr = skb_push(skb, ETH_HLEN - ENCAPS_OVERHEAD);
 	} else {
 		/* 802.3 frame - prepend 802.3 header as is */
-		hdr = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+		hdr = skb_push(skb, ETH_HLEN);
 		hdr->h_proto = htons(length);
 	}
 	memcpy(hdr->h_dest, desc->addr1, ETH_ALEN);
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 24e5ff9..42521d7 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -815,8 +815,8 @@ void p54_tx_80211(struct ieee80211_hw *dev,
 		}
 	}
 
-	txhdr = (struct p54_tx_data *) skb_push(skb, sizeof(*txhdr) + padding);
-	hdr = (struct p54_hdr *) skb_push(skb, sizeof(*hdr));
+	txhdr = skb_push(skb, sizeof(*txhdr) + padding);
+	hdr = skb_push(skb, sizeof(*hdr));
 
 	if (padding)
 		hdr_flags |= P54_HDR_FLAG_DATA_ALIGN;
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 674658f..6ac8e24 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -276,10 +276,7 @@ islpci_monitor_rx(islpci_private *priv, struct sk_buff **skb)
 		}
 
 		/* make room for the new header and fill it. */
-		avs =
-		    (struct avs_80211_1_header *) skb_push(*skb,
-							   sizeof (struct
-								   avs_80211_1_header));
+		avs = skb_push(*skb, sizeof(struct avs_80211_1_header));
 
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 629ad8c..bbd2988 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -278,8 +278,7 @@ static void rtl8187_tx(struct ieee80211_hw *dev,
 	}
 
 	if (!priv->is_rtl8187b) {
-		struct rtl8187_tx_hdr *hdr =
-			(struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
+		struct rtl8187_tx_hdr *hdr = skb_push(skb, sizeof(*hdr));
 		hdr->flags = cpu_to_le32(flags);
 		hdr->len = 0;
 		hdr->rts_duration = rts_dur;
@@ -292,8 +291,7 @@ static void rtl8187_tx(struct ieee80211_hw *dev,
 		unsigned int epmap[4] = { 6, 7, 5, 4 };
 		u16 fc = le16_to_cpu(tx_hdr->frame_control);
 
-		struct rtl8187b_tx_hdr *hdr =
-			(struct rtl8187b_tx_hdr *)skb_push(skb, sizeof(*hdr));
+		struct rtl8187b_tx_hdr *hdr = skb_push(skb, sizeof(*hdr));
 		struct ieee80211_rate *txrate =
 			ieee80211_get_tx_rate(dev, info);
 		memset(hdr, 0, sizeof(*hdr));
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index cbead00..065e8fb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -516,7 +516,7 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 
 	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
 	rtl_get_tcb_desc(hw, info, sta, skb, tcb_desc);
-	txdesc = (u8 *)skb_push(skb, RTL_TX_HEADER_SIZE);
+	txdesc = skb_push(skb, RTL_TX_HEADER_SIZE);
 	memset(txdesc, 0, RTL_TX_HEADER_SIZE);
 	SET_TX_DESC_PKT_SIZE(txdesc, pktlen);
 	SET_TX_DESC_LINIP(txdesc, 0);
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 81de83c..de2fa67 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -161,8 +161,7 @@ static int wl1251_tx_fill_hdr(struct wl1251 *wl, struct sk_buff *skb,
 		return id;
 
 	fc = *(u16 *)skb->data;
-	tx_hdr = (struct tx_double_buffer_desc *) skb_push(skb,
-							   sizeof(*tx_hdr));
+	tx_hdr = skb_push(skb, sizeof(*tx_hdr));
 
 	tx_hdr->length = cpu_to_le16(skb->len - sizeof(*tx_hdr));
 	rate = ieee80211_get_tx_rate(wl->hw, control);
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index d4899c8..d464abd 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -1280,7 +1280,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		memset(skb_push(skb, sizeof(__le16)), 0, sizeof(__le16));
 
 	/* mac80211 header */
-	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
+	hdr = skb_push(skb, sizeof(*hdr));
 	memset(hdr, 0, sizeof(*hdr));
 	fc = IEEE80211_FTYPE_DATA | IEEE80211_FCTL_TODS;
 	if (wlvif->sta.qos)
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index f0ac361..a06de70 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -223,8 +223,7 @@ static int wl1271_tx_allocate(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	total_blocks = wlcore_hw_calc_tx_blocks(wl, total_len, spare_blocks);
 
 	if (total_blocks <= wl->tx_blocks_available) {
-		desc = (struct wl1271_tx_hw_descr *)skb_push(
-			skb, total_len - skb->len);
+		desc = skb_push(skb, total_len - skb->len);
 
 		wlcore_hw_set_tx_desc_blocks(wl, desc, total_blocks,
 					     spare_blocks);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index e7af261..87b1845 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -868,8 +868,7 @@ static int fill_ctrlset(struct zd_mac *mac,
 	unsigned int frag_len = skb->len + FCS_LEN;
 	unsigned int packet_length;
 	struct ieee80211_rate *txrate;
-	struct zd_ctrlset *cs = (struct zd_ctrlset *)
-		skb_push(skb, sizeof(struct zd_ctrlset));
+	struct zd_ctrlset *cs = skb_push(skb, sizeof(struct zd_ctrlset));
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 	ZD_ASSERT(frag_len <= 0xffff);
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 0ea0869..6336431 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -768,8 +768,7 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						sizeof(struct qeth_hdr));
 			if (!new_skb)
 				goto tx_drop;
-			hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr));
+			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
 			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
 			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
 		}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 04e42c6..02f5bd7 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3035,16 +3035,14 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (large_send && (cast_type == RTN_UNSPEC)) {
-		hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr_tso));
+		hdr = skb_push(new_skb, sizeof(struct qeth_hdr_tso));
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
 		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
 		qeth_tso_fill_header(card, hdr, new_skb);
 		elements_needed++;
 	} else {
 		if (data_offset < 0) {
-			hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr));
+			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
 			qeth_l3_fill_header(card, hdr, new_skb, ipv,
 						cast_type);
 		} else {
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index c150d9e..a3c3728 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -623,7 +623,7 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip, struct fc_lport *lport,
 	fh = (struct fc_frame_header *)skb->data;
 	op = *(u8 *)(fh + 1);
 	dlen = sizeof(struct fip_encaps) + skb->len;	/* len before push */
-	cap = (struct fip_encaps_head *)skb_push(skb, sizeof(*cap));
+	cap = skb_push(skb, sizeof(*cap));
 	memset(cap, 0, sizeof(*cap));
 
 	if (lport->point_to_multipoint) {
diff --git a/drivers/scsi/fnic/fnic_fcs.c b/drivers/scsi/fnic/fnic_fcs.c
index bf0bbd4..22676fb 100644
--- a/drivers/scsi/fnic/fnic_fcs.c
+++ b/drivers/scsi/fnic/fnic_fcs.c
@@ -984,8 +984,7 @@ void fnic_eth_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
 
 	if (!fnic->vlan_hw_insert) {
 		eth_hdr = (struct ethhdr *)skb_mac_header(skb);
-		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb,
-				sizeof(*vlan_hdr) - sizeof(*eth_hdr));
+		vlan_hdr = skb_push(skb, sizeof(*vlan_hdr) - sizeof(*eth_hdr));
 		memcpy(vlan_hdr, eth_hdr, 2 * ETH_ALEN);
 		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
 		vlan_hdr->h_vlan_encapsulated_proto = eth_hdr->h_proto;
@@ -1042,7 +1041,7 @@ static int fnic_send_frame(struct fnic *fnic, struct fc_frame *fp)
 
 	if (!fnic->vlan_hw_insert) {
 		eth_hdr_len = sizeof(*vlan_hdr) + sizeof(*fcoe_hdr);
-		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb, eth_hdr_len);
+		vlan_hdr = skb_push(skb, eth_hdr_len);
 		eth_hdr = (struct ethhdr *)vlan_hdr;
 		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
 		vlan_hdr->h_vlan_encapsulated_proto = htons(ETH_P_FCOE);
@@ -1050,7 +1049,7 @@ static int fnic_send_frame(struct fnic *fnic, struct fc_frame *fp)
 		fcoe_hdr = (struct fcoe_hdr *)(vlan_hdr + 1);
 	} else {
 		eth_hdr_len = sizeof(*eth_hdr) + sizeof(*fcoe_hdr);
-		eth_hdr = (struct ethhdr *)skb_push(skb, eth_hdr_len);
+		eth_hdr = skb_push(skb, eth_hdr_len);
 		eth_hdr->h_proto = htons(ETH_P_FCOE);
 		fcoe_hdr = (struct fcoe_hdr *)(eth_hdr + 1);
 	}
diff --git a/drivers/staging/wlan-ng/p80211conv.c b/drivers/staging/wlan-ng/p80211conv.c
index bd69e8c..868b85e 100644
--- a/drivers/staging/wlan-ng/p80211conv.c
+++ b/drivers/staging/wlan-ng/p80211conv.c
@@ -147,9 +147,7 @@ int skb_ether_to_p80211(wlandevice_t *wlandev, u32 ethconv,
 			skb_pull(skb, WLAN_ETHHDR_LEN);
 
 			/* tack on SNAP */
-			e_snap =
-			    (struct wlan_snap *) skb_push(skb,
-				sizeof(struct wlan_snap));
+			e_snap = skb_push(skb, sizeof(struct wlan_snap));
 			e_snap->type = htons(proto);
 			if (ethconv == WLAN_ETHCONV_8021h
 			    && p80211_stt_findproto(proto)) {
@@ -161,9 +159,7 @@ int skb_ether_to_p80211(wlandevice_t *wlandev, u32 ethconv,
 			}
 
 			/* tack on llc */
-			e_llc =
-			    (struct wlan_llc *) skb_push(skb,
-				sizeof(struct wlan_llc));
+			e_llc = skb_push(skb, sizeof(struct wlan_llc));
 			e_llc->dsap = 0xAA;	/* SNAP, see IEEE 802 */
 			e_llc->ssap = 0xAA;
 			e_llc->ctl = 0x03;
@@ -404,7 +400,7 @@ int skb_p80211_to_ether(wlandevice_t *wlandev, u32 ethconv,
 		skb_pull(skb, payload_offset);
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *) skb_push(skb, WLAN_ETHHDR_LEN);
+		e_hdr = skb_push(skb, WLAN_ETHHDR_LEN);
 		memcpy(e_hdr->daddr, daddr, WLAN_ETHADDR_LEN);
 		memcpy(e_hdr->saddr, saddr, WLAN_ETHADDR_LEN);
 		e_hdr->type = htons(payload_length);
@@ -444,7 +440,7 @@ int skb_p80211_to_ether(wlandevice_t *wlandev, u32 ethconv,
 		skb_pull(skb, sizeof(struct wlan_snap));
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *) skb_push(skb, WLAN_ETHHDR_LEN);
+		e_hdr = skb_push(skb, WLAN_ETHHDR_LEN);
 		e_hdr->type = e_snap->type;
 		memcpy(e_hdr->daddr, daddr, WLAN_ETHADDR_LEN);
 		memcpy(e_hdr->saddr, saddr, WLAN_ETHADDR_LEN);
@@ -471,7 +467,7 @@ int skb_p80211_to_ether(wlandevice_t *wlandev, u32 ethconv,
 		skb_pull(skb, payload_offset);
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *) skb_push(skb, WLAN_ETHHDR_LEN);
+		e_hdr = skb_push(skb, WLAN_ETHHDR_LEN);
 		memcpy(e_hdr->daddr, daddr, WLAN_ETHADDR_LEN);
 		memcpy(e_hdr->saddr, saddr, WLAN_ETHADDR_LEN);
 		e_hdr->type = htons(payload_length);
diff --git a/drivers/usb/gadget/function/rndis.c b/drivers/usb/gadget/function/rndis.c
index 95d2324..f378bf9 100644
--- a/drivers/usb/gadget/function/rndis.c
+++ b/drivers/usb/gadget/function/rndis.c
@@ -952,7 +952,7 @@ void rndis_add_hdr(struct sk_buff *skb)
 
 	if (!skb)
 		return;
-	header = (void *)skb_push(skb, sizeof(*header));
+	header = skb_push(skb, sizeof(*header));
 	memset(header, 0, sizeof *header);
 	header->MessageType = cpu_to_le32(RNDIS_MSG_PACKET);
 	header->MessageLength = cpu_to_le32(skb->len);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 920e445..e041c32 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -300,7 +300,7 @@ static inline int __vlan_insert_tag(struct sk_buff *skb,
 	if (skb_cow_head(skb, VLAN_HLEN) < 0)
 		return -ENOMEM;
 
-	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+	veth = skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the beginning of the new header. */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
diff --git a/net/802/fc.c b/net/802/fc.c
index 7b92190..4f6b2a9 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -49,7 +49,7 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 		struct fcllc *fcllc;
 
 		hdr_len = sizeof(struct fch_hdr) + sizeof(struct fcllc);
-		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
+		fch = skb_push(skb, hdr_len);
 		fcllc = (struct fcllc *)(fch+1);
 		fcllc->dsap = fcllc->ssap = EXTENDED_SAP;
 		fcllc->llc = UI_CMD;
@@ -59,7 +59,7 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 	else
 	{
 		hdr_len = sizeof(struct fch_hdr);
-		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
+		fch = skb_push(skb, hdr_len);
 	}
 
 	if(saddr)
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 7d3a0af..00acac6 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -58,7 +58,7 @@ static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 
 	if(type != ETH_P_IP && type != ETH_P_IPV6 && type != ETH_P_ARP)
 		hl=FDDI_K_8022_HLEN-3;
-	fddi = (struct fddihdr *)skb_push(skb, hl);
+	fddi = skb_push(skb, hl);
 	fddi->fc			 = FDDI_FC_K_ASYNC_LLC_DEF;
 	if(type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP)
 	{
diff --git a/net/802/hippi.c b/net/802/hippi.c
index ade1a52..2aa74dc 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -47,7 +47,7 @@ static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type,
 			const void *daddr, const void *saddr, unsigned int len)
 {
-	struct hippi_hdr *hip = (struct hippi_hdr *)skb_push(skb, HIPPI_HLEN);
+	struct hippi_hdr *hip = skb_push(skb, HIPPI_HLEN);
 	struct hippi_cb *hcb = (struct hippi_cb *) skb->cb;
 
 	if (!len){
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 01d7ba8..14def3a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -57,7 +57,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	int rc;
 
 	if (!(vlan->flags & VLAN_FLAG_REORDER_HDR)) {
-		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
+		vhdr = skb_push(skb, VLAN_HLEN);
 
 		vlan_tci = vlan->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb->priority);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index a2db716..5e03c8d 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1529,7 +1529,7 @@ static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		 * The push leaves us with a ddephdr not an shdr, and
 		 * handily the port bytes in the right place preset.
 		 */
-		ddp = (struct ddpehdr *) skb_push(skb, sizeof(*ddp) - 4);
+		ddp = skb_push(skb, sizeof(*ddp) - 4);
 
 		/* Now fill in the long header */
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 233b975..c934adf 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -289,7 +289,7 @@ void hci_send_to_monitor(struct hci_dev *hdev, struct sk_buff *skb)
 		return;
 
 	/* Put header before the data */
-	hdr = (void *) skb_push(skb_copy, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb_copy, HCI_MON_HDR_SIZE);
 	hdr->opcode = opcode;
 	hdr->index = cpu_to_le16(hdev->id);
 	hdr->len = cpu_to_le16(skb->len);
@@ -335,7 +335,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 
 	__net_timestamp(skb);
 
-	hdr = (void *) skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = opcode;
 	hdr->index = cpu_to_le16(hdev->id);
 	hdr->len = cpu_to_le16(skb->len - HCI_MON_HDR_SIZE);
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 4fea242..2ff2fc1 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1153,10 +1153,10 @@ static void rfcomm_make_uih(struct sk_buff *skb, u8 addr)
 	u8 *crc;
 
 	if (len > 127) {
-		hdr = (void *) skb_push(skb, 4);
+		hdr = skb_push(skb, 4);
 		put_unaligned(cpu_to_le16(__len16(len)), (__le16 *) &hdr->len);
 	} else {
-		hdr = (void *) skb_push(skb, 3);
+		hdr = skb_push(skb, 3);
 		hdr->len = __len8(len);
 	}
 	hdr->addr = addr;
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index bf4e51f..4b6706c 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -29,7 +29,7 @@ static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
 {
 	struct ethhdr *eth;
 
-	eth = (struct ethhdr *)skb_push(nskb, ETH_HLEN);
+	eth = skb_push(nskb, ETH_HLEN);
 	skb_reset_mac_header(nskb);
 	ether_addr_copy(eth->h_source, eth_hdr(oldskb)->h_dest);
 	ether_addr_copy(eth->h_dest, eth_hdr(oldskb)->h_source);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c126a87..2a710ca 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -428,7 +428,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		ip6h->saddr = np->local_ip.in6;
 		ip6h->daddr = np->remote_ip.in6;
 
-		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		eth = skb_push(skb, ETH_HLEN);
 		skb_reset_mac_header(skb);
 		skb->protocol = eth->h_proto = htons(ETH_P_IPV6);
 	} else {
@@ -457,7 +457,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		put_unaligned(np->remote_ip.ip, &(iph->daddr));
 		iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
-		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		eth = skb_push(skb, ETH_HLEN);
 		skb_reset_mac_header(skb);
 		skb->protocol = eth->h_proto = htons(ETH_P_IP);
 	}
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 127d466..d0ed22f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2616,7 +2616,7 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 				goto err;
 			}
 			/* restore ll */
-			eth = (__u8 *) skb_push(skb, ETH_HLEN);
+			eth = skb_push(skb, ETH_HLEN);
 			memcpy(eth, pkt_dev->hh, 12);
 			*(u16 *) &eth[12] = protocol;
 
@@ -2783,7 +2783,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb_reserve(skb, datalen);
 
 	/*  Reserve for ethernet and IP header  */
-	eth = (__u8 *) skb_push(skb, 14);
+	eth = skb_push(skb, 14);
 	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
@@ -2911,7 +2911,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb_reserve(skb, 16);
 
 	/*  Reserve for ethernet and IP header  */
-	eth = (__u8 *) skb_push(skb, 14);
+	eth = skb_push(skb, 14);
 	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 577d913..246044b 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -863,7 +863,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	msg->datalen = 0x02;
 	memset(msg->data, 0xAA, 2);
 
-	pktlen = (__le16 *)skb_push(skb,2);
+	pktlen = skb_push(skb, 2);
 	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
@@ -955,7 +955,7 @@ static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 	skb_trim(skb, (27 + *i2));
 
-	pktlen = (__le16 *)skb_push(skb, 2);
+	pktlen = skb_push(skb, 2);
 	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 314e4c5..29f6256 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -79,7 +79,7 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 	       unsigned short type,
 	       const void *daddr, const void *saddr, unsigned int len)
 {
-	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+	struct ethhdr *eth = skb_push(skb, ETH_HLEN);
 
 	if (type != ETH_P_802_3 && type != ETH_P_802_2)
 		eth->h_proto = htons(type);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5fd7064..67470d8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -374,7 +374,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	struct iphdr *iph;
 	struct gre_base_hdr *greh;
 
-	iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
+	iph = skb_push(skb, t->hlen + sizeof(*iph));
 	greh = (struct gre_base_hdr *)(iph+1);
 	greh->flags = tnl_flags_to_gre_flags(t->parms.o_flags);
 	greh->protocol = htons(type);
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a7bbbe4..fe95eea 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -661,7 +661,7 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 
 	ihdr = (struct rt0_hdr *) opt;
 
-	phdr = (struct rt0_hdr *) skb_push(skb, (ihdr->rt_hdr.hdrlen + 1) << 3);
+	phdr = skb_push(skb, (ihdr->rt_hdr.hdrlen + 1) << 3);
 	memcpy(phdr, ihdr, sizeof(struct rt0_hdr));
 
 	hops = ihdr->rt_hdr.hdrlen >> 1;
@@ -679,7 +679,7 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 
 static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 type, struct ipv6_opt_hdr *opt)
 {
-	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, ipv6_optlen(opt));
+	struct ipv6_opt_hdr *h = skb_push(skb, ipv6_optlen(opt));
 
 	memcpy(h, opt, ipv6_optlen(opt));
 	h->nexthdr = *proto;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a38d3ac..782a29c 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1177,7 +1177,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
+	struct ipv6hdr *ipv6h = skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
 
 	ip6_flow_hdr(ipv6h, 0,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6575d6..63d9c00 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -755,7 +755,7 @@ static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
 
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
-	t1 = (struct tcphdr *) skb_push(buff, tot_len);
+	t1 = skb_push(buff, tot_len);
 	skb_reset_transport_header(buff);
 
 	/* Swap the send and the receive. */
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 6daa52a..e65c620 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -322,8 +322,7 @@ static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
 	int err, confirm_recv = 0;
 
 	memset(skb->head, 0, ETH_HLEN);
-	phs_hdr = (struct af_iucv_trans_hdr *)skb_push(skb,
-					sizeof(struct af_iucv_trans_hdr));
+	phs_hdr = skb_push(skb, sizeof(struct af_iucv_trans_hdr));
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb_push(skb, ETH_HLEN);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index b1aaea6..5b4248a 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -178,7 +178,7 @@ ieee80211_add_rx_radiotap_header(struct ieee80211_local *local,
 	if (!(has_fcs && (local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS)))
 		mpdulen += FCS_LEN;
 
-	rthdr = (struct ieee80211_radiotap_header *)skb_push(skb, rtap_len);
+	rthdr = skb_push(skb, rtap_len);
 	memset(rthdr, 0, rtap_len - rtap.len - rtap.pad);
 	it_present = &rthdr->it_present;
 
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 005fdbe..a2334d5 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -280,7 +280,7 @@ ieee80211_add_tx_radiotap_header(struct ieee80211_local *local,
 	unsigned char *pos;
 	u16 txflags;
 
-	rthdr = (struct ieee80211_radiotap_header *) skb_push(skb, rtap_len);
+	rthdr = skb_push(skb, rtap_len);
 
 	memset(rthdr, 0, rtap_len);
 	rthdr->it_len = cpu_to_le16(rtap_len);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 22f3382..34ac785 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2354,7 +2354,7 @@ static struct sk_buff *ieee80211_build_hdr(struct ieee80211_sub_if_data *sdata,
 	if (ieee80211_is_data_qos(fc)) {
 		__le16 *qos_control;
 
-		qos_control = (__le16 *) skb_push(skb, 2);
+		qos_control = skb_push(skb, 2);
 		memcpy(skb_push(skb, hdrlen - 2), &hdr, hdrlen - 2);
 		/*
 		 * Maybe we could actually set some fields here, for now just
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 566466d..28036df 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -81,7 +81,7 @@ static inline void nci_push_data_hdr(struct nci_dev *ndev,
 	struct nci_data_hdr *hdr;
 	int plen = skb->len;
 
-	hdr = (struct nci_data_hdr *) skb_push(skb, NCI_DATA_HDR_SIZE);
+	hdr = skb_push(skb, NCI_DATA_HDR_SIZE);
 	hdr->conn_id = conn_id;
 	hdr->rfu = 0;
 	hdr->plen = plen;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index fc5e45b..d7b53b3 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -425,7 +425,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	skb_dst_set(nskb, dst);
 
 	/* Build the SCTP header.  */
-	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
+	sh = skb_push(nskb, sizeof(struct sctphdr));
 	skb_reset_transport_header(nskb);
 	sh->source = htons(packet->source_port);
 	sh->dest   = htons(packet->destination_port);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3ee27b7..ed0aec9 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -771,8 +771,8 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 		auth.skb = chunk->auth_chunk;
 		auth.asoc = chunk->asoc;
 		auth.sctp_hdr = chunk->sctp_hdr;
-		auth.chunk_hdr = (sctp_chunkhdr_t *)skb_push(chunk->auth_chunk,
-					    sizeof(sctp_chunkhdr_t));
+		auth.chunk_hdr = skb_push(chunk->auth_chunk,
+					  sizeof(sctp_chunkhdr_t));
 		skb_pull(chunk->auth_chunk, sizeof(sctp_chunkhdr_t));
 		auth.transport = chunk->transport;
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 2202755..8b1706c 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -150,8 +150,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 		sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
 		/* Include the notification structure */
-		sac = (struct sctp_assoc_change *)
-			skb_push(skb, sizeof(struct sctp_assoc_change));
+		sac = skb_push(skb, sizeof(struct sctp_assoc_change));
 
 		/* Trim the buffer to the right length.  */
 		skb_trim(skb, sizeof(struct sctp_assoc_change) +
@@ -397,7 +396,7 @@ sctp_ulpevent_make_remote_error(const struct sctp_association *asoc,
 	event = sctp_skb2event(skb);
 	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
-	sre = (struct sctp_remote_error *) skb_push(skb, sizeof(*sre));
+	sre = skb_push(skb, sizeof(*sre));
 
 	/* Trim the buffer to the right length.  */
 	skb_trim(skb, sizeof(*sre) + elen);
@@ -448,8 +447,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_send_failed(
 	event = sctp_skb2event(skb);
 	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
-	ssf = (struct sctp_send_failed *)
-		skb_push(skb, sizeof(struct sctp_send_failed));
+	ssf = skb_push(skb, sizeof(struct sctp_send_failed));
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.4 SCTP_SEND_FAILED
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 70051ab..2de2e7d 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -518,7 +518,7 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 
 		skb_pull(skb, hdrlen);
 		len = htons(skb->len);
-		ehdr = (struct ethhdr *) skb_push(skb, sizeof(struct ethhdr));
+		ehdr = skb_push(skb, sizeof(struct ethhdr));
 		memcpy(ehdr->h_dest, dst, ETH_ALEN);
 		memcpy(ehdr->h_source, src, ETH_ALEN);
 		ehdr->h_proto = len;
-- 
2.1.4
