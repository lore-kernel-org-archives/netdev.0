From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH v2 net-next 2/5] net: Fix (nearly-)kernel-doc comments for
 various functions
Date: Tue, 10 Jul 2012 21:55:09 +0100
Message-ID: <1341953709.2605.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41147 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751996Ab2GJUzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 16:55:12 -0400
In-Reply-To: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect start markers, wrapped summary lines, missing section
breaks, incorrect separators, and some name mismatches.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/9p/trans_virtio.c                  |    2 +-
 net/appletalk/ddp.c                    |    8 ++--
 net/batman-adv/bridge_loop_avoidance.c |   51 +++++++++++++++++++++----------
 net/batman-adv/hash.h                  |    3 +-
 net/batman-adv/main.h                  |    3 +-
 net/batman-adv/types.h                 |    3 +-
 net/core/dev.c                         |    8 +++--
 net/core/rtnetlink.c                   |    2 +-
 net/core/skbuff.c                      |    5 ++-
 net/dccp/ackvec.h                      |    7 +++-
 net/dccp/ccid.c                        |    1 +
 net/dccp/ccids/ccid3.c                 |    8 ++++-
 net/dccp/ccids/lib/loss_interval.c     |    1 +
 net/dccp/ccids/lib/packet_history.c    |    3 +-
 net/dccp/ccids/lib/tfrc_equation.c     |    2 +
 net/dccp/dccp.h                        |    1 +
 net/dccp/feat.c                        |   10 ++++++
 net/dccp/input.c                       |    1 +
 net/dccp/options.c                     |    1 +
 net/dccp/output.c                      |    1 +
 net/ethernet/eth.c                     |    3 ++
 net/ipv4/ipmr.c                        |    4 +-
 net/ipv6/ip6_tunnel.c                  |    2 +-
 net/llc/af_llc.c                       |    2 +-
 net/llc/llc_station.c                  |   16 +++++-----
 net/mac80211/mesh.c                    |    2 +-
 net/mac80211/mesh_hwmp.c               |    7 +++-
 net/mac80211/mesh_pathtbl.c            |    4 +-
 net/mac80211/mesh_plink.c              |    5 ++-
 net/mac80211/rx.c                      |    2 +-
 net/netfilter/xt_TPROXY.c              |    4 +-
 net/netlink/genetlink.c                |    2 +-
 net/rds/page.c                         |    9 +++--
 net/rxrpc/ar-output.c                  |    2 +-
 net/sunrpc/backchannel_rqst.c          |    9 +++--
 net/sunrpc/clnt.c                      |    2 +-
 net/sunrpc/xdr.c                       |   12 ++++---
 net/sunrpc/xprt.c                      |    2 +-
 net/tipc/bcast.c                       |   10 +++---
 net/tipc/bearer.c                      |    7 ++--
 net/tipc/bearer.h                      |    2 +-
 net/tipc/link.c                        |   22 +++++++-------
 net/tipc/name_table.c                  |   10 +++---
 net/tipc/port.c                        |    2 +-
 net/tipc/port.h                        |    1 +
 net/x25/x25_route.c                    |    2 +-
 46 files changed, 163 insertions(+), 103 deletions(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 2a16765..35b8911 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -212,7 +212,7 @@ static int p9_virtio_cancel(struct p9_client *client, struct p9_req_t *req)
  * this takes a list of pages.
  * @sg: scatter/gather list to pack into
  * @start: which segment of the sg_list to start at
- * @**pdata: a list of pages to add into sg.
+ * @pdata: a list of pages to add into sg.
  * @nr_pages: number of pages to pack into the scatter/gather list
  * @data: data to pack into scatter/gather list
  * @count: amount of data to pack into the scatter/gather list
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 8685296..3347529 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -129,8 +129,8 @@ found:
 
 /**
  * atalk_find_or_insert_socket - Try to find a socket matching ADDR
- * @sk - socket to insert in the list if it is not there already
- * @sat - address to search for
+ * @sk: socket to insert in the list if it is not there already
+ * @sat: address to search for
  *
  * Try to find a socket matching ADDR in the socket list, if found then return
  * it. If not, insert SK into the socket list.
@@ -1066,8 +1066,8 @@ static int atalk_release(struct socket *sock)
 
 /**
  * atalk_pick_and_bind_port - Pick a source port when one is not given
- * @sk - socket to insert into the tables
- * @sat - address to search for
+ * @sk: socket to insert into the tables
+ * @sat: address to search for
  *
  * Pick a source port when one is not given. If we can find a suitable free
  * one, we insert the socket into the tables using it.
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 49e10d9..3483e40 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -162,12 +162,13 @@ static struct batadv_claim *batadv_claim_hash_find(struct batadv_priv *bat_priv,
 	return claim_tmp;
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_backbone_hash_find - looks for a claim in the hash
+ * @bat_priv: the bat priv with all the soft interface information
  * @addr: the address of the originator
  * @vid: the VLAN ID
  *
- * looks for a claim in the hash, and returns it if found
- * or NULL otherwise.
+ * Returns claim if found or NULL otherwise.
  */
 static struct batadv_backbone_gw *
 batadv_backbone_hash_find(struct batadv_priv *bat_priv,
@@ -242,12 +243,12 @@ batadv_bla_del_backbone_claims(struct batadv_backbone_gw *backbone_gw)
 	backbone_gw->crc = BATADV_BLA_CRC_INIT;
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_send_claim - sends a claim frame according to the provided info
+ * @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address to be announced within the claim
  * @vid: the VLAN ID
  * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
- *
- * sends a claim frame according to the provided info.
  */
 static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 				  short vid, int claimtype)
@@ -348,7 +349,9 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_get_backbone_gw
+ * @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address of the originator
  * @vid: the VLAN ID
  *
@@ -520,12 +523,12 @@ static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_add_claim - Adds a claim in the claim hash
+ * @bat_priv: the bat priv with all the soft interface information
  * @mac: the mac address of the claim
  * @vid: the VLAN ID of the frame
  * @backbone_gw: the backbone gateway which claims it
- *
- * Adds a claim in the claim hash.
  */
 static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 				 const uint8_t *mac, const short vid,
@@ -743,7 +746,9 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 	return 1;
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_check_claim_group
+ * @bat_priv: the bat priv with all the soft interface information
  * @hw_src: the Hardware source in the ARP Header
  * @hw_dst: the Hardware destination in the ARP Header
  * @ethhdr: pointer to the Ethernet header of the claim frame
@@ -975,7 +980,9 @@ purge_now:
 	}
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_purge_claims
+ * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the selected primary interface, may be NULL if now is set
  * @now: whether the whole hash shall be wiped now
  *
