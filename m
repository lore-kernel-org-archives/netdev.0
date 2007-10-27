From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/5][ATM]: [br2864] whitespace cleanup
Date: Sat, 27 Oct 2007 08:44:49 -0400
Message-ID: <200710271244.l9RCinei002926@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:51129 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbXJ0Mqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 08:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6b11f93a718dc916198feb1099ae0cef39ce3936
Author: Chas Williams <chas@vger.cmf.nrl.navy.mil>
Date:   Sat Oct 27 08:33:40 2007 -0400

    [ATM]: [br2864] whitespace cleanup
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/include/linux/atmbr2684.h b/include/linux/atmbr2684.h
index ccdab6c..52bf72a 100644
--- a/include/linux/atmbr2684.h
+++ b/include/linux/atmbr2684.h
@@ -15,7 +15,7 @@
 #define BR2684_MEDIA_802_6	(4)	/* 802.6 */
 
 					/* used only at device creation:  */
-#define BR2684_FLAG_ROUTED	(1<<16) /* payload is routed, not bridged */
+#define BR2684_FLAG_ROUTED	(1<<16)	/* payload is routed, not bridged */
 
 /*
  * Is there FCS inbound on this VC?  This currently isn't supported.
@@ -45,17 +45,16 @@
 #define BR2684_PAYLOAD_ROUTED   (0)
 #define BR2684_PAYLOAD_BRIDGED  (1)
 
-
 /*
  * This is for the ATM_NEWBACKENDIF call - these are like socket families:
  * the first element of the structure is the backend number and the rest
  * is per-backend specific
  */
 struct atm_newif_br2684 {
-	atm_backend_t	backend_num;	/* ATM_BACKEND_BR2684 */
-	int		media;		/* BR2684_MEDIA_*, flags in upper bits */
-	char		ifname[IFNAMSIZ];
-	int		mtu;
+	atm_backend_t backend_num;	/* ATM_BACKEND_BR2684 */
+	int media;		/* BR2684_MEDIA_*, flags in upper bits */
+	char ifname[IFNAMSIZ];
+	int mtu;
 };
 
 /*
@@ -66,10 +65,10 @@ struct atm_newif_br2684 {
 #define BR2684_FIND_BYNUM	(1)
 #define BR2684_FIND_BYIFNAME	(2)
 struct br2684_if_spec {
-	int method;			/* BR2684_FIND_* */
+	int method;		/* BR2684_FIND_* */
 	union {
-		char		ifname[IFNAMSIZ];
-		int		devnum;
+		char ifname[IFNAMSIZ];
+		int devnum;
 	} spec;
 };
 
