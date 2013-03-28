From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2] net: add ETH_P_802_3_MIN
Date: Thu, 28 Mar 2013 13:38:25 +0900
Message-ID: <1364445505-9745-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>,
	bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bart De Schuymer <bart.de.schuymer-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
an 802.3 frame. Frames with a lower value in the ethernet type field
are Ethernet II.

Also update all the users of this value that David Miller and
I could find to use the new constant.

Also correct a bug in util.c. The comparison with ETH_P_802_3_MIN
should be >= not >.

As suggested by Jesse Gross.

Compile tested only.

Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Cc: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Cc: Bart De Schuymer <bart.de.schuymer-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Acked-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2
* Make updates to the following files as suggested by David Miller
  - drivers/media/dvb-core/dvb_net.c
  - drivers/net/wireless/ray_cs.c
  - net/bridge/netfilter/ebtables.c
  - include/linux/if_vlan.h
  - net/bluetooth/bnep/netdev.c
  - net/openvswitch/flow.c
  - net/mac80211/tx.c
  - net/wireless/util.c
---
 drivers/firewire/net.c           |    2 +-
 drivers/isdn/i4l/isdn_net.c      |    2 +-
 drivers/media/dvb-core/dvb_net.c |   10 +++++-----
 drivers/net/ethernet/sun/niu.c   |    2 +-
 drivers/net/plip/plip.c          |    2 +-
 drivers/net/wireless/ray_cs.c    |    2 +-
 include/linux/if_vlan.h          |    2 +-
 include/uapi/linux/if_ether.h    |    3 +++
 net/atm/lec.h                    |    2 +-
 net/bluetooth/bnep/netdev.c      |    2 +-
 net/bridge/netfilter/ebtables.c  |    2 +-
 net/ethernet/eth.c               |    2 +-
 net/mac80211/tx.c                |    2 +-
 net/openvswitch/datapath.c       |    2 +-
 net/openvswitch/flow.c           |    6 +++---
 net/wireless/util.c              |    2 +-
 16 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 5679633..4d56536 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -547,7 +547,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 			if (memcmp(eth->h_dest, net->dev_addr, net->addr_len))
 				skb->pkt_type = PACKET_OTHERHOST;
 		}
-		if (ntohs(eth->h_proto) >= 1536) {
+		if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN) {
 			protocol = eth->h_proto;
 		} else {
 			rawp = (u16 *)skb->data;
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index babc621..88d657d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1385,7 +1385,7 @@ isdn_net_type_trans(struct sk_buff *skb, struct net_device *dev)
 		if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 44225b1..83a23af 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -185,7 +185,7 @@ static __be16 dvb_net_eth_type_trans(struct sk_buff *skb,
 			skb->pkt_type=PACKET_MULTICAST;
 	}
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
@@ -228,9 +228,9 @@ static int ule_test_sndu( struct dvb_net_priv *p )
 static int ule_bridged_sndu( struct dvb_net_priv *p )
 {
 	struct ethhdr *hdr = (struct ethhdr*) p->ule_next_hdr;
-	if(ntohs(hdr->h_proto) < 1536) {
+	if(ntohs(hdr->h_proto) < ETH_P_802_3_MIN) {
 		int framelen = p->ule_sndu_len - ((p->ule_next_hdr+sizeof(struct ethhdr)) - p->ule_skb->data);
-		/* A frame Type < 1536 for a bridged frame, introduces a LLC Length field. */
+		/* A frame Type < ETH_P_802_3_MIN for a bridged frame, introduces a LLC Length field. */
 		if(framelen != ntohs(hdr->h_proto)) {
 			return -1;
 		}
@@ -320,7 +320,7 @@ static int handle_ule_extensions( struct dvb_net_priv *p )
 			(int) p->ule_sndu_type, l, total_ext_len);
 #endif
 
-	} while (p->ule_sndu_type < 1536);
+	} while (p->ule_sndu_type < ETH_P_802_3_MIN);
 
 	return total_ext_len;
 }
@@ -712,7 +712,7 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 				}
 
 				/* Handle ULE Extension Headers. */