@@ -1023,7 +1030,9 @@ purge_now:
 	}
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_update_orig_address
+ * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the new selected primary_if
  * @oldif: the old primary interface, may be NULL
  *
@@ -1193,7 +1202,9 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 	return 0;
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_check_bcast_duplist
+ * @bat_priv: the bat priv with all the soft interface information
  * @bcast_packet: originator mac address
  * @hdr_size: maximum length of the frame
  *
@@ -1297,7 +1308,9 @@ int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig)
 }
 

-/* @skb: the frame to be checked
+/**
+ * batadv_bla_is_backbone_gw
+ * @skb: the frame to be checked
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
  *
@@ -1363,7 +1376,9 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
 		batadv_hardif_free_ref(primary_if);
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_rx
+ * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  *
@@ -1450,7 +1465,9 @@ out:
 	return ret;
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_tx
+ * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 83990e3..977de9c 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -81,7 +81,8 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
 	batadv_hash_destroy(hash);
 }
 
-/*	hash_add - adds data to the hashtable
+/**
+ *	batadv_hash_add - adds data to the hashtable
  *	@hash: storage hash table
  *	@compare: callback to determine if 2 hash elements are identical
  *	@choose: callback calculating the hash index
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index b8d4ac1..5d8fa07 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -216,7 +216,8 @@ static inline int batadv_compare_eth(const void *data1, const void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-/* has_timed_out - compares current time (jiffies) and timestamp + timeout
+/**
+ * has_timed_out - compares current time (jiffies) and timestamp + timeout
  * @timestamp:		base value to compare with (in jiffies)
  * @timeout:		added to base value before comparing (in milliseconds)
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 2141c13..12635fd 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -44,7 +44,8 @@ struct batadv_hard_iface {
 	struct rcu_head rcu;
 };
 
-/*	batadv_orig_node - structure for orig_list maintaining nodes of mesh
+/**
+ *	struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
  *	@primary_addr: hosts primary interface address
  *	@last_seen: when last packet from this node was received
  *	@bcast_seqno_reset: time when the broadcast seqno window was reset
diff --git a/net/core/dev.c b/net/core/dev.c
index 9c21548..5ab6f4b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1691,7 +1691,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_unlock();
 }
 
-/* netif_setup_tc - Handle tc mappings on real_num_tx_queues change
+/**
+ * netif_setup_tc - Handle tc mappings on real_num_tx_queues change
  * @dev: Network device
  * @txq: number of queues available
  *
@@ -1793,7 +1794,8 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 EXPORT_SYMBOL(netif_set_real_num_rx_queues);
 #endif
 
-/* netif_get_num_default_rss_queues - default number of RSS queues
+/**
+ * netif_get_num_default_rss_queues - default number of RSS queues
  *
  * This routine should set an upper limit on the number of RSS queues
  * used by default by multiqueue devices.
@@ -5670,7 +5672,7 @@ int netdev_refcnt_read(const struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_refcnt_read);
 
-/*
+/**
  * netdev_wait_allrefs - wait until all references are gone.
  *
  * This is called when unregistering network devices.
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2b325c3..b79a7fe 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2176,7 +2176,7 @@ skip:
 }
 
 /**
- * ndo_dflt_fdb_dump: default netdevice operation to dump an FDB table.
+ * ndo_dflt_fdb_dump - default netdevice operation to dump an FDB table.
  * @nlh: netlink message header
  * @dev: netdevice
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a789a8..506f678 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -713,7 +713,8 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
-/*	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
+/**
+ *	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
  *	@skb: the skb to modify
  *	@gfp_mask: allocation priority
  *
@@ -2614,7 +2615,7 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 EXPORT_SYMBOL(skb_find_text);
 
 /**
- * skb_append_datato_frags: - append the user data to a skb
+ * skb_append_datato_frags - append the user data to a skb
  * @sk: sock  structure
  * @skb: skb structure to be appened with user data.
  * @getfrag: call back function to be used for getting the user data
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index e2ab062..a269aa7 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -50,7 +50,8 @@ static inline u8 dccp_ackvec_state(const u8 *cell)
 	return *cell & ~DCCPAV_MAX_RUNLEN;
 }
 
-/** struct dccp_ackvec - Ack Vector main data structure
+/**
+ * struct dccp_ackvec - Ack Vector main data structure
  *
  * This implements a fixed-size circular buffer within an array and is largely
  * based on Appendix A of RFC 4340.
@@ -76,7 +77,8 @@ struct dccp_ackvec {
 	struct list_head	av_records;
 };
 
-/** struct dccp_ackvec_record - Records information about sent Ack Vectors
+/**
+ * struct dccp_ackvec_record - Records information about sent Ack Vectors
  *
  * These list entries define the additional information which the HC-Receiver
  * keeps about recently-sent Ack Vectors; again refer to RFC 4340, Appendix A.
@@ -121,6 +123,7 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
  * @len:	length of @vec
  * @nonce:	whether @vec had an ECN nonce of 0 or 1
  * @node:	FIFO - arranged in descending order of ack_ackno
+ *
  * This structure is used by CCIDs to access Ack Vectors in a received skb.
  */
 struct dccp_ackvec_parsed {
diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 48b585a..5975572 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -46,6 +46,7 @@ bool ccid_support_check(u8 const *ccid_array, u8 array_len)
  * ccid_get_builtin_ccids  -  Populate a list of built-in CCIDs
  * @ccid_array: pointer to copy into
  * @array_len: value to return length into
+ *
  * This function allocates memory - caller must see that it is freed after use.
  */
 int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 8c67bed..d65e987 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -113,6 +113,7 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hc, ktime_t now)
 /**
  * ccid3_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
+ *
  * This function tracks draft rfc3448bis, check there for latest details.
  *
  * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
@@ -161,9 +162,11 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 	}
 }
 
-/*
- *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
+/**
+ *	ccid3_hc_tx_update_s - Track the mean packet size `s'
  *	@len: DCCP packet payload size in bytes
+ *
+ *	cf. RFC 4342, 5.3 and  RFC 3448, 4.1
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hc, int len)
 {
@@ -270,6 +273,7 @@ out:
 /**
  * ccid3_hc_tx_send_packet  -  Delay-based dequeueing of TX packets
  * @skb: next packet candidate to send on @sk
+ *
  * This function uses the convention of ccid_packet_dequeue_eval() and
  * returns a millisecond-delay value between 0 and t_mbi = 64000 msec.
  */
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 497723c..57f9fd78 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -133,6 +133,7 @@ static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
  * @rh:		   Receive history containing a fresh loss event
  * @calc_first_li: Caller-dependent routine to compute length of first interval
  * @sk:		   Used by @calc_first_li in caller-specific way (subtyping)