@@ -79,16 +78,16 @@ struct br2684_if_spec {
  * is per-backend specific
  */
 struct atm_backend_br2684 {
-	atm_backend_t	backend_num;	/* ATM_BACKEND_BR2684 */
+	atm_backend_t backend_num;	/* ATM_BACKEND_BR2684 */
 	struct br2684_if_spec ifspec;
-	int	fcs_in;		/* BR2684_FCSIN_* */
-	int	fcs_out;	/* BR2684_FCSOUT_* */
-	int	fcs_auto;	/* 1: fcs_{in,out} disabled if no FCS rx'ed */
-	int	encaps;		/* BR2684_ENCAPS_* */
-	int	has_vpiid;	/* 1: use vpn_id - Unsupported */
-	__u8	vpn_id[7];
-	int	send_padding;	/* unsupported */
-	int	min_size;	/* we will pad smaller packets than this */
+	int fcs_in;		/* BR2684_FCSIN_* */
+	int fcs_out;		/* BR2684_FCSOUT_* */
+	int fcs_auto;		/* 1: fcs_{in,out} disabled if no FCS rx'ed */
+	int encaps;		/* BR2684_ENCAPS_* */
+	int has_vpiid;		/* 1: use vpn_id - Unsupported */
+	__u8 vpn_id[7];
+	int send_padding;	/* unsupported */
+	int min_size;		/* we will pad smaller packets than this */
 };
 
 /*
@@ -97,8 +96,8 @@ struct atm_backend_br2684 {
  * efficient per-if in/out filters, this support will be removed
  */
 struct br2684_filter {
-	__be32	prefix;		/* network byte order */
-	__be32	netmask;	/* 0 = disable filter */
+	__be32 prefix;		/* network byte order */
+	__be32 netmask;		/* 0 = disable filter */
 };
 
 struct br2684_filter_set {
@@ -107,8 +106,8 @@ struct br2684_filter_set {
 };
 
 enum br2684_payload {
-        p_routed = BR2684_PAYLOAD_ROUTED,
-        p_bridged = BR2684_PAYLOAD_BRIDGED,
+	p_routed = BR2684_PAYLOAD_ROUTED,
+	p_bridged = BR2684_PAYLOAD_BRIDGED,
 };
 
 #define BR2684_SETFILT	_IOW( 'a', ATMIOC_BACKEND + 0, \
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index d9bb2a1..f5a3794 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -1,9 +1,10 @@
 /*
-Ethernet netdevice using ATM AAL5 as underlying carrier
-(RFC1483 obsoleted by RFC2684) for Linux
-Authors: Marcell GAL, 2000, XDSL Ltd, Hungary
-         Eric Kinzie, 2006-2007, US Naval Research Laboratory
-*/
+ * Ethernet netdevice using ATM AAL5 as underlying carrier
+ * (RFC1483 obsoleted by RFC2684) for Linux
+ *
+ * Authors: Marcell GAL, 2000, XDSL Ltd, Hungary
+ *          Eric Kinzie, 2006-2007, US Naval Research Laboratory
+ */
 
 #include <linux/module.h>
 #include <linux/init.h>
@@ -51,28 +52,24 @@ static void skb_debug(const struct sk_buff *skb)
 #define ETHERTYPE_IPV6	0x86, 0xdd
 #define PAD_BRIDGED	0x00, 0x00
 
-static unsigned char ethertype_ipv4[] =
-	{ ETHERTYPE_IPV4 };
-static unsigned char ethertype_ipv6[] =
-	{ ETHERTYPE_IPV6 };
+static unsigned char ethertype_ipv4[] = { ETHERTYPE_IPV4 };
+static unsigned char ethertype_ipv6[] = { ETHERTYPE_IPV6 };
 static unsigned char llc_oui_pid_pad[] =
-	{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
-static unsigned char llc_oui_ipv4[] =
-	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
-static unsigned char llc_oui_ipv6[] =
-	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
+			{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
+static unsigned char llc_oui_ipv4[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
+static unsigned char llc_oui_ipv6[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
 
 enum br2684_encaps {
-	e_vc  = BR2684_ENCAPS_VC,
+	e_vc = BR2684_ENCAPS_VC,
 	e_llc = BR2684_ENCAPS_LLC,
 };
 
 struct br2684_vcc {
-	struct atm_vcc  *atmvcc;
+	struct atm_vcc *atmvcc;
 	struct net_device *device;
-	/* keep old push,pop functions for chaining */
-	void (*old_push)(struct atm_vcc *vcc,struct sk_buff *skb);
-	/* void (*old_pop)(struct atm_vcc *vcc,struct sk_buff *skb); */
+	/* keep old push, pop functions for chaining */
+	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
+	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -85,7 +82,7 @@ struct br2684_dev {
 	struct net_device *net_dev;
 	struct list_head br2684_devs;
 	int number;
-	struct list_head brvccs; /* one device <=> one vcc (before xmas) */
+	struct list_head brvccs;	/* one device <=> one vcc (before xmas) */
 	struct net_device_stats stats;
 	int mac_was_set;
 	enum br2684_payload payload;
@@ -104,7 +101,7 @@ static LIST_HEAD(br2684_devs);
 
 static inline struct br2684_dev *BRPRIV(const struct net_device *net_dev)
 {
-	return (struct br2684_dev *) net_dev->priv;
+	return (struct br2684_dev *)net_dev->priv;
 }
 
 static inline struct net_device *list_entry_brdev(const struct list_head *le)
@@ -114,7 +111,7 @@ static inline struct net_device *list_entry_brdev(const struct list_head *le)
 
 static inline struct br2684_vcc *BR2684_VCC(const struct atm_vcc *atmvcc)
 {
-	return (struct br2684_vcc *) (atmvcc->user_back);
+	return (struct br2684_vcc *)(atmvcc->user_back);
 }
 
 static inline struct br2684_vcc *list_entry_brvcc(const struct list_head *le)
@@ -152,7 +149,7 @@ static struct net_device *br2684_find_dev(const struct br2684_if_spec *s)
  * otherwise false
  */
 static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
-	struct br2684_vcc *brvcc)
+			   struct br2684_vcc *brvcc)
 {
 	struct atm_vcc *atmvcc;
 	int minheadroom = (brvcc->encaps == e_llc) ? 10 : 2;
@@ -171,21 +168,24 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 	if (brvcc->encaps == e_llc) {
 		if (brdev->payload == p_bridged) {
 			skb_push(skb, sizeof(llc_oui_pid_pad));
-			skb_copy_to_linear_data(skb, llc_oui_pid_pad, sizeof(llc_oui_pid_pad));
+			skb_copy_to_linear_data(skb, llc_oui_pid_pad,
+						sizeof(llc_oui_pid_pad));
 		} else if (brdev->payload == p_routed) {
 			unsigned short prot = ntohs(skb->protocol);
 
 			skb_push(skb, sizeof(llc_oui_ipv4));
 			switch (prot) {
-				case ETH_P_IP:
-					skb_copy_to_linear_data(skb, llc_oui_ipv4, sizeof(llc_oui_ipv4));
-					break;
-				case ETH_P_IPV6:
-					skb_copy_to_linear_data(skb, llc_oui_ipv6, sizeof(llc_oui_ipv6));
-					break;
-				default:
-					dev_kfree_skb(skb);
-					return 0;
+			case ETH_P_IP:
+				skb_copy_to_linear_data(skb, llc_oui_ipv4,
+							sizeof(llc_oui_ipv4));
+				break;
+			case ETH_P_IPV6:
+				skb_copy_to_linear_data(skb, llc_oui_ipv6,
+							sizeof(llc_oui_ipv6));
+				break;
+			default:
+				dev_kfree_skb(skb);
+				return 0;
 			}
 		}
 	} else {
@@ -198,13 +198,14 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
 	if (!atm_may_send(atmvcc, skb->truesize)) {
-		/* we free this here for now, because we cannot know in a higher
-			layer whether the skb point it supplied wasn't freed yet.
-			now, it always is.
-		*/
+		/*
+		 * We free this here for now, because we cannot know in a higher
+		 * layer whether the skb pointer it supplied wasn't freed yet.
+		 * Now, it always is.
+		 */
 		dev_kfree_skb(skb);
 		return 0;
-		}
+	}
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	brdev->stats.tx_packets++;
@@ -214,10 +215,9 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 }
 
 static inline struct br2684_vcc *pick_outgoing_vcc(struct sk_buff *skb,
-	struct br2684_dev *brdev)
+						   struct br2684_dev *brdev)
 {
-	return list_empty(&brdev->brvccs) ? NULL :
-	    list_entry_brvcc(brdev->brvccs.next); /* 1 vcc/dev right now */
+	return list_empty(&brdev->brvccs) ? NULL : list_entry_brvcc(brdev->brvccs.next);	/* 1 vcc/dev right now */
 }
 
 static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -241,11 +241,10 @@ static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/*
 		 * We should probably use netif_*_queue() here, but that
 		 * involves added complication.  We need to walk before
-		 * we can run
+		 * we can run.
+		 *
+		 * Don't free here! this pointer might be no longer valid!
 		 */
-		/* don't free here! this pointer might be no longer valid!
-		dev_kfree_skb(skb);
-		*/
 		brdev->stats.tx_errors++;
 		brdev->stats.tx_fifo_errors++;
 	}
@@ -259,12 +258,11 @@ static struct net_device_stats *br2684_get_stats(struct net_device *dev)
 	return &BRPRIV(dev)->stats;
 }
 
-
 /*
  * We remember when the MAC gets set, so we don't override it later with
  * the ESI of the ATM card of the first VC
  */
-static int (*my_eth_mac_addr)(struct net_device *, void *);
+static int (*my_eth_mac_addr) (struct net_device *, void *);
 static int br2684_mac_addr(struct net_device *dev, void *p)
 {
 	int err = my_eth_mac_addr(dev, p);
@@ -275,7 +273,7 @@ static int br2684_mac_addr(struct net_device *dev, void *p)
 
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 /* this IOCTL is experimental. */
-static int br2684_setfilt(struct atm_vcc *atmvcc, void __user *arg)
+static int br2684_setfilt(struct atm_vcc *atmvcc, void __user * arg)
 {
 	struct br2684_vcc *brvcc;
 	struct br2684_filter_set fs;
@@ -285,13 +283,12 @@ static int br2684_setfilt(struct atm_vcc *atmvcc, void __user *arg)
 	if (fs.ifspec.method != BR2684_FIND_BYNOTHING) {
 		/*
 		 * This is really a per-vcc thing, but we can also search
-		 * by device
+		 * by device.
 		 */
 		struct br2684_dev *brdev;
 		read_lock(&devs_lock);
 		brdev = BRPRIV(br2684_find_dev(&fs.ifspec));
-		if (brdev == NULL || list_empty(&brdev->brvccs) ||
-		    brdev->brvccs.next != brdev->brvccs.prev)  /* >1 VCC */
+		if (brdev == NULL || list_empty(&brdev->brvccs) || brdev->brvccs.next != brdev->brvccs.prev)	/* >1 VCC */
 			brvcc = NULL;
 		else
 			brvcc = list_entry_brvcc(brdev->brvccs.next);
@@ -309,15 +306,16 @@ static inline int
 packet_fails_filter(__be16 type, struct br2684_vcc *brvcc, struct sk_buff *skb)
 {
 	if (brvcc->filter.netmask == 0)
-		return 0;			/* no filter in place */
+		return 0;	/* no filter in place */
 	if (type == htons(ETH_P_IP) &&
-	    (((struct iphdr *) (skb->data))->daddr & brvcc->filter.
+	    (((struct iphdr *)(skb->data))->daddr & brvcc->filter.
 	     netmask) == brvcc->filter.prefix)
 		return 0;
 	if (type == htons(ETH_P_ARP))
 		return 0;
-	/* TODO: we should probably filter ARPs too.. don't want to have
-	 *   them returning values that don't make sense, or is that ok?
+	/* 
+	 * TODO: we should probably filter ARPs too.. don't want to have
+	 * them returning values that don't make sense, or is that ok?
 	 */
 	return 1;		/* drop */
 }
@@ -367,10 +365,17 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 
 		/* accept packets that have "ipv[46]" in the snap header */
 		if ((skb->len >= (sizeof(llc_oui_ipv4)))
-		    && (memcmp(skb->data, llc_oui_ipv4, sizeof(llc_oui_ipv4) - BR2684_ETHERTYPE_LEN) == 0)) {
-			if (memcmp(skb->data + 6, ethertype_ipv6, sizeof(ethertype_ipv6)) == 0)
+		    &&
+		    (memcmp
+		     (skb->data, llc_oui_ipv4,
+		      sizeof(llc_oui_ipv4) - BR2684_ETHERTYPE_LEN) == 0)) {
+			if (memcmp
+			    (skb->data + 6, ethertype_ipv6,
+			     sizeof(ethertype_ipv6)) == 0)
 				skb->protocol = __constant_htons(ETH_P_IPV6);
-			else if (memcmp(skb->data + 6, ethertype_ipv4, sizeof(ethertype_ipv4)) == 0)
+			else if (memcmp
+				 (skb->data + 6, ethertype_ipv4,
+				  sizeof(ethertype_ipv4)) == 0)
 				skb->protocol = __constant_htons(ETH_P_IP);
 			else {
 				brdev->stats.rx_errors++;
@@ -380,12 +385,13 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			skb_pull(skb, sizeof(llc_oui_ipv4));
 			skb_reset_network_header(skb);
 			skb->pkt_type = PACKET_HOST;
-
-		/* let us waste some time for checking the encapsulation.
-		   Note, that only 7 char is checked so frames with a valid FCS
-		   are also accepted (but FCS is not checked of course) */
+			/*
+			 * Let us waste some time for checking the encapsulation.
+			 * Note, that only 7 char is checked so frames with a valid FCS
+			 * are also accepted (but FCS is not checked of course).
+			 */
 		} else if ((skb->len >= sizeof(llc_oui_pid_pad)) &&
-		           (memcmp(skb->data, llc_oui_pid_pad, 7) == 0)) {
+			   (memcmp(skb->data, llc_oui_pid_pad, 7) == 0)) {
 			skb_pull(skb, sizeof(llc_oui_pid_pad));
 			skb->protocol = eth_type_trans(skb, net_dev);
 		} else {
@@ -401,7 +407,7 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			dev_kfree_skb(skb);
 			return;
 		}
-		skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN); /* pad, dstmac, srcmac, ethtype */
+		skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN);	/* pad, dstmac, srcmac, ethtype */
 		skb->protocol = eth_type_trans(skb, net_dev);
 	}
 
@@ -428,11 +434,12 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	netif_rx(skb);
 }
 
-static int br2684_regvcc(struct atm_vcc *atmvcc, void __user *arg)
+/*
+ * Assign a vcc to a dev
+ * Note: we do not have explicit unassign, but look at _push()
+ */
+static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 {
-/* assign a vcc to a dev
-Note: we do not have explicit unassign, but look at _push()
-*/
 	int err;
 	struct br2684_vcc *brvcc;
 	struct sk_buff *skb;
@@ -451,7 +458,7 @@ Note: we do not have explicit unassign, but look at _push()
 	net_dev = br2684_find_dev(&be.ifspec);
 	if (net_dev == NULL) {
 		printk(KERN_ERR
-		    "br2684: tried to attach to non-existant device\n");
+		       "br2684: tried to attach to non-existant device\n");
 		err = -ENXIO;
 		goto error;
 	}
@@ -467,13 +474,15 @@ Note: we do not have explicit unassign, but look at _push()
 	}
 	if (be.fcs_in != BR2684_FCSIN_NO || be.fcs_out != BR2684_FCSOUT_NO ||
 	    be.fcs_auto || be.has_vpiid || be.send_padding || (be.encaps !=
-	    BR2684_ENCAPS_VC && be.encaps != BR2684_ENCAPS_LLC) ||
-	    be.min_size != 0) {
+							       BR2684_ENCAPS_VC
+							       && be.encaps !=
+							       BR2684_ENCAPS_LLC)
+	    || be.min_size != 0) {
 		err = -EINVAL;
 		goto error;
 	}
-	pr_debug("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc, be.encaps,
-		brvcc);
+	pr_debug("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc,
+		 be.encaps, brvcc);
 	if (list_empty(&brdev->brvccs) && !brdev->mac_was_set) {
 		unsigned char *esi = atmvcc->dev->esi;
 		if (esi[0] | esi[1] | esi[2] | esi[3] | esi[4] | esi[5])
@@ -486,7 +495,7 @@ Note: we do not have explicit unassign, but look at _push()
 	brvcc->device = net_dev;
 	brvcc->atmvcc = atmvcc;
 	atmvcc->user_back = brvcc;
-	brvcc->encaps = (enum br2684_encaps) be.encaps;
+	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
 	barrier();
 	atmvcc->push = br2684_push;
@@ -517,7 +526,7 @@ Note: we do not have explicit unassign, but look at _push()
 	}
 	__module_get(THIS_MODULE);
 	return 0;
-    error:
+      error:
 	write_unlock_irq(&devs_lock);
 	kfree(brvcc);
 	return err;
@@ -556,7 +565,7 @@ static void br2684_setup_routed(struct net_device *netdev)
 	INIT_LIST_HEAD(&brdev->brvccs);
 }
 
-static int br2684_create(void __user *arg)
+static int br2684_create(void __user * arg)
 {
 	int err;
 	struct net_device *netdev;
@@ -574,7 +583,7 @@ static int br2684_create(void __user *arg)
 		payload = p_routed;
 	else
 		payload = p_bridged;
-	ni.media &= 0xffff; /* strip flags */
+	ni.media &= 0xffff;	/* strip flags */
 
 	if (ni.media != BR2684_MEDIA_ETHERNET || ni.mtu != 1500) {
 		return -EINVAL;
@@ -583,7 +592,7 @@ static int br2684_create(void __user *arg)
 	netdev = alloc_netdev(sizeof(struct br2684_dev),
 			      ni.ifname[0] ? ni.ifname : "nas%d",
 			      (payload == p_routed) ?
-			       br2684_setup_routed : br2684_setup);
+			      br2684_setup_routed : br2684_setup);
 	if (!netdev)
 		return -ENOMEM;
 
@@ -612,16 +621,16 @@ static int br2684_create(void __user *arg)
  * -ENOIOCTLCMD for any unrecognized ioctl
  */
 static int br2684_ioctl(struct socket *sock, unsigned int cmd,
-	unsigned long arg)
+			unsigned long arg)
 {
 	struct atm_vcc *atmvcc = ATM_SD(sock);
 	void __user *argp = (void __user *)arg;
+	atm_backend_t b;
 
 	int err;
-	switch(cmd) {
+	switch (cmd) {
 	case ATM_SETBACKEND:
-	case ATM_NEWBACKENDIF: {
-		atm_backend_t b;
+	case ATM_NEWBACKENDIF:
 		err = get_user(b, (atm_backend_t __user *) argp);
 		if (err)
 			return -EFAULT;
@@ -633,7 +642,6 @@ static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 			return br2684_regvcc(atmvcc, argp);
 		else
 			return br2684_create(argp);
-		}
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	case BR2684_SETFILT:
 		if (atmvcc->push != br2684_push)
@@ -641,6 +649,7 @@ static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		err = br2684_setfilt(atmvcc, argp);
+
 		return err;
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
 	}
@@ -648,19 +657,18 @@ static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 }
 
 static struct atm_ioctl br2684_ioctl_ops = {
-	.owner	= THIS_MODULE,
-	.ioctl	= br2684_ioctl,
+	.owner = THIS_MODULE,
+	.ioctl = br2684_ioctl,
 };
 
-
 #ifdef CONFIG_PROC_FS
-static void *br2684_seq_start(struct seq_file *seq, loff_t *pos)
+static void *br2684_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	read_lock(&devs_lock);
 	return seq_list_start(&br2684_devs, *pos);
 }
 
-static void *br2684_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *br2684_seq_next(struct seq_file *seq, void *v, loff_t * pos)
 {
 	return seq_list_next(v, &br2684_devs, pos);
 }
@@ -673,7 +681,7 @@ static void br2684_seq_stop(struct seq_file *seq, void *v)
 static int br2684_seq_show(struct seq_file *seq, void *v)
 {
 	const struct br2684_dev *brdev = list_entry(v, struct br2684_dev,
-			br2684_devs);
+						    br2684_devs);
 	const struct net_device *net_dev = brdev->net_dev;
 	const struct br2684_vcc *brvcc;
 	DECLARE_MAC_BUF(mac);
@@ -686,20 +694,18 @@ static int br2684_seq_show(struct seq_file *seq, void *v)
 
 	list_for_each_entry(brvcc, &brdev->brvccs, brvccs) {
 		seq_printf(seq, "  vcc %d.%d.%d: encaps=%s payload=%s"
-			        ", failed copies %u/%u"
-			        "\n", brvcc->atmvcc->dev->number,
-				      brvcc->atmvcc->vpi, brvcc->atmvcc->vci,
-				      (brvcc->encaps == e_llc) ? "LLC" : "VC",
-				      (brdev->payload == p_bridged) ? "bridged" : "routed",
-				      brvcc->copies_failed,
-				      brvcc->copies_needed);
+			   ", failed copies %u/%u"
+			   "\n", brvcc->atmvcc->dev->number,
+			   brvcc->atmvcc->vpi, brvcc->atmvcc->vci,
+			   (brvcc->encaps == e_llc) ? "LLC" : "VC",
+			   (brdev->payload == p_bridged) ? "bridged" : "routed",
+			   brvcc->copies_failed, brvcc->copies_needed);
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 #define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
 #define bs(var)		b1(var, 0), b1(var, 1), b1(var, 2), b1(var, 3)
-			if (brvcc->filter.netmask != 0)
-				seq_printf(seq, "    filter=%d.%d.%d.%d/"
-						"%d.%d.%d.%d\n",
-						bs(prefix), bs(netmask));
+		if (brvcc->filter.netmask != 0)
+			seq_printf(seq, "    filter=%d.%d.%d.%d/"
+				   "%d.%d.%d.%d\n", bs(prefix), bs(netmask));
 #undef bs
 #undef b1
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
@@ -709,9 +715,9 @@ static int br2684_seq_show(struct seq_file *seq, void *v)
 
 static const struct seq_operations br2684_seq_ops = {
 	.start = br2684_seq_start,
-	.next  = br2684_seq_next,
-	.stop  = br2684_seq_stop,
-	.show  = br2684_seq_show,
+	.next = br2684_seq_next,
+	.stop = br2684_seq_stop,
+	.show = br2684_seq_show,
 };
 
 static int br2684_proc_open(struct inode *inode, struct file *file)
@@ -720,15 +726,15 @@ static int br2684_proc_open(struct inode *inode, struct file *file)
 }
 
 static const struct file_operations br2684_proc_ops = {
-	.owner   = THIS_MODULE,
-	.open    = br2684_proc_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
+	.owner = THIS_MODULE,
+	.open = br2684_proc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
 	.release = seq_release,
 };
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
-#endif
+#endif /* CONFIG_PROC_FS */
 
 static int __init br2684_init(void)
 {