-				if (priv->ule_sndu_type < 1536) {
+				if (priv->ule_sndu_type < ETH_P_802_3_MIN) {
 					/* There is an extension header.  Handle it accordingly. */
 					int l = handle_ule_extensions(priv);
 					if (l < 0) {
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index e4c1c88..95cff98 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6618,7 +6618,7 @@ static u64 niu_compute_tx_flags(struct sk_buff *skb, struct ethhdr *ehdr,
 	       (len << TXHDR_LEN_SHIFT) |
 	       ((l3off / 2) << TXHDR_L3START_SHIFT) |
 	       (ihl << TXHDR_IHL_SHIFT) |
-	       ((eth_proto_inner < 1536) ? TXHDR_LLC : 0) |
+	       ((eth_proto_inner < ETH_P_802_3_MIN) ? TXHDR_LLC : 0) |
 	       ((eth_proto == ETH_P_8021Q) ? TXHDR_VLAN : 0) |
 	       (ipv6 ? TXHDR_IP_VER : 0) |
 	       csum_bits);
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index bed62d9..1f7bef9 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -560,7 +560,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *	so don't forget to remove it.
 	 */
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 4775b5d..ebada81 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -953,7 +953,7 @@ static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
 			   unsigned char *data, int len)
 {
 	__be16 proto = ((struct ethhdr *)data)->h_proto;
-	if (ntohs(proto) >= 1536) { /* DIX II ethernet frame */
+	if (ntohs(proto) >= ETH_P_802_3_MIN) { /* DIX II ethernet frame */
 		pr_debug("ray_cs translate_frame DIX II\n");
 		/* Copy LLC header to card buffer */
 		memcpy_toio(&ptx->var, eth2_llc, sizeof(eth2_llc));
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 218a3b6..70962f3 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -339,7 +339,7 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 	 */
 
 	proto = vhdr->h_vlan_encapsulated_proto;
-	if (ntohs(proto) >= 1536) {
+	if (ntohs(proto) >= ETH_P_802_3_MIN) {
 		skb->protocol = proto;
 		return;
 	}
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 798032d..ade07f1 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -94,6 +94,9 @@
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
 
+#define ETH_P_802_3_MIN	0x0600		/* If the value in the ethernet type is less than this value
+					 * then the frame is Ethernet II. Else it is 802.3 */
+
 /*
  *	Non DIX types. Won't clash for 1500 types.
  */
diff --git a/net/atm/lec.h b/net/atm/lec.h
index a86aff9..4149db1 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -58,7 +58,7 @@ struct lane2_ops {
  *    field in h_type field. Data follows immediately after header.
  * 2. LLC Data frames whose total length, including LLC field and data,
  *    but not padding required to meet the minimum data frame length,
- *    is less than 1536(0x0600) MUST be encoded by placing that length
+ *    is less than ETH_P_802_3_MIN MUST be encoded by placing that length
  *    in the h_type field. The LLC field follows header immediately.
  * 3. LLC data frames longer than this maximum MUST be encoded by placing
  *    the value 0 in the h_type field.
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index e58c8b3..4b488ec 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -136,7 +136,7 @@ static u16 bnep_net_eth_proto(struct sk_buff *skb)
 	struct ethhdr *eh = (void *) skb->data;
 	u16 proto = ntohs(eh->h_proto);
 
-	if (proto >= 1536)
+	if (proto >= ETH_P_802_3_MIN)
 		return proto;
 
 	if (get_unaligned((__be16 *) skb->data) == htons(0xFFFF))
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 8d493c9..3d110c4 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -138,7 +138,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		ethproto = h->h_proto;
 
 	if (e->bitmask & EBT_802_3) {
-		if (FWINV2(ntohs(ethproto) >= 1536, EBT_IPROTO))
+		if (FWINV2(ntohs(ethproto) >= ETH_P_802_3_MIN, EBT_IPROTO))
 			return 1;
 	} else if (!(e->bitmask & EBT_NOPROTO) &&
 	   FWINV2(e->ethproto != ethproto, EBT_IPROTO))
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a36c85ea..5359560 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -195,7 +195,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if (netdev_uses_trailer_tags(dev))
 		return htons(ETH_P_TRAILER);
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	/*
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 8914d2d..4e8a861 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2085,7 +2085,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		encaps_data = bridge_tunnel_header;
 		encaps_len = sizeof(bridge_tunnel_header);
 		skip_header_bytes -= 2;
-	} else if (ethertype >= 0x600) {
+	} else if (ethertype >= ETH_P_802_3_MIN) {
 		encaps_data = rfc1042_header;
 		encaps_len = sizeof(rfc1042_header);
 		skip_header_bytes -= 2;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d61cd99..8759265 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -681,7 +681,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	/* Normally, setting the skb 'protocol' field would be handled by a
 	 * call to eth_type_trans(), but it assumes there's a sending
 	 * device, which we may not have. */
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		packet->protocol = eth->h_proto;
 	else
 		packet->protocol = htons(ETH_P_802_2);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fe0e421..3324868 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -466,7 +466,7 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 	proto = *(__be16 *) skb->data;
 	__skb_pull(skb, sizeof(__be16));
 
-	if (ntohs(proto) >= 1536)
+	if (ntohs(proto) >= ETH_P_802_3_MIN)
 		return proto;
 
 	if (skb->len < sizeof(struct llc_snap_hdr))
@@ -483,7 +483,7 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 
 	__skb_pull(skb, sizeof(struct llc_snap_hdr));
 
-	if (ntohs(llc->ethertype) >= 1536)
+	if (ntohs(llc->ethertype) >= ETH_P_802_3_MIN)
 		return llc->ethertype;
 
 	return htons(ETH_P_802_2);
@@ -1038,7 +1038,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 
 	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
 		swkey->eth.type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-		if (ntohs(swkey->eth.type) < 1536)
+		if (ntohs(swkey->eth.type) < ETH_P_802_3_MIN)
 			return -EINVAL;
 		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 	} else {
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 37a56ee..6cbac99 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -511,7 +511,7 @@ int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 		encaps_data = bridge_tunnel_header;
 		encaps_len = sizeof(bridge_tunnel_header);
 		skip_header_bytes -= 2;
-	} else if (ethertype > 0x600) {
+	} else if (ethertype >= ETH_P_802_3_MIN) {
 		encaps_data = rfc1042_header;
 		encaps_len = sizeof(rfc1042_header);
 		skip_header_bytes -= 2;
-- 
1.7.10.4