+ *
  * Updates I_mean and returns 1 if a new interval has in fact been added to @lh.
  */
 int tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index de8fe29..08df7a3 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -315,6 +315,7 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
  *  @ndp:	    The NDP count belonging to @skb
  *  @calc_first_li: Caller-dependent computation of first loss interval in @lh
  *  @sk:	    Used by @calc_first_li (see tfrc_lh_interval_add)
+ *
  *  Chooses action according to pending loss, updates LI database when a new
  *  loss was detected, and does required post-processing. Returns 1 when caller
  *  should send feedback, 0 otherwise.
@@ -387,7 +388,7 @@ static inline struct tfrc_rx_hist_entry *
 }
 
 /**
- * tfrc_rx_hist_rtt_prev_s: previously suitable (wrt rtt_last_s) RTT-sampling entry
+ * tfrc_rx_hist_rtt_prev_s - previously suitable (wrt rtt_last_s) RTT-sampling entry
  */
 static inline struct tfrc_rx_hist_entry *
 			tfrc_rx_hist_rtt_prev_s(const struct tfrc_rx_hist *h)
diff --git a/net/dccp/ccids/lib/tfrc_equation.c b/net/dccp/ccids/lib/tfrc_equation.c
index a052a43..88ef982 100644
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -611,6 +611,7 @@ static inline u32 tfrc_binsearch(u32 fval, u8 small)
  * @s: packet size          in bytes
  * @R: RTT                  scaled by 1000000   (i.e., microseconds)
  * @p: loss ratio estimate  scaled by 1000000
+ *
  * Returns X_calc           in bytes per second (not scaled).
  */
 u32 tfrc_calc_x(u16 s, u32 R, u32 p)
@@ -659,6 +660,7 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 /**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
  *  @fvalue: function value to match, scaled by 1000000
+ *
  *  Returns closest match for p, also scaled by 1000000
  */
 u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9040be0..708e75b 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -352,6 +352,7 @@ static inline int dccp_bad_service_code(const struct sock *sk,
  * @dccpd_opt_len: total length of all options (5.8) in the packet
  * @dccpd_seq: sequence number
  * @dccpd_ack_seq: acknowledgment number subheader field value
+ *
  * This is used for transmission as well as for reception.
  */
 struct dccp_skb_cb {
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 78a2ad7..9733ddb 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -350,6 +350,7 @@ static int __dccp_feat_activate(struct sock *sk, const int idx,
  * @feat_num: feature to activate, one of %dccp_feature_numbers
  * @local: whether local (1) or remote (0) @feat_num is meant
  * @fval: the value (SP or NN) to activate, or NULL to use the default value
+ *
  * For general use this function is preferable over __dccp_feat_activate().
  */
 static int dccp_feat_activate(struct sock *sk, u8 feat_num, bool local,
@@ -446,6 +447,7 @@ static struct dccp_feat_entry *dccp_feat_list_lookup(struct list_head *fn_list,
  * @head:  list to add to
  * @feat:  feature number
  * @local: whether the local (1) or remote feature with number @feat is meant
+ *
  * This is the only constructor and serves to ensure the above invariants.
  */
 static struct dccp_feat_entry *
@@ -504,6 +506,7 @@ static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
  * @feat: one of %dccp_feature_numbers
  * @local: whether local (1) or remote (0) @feat_num is being confirmed
  * @fval: pointer to NN/SP value to be inserted or NULL
+ *
  * Returns 0 on success, a Reset code for further processing otherwise.
  */
 static int dccp_feat_push_confirm(struct list_head *fn_list, u8 feat, u8 local,
@@ -691,6 +694,7 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
  * @feat: an NN feature from %dccp_feature_numbers
  * @mandatory: use Mandatory option if 1
  * @nn_val: value to register (restricted to 4 bytes)
+ *
  * Note that NN features are local by definition (RFC 4340, 6.3.2).
  */
 static int __feat_register_nn(struct list_head *fn, u8 feat,
@@ -760,6 +764,7 @@ int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
  * dccp_feat_nn_get  -  Query current/pending value of NN feature
  * @sk: DCCP socket of an established connection
  * @feat: NN feature number from %dccp_feature_numbers
+ *
  * For a known NN feature, returns value currently being negotiated, or
  * current (confirmed) value if no negotiation is going on.
  */
@@ -790,6 +795,7 @@ EXPORT_SYMBOL_GPL(dccp_feat_nn_get);
  * @sk: DCCP socket of an established connection
  * @feat: NN feature number from %dccp_feature_numbers
  * @nn_val: the new value to use
+ *
  * This function is used to communicate NN updates out-of-band.
  */
 int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val)
@@ -930,6 +936,7 @@ static const struct ccid_dependency *dccp_feat_ccid_deps(u8 ccid, bool is_local)
  * @fn: feature-negotiation list to update
  * @id: CCID number to track
  * @is_local: whether TX CCID (1) or RX CCID (0) is meant
+ *
  * This function needs to be called after registering all other features.
  */
 static int dccp_feat_propagate_ccid(struct list_head *fn, u8 id, bool is_local)
@@ -953,6 +960,7 @@ static int dccp_feat_propagate_ccid(struct list_head *fn, u8 id, bool is_local)
 /**
  * dccp_feat_finalise_settings  -  Finalise settings before starting negotiation
  * @dp: client or listening socket (settings will be inherited)
+ *
  * This is called after all registrations (socket initialisation, sysctls, and
  * sockopt calls), and before sending the first packet containing Change options
  * (ie. client-Request or server-Response), to ensure internal consistency.
@@ -1284,6 +1292,7 @@ confirmation_failed:
  * @feat:	NN number, one of %dccp_feature_numbers
  * @val:	NN value
  * @len:	length of @val in bytes
+ *
  * This function combines the functionality of change_recv/confirm_recv, with
  * the following differences (reset codes are the same):
  *    - cleanup after receiving the Confirm;
@@ -1379,6 +1388,7 @@ fast_path_failed:
  * @feat: one of %dccp_feature_numbers
  * @val: value contents of @opt
  * @len: length of @val in bytes
+ *
  * Returns 0 on success, a Reset code for ending the connection otherwise.
  */
 int dccp_feat_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
diff --git a/net/dccp/input.c b/net/dccp/input.c
index bc93a33..14cdafa 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -710,6 +710,7 @@ EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
 /**
  *  dccp_sample_rtt  -  Validate and finalise computation of RTT sample
  *  @delta:	number of microseconds between packet and acknowledgment
+ *
  *  The routine is kept generic to work in different contexts. It should be
  *  called immediately when the ACK used for the RTT sample arrives.
  */
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 68fa6b7..a58e0b6 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -527,6 +527,7 @@ int dccp_insert_option_mandatory(struct sk_buff *skb)
  * @val: NN value or SP array (preferred element first) to copy
  * @len: true length of @val in bytes (excluding first element repetition)
  * @repeat_first: whether to copy the first element of @val twice
+ *
  * The last argument is used to construct Confirm options, where the preferred
  * value and the preference list appear separately (RFC 4340, 6.3.1). Preference
  * lists are kept such that the preferred entry is always first, so we only need
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 7873673..d17fc90 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -214,6 +214,7 @@ void dccp_write_space(struct sock *sk)
  * dccp_wait_for_ccid  -  Await CCID send permission
  * @sk:    socket to wait for
  * @delay: timeout in jiffies
+ *
  * This is used by CCIDs which need to delay the send time in process context.
  */
 static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index db6a6c1..4efad53 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -232,6 +232,7 @@ EXPORT_SYMBOL(eth_header_parse);
  * @neigh: source neighbour
  * @hh: destination cache entry
  * @type: Ethernet type field
+ *
  * Create an Ethernet header template from the neighbour.
  */
 int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type)
@@ -274,6 +275,7 @@ EXPORT_SYMBOL(eth_header_cache_update);
  * eth_mac_addr - set new Ethernet hardware address
  * @dev: network device
  * @p: socket address
+ *
  * Change hardware address of device.
  *
  * This doesn't change hardware matching, so needs to be overridden
@@ -331,6 +333,7 @@ const struct header_ops eth_header_ops ____cacheline_aligned = {
 /**
  * ether_setup - setup Ethernet network device
  * @dev: network device
+ *
  * Fill in the fields of the device structure with Ethernet-generic values.
  */
 void ether_setup(struct net_device *dev)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b4ac39f..5716c6b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -524,8 +524,8 @@ failure:
 }
 #endif
 
-/*
- *	Delete a VIF entry
+/**
+ *	vif_delete - Delete a VIF entry
  *	@notify: Set to 1, if the caller is a notifier_call
  */
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 04a3cba..6af3fcf 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -252,7 +252,7 @@ static void ip6_dev_free(struct net_device *dev)
 }
 
 /**
- * ip6_tnl_create() - create a new tunnel
+ * ip6_tnl_create - create a new tunnel
  *   @p: tunnel parameters
  *   @pt: pointer to new tunnel
  *
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index fe5453c..f6fe4d4 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -1024,7 +1024,7 @@ static int llc_ui_ioctl(struct socket *sock, unsigned int cmd,
  *	@sock: Socket to set options on.
  *	@level: Socket level user is requesting operations on.
  *	@optname: Operation name.
- *	@optval User provided operation data.
+ *	@optval: User provided operation data.
  *	@optlen: Length of optval.
  *
  *	Set various connection specific parameters.
diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index cf4aea3..39a8d89 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -30,12 +30,12 @@
  *
  * SAP and connection resource manager, one per adapter.
  *
- * @state - state of station
- * @xid_r_count - XID response PDU counter
- * @mac_sa - MAC source address
- * @sap_list - list of related SAPs
- * @ev_q - events entering state mach.
- * @mac_pdu_q - PDUs ready to send to MAC
+ * @state: state of station
+ * @xid_r_count: XID response PDU counter
+ * @mac_sa: MAC source address
+ * @sap_list: list of related SAPs
+ * @ev_q: events entering state mach.
+ * @mac_pdu_q: PDUs ready to send to MAC
  */
 struct llc_station {
 	u8			    state;
@@ -646,7 +646,7 @@ static void llc_station_service_events(void)
 }
 
 /**
- *	llc_station_state_process: queue event and try to process queue.
+ *	llc_station_state_process - queue event and try to process queue.
  *	@skb: Address of the event
  *
  *	Queues an event (on the station event queue) for handling by the
@@ -672,7 +672,7 @@ static void llc_station_ack_tmr_cb(unsigned long timeout_data)
 	}
 }
 
-/*
+/**
  *	llc_station_rcv - send received pdu to the station state machine
  *	@skb: received frame.
  *
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 764593d..6fac18c 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -133,7 +133,7 @@ bool mesh_peer_accepts_plinks(struct ieee802_11_elems *ie)
 }
 
 /**
- * mesh_accept_plinks_update: update accepting_plink in local mesh beacons
+ * mesh_accept_plinks_update - update accepting_plink in local mesh beacons
  *
  * @sdata: mesh interface in which mesh beacons are going to be updated
  */
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index fb7b6a1..494bc39 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -1054,12 +1054,15 @@ enddiscovery:
 	kfree(preq_node);
 }
 
-/* mesh_nexthop_resolve - lookup next hop for given skb and start path
- * discovery if no forwarding information is found.
+/**
+ * mesh_nexthop_resolve - lookup next hop; conditionally start path discovery
  *
  * @skb: 802.11 frame to be sent
  * @sdata: network subif the frame will be sent through
  *
+ * Lookup next hop for given skb and start path discovery if no
+ * forwarding information is found.
+ *
  * Returns: 0 if the next hop was found and -ENOENT if the frame was queued.
  * skb is freeed here if no mpath could be allocated.
  */
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index c9ae931..075bc53 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -778,7 +778,7 @@ static void __mesh_path_del(struct mesh_table *tbl, struct mpath_node *node)
 /**
  * mesh_path_flush_by_nexthop - Deletes mesh paths if their next hop matches
  *
- * @sta - mesh peer to match
+ * @sta: mesh peer to match
  *
  * RCU notes: this function is called when a mesh plink transitions from
  * PLINK_ESTAB to any other state, since PLINK_ESTAB state is the only one that
@@ -833,7 +833,7 @@ static void table_flush_by_iface(struct mesh_table *tbl,
  *
  * This function deletes both mesh paths as well as mesh portal paths.
  *
- * @sdata - interface data to match
+ * @sdata: interface data to match
  *
  */
 void mesh_path_flush_by_iface(struct ieee80211_sub_if_data *sdata)
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index a1dbd15..9ad74dd 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -99,7 +99,7 @@ static struct sta_info *mesh_plink_alloc(struct ieee80211_sub_if_data *sdata,
 	return sta;
 }
 
-/*
+/**
  * mesh_set_ht_prot_mode - set correct HT protection mode
  *
  * Section 9.23.3.5 of IEEE 80211-2012 describes the protection rules for HT
@@ -320,7 +320,8 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_data *sdata,
 	return 0;
 }
 
-/* mesh_peer_init - initialize new mesh peer and return resulting sta_info
+/**
+ * mesh_peer_init - initialize new mesh peer and return resulting sta_info
  *
  * @sdata: local meshif
  * @addr: peer's address
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 839cac8..67edd69 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -94,7 +94,7 @@ ieee80211_rx_radiotap_len(struct ieee80211_local *local,
 	return len;
 }
 
-/*
+/**
  * ieee80211_add_rx_radiotap_header - add radiotap header
  *
  * add a radiotap header containing all the fields which the hardware provided.
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 146033a..d7f1953 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -69,7 +69,7 @@ tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
 }
 
 /**
- * tproxy_handle_time_wait4() - handle IPv4 TCP TIME_WAIT reopen redirections
+ * tproxy_handle_time_wait4 - handle IPv4 TCP TIME_WAIT reopen redirections
  * @skb:	The skb being processed.
  * @laddr:	IPv4 address to redirect to or zero.
  * @lport:	TCP port to redirect to or zero.
@@ -220,7 +220,7 @@ tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
 }
 
 /**
- * tproxy_handle_time_wait6() - handle IPv6 TCP TIME_WAIT reopen redirections
+ * tproxy_handle_time_wait6 - handle IPv6 TCP TIME_WAIT reopen redirections
  * @skb:	The skb being processed.
  * @tproto:	Transport protocol.
  * @thoff:	Transport protocol header offset.
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 32761b5..62ebe3c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -504,7 +504,7 @@ EXPORT_SYMBOL(genl_unregister_family);
  * @pid: netlink pid the message is addressed to
  * @seq: sequence number (usually the one of the sender)
  * @family: generic netlink family
- * @flags netlink message flags
+ * @flags: netlink message flags
  * @cmd: generic netlink command
  *
  * Returns pointer to user specific header
diff --git a/net/rds/page.c b/net/rds/page.c
index 2499cd1..9005a2c 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -74,11 +74,12 @@ int rds_page_copy_user(struct page *page, unsigned long offset,
 }
 EXPORT_SYMBOL_GPL(rds_page_copy_user);
 
-/*
- * Message allocation uses this to build up regions of a message.
+/**
+ * rds_page_remainder_alloc - build up regions of a message.
  *
- * @bytes - the number of bytes needed.
- * @gfp - the waiting behaviour of the allocation
+ * @scat: Scatter list for message
+ * @bytes: the number of bytes needed.
+ * @gfp: the waiting behaviour of the allocation
  *
  * @gfp is always ored with __GFP_HIGHMEM.  Callers must be prepared to
  * kmap the pages, etc.
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 16ae887..e1ac183 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -242,7 +242,7 @@ int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
 
 EXPORT_SYMBOL(rxrpc_kernel_send_data);
 
-/*
+/**
  * rxrpc_kernel_abort_call - Allow a kernel service to abort a call
  * @call: The call to be aborted
  * @abort_code: The abort code to stick into the ABORT packet
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 31def68..5a3d675 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -176,13 +176,14 @@ out_free:
 }
 EXPORT_SYMBOL_GPL(xprt_setup_backchannel);
 
-/*
- * Destroys the backchannel preallocated structures.
+/**
+ * xprt_destroy_backchannel - Destroys the backchannel preallocated structures.
+ * @xprt:	the transport holding the preallocated strucures
+ * @max_reqs	the maximum number of preallocated structures to destroy
+ *
  * Since these structures may have been allocated by multiple calls
  * to xprt_setup_backchannel, we only destroy up to the maximum number
  * of reqs specified by the caller.
- * @xprt:	the transport holding the preallocated strucures
- * @max_reqs	the maximum number of preallocated structures to destroy
  */
 void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f56f045..00eb859 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -385,7 +385,7 @@ out_no_rpciod:
 	return ERR_PTR(err);
 }
 
-/*
+/**
  * rpc_create - create an RPC client and transport with one call
  * @args: rpc_clnt create argument structure
  *
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fddcccf..0cf1655 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -180,7 +180,9 @@ EXPORT_SYMBOL_GPL(xdr_inline_pages);
 
 /*
  * Helper routines for doing 'memmove' like operations on a struct xdr_buf
- *
+ */
+
+/**
  * _shift_data_right_pages
  * @pages: vector of pages containing both the source and dest memory area.
  * @pgto_base: page vector address of destination
@@ -242,7 +244,7 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	} while ((len -= copy) != 0);
 }
 
-/*
+/**
  * _copy_to_pages
  * @pages: array of pages
  * @pgbase: page vector address of destination
@@ -286,7 +288,7 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 	flush_dcache_page(*pgto);
 }
 
-/*
+/**
  * _copy_from_pages
  * @p: pointer to destination
  * @pages: array of pages
@@ -326,7 +328,7 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 }
 EXPORT_SYMBOL_GPL(_copy_from_pages);
 
-/*
+/**
  * xdr_shrink_bufhead
  * @buf: xdr_buf
  * @len: bytes to remove from buf->head[0]
@@ -399,7 +401,7 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 		buf->len = buf->buflen;
 }
 
-/*
+/**
  * xdr_shrink_pagelen
  * @buf: xdr_buf
  * @len: bytes to remove from buf->pages
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3c83035..a5a402a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -531,7 +531,7 @@ void xprt_set_retrans_timeout_def(struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
 
-/*
+/**
  * xprt_set_retrans_timeout_rtt - set a request's retransmit timeout
  * @task: task whose timeout is to be set
  *
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2625f5e..d9df34f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -162,7 +162,7 @@ static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
 }
 

-/*
+/**
  * tipc_bclink_retransmit_to - get most recent node to request retransmission
  *
  * Called with bc_lock locked
@@ -270,7 +270,7 @@ exit:
 	spin_unlock_bh(&bc_lock);
 }
 
-/*
+/**
  * tipc_bclink_update_link_state - update broadcast link state
  *
  * tipc_net_lock and node lock set
@@ -330,7 +330,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 	}
 }
 
-/*
+/**
  * bclink_peek_nack - monitor retransmission requests sent by other nodes
  *
  * Delay any upcoming NACK by this node if another node has already
@@ -381,7 +381,7 @@ exit:
 	return res;
 }
 
-/*
+/**
  * bclink_accept_pkt - accept an incoming, in-sequence broadcast packet
  *
  * Called with both sending node's lock and bc_lock taken.
@@ -406,7 +406,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 	}
 }
 
-/*
+/**
  * tipc_bclink_recv_pkt - receive a broadcast packet, and deliver upwards
  *
  * tipc_net_lock is read_locked, no other locks set
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a297e3a..86b703f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -172,8 +172,8 @@ struct sk_buff *tipc_media_get_names(void)
 
 /**
  * bearer_name_validate - validate & (optionally) deconstruct bearer name
- * @name - ptr to bearer name string
- * @name_parts - ptr to area for bearer name components (or NULL if not needed)
+ * @name: ptr to bearer name string
+ * @name_parts: ptr to area for bearer name components (or NULL if not needed)
  *
  * Returns 1 if bearer name is valid, otherwise 0.
  */
@@ -520,8 +520,7 @@ exit:
 }
 
 /**
- * tipc_block_bearer(): Block the bearer with the given name,
- *                      and reset all its links
+ * tipc_block_bearer - Block the bearer with the given name, and reset all its links
  */
 int tipc_block_bearer(const char *name)
 {
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index e3b2be3..4680de1 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -57,7 +57,7 @@
  */
 #define TIPC_MEDIA_TYPE_ETH	1
 
-/*
+/**
  * struct tipc_media_addr - destination address used by TIPC bearers
  * @value: address info (format defined by media)
  * @media_id: TIPC media type identifier
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7a614f4..f6bf483 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -153,8 +153,8 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
 
 /**
  * link_name_validate - validate & (optionally) deconstruct tipc_link name
- * @name - ptr to link name string
- * @name_parts - ptr to area for link name components (or NULL if not needed)
+ * @name: ptr to link name string
+ * @name_parts: ptr to area for link name components (or NULL if not needed)
  *
  * Returns 1 if link name is valid, otherwise 0.
  */
@@ -944,7 +944,7 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 	return res;
 }
 
-/*
+/**
  * tipc_link_send_names - send name table entries to new neighbor
  *
  * Send routine for bulk delivery of name table messages when contact
@@ -1787,7 +1787,7 @@ cont:
 	read_unlock_bh(&tipc_net_lock);
 }
 
-/*
+/**
  * tipc_link_defer_pkt - Add out-of-sequence message to deferred reception queue
  *
  * Returns increase in queue length (i.e. 0 or 1)
@@ -2635,8 +2635,8 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 
 /**
  * link_find_link - locate link by name
- * @name - ptr to link name string
- * @node - ptr to area to be filled with ptr to associated node
+ * @name: ptr to link name string
+ * @node: ptr to area to be filled with ptr to associated node
  *
  * Caller must hold 'tipc_net_lock' to ensure node and bearer are not deleted;
  * this also prevents link deletion.
@@ -2671,8 +2671,8 @@ static struct tipc_link *link_find_link(const char *name,
 /**
  * link_value_is_valid -- validate proposed link tolerance/priority/window
  *
- * @cmd - value type (TIPC_CMD_SET_LINK_*)
- * @new_value - the new value
+ * @cmd: value type (TIPC_CMD_SET_LINK_*)
+ * @new_value: the new value
  *
  * Returns 1 if value is within range, 0 if not.
  */
@@ -2693,9 +2693,9 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
 
 /**
  * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
- * @name - ptr to link, bearer, or media name
- * @new_value - new value of link, bearer, or media setting
- * @cmd - which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
+ * @name: ptr to link, bearer, or media name
+ * @new_value: new value of link, bearer, or media setting
+ * @cmd: which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
  *
  * Caller must hold 'tipc_net_lock' to ensure link/bearer/media is not deleted.
  *
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 010f24a..13fb9d5 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -191,7 +191,7 @@ static void nameseq_delete_empty(struct name_seq *seq)
 	}
 }
 
-/*
+/**
  * nameseq_find_subseq - find sub-sequence (if any) matching a name instance
  *
  * Very time-critical, so binary searches through sub-sequence array.
@@ -435,7 +435,7 @@ found:
 }
 
 /**
- * tipc_nameseq_subscribe: attach a subscription, and issue
+ * tipc_nameseq_subscribe - attach a subscription, and issue
  * the prescribed number of events if there is any sub-
  * sequence overlapping with the requested sequence
  */
@@ -520,7 +520,7 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 	return publ;
 }
 
-/*
+/**
  * tipc_nametbl_translate - perform name translation
  *
  * On entry, 'destnode' is the search domain used during translation.
@@ -751,7 +751,7 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 

 /**
- * subseq_list: print specified sub-sequence contents into the given buffer
+ * subseq_list - print specified sub-sequence contents into the given buffer
  */
 static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			u32 index)
@@ -787,7 +787,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 }
 
 /**
- * nameseq_list: print specified name sequence contents into the given buffer
+ * nameseq_list - print specified name sequence contents into the given buffer
  */
 static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 			 u32 type, u32 lowbound, u32 upbound, u32 index)
diff --git a/net/tipc/port.c b/net/tipc/port.c
index a1e8289..70bf78b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -69,7 +69,7 @@ static u32 port_peerport(struct tipc_port *p_ptr)
 	return msg_destport(&p_ptr->phdr);
 }
 
-/*
+/**
  * tipc_port_peer_msg - verify message was sent by connected port's peer
  *
  * Handles cases where the node's network address has changed from
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 98cbec9..4660e30 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -79,6 +79,7 @@ typedef void (*tipc_continue_event) (void *usr_handle, u32 portref);
  * struct user_port - TIPC user port (used with native API)
  * @usr_handle: user-specified field
  * @ref: object reference to associated TIPC port
+ *
  * <various callback routines>
  */
 struct user_port {
diff --git a/net/x25/x25_route.c b/net/x25/x25_route.c
index cf63662..277c8d2 100644
--- a/net/x25/x25_route.c
+++ b/net/x25/x25_route.c
@@ -66,7 +66,7 @@ out:
 
 /**
  * __x25_remove_route - remove route from x25_route_list
- * @rt - route to remove
+ * @rt: route to remove
  *
  * Remove route from x25_route_list. If it was there.
  * Caller must hold x25_route_list_lock.
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
