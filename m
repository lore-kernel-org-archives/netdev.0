From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: replace remaining __FUNCTION__ occurances
Date: Mon, 03 Mar 2008 12:16:46 -0800
Message-ID: <1204575406.3266.55.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:13301 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbYCCURA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:17:00 -0500
Received: by wa-out-1112.google.com with SMTP id v27so275032wah.23
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 12:16:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
This was done with sed and looking over the results afterwards,
haven't reviewed every line.

 net/8021q/vlan_dev.c                          |   12 +-
 net/8021q/vlanproc.c                          |    2 +-
 net/9p/error.c                                |    2 +-
 net/bridge/br_sysfs_br.c                      |    6 +-
 net/core/sock.c                               |    2 +-
 net/dccp/dccp.h                               |    6 +-
 net/ieee80211/softmac/ieee80211softmac_priv.h |    2 +-
 net/ipv4/af_inet.c                            |    2 +-
 net/ipv4/ipvs/ip_vs_proto_tcp.c               |    2 +-
 net/ipv4/ipvs/ip_vs_proto_udp.c               |    2 +-
 net/ipv4/ipvs/ip_vs_sync.c                    |    4 +-
 net/ipv4/netfilter/arp_tables.c               |    2 +-
 net/ipv4/netfilter/ip_tables.c                |    2 +-
 net/ipv4/tcp_input.c                          |    2 +-
 net/ipv4/udplite.c                            |    4 +-
 net/ipv6/addrconf.c                           |    4 +-
 net/ipv6/addrlabel.c                          |   14 +-
 net/ipv6/ip6_tunnel.c                         |    2 +-
 net/ipv6/mip6.c                               |   20 ++--
 net/ipv6/ndisc.c                              |   14 +-
 net/ipv6/netfilter/ip6_tables.c               |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c              |    2 +-
 net/ipv6/route.c                              |    4 +-
 net/ipv6/tcp_ipv6.c                           |    8 +-
 net/irda/af_irda.c                            |  178 ++++++++++++------------
 net/irda/discovery.c                          |    4 +-
 net/irda/ircomm/ircomm_core.c                 |   46 +++---
 net/irda/ircomm/ircomm_event.c                |   12 +-
 net/irda/ircomm/ircomm_lmp.c                  |   30 ++--
 net/irda/ircomm/ircomm_param.c                |   32 +++---
 net/irda/ircomm/ircomm_ttp.c                  |   26 ++--
 net/irda/ircomm/ircomm_tty.c                  |   90 ++++++------
 net/irda/ircomm/ircomm_tty_attach.c           |   78 ++++++------
 net/irda/ircomm/ircomm_tty_ioctl.c            |   18 ++--
 net/irda/irda_device.c                        |   18 ++--
 net/irda/iriap.c                              |   76 ++++++------
 net/irda/iriap_event.c                        |   38 +++---
 net/irda/irias_object.c                       |   44 +++---
 net/irda/irlan/irlan_client.c                 |   48 ++++----
 net/irda/irlan/irlan_client_event.c           |   64 +++++-----
 net/irda/irlan/irlan_common.c                 |   72 +++++-----
 net/irda/irlan/irlan_eth.c                    |   18 ++--
 net/irda/irlan/irlan_event.c                  |    4 +-
 net/irda/irlan/irlan_filter.c                 |    4 +-
 net/irda/irlan/irlan_provider.c               |   30 ++--
 net/irda/irlan/irlan_provider_event.c         |   16 +-
 net/irda/irlap.c                              |   56 ++++----
 net/irda/irlap_event.c                        |  122 +++++++++---------
 net/irda/irlap_frame.c                        |   74 +++++-----
 net/irda/irlmp.c                              |  112 ++++++++--------
 net/irda/irlmp_event.c                        |   94 +++++++-------
 net/irda/irlmp_frame.c                        |   36 +++---
 net/irda/irmod.c                              |    2 +-
 net/irda/irnet/irnet.h                        |   10 +-
 net/irda/irnetlink.c                          |    4 +-
 net/irda/irqueue.c                            |    8 +-
 net/irda/irttp.c                              |  108 ++++++++--------
 net/irda/parameters.c                         |   42 +++---
 net/irda/qos.c                                |   24 ++--
 net/irda/wrapper.c                            |   18 ++--
 net/llc/af_llc.c                              |   16 +-
 net/llc/llc_c_ac.c                            |    2 +-
 net/llc/llc_c_ev.c                            |    8 +-
 net/llc/llc_conn.c                            |   24 ++--
 net/llc/llc_input.c                           |    4 +-
 net/mac80211/ieee80211_iface.c                |    2 +-
 net/rxrpc/ar-internal.h                       |    8 +-
 net/sctp/associola.c                          |    8 +-
 net/sctp/chunk.c                              |    2 +-
 net/sctp/input.c                              |    2 +-
 net/sctp/ipv6.c                               |    8 +-
 net/sctp/output.c                             |   14 +-
 net/sctp/outqueue.c                           |   14 +-
 net/sctp/protocol.c                           |    4 +-
 net/sctp/sm_sideeffect.c                      |    6 +-
 net/sctp/sm_statefuns.c                       |   10 +-
 net/sctp/socket.c                             |   14 +-
 net/sctp/transport.c                          |   10 +-
 net/sunrpc/auth_gss/auth_gss.c                |    2 +-
 net/sunrpc/clnt.c                             |   44 +++---
 net/sunrpc/rpc_pipe.c                         |   12 +-
 net/sunrpc/rpcb_clnt.c                        |   20 ++--
 net/sunrpc/xprtsock.c                         |    2 +-
 net/unix/af_unix.c                            |    2 +-
 84 files changed, 1008 insertions(+), 1008 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 77f04e4..556b289 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -171,7 +171,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = __find_vlan_dev(dev, vid);
 	if (!skb->dev) {
 		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
-			 __FUNCTION__, (unsigned int)vid, dev->name);
+			 __func__, (unsigned int)vid, dev->name);
 		goto err_unlock;
 	}
 
@@ -187,7 +187,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 						  ntohs(vhdr->h_vlan_TCI));
 
 	pr_debug("%s: priority: %u for TCI: %hu\n",
-		 __FUNCTION__, skb->priority, ntohs(vhdr->h_vlan_TCI));
+		 __func__, skb->priority, ntohs(vhdr->h_vlan_TCI));
 
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST: /* Yeah, stats collect these together.. */
@@ -268,7 +268,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	struct net_device *vdev = dev;
 
 	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
-		 __FUNCTION__, skb, type, len, vlan_dev_info(dev)->vlan_id,
+		 __func__, skb, type, len, vlan_dev_info(dev)->vlan_id,
 		 daddr);
 
 	/* build vlan header only if re_order_header flag is NOT set.  This
@@ -340,7 +340,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			return -ENOMEM;
 		}
 		vlan_dev_info(vdev)->cnt_inc_headroom_on_tx++;
-		pr_debug("%s: %s: had to grow skb\n", __FUNCTION__, vdev->name);
+		pr_debug("%s: %s: had to grow skb\n", __func__, vdev->name);
 	}
 
 	if (build_vlan_header) {
@@ -382,7 +382,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_dev_info(dev)->cnt_encap_on_xmit++;
 
 		pr_debug("%s: proto to encap: 0x%hx\n",
-			 __FUNCTION__, htons(veth->h_vlan_proto));
+			 __func__, htons(veth->h_vlan_proto));
 		/* Construct the second two bytes. This field looks something
 		 * like:
 		 * usr_priority: 3 bits	 (high bits)
@@ -403,7 +403,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	pr_debug("%s: about to send skb: %p to dev: %s\n",
-		__FUNCTION__, skb, skb->dev->name);
+		__func__, skb, skb->dev->name);
 	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
 		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
 		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 146cfb0..3b8657a 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -168,7 +168,7 @@ int __init vlan_proc_init(void)
 	return 0;
 
 err:
-	pr_err("%s: can't create entry in proc filesystem!\n", __FUNCTION__);
+	pr_err("%s: can't create entry in proc filesystem!\n", __func__);
 	vlan_proc_cleanup();
 	return -ENOBUFS;
 }
diff --git a/net/9p/error.c b/net/9p/error.c
index ab2458b..64104b9 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -230,7 +230,7 @@ int p9_errstr2errno(char *errstr, int len)
 	if (errno == 0) {
 		/* TODO: if error isn't found, add it dynamically */
 		errstr[len] = 0;
-		printk(KERN_ERR "%s: errstr :%s: not found\n", __FUNCTION__,
+		printk(KERN_ERR "%s: errstr :%s: not found\n", __func__,
 		       errstr);
 		errno = 1;
 	}
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 9cf0538..27d6a51 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -415,21 +415,21 @@ int br_sysfs_addbr(struct net_device *dev)
 	err = sysfs_create_group(brobj, &bridge_group);
 	if (err) {
 		pr_info("%s: can't create group %s/%s\n",
-			__FUNCTION__, dev->name, bridge_group.name);
+			__func__, dev->name, bridge_group.name);
 		goto out1;
 	}
 
 	err = sysfs_create_bin_file(brobj, &bridge_forward);
 	if (err) {
 		pr_info("%s: can't create attribute file %s/%s\n",
-			__FUNCTION__, dev->name, bridge_forward.attr.name);
+			__func__, dev->name, bridge_forward.attr.name);
 		goto out2;
 	}
 
 	br->ifobj = kobject_create_and_add(SYSFS_BRIDGE_PORT_SUBDIR, brobj);
 	if (!br->ifobj) {
 		pr_info("%s: can't add kobject (directory) %s/%s\n",
-			__FUNCTION__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
+			__func__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
 		goto out3;
 	}
 	return 0;
diff --git a/net/core/sock.c b/net/core/sock.c
index 0ca0697..bb5236a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -981,7 +981,7 @@ void sk_free(struct sock *sk)
 
 	if (atomic_read(&sk->sk_omem_alloc))
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
-		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
+		       __func__, atomic_read(&sk->sk_omem_alloc));
 
 	put_net(sk->sk_net);
 	sk_prot_free(sk->sk_prot_creator, sk);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 287a62b..e1b7c9c 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -23,9 +23,9 @@
  * 	DCCP - specific warning and debugging macros.
  */
 #define DCCP_WARN(fmt, a...) LIMIT_NETDEBUG(KERN_WARNING "%s: " fmt,       \
-							__FUNCTION__, ##a)
+							__func__, ##a)
 #define DCCP_CRIT(fmt, a...) printk(KERN_CRIT fmt " at %s:%d/%s()\n", ##a, \
-					 __FILE__, __LINE__, __FUNCTION__)
+					 __FILE__, __LINE__, __func__)
 #define DCCP_BUG(a...)       do { DCCP_CRIT("BUG: " a); dump_stack(); } while(0)
 #define DCCP_BUG_ON(cond)    do { if (unlikely((cond) != 0))		   \
 				     DCCP_BUG("\"%s\" holds (exception!)", \
@@ -36,7 +36,7 @@
 							printk(fmt, ##args); \
 						} while(0)
 #define DCCP_PR_DEBUG(enable, fmt, a...)	DCCP_PRINTK(enable, KERN_DEBUG \
-						  "%s: " fmt, __FUNCTION__, ##a)
+						  "%s: " fmt, __func__, ##a)
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern int dccp_debug;
diff --git a/net/ieee80211/softmac/ieee80211softmac_priv.h b/net/ieee80211/softmac/ieee80211softmac_priv.h
index c43b189..f9232c8 100644
--- a/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ b/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -43,7 +43,7 @@
 	do {										\
 		if (unlikely(!(expr))) {						\
 		printkl(KERN_ERR PFX "ASSERTION FAILED (%s) at: %s:%d:%s()\n", #expr,	\
-			__FILE__, __LINE__, __FUNCTION__);				\
+			__FILE__, __LINE__, __func__);				\
 		}									\
 	} while (0)
 #else
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4f539bd..4cb8a13 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1060,7 +1060,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	if (sysctl_ip_dynaddr > 1) {
 		printk(KERN_INFO "%s(): shifting inet->"
 				 "saddr from %d.%d.%d.%d to %d.%d.%d.%d\n",
-		       __FUNCTION__,
+		       __func__,
 		       NIPQUAD(old_saddr),
 		       NIPQUAD(new_saddr));
 	}
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 12dc0d6..620e40f 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -550,7 +550,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 
 			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
 				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __FUNCTION__,
+				  __func__,
 				  NIPQUAD(cp->caddr), ntohs(cp->cport),
 				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
 				  inc->name, ntohs(inc->port));
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 1fa7b33..1caa290 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -344,7 +344,7 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 
 			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
 				  "%u.%u.%u.%u:%u to app %s on port %u\n",
-				  __FUNCTION__,
+				  __func__,
 				  NIPQUAD(cp->caddr), ntohs(cp->cport),
 				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
 				  inc->name, ntohs(inc->port));
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 948378d..69c5666 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -916,7 +916,7 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 	if (!tinfo)
 		return -ENOMEM;
 
-	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, task_pid_nr(current));
+	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn));
 
@@ -956,7 +956,7 @@ int stop_sync_thread(int state)
 	    (state == IP_VS_STATE_BACKUP && !sync_backup_pid))
 		return -ESRCH;
 
-	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, task_pid_nr(current));
+	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_INFO("stopping sync thread %d ...\n",
 		   (state == IP_VS_STATE_MASTER) ?
 		   sync_master_pid : sync_backup_pid);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a7591ce..5d5e604 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -52,7 +52,7 @@ MODULE_DESCRIPTION("arptables core");
 do {								\
 	if (!(x))						\
 		printk("ARP_NF_ASSERT: %s:%s:%u\n",		\
-		       __FUNCTION__, __FILE__, __LINE__);	\
+		       __func__, __FILE__, __LINE__);	\
 } while(0)
 #else
 #define ARP_NF_ASSERT(x)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 600737f..85a75e1 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -53,7 +53,7 @@ MODULE_DESCRIPTION("IPv4 packet filter");
 do {								\
 	if (!(x))						\
 		printk("IP_NF_ASSERT: %s:%s:%u\n",		\
-		       __FUNCTION__, __FILE__, __LINE__);	\
+		       __func__, __FILE__, __LINE__);	\
 } while(0)
 #else
 #define IP_NF_ASSERT(x)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..30eeac6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3557,7 +3557,7 @@ static void tcp_fin(struct sk_buff *skb, struct sock *sk, struct tcphdr *th)
 		 * cases we should never reach this piece of code.
 		 */
 		printk(KERN_ERR "%s: Impossible, sk->sk_state=%d\n",
-		       __FUNCTION__, sk->sk_state);
+		       __func__, sk->sk_state);
 		break;
 	}
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 001b881..d49c6d6 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -106,14 +106,14 @@ void __init udplite4_register(void)
 
 #ifdef CONFIG_PROC_FS
 	if (udp_proc_register(&udplite4_seq_afinfo)) /* udplite4_proc_init() */
-		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
+		printk(KERN_ERR "%s: Cannot register /proc!\n", __func__);
 #endif
 	return;
 
 out_unregister_proto:
 	proto_unregister(&udplite_prot);
 out_register_err:
-	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __FUNCTION__);
+	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __func__);
 }
 
 EXPORT_SYMBOL(udplite_hash);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 18e3a98..555489b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -349,7 +349,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	if (snmp6_alloc_dev(ndev) < 0) {
 		ADBG((KERN_WARNING
 			"%s(): cannot allocate memory for statistics; dev=%s.\n",
-			__FUNCTION__, dev->name));
+			__func__, dev->name));
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
 		in6_dev_finish_destroy(ndev);
@@ -359,7 +359,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	if (snmp6_register_dev(ndev) < 0) {
 		ADBG((KERN_WARNING
 			"%s(): cannot create /proc/net/dev_snmp6/%s\n",
-			__FUNCTION__, dev->name));
+			__func__, dev->name));
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
 		in6_dev_finish_destroy(ndev);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 3a8b3f5..de371b5 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -166,7 +166,7 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 	rcu_read_unlock();
 
 	ADDRLABEL(KERN_DEBUG "%s(addr=" NIP6_FMT ", type=%d, ifindex=%d) => %08x\n",
-			__FUNCTION__,
+			__func__,
 			NIP6(*addr), type, ifindex,
 			label);
 
@@ -182,7 +182,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 	int addrtype;
 
 	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
-			__FUNCTION__,
+			__func__,
 			NIP6(*prefix), prefixlen,
 			ifindex,
 			(unsigned int)label);
@@ -226,7 +226,7 @@ static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 	int ret = 0;
 
 	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n",
-			__FUNCTION__,
+			__func__,
 			newp, replace);
 
 	if (hlist_empty(&ip6addrlbl_table.head)) {
@@ -268,7 +268,7 @@ static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 	int ret = 0;
 
 	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
-			__FUNCTION__,
+			__func__,
 			NIP6(*prefix), prefixlen,
 			ifindex,
 			(unsigned int)label,
@@ -294,7 +294,7 @@ static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 	int ret = -ESRCH;
 
 	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
-			__FUNCTION__,
+			__func__,
 			NIP6(*prefix), prefixlen,
 			ifindex);
 
@@ -318,7 +318,7 @@ static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 	int ret;
 
 	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
-			__FUNCTION__,
+			__func__,
 			NIP6(*prefix), prefixlen,
 			ifindex);
 
@@ -335,7 +335,7 @@ static __init int ip6addrlbl_init(void)
 	int err = 0;
 	int i;
 
-	ADDRLABEL(KERN_DEBUG "%s()\n", __FUNCTION__);
+	ADDRLABEL(KERN_DEBUG "%s()\n", __func__);
 
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
 		int ret = ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 78f4388..1f9de5e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -60,7 +60,7 @@ MODULE_LICENSE("GPL");
 #define IPV6_TLV_TEL_DST_SIZE 8
 
 #ifdef IP6_TNL_DEBUG
-#define IP6_TNL_TRACE(x...) printk(KERN_DEBUG "%s:" x "\n", __FUNCTION__)
+#define IP6_TNL_TRACE(x...) printk(KERN_DEBUG "%s:" x "\n", __func__)
 #else
 #define IP6_TNL_TRACE(x...) do {;} while(0)
 #endif
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index cd8a5bd..42403c6 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -304,13 +304,13 @@ static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
 static int mip6_destopt_init_state(struct xfrm_state *x)
 {
 	if (x->id.spi) {
-		printk(KERN_INFO "%s: spi is not 0: %u\n", __FUNCTION__,
+		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,
 		       x->id.spi);
 		return -EINVAL;
 	}
 	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
 		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
-		       __FUNCTION__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		       __func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
 		return -EINVAL;
 	}
 
@@ -439,13 +439,13 @@ static int mip6_rthdr_offset(struct xfrm_state *x, struct sk_buff *skb,
 static int mip6_rthdr_init_state(struct xfrm_state *x)
 {
 	if (x->id.spi) {
-		printk(KERN_INFO "%s: spi is not 0: %u\n", __FUNCTION__,
+		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,
 		       x->id.spi);
 		return -EINVAL;
 	}
 	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
 		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
-		       __FUNCTION__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		       __func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
 		return -EINVAL;
 	}
 
@@ -480,15 +480,15 @@ static int __init mip6_init(void)
 	printk(KERN_INFO "Mobile IPv6\n");
 
 	if (xfrm_register_type(&mip6_destopt_type, AF_INET6) < 0) {
-		printk(KERN_INFO "%s: can't add xfrm type(destopt)\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't add xfrm type(destopt)\n", __func__);
 		goto mip6_destopt_xfrm_fail;
 	}
 	if (xfrm_register_type(&mip6_rthdr_type, AF_INET6) < 0) {
-		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __func__);
 		goto mip6_rthdr_xfrm_fail;
 	}
 	if (rawv6_mh_filter_register(mip6_mh_filter) < 0) {
-		printk(KERN_INFO "%s: can't add rawv6 mh filter\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't add rawv6 mh filter\n", __func__);
 		goto mip6_rawv6_mh_fail;
 	}
 
@@ -506,11 +506,11 @@ static int __init mip6_init(void)
 static void __exit mip6_fini(void)
 {
 	if (rawv6_mh_filter_unregister(mip6_mh_filter) < 0)
-		printk(KERN_INFO "%s: can't remove rawv6 mh filter\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't remove rawv6 mh filter\n", __func__);
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
-		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __func__);
 	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
-		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __FUNCTION__);
+		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __func__);
 }
 
 module_init(mip6_init);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1fc33c8..e0dce00 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -270,7 +270,7 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
 				ND_PRINTK2(KERN_WARNING
 					   "%s(): duplicated ND6 option found: type=%d\n",
-					   __FUNCTION__,
+					   __func__,
 					   nd_opt->nd_opt_type);
 			} else {
 				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
@@ -301,7 +301,7 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 				 */
 				ND_PRINTK2(KERN_NOTICE
 					   "%s(): ignored unsupported option; type=%d, len=%d\n",
-					   __FUNCTION__,
+					   __func__,
 					   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
 			}
 		}
@@ -499,7 +499,7 @@ static void __ndisc_send(struct net_device *dev,
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 ND: %s() failed to allocate an skb.\n",
-			   __FUNCTION__);
+			   __func__);
 		dst_release(dst);
 		return;
 	}
@@ -662,7 +662,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 			ND_PRINTK1(KERN_DEBUG
 				   "%s(): trying to ucast probe in NUD_INVALID: "
 				   NIP6_FMT "\n",
-				   __FUNCTION__,
+				   __func__,
 				   NIP6(*target));
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
@@ -1164,7 +1164,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		if (rt == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() failed to add default route.\n",
-				   __FUNCTION__);
+				   __func__);
 			in6_dev_put(in6_dev);
 			return;
 		}
@@ -1173,7 +1173,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
-				   __FUNCTION__);
+				   __func__);
 			dst_release(&rt->u.dst);
 			in6_dev_put(in6_dev);
 			return;
@@ -1486,7 +1486,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 Redirect: %s() failed to allocate an skb.\n",
-			   __FUNCTION__);
+			   __func__);
 		dst_release(dst);
 		return;
 	}
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index bf9bb6e..af1ec7b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -55,7 +55,7 @@ MODULE_DESCRIPTION("IPv6 packet filter");
 do {								\
 	if (!(x))						\
 		printk("IP_NF_ASSERT: %s:%s:%u\n",		\
-		       __FUNCTION__, __FILE__, __LINE__);	\
+		       __func__, __FILE__, __LINE__);	\
 } while(0)
 #else
 #define IP_NF_ASSERT(x)
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index b23baa6..80daa38 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -177,7 +177,7 @@ reject_tg6(struct sk_buff *skb, const struct net_device *in,
 {
 	const struct ip6t_reject_info *reject = targinfo;
 
-	pr_debug("%s: medium point\n", __FUNCTION__);
+	pr_debug("%s: medium point\n", __func__);
 	/* WARNING: This code causes reentry within ip6tables.
 	   This means that the ip6tables jump stack is now crap.  We
 	   must return an absolute verdict. --RR */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e8b241c..33d6f1c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -411,7 +411,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	struct rt6_info *match, *rt0;
 
 	RT6_TRACE("%s(fn->leaf=%p, oif=%d)\n",
-		  __FUNCTION__, fn->leaf, oif);
+		  __func__, fn->leaf, oif);
 
 	rt0 = fn->rr_ptr;
 	if (!rt0)
@@ -432,7 +432,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	}
 
 	RT6_TRACE("%s() => %p\n",
-		  __FUNCTION__, match);
+		  __func__, match);
 
 	return (match ? match : &ip6_null_entry);
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1cbbb87..517b8c3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -739,7 +739,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp) {
-		printk(KERN_WARNING "%s(): hash pool not found...\n", __FUNCTION__);
+		printk(KERN_WARNING "%s(): hash pool not found...\n", __func__);
 		goto clear_hash_noput;
 	}
 	bp = &hp->md5_blk.ip6;
@@ -779,17 +779,17 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	/* Now store the hash into the packet */
 	err = crypto_hash_init(desc);
 	if (err) {
-		printk(KERN_WARNING "%s(): hash_init failed\n", __FUNCTION__);
+		printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
 		goto clear_hash;
 	}
 	err = crypto_hash_update(desc, sg, nbytes);
 	if (err) {
-		printk(KERN_WARNING "%s(): hash_update failed\n", __FUNCTION__);
+		printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
 		goto clear_hash;
 	}
 	err = crypto_hash_final(desc, md5_hash);
 	if (err) {
-		printk(KERN_WARNING "%s(): hash_final failed\n", __FUNCTION__);
+		printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
 		goto clear_hash;
 	}
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 240b0cb..6f21a53 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -85,14 +85,14 @@ static int irda_data_indication(void *instance, void *sap, struct sk_buff *skb)
 	struct sock *sk;
 	int err;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	self = instance;
 	sk = instance;
 
 	err = sock_queue_rcv_skb(sk, skb);
 	if (err) {
-		IRDA_DEBUG(1, "%s(), error: no more mem!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), error: no more mem!\n", __func__);
 		self->rx_flow = FLOW_STOP;
 
 		/* When we return error, TTP will need to requeue the skb */
@@ -116,7 +116,7 @@ static void irda_disconnect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	/* Don't care about it, but let's not leak it */
 	if(skb)
@@ -125,7 +125,7 @@ static void irda_disconnect_indication(void *instance, void *sap,
 	sk = instance;
 	if (sk == NULL) {
 		IRDA_DEBUG(0, "%s(%p) : BUG : sk is NULL\n",
-			   __FUNCTION__, self);
+			   __func__, self);
 		return;
 	}
 
@@ -181,7 +181,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	sk = instance;
 	if (sk == NULL) {
@@ -203,7 +203,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 	case SOCK_STREAM:
 		if (max_sdu_size != 0) {
 			IRDA_ERROR("%s: max_sdu_size must be 0\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
@@ -211,7 +211,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 	case SOCK_SEQPACKET:
 		if (max_sdu_size == 0) {
 			IRDA_ERROR("%s: max_sdu_size cannot be 0\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 		self->max_data_size = max_sdu_size;
@@ -220,7 +220,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
 	}
 
-	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __func__,
 		   self->max_data_size);
 
 	memcpy(&self->qos_tx, qos, sizeof(struct qos_info));
@@ -245,7 +245,7 @@ static void irda_connect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	sk = instance;
 	if (sk == NULL) {
@@ -264,7 +264,7 @@ static void irda_connect_indication(void *instance, void *sap,
 	case SOCK_STREAM:
 		if (max_sdu_size != 0) {
 			IRDA_ERROR("%s: max_sdu_size must be 0\n",
-				   __FUNCTION__);
+				   __func__);
 			kfree_skb(skb);
 			return;
 		}
@@ -273,7 +273,7 @@ static void irda_connect_indication(void *instance, void *sap,
 	case SOCK_SEQPACKET:
 		if (max_sdu_size == 0) {
 			IRDA_ERROR("%s: max_sdu_size cannot be 0\n",
-				   __FUNCTION__);
+				   __func__);
 			kfree_skb(skb);
 			return;
 		}
@@ -283,7 +283,7 @@ static void irda_connect_indication(void *instance, void *sap,
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
 	}
 
-	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __func__,
 		   self->max_data_size);
 
 	memcpy(&self->qos_tx, qos, sizeof(struct qos_info));
@@ -302,13 +302,13 @@ static void irda_connect_response(struct irda_sock *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
 			GFP_ATOMIC);
 	if (skb == NULL) {
 		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
@@ -329,7 +329,7 @@ static void irda_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	struct irda_sock *self;
 	struct sock *sk;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	self = instance;
 	sk = instance;
@@ -338,17 +338,17 @@ static void irda_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	switch (flow) {
 	case FLOW_STOP:
 		IRDA_DEBUG(1, "%s(), IrTTP wants us to slow down\n",
-			   __FUNCTION__);
+			   __func__);
 		self->tx_flow = flow;
 		break;
 	case FLOW_START:
 		self->tx_flow = flow;
 		IRDA_DEBUG(1, "%s(), IrTTP wants us to start again\n",
-			   __FUNCTION__);
+			   __func__);
 		wake_up_interruptible(sk->sk_sleep);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown flow command!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Unknown flow command!\n", __func__);
 		/* Unknown flow command, better stop */
 		self->tx_flow = flow;
 		break;
@@ -370,11 +370,11 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 
 	self = (struct irda_sock *) priv;
 	if (!self) {
-		IRDA_WARNING("%s: lost myself!\n", __FUNCTION__);
+		IRDA_WARNING("%s: lost myself!\n", __func__);
 		return;
 	}
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	/* We probably don't need to make any more queries */
 	iriap_close(self->iriap);
@@ -382,7 +382,7 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(1, "%s(), IAS query failed! (%d)\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), IAS query failed! (%d)\n", __func__,
 			   result);
 
 		self->errno = result;	/* We really need it later */
@@ -415,11 +415,11 @@ static void irda_selective_discovery_indication(discinfo_t *discovery,
 {
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	self = (struct irda_sock *) priv;
 	if (!self) {
-		IRDA_WARNING("%s: lost myself!\n", __FUNCTION__);
+		IRDA_WARNING("%s: lost myself!\n", __func__);
 		return;
 	}
 
@@ -442,7 +442,7 @@ static void irda_discovery_timeout(u_long priv)
 {
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	self = (struct irda_sock *) priv;
 	BUG_ON(self == NULL);
@@ -467,7 +467,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 	notify_t notify;
 
 	if (self->tsap) {
-		IRDA_WARNING("%s: busy!\n", __FUNCTION__);
+		IRDA_WARNING("%s: busy!\n", __func__);
 		return -EBUSY;
 	}
 
@@ -486,7 +486,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 				     &notify);
 	if (self->tsap == NULL) {
 		IRDA_DEBUG(0, "%s(), Unable to allocate TSAP!\n",
-			   __FUNCTION__);
+			   __func__);
 		return -ENOMEM;
 	}
 	/* Remember which TSAP selector we actually got */
@@ -507,7 +507,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
 	notify_t notify;
 
 	if (self->lsap) {
-		IRDA_WARNING("%s(), busy!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), busy!\n", __func__);
 		return -EBUSY;
 	}
 
@@ -519,7 +519,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
 
 	self->lsap = irlmp_open_lsap(LSAP_CONNLESS, &notify, pid);
 	if (self->lsap == NULL) {
-		IRDA_DEBUG( 0, "%s(), Unable to allocate LSAP!\n", __FUNCTION__);
+		IRDA_DEBUG( 0, "%s(), Unable to allocate LSAP!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -540,11 +540,11 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
  */
 static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 {
-	IRDA_DEBUG(2, "%s(%p, %s)\n", __FUNCTION__, self, name);
+	IRDA_DEBUG(2, "%s(%p, %s)\n", __func__, self, name);
 
 	if (self->iriap) {
 		IRDA_WARNING("%s(): busy with a previous query\n",
-			     __FUNCTION__);
+			     __func__);
 		return -EBUSY;
 	}
 
@@ -580,7 +580,7 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 	switch (self->ias_result->type) {
 	case IAS_INTEGER:
 		IRDA_DEBUG(4, "%s() int=%d\n",
-			   __FUNCTION__, self->ias_result->t.integer);
+			   __func__, self->ias_result->t.integer);
 
 		if (self->ias_result->t.integer != -1)
 			self->dtsap_sel = self->ias_result->t.integer;
@@ -589,7 +589,7 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 		break;
 	default:
 		self->dtsap_sel = 0;
-		IRDA_DEBUG(0, "%s(), bad type!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), bad type!\n", __func__);
 		break;
 	}
 	if (self->ias_result)
@@ -627,7 +627,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	__u32	daddr = DEV_ADDR_ANY;	/* Address we found the service on */
 	__u8	dtsap_sel = 0x0;	/* TSAP associated with it */
 
-	IRDA_DEBUG(2, "%s(), name=%s\n", __FUNCTION__, name);
+	IRDA_DEBUG(2, "%s(), name=%s\n", __func__, name);
 
 	/* Ask lmp for the current discovery log
 	 * Note : we have to use irlmp_get_discoveries(), as opposed
@@ -649,7 +649,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 		self->daddr = discoveries[i].daddr;
 		self->saddr = 0x0;
 		IRDA_DEBUG(1, "%s(), trying daddr = %08x\n",
-			   __FUNCTION__, self->daddr);
+			   __func__, self->daddr);
 
 		/* Query remote LM-IAS for this service */
 		err = irda_find_lsap_sel(self, name);
@@ -658,7 +658,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 			/* We found the requested service */
 			if(daddr != DEV_ADDR_ANY) {
 				IRDA_DEBUG(1, "%s(), discovered service ''%s'' in two different devices !!!\n",
-					   __FUNCTION__, name);
+					   __func__, name);
 				self->daddr = DEV_ADDR_ANY;
 				kfree(discoveries);
 				return(-ENOTUNIQ);
@@ -672,7 +672,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 			break;
 		default:
 			/* Something bad did happen :-( */
-			IRDA_DEBUG(0, "%s(), unexpected IAS query failure\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), unexpected IAS query failure\n", __func__);
 			self->daddr = DEV_ADDR_ANY;
 			kfree(discoveries);
 			return(-EHOSTUNREACH);
@@ -685,7 +685,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	/* Check out what we found */
 	if(daddr == DEV_ADDR_ANY) {
 		IRDA_DEBUG(1, "%s(), cannot discover service ''%s'' in any device !!!\n",
-			   __FUNCTION__, name);
+			   __func__, name);
 		self->daddr = DEV_ADDR_ANY;
 		return(-EADDRNOTAVAIL);
 	}
@@ -696,7 +696,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	self->dtsap_sel = dtsap_sel;
 
 	IRDA_DEBUG(1, "%s(), discovered requested service ''%s'' at address %08x\n",
-		   __FUNCTION__, name, self->daddr);
+		   __func__, name, self->daddr);
 
 	return 0;
 }
@@ -727,8 +727,8 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 		saddr.sir_addr = self->saddr;
 	}
 
-	IRDA_DEBUG(1, "%s(), tsap_sel = %#x\n", __FUNCTION__, saddr.sir_lsap_sel);
-	IRDA_DEBUG(1, "%s(), addr = %08x\n", __FUNCTION__, saddr.sir_addr);
+	IRDA_DEBUG(1, "%s(), tsap_sel = %#x\n", __func__, saddr.sir_lsap_sel);
+	IRDA_DEBUG(1, "%s(), addr = %08x\n", __func__, saddr.sir_addr);
 
 	/* uaddr_len come to us uninitialised */
 	*uaddr_len = sizeof (struct sockaddr_irda);
@@ -747,7 +747,7 @@ static int irda_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
 	    (sk->sk_type != SOCK_DGRAM))
@@ -776,7 +776,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct irda_sock *self = irda_sk(sk);
 	int err;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	if (addr_len != sizeof(struct sockaddr_irda))
 		return -EINVAL;
@@ -787,7 +787,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	    (sk->sk_protocol == IRDAPROTO_ULTRA)) {
 		self->pid = addr->sir_lsap_sel;
 		if (self->pid & 0x80) {
-			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
 			return -EOPNOTSUPP;
 		}
 		err = irda_open_lsap(self, self->pid);
@@ -835,7 +835,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	err = irda_create(sk->sk_net, newsock, sk->sk_protocol);
 	if (err)
@@ -893,7 +893,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	/* Now attach up the new socket */
 	new->tsap = irttp_dup(self->tsap, new);
 	if (!new->tsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -954,7 +954,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct irda_sock *self = irda_sk(sk);
 	int err;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	/* Don't allow connect for Ultra sockets */
 	if ((sk->sk_type == SOCK_DGRAM) && (sk->sk_protocol == IRDAPROTO_ULTRA))
@@ -984,13 +984,13 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 		/* Try to find one suitable */
 		err = irda_discover_daddr_and_lsap_sel(self, addr->sir_name);
 		if (err) {
-			IRDA_DEBUG(0, "%s(), auto-connect failed!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), auto-connect failed!\n", __func__);
 			return err;
 		}
 	} else {
 		/* Use the one provided by the user */
 		self->daddr = addr->sir_addr;
-		IRDA_DEBUG(1, "%s(), daddr = %08x\n", __FUNCTION__, self->daddr);
+		IRDA_DEBUG(1, "%s(), daddr = %08x\n", __func__, self->daddr);
 
 		/* If we don't have a valid service name, we assume the
 		 * user want to connect on a specific LSAP. Prevent
@@ -1000,7 +1000,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 			/* Query remote LM-IAS using service name */
 			err = irda_find_lsap_sel(self, addr->sir_name);
 			if (err) {
-				IRDA_DEBUG(0, "%s(), connect failed!\n", __FUNCTION__);
+				IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
 				return err;
 			}
 		} else {
@@ -1025,7 +1025,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 				    self->saddr, self->daddr, NULL,
 				    self->max_sdu_size_rx, NULL);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), connect failed!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
 		return err;
 	}
 
@@ -1068,7 +1068,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 	struct sock *sk;
 	struct irda_sock *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
@@ -1089,7 +1089,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 		return -ENOMEM;
 
 	self = irda_sk(sk);
-	IRDA_DEBUG(2, "%s() : self is %p\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s() : self is %p\n", __func__, self);
 
 	init_waitqueue_head(&self->query_wait);
 
@@ -1149,7 +1149,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
  */
 static void irda_destroy_socket(struct irda_sock *self)
 {
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	/* Unregister with IrLMP */
 	irlmp_unregister_client(self->ckey);
@@ -1186,7 +1186,7 @@ static int irda_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (sk == NULL)
 		return 0;
@@ -1254,7 +1254,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err = -EPIPE;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __FUNCTION__, len);
+	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR | MSG_CMSG_COMPAT |
@@ -1282,7 +1282,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	/* Check that we don't send out too big frames */
 	if (len > self->max_data_size) {
 		IRDA_DEBUG(2, "%s(), Chopping frame from %zd to %d bytes!\n",
-			   __FUNCTION__, len, self->max_data_size);
+			   __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1306,7 +1306,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	 */
 	err = irttp_data_request(self->tsap, skb);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), err=%d\n", __FUNCTION__, err);
+		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 		goto out_err;
 	}
 	/* Tell client how much data we actually sent */
@@ -1332,7 +1332,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	size_t copied;
 	int err;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	if ((err = sock_error(sk)) < 0)
 		return err;
@@ -1347,7 +1347,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 
 	if (copied > size) {
 		IRDA_DEBUG(2, "%s(), Received truncated frame (%zd < %zd)!\n",
-			   __FUNCTION__, copied, size);
+			   __func__, copied, size);
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
@@ -1363,7 +1363,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	 */
 	if (self->rx_flow == FLOW_STOP) {
 		if ((atomic_read(&sk->sk_rmem_alloc) << 2) <= sk->sk_rcvbuf) {
-			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __func__);
 			self->rx_flow = FLOW_START;
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
@@ -1385,7 +1385,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 	int target, err;
 	long timeo;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	if ((err = sock_error(sk)) < 0)
 		return err;
@@ -1459,14 +1459,14 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 			/* put the skb back if we didn't use it up.. */
 			if (skb->len) {
 				IRDA_DEBUG(1, "%s(), back on q!\n",
-					   __FUNCTION__);
+					   __func__);
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				break;
 			}
 
 			kfree_skb(skb);
 		} else {
-			IRDA_DEBUG(0, "%s() questionable!?\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s() questionable!?\n", __func__);
 
 			/* put message back and return */
 			skb_queue_head(&sk->sk_receive_queue, skb);
@@ -1482,7 +1482,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 	 */
 	if (self->rx_flow == FLOW_STOP) {
 		if ((atomic_read(&sk->sk_rmem_alloc) << 2) <= sk->sk_rcvbuf) {
-			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), Starting IrTTP\n", __func__);
 			self->rx_flow = FLOW_START;
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
@@ -1506,7 +1506,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __FUNCTION__, len);
+	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
@@ -1528,7 +1528,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	if (len > self->max_data_size) {
 		IRDA_DEBUG(0, "%s(), Warning to much data! "
 			   "Chopping frame from %zd to %d bytes!\n",
-			   __FUNCTION__, len, self->max_data_size);
+			   __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1540,7 +1540,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
 
-	IRDA_DEBUG(4, "%s(), appending user data\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
 	skb_put(skb, len);
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
@@ -1554,7 +1554,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	 */
 	err = irttp_udata_request(self->tsap, skb);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), err=%d\n", __FUNCTION__, err);
+		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 		return err;
 	}
 	return len;
@@ -1577,7 +1577,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	IRDA_DEBUG(4, "%s(), len=%zd\n", __FUNCTION__, len);
+	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
 		return -EINVAL;
@@ -1600,7 +1600,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 		pid = addr->sir_lsap_sel;
 		if (pid & 0x80) {
-			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
 			return -EOPNOTSUPP;
 		}
 	} else {
@@ -1609,7 +1609,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 		if ((self->lsap == NULL) ||
 		    (sk->sk_state != TCP_ESTABLISHED)) {
 			IRDA_DEBUG(0, "%s(), socket not bound to Ultra PID.\n",
-				   __FUNCTION__);
+				   __func__);
 			return -ENOTCONN;
 		}
 		/* Use PID from socket */
@@ -1623,7 +1623,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	if (len > self->max_data_size) {
 		IRDA_DEBUG(0, "%s(), Warning to much data! "
 			   "Chopping frame from %zd to %d bytes!\n",
-			   __FUNCTION__, len, self->max_data_size);
+			   __func__, len, self->max_data_size);
 		len = self->max_data_size;
 	}
 
@@ -1635,7 +1635,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
 
-	IRDA_DEBUG(4, "%s(), appending user data\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s(), appending user data\n", __func__);
 	skb_put(skb, len);
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
@@ -1646,7 +1646,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	err = irlmp_connless_data_request((bound ? self->lsap : NULL),
 					  skb, pid);
 	if (err) {
-		IRDA_DEBUG(0, "%s(), err=%d\n", __FUNCTION__, err);
+		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 		return err;
 	}
 	return len;
@@ -1661,7 +1661,7 @@ static int irda_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 
-	IRDA_DEBUG(1, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(1, "%s(%p)\n", __func__, self);
 
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
@@ -1696,7 +1696,7 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	struct irda_sock *self = irda_sk(sk);
 	unsigned int mask;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	poll_wait(file, sk->sk_sleep, wait);
 	mask = 0;
@@ -1705,7 +1705,7 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	if (sk->sk_err)
 		mask |= POLLERR;
 	if (sk->sk_shutdown & RCV_SHUTDOWN) {
-		IRDA_DEBUG(0, "%s(), POLLHUP\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), POLLHUP\n", __func__);
 		mask |= POLLHUP;
 	}
 
@@ -1719,7 +1719,7 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	switch (sk->sk_type) {
 	case SOCK_STREAM:
 		if (sk->sk_state == TCP_CLOSE) {
-			IRDA_DEBUG(0, "%s(), POLLHUP\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), POLLHUP\n", __func__);
 			mask |= POLLHUP;
 		}
 
@@ -1755,7 +1755,7 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 
-	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __FUNCTION__, cmd);
+	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __func__, cmd);
 
 	switch (cmd) {
 	case TIOCOUTQ: {
@@ -1796,7 +1796,7 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCSIFMETRIC:
 		return -EINVAL;
 	default:
-		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __func__);
 		return -ENOIOCTLCMD;
 	}
 
@@ -1833,7 +1833,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
 	int opt, free_ias = 0;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	if (level != SOL_IRLMP)
 		return -ENOPROTOOPT;
@@ -2012,7 +2012,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 
 		/* Check is the user space own the object */
 		if(ias_attr->value->owner != IAS_USER_ATTR) {
-			IRDA_DEBUG(1, "%s(), attempting to delete a kernel attribute\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), attempting to delete a kernel attribute\n", __func__);
 			kfree(ias_opt);
 			return -EPERM;
 		}
@@ -2031,11 +2031,11 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 		/* Only possible for a seqpacket service (TTP with SAR) */
 		if (sk->sk_type != SOCK_SEQPACKET) {
 			IRDA_DEBUG(2, "%s(), setting max_sdu_size = %d\n",
-				   __FUNCTION__, opt);
+				   __func__, opt);
 			self->max_sdu_size_rx = opt;
 		} else {
 			IRDA_WARNING("%s: not allowed to set MAXSDUSIZE for this socket type!\n",
-				     __FUNCTION__);
+				     __func__);
 			return -ENOPROTOOPT;
 		}
 		break;
@@ -2149,7 +2149,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 	int err;
 	int offset, total;
 
-	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	if (level != SOL_IRLMP)
 		return -ENOPROTOOPT;
@@ -2310,7 +2310,7 @@ bed:
 		/* Check that we can proceed with IAP */
 		if (self->iriap) {
 			IRDA_WARNING("%s: busy with a previous query\n",
-				     __FUNCTION__);
+				     __func__);
 			kfree(ias_opt);
 			return -EBUSY;
 		}
@@ -2406,7 +2406,7 @@ bed:
 		if (!self->cachedaddr) {
 			int ret = 0;
 
-			IRDA_DEBUG(1, "%s(), nothing discovered yet, going to sleep...\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), nothing discovered yet, going to sleep...\n", __func__);
 
 			/* Set watchdog timer to expire in <val> ms. */
 			self->errno = 0;
@@ -2424,14 +2424,14 @@ bed:
 			if(timer_pending(&(self->watchdog)))
 				del_timer(&(self->watchdog));
 
-			IRDA_DEBUG(1, "%s(), ...waking up !\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ...waking up !\n", __func__);
 
 			if (ret != 0)
 				return ret;
 		}
 		else
 			IRDA_DEBUG(1, "%s(), found immediately !\n",
-				   __FUNCTION__);
+				   __func__);
 
 		/* Tell IrLMP that we have been notified */
 		irlmp_update_client(self->ckey, self->mask.word,
diff --git a/net/irda/discovery.c b/net/irda/discovery.c
index 80c33f4..bfacef8 100644
--- a/net/irda/discovery.c
+++ b/net/irda/discovery.c
@@ -110,7 +110,7 @@ void irlmp_add_discovery_log(hashbin_t *cachelog, hashbin_t *log)
 {
 	discovery_t *discovery;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/*
 	 *  If log is missing this means that IrLAP was unable to perform the
@@ -157,7 +157,7 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 	int			i = 0;		/* How many we expired */
 
 	IRDA_ASSERT(log != NULL, return;);
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	spin_lock_irqsave(&log->hb_spinlock, flags);
 
diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index b825399..256a323 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -70,7 +70,7 @@ static int __init ircomm_init(void)
 {
 	ircomm = hashbin_new(HB_LOCK);
 	if (ircomm == NULL) {
-		IRDA_ERROR("%s(), can't allocate hashbin!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), can't allocate hashbin!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -89,7 +89,7 @@ static int __init ircomm_init(void)
 
 static void __exit ircomm_cleanup(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	hashbin_delete(ircomm, (FREE_FUNC) __ircomm_close);
 
@@ -109,7 +109,7 @@ struct ircomm_cb *ircomm_open(notify_t *notify, __u8 service_type, int line)
 	struct ircomm_cb *self = NULL;
 	int ret;
 
-	IRDA_DEBUG(2, "%s(), service_type=0x%02x\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s(), service_type=0x%02x\n", __func__ ,
 		   service_type);
 
 	IRDA_ASSERT(ircomm != NULL, return NULL;);
@@ -153,7 +153,7 @@ EXPORT_SYMBOL(ircomm_open);
  */
 static int __ircomm_close(struct ircomm_cb *self)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Disconnect link if any */
 	ircomm_do_event(self, IRCOMM_DISCONNECT_REQUEST, NULL, NULL);
@@ -189,7 +189,7 @@ int ircomm_close(struct ircomm_cb *self)
 	IRDA_ASSERT(self != NULL, return -EIO;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EIO;);
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	entry = hashbin_remove(ircomm, self->line, NULL);
 
@@ -214,7 +214,7 @@ int ircomm_connect_request(struct ircomm_cb *self, __u8 dlsap_sel,
 	struct ircomm_info info;
 	int ret;
 
-	IRDA_DEBUG(2 , "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2 , "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
@@ -243,7 +243,7 @@ void ircomm_connect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 {
 	int clen = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Check if the packet contains data on the control channel */
 	if (skb->len > 0)
@@ -259,7 +259,7 @@ void ircomm_connect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 						info->qos, info->max_data_size,
 						info->max_header_size, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
 	}
 }
 
@@ -276,7 +276,7 @@ int ircomm_connect_response(struct ircomm_cb *self, struct sk_buff *userdata)
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	ret = ircomm_do_event(self, IRCOMM_CONNECT_RESPONSE, userdata, NULL);
 
@@ -294,7 +294,7 @@ EXPORT_SYMBOL(ircomm_connect_response);
 void ircomm_connect_confirm(struct ircomm_cb *self, struct sk_buff *skb,
 			    struct ircomm_info *info)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	if (self->notify.connect_confirm )
 		self->notify.connect_confirm(self->notify.instance,
@@ -302,7 +302,7 @@ void ircomm_connect_confirm(struct ircomm_cb *self, struct sk_buff *skb,
 					     info->max_data_size,
 					     info->max_header_size, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
 	}
 }
 
@@ -316,7 +316,7 @@ int ircomm_data_request(struct ircomm_cb *self, struct sk_buff *skb)
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -EFAULT;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EFAULT;);
@@ -337,14 +337,14 @@ EXPORT_SYMBOL(ircomm_data_request);
  */
 void ircomm_data_indication(struct ircomm_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(skb->len > 0, return;);
 
 	if (self->notify.data_indication)
 		self->notify.data_indication(self->notify.instance, self, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
 	}
 }
 
@@ -370,7 +370,7 @@ void ircomm_process_data(struct ircomm_cb *self, struct sk_buff *skb)
 	 */
 	if (unlikely(skb->len < (clen + 1))) {
 		IRDA_DEBUG(2, "%s() throwing away illegal frame\n",
-			   __FUNCTION__ );
+			   __func__ );
 		return;
 	}
 
@@ -389,7 +389,7 @@ void ircomm_process_data(struct ircomm_cb *self, struct sk_buff *skb)
 		ircomm_data_indication(self, skb);
 	else {
 		IRDA_DEBUG(4, "%s(), data was control info only!\n",
-			   __FUNCTION__ );
+			   __func__ );
 	}
 }
 
@@ -403,7 +403,7 @@ int ircomm_control_request(struct ircomm_cb *self, struct sk_buff *skb)
 {
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -EFAULT;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -EFAULT;);
@@ -425,7 +425,7 @@ EXPORT_SYMBOL(ircomm_control_request);
 static void ircomm_control_indication(struct ircomm_cb *self,
 				      struct sk_buff *skb, int clen)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Use udata for delivering data on the control channel */
 	if (self->notify.udata_indication) {
@@ -446,7 +446,7 @@ static void ircomm_control_indication(struct ircomm_cb *self,
 		 * see ircomm_tty_control_indication(). */
 		dev_kfree_skb(ctrl_skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
 	}
 }
 
@@ -461,7 +461,7 @@ int ircomm_disconnect_request(struct ircomm_cb *self, struct sk_buff *userdata)
 	struct ircomm_info info;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
@@ -482,7 +482,7 @@ EXPORT_SYMBOL(ircomm_disconnect_request);
 void ircomm_disconnect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 				  struct ircomm_info *info)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(info != NULL, return;);
 
@@ -490,7 +490,7 @@ void ircomm_disconnect_indication(struct ircomm_cb *self, struct sk_buff *skb,
 		self->notify.disconnect_indication(self->notify.instance, self,
 						   info->reason, skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), missing handler\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), missing handler\n", __func__ );
 	}
 }
 
@@ -502,7 +502,7 @@ void ircomm_disconnect_indication(struct ircomm_cb *self, struct sk_buff *skb,
  */
 void ircomm_flow_request(struct ircomm_cb *self, LOCAL_FLOW flow)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index 8ba4e59..c35b3ef 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
@@ -108,7 +108,7 @@ static int ircomm_state_idle(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_connect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(4, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(4, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_event[event]);
 		ret = -EINVAL;
 	}
@@ -138,7 +138,7 @@ static int ircomm_state_waiti(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_disconnect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(0, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_event[event]);
 		ret = -EINVAL;
 	}
@@ -171,7 +171,7 @@ static int ircomm_state_waitr(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ircomm_disconnect_indication(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __func__ ,
 			   ircomm_event[event]);
 		ret = -EINVAL;
 	}
@@ -213,7 +213,7 @@ static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 		ret = self->issue.disconnect_request(self, skb, info);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(0, "%s(), unknown event = %s\n", __func__ ,
 			   ircomm_event[event]);
 		ret = -EINVAL;
 	}
@@ -229,7 +229,7 @@ static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 int ircomm_do_event(struct ircomm_cb *self, IRCOMM_EVENT event,
 		    struct sk_buff *skb, struct ircomm_info *info)
 {
-	IRDA_DEBUG(4, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(4, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_state[self->state], ircomm_event[event]);
 
 	return (*state[self->state])(self, event, skb, info);
@@ -245,6 +245,6 @@ void ircomm_next_state(struct ircomm_cb *self, IRCOMM_STATE state)
 {
 	self->state = state;
 
-	IRDA_DEBUG(4, "%s: next state=%s, service type=%d\n", __FUNCTION__ ,
+	IRDA_DEBUG(4, "%s: next state=%s, service type=%d\n", __func__ ,
 		   ircomm_state[self->state], self->service_type);
 }
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 55860ee..67c99d2 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -53,7 +53,7 @@ static int ircomm_lmp_connect_request(struct ircomm_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
@@ -76,7 +76,7 @@ static int ircomm_lmp_connect_response(struct ircomm_cb *self,
 	struct sk_buff *tx_skb;
 	int ret;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
@@ -111,7 +111,7 @@ static int ircomm_lmp_disconnect_request(struct ircomm_cb *self,
 	struct sk_buff *tx_skb;
 	int ret;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	if (!userdata) {
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
@@ -148,13 +148,13 @@ static void ircomm_lmp_flow_control(struct sk_buff *skb)
 
 	cb = (struct irda_skb_cb *) skb->cb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	line = cb->line;
 
 	self = (struct ircomm_cb *) hashbin_lock_find(ircomm, line, NULL);
 	if (!self) {
-		IRDA_DEBUG(2, "%s(), didn't find myself\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), didn't find myself\n", __func__ );
 		return;
 	}
 
@@ -164,7 +164,7 @@ static void ircomm_lmp_flow_control(struct sk_buff *skb)
 	self->pkt_count--;
 
 	if ((self->pkt_count < 2) && (self->flow_status == FLOW_STOP)) {
-		IRDA_DEBUG(2, "%s(), asking TTY to start again!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), asking TTY to start again!\n", __func__ );
 		self->flow_status = FLOW_START;
 		if (self->notify.flow_indication)
 			self->notify.flow_indication(self->notify.instance,
@@ -191,7 +191,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 
 	cb->line = self->line;
 
-	IRDA_DEBUG(4, "%s(), sending frame\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s(), sending frame\n", __func__ );
 
 	/* Don't forget to refcount it - see ircomm_tty_do_softint() */
 	skb_get(skb);
@@ -199,7 +199,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 	skb->destructor = ircomm_lmp_flow_control;
 
 	if ((self->pkt_count++ > 7) && (self->flow_status == FLOW_START)) {
-		IRDA_DEBUG(2, "%s(), asking TTY to slow down!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), asking TTY to slow down!\n", __func__ );
 		self->flow_status = FLOW_STOP;
 		if (self->notify.flow_indication)
 			self->notify.flow_indication(self->notify.instance,
@@ -207,7 +207,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 	}
 	ret = irlmp_data_request(self->lsap, skb);
 	if (ret) {
-		IRDA_ERROR("%s(), failed\n", __FUNCTION__);
+		IRDA_ERROR("%s(), failed\n", __func__);
 		/* irlmp_data_request already free the packet */
 	}
 
@@ -225,7 +225,7 @@ static int ircomm_lmp_data_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
@@ -255,7 +255,7 @@ static void ircomm_lmp_connect_confirm(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -288,7 +288,7 @@ static void ircomm_lmp_connect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *)instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -318,7 +318,7 @@ static void ircomm_lmp_disconnect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -341,7 +341,7 @@ int ircomm_open_lsap(struct ircomm_cb *self)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	/* Register callbacks */
 	irda_notify_init(&notify);
@@ -354,7 +354,7 @@ int ircomm_open_lsap(struct ircomm_cb *self)
 
 	self->lsap = irlmp_open_lsap(LSAP_ANY, &notify, 0);
 	if (!self->lsap) {
-		IRDA_DEBUG(0,"%sfailed to allocate tsap\n", __FUNCTION__ );
+		IRDA_DEBUG(0,"%sfailed to allocate tsap\n", __func__ );
 		return -1;
 	}
 	self->slsap_sel = self->lsap->slsap_sel;
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 598dcbe..d57aefd 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -103,7 +103,7 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 	struct sk_buff *skb;
 	int count;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
@@ -136,7 +136,7 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 	count = irda_param_insert(self, pi, skb_tail_pointer(skb),
 				  skb_tailroom(skb), &ircomm_param_info);
 	if (count < 0) {
-		IRDA_WARNING("%s(), no room for parameter!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), no room for parameter!\n", __func__);
 		spin_unlock_irqrestore(&self->spinlock, flags);
 		return -1;
 	}
@@ -144,7 +144,7 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
-	IRDA_DEBUG(2, "%s(), skb->len=%d\n", __FUNCTION__ , skb->len);
+	IRDA_DEBUG(2, "%s(), skb->len=%d\n", __func__ , skb->len);
 
 	if (flush) {
 		/* ircomm_tty_do_softint will take care of the rest */
@@ -179,10 +179,10 @@ static int ircomm_param_service_type(void *instance, irda_param_t *param,
 	service_type &= self->service_type;
 	if (!service_type) {
 		IRDA_DEBUG(2,
-			   "%s(), No common service type to use!\n", __FUNCTION__ );
+			   "%s(), No common service type to use!\n", __func__ );
 		return -1;
 	}
-	IRDA_DEBUG(0, "%s(), services in common=%02x\n", __FUNCTION__ ,
+	IRDA_DEBUG(0, "%s(), services in common=%02x\n", __func__ ,
 		   service_type);
 
 	/*
@@ -197,7 +197,7 @@ static int ircomm_param_service_type(void *instance, irda_param_t *param,
 	else if (service_type & IRCOMM_3_WIRE_RAW)
 		self->settings.service_type = IRCOMM_3_WIRE_RAW;
 
-	IRDA_DEBUG(0, "%s(), resulting service type=0x%02x\n", __FUNCTION__ ,
+	IRDA_DEBUG(0, "%s(), resulting service type=0x%02x\n", __func__ ,
 		   self->settings.service_type);
 
 	/*
@@ -240,7 +240,7 @@ static int ircomm_param_port_type(void *instance, irda_param_t *param, int get)
 	else {
 		self->settings.port_type = (__u8) param->pv.i;
 
-		IRDA_DEBUG(0, "%s(), port type=%d\n", __FUNCTION__ ,
+		IRDA_DEBUG(0, "%s(), port type=%d\n", __func__ ,
 			   self->settings.port_type);
 	}
 	return 0;
@@ -260,9 +260,9 @@ static int ircomm_param_port_name(void *instance, irda_param_t *param, int get)
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	if (get) {
-		IRDA_DEBUG(0, "%s(), not imp!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), not imp!\n", __func__ );
 	} else {
-		IRDA_DEBUG(0, "%s(), port-name=%s\n", __FUNCTION__ , param->pv.c);
+		IRDA_DEBUG(0, "%s(), port-name=%s\n", __func__ , param->pv.c);
 		strncpy(self->settings.port_name, param->pv.c, 32);
 	}
 
@@ -287,7 +287,7 @@ static int ircomm_param_data_rate(void *instance, irda_param_t *param, int get)
 	else
 		self->settings.data_rate = param->pv.i;
 
-	IRDA_DEBUG(2, "%s(), data rate = %d\n", __FUNCTION__ , param->pv.i);
+	IRDA_DEBUG(2, "%s(), data rate = %d\n", __func__ , param->pv.i);
 
 	return 0;
 }
@@ -333,7 +333,7 @@ static int ircomm_param_flow_control(void *instance, irda_param_t *param,
 	else
 		self->settings.flow_control = (__u8) param->pv.i;
 
-	IRDA_DEBUG(1, "%s(), flow control = 0x%02x\n", __FUNCTION__ , (__u8) param->pv.i);
+	IRDA_DEBUG(1, "%s(), flow control = 0x%02x\n", __func__ , (__u8) param->pv.i);
 
 	return 0;
 }
@@ -359,7 +359,7 @@ static int ircomm_param_xon_xoff(void *instance, irda_param_t *param, int get)
 		self->settings.xonxoff[1] = (__u16) param->pv.i >> 8;
 	}
 
-	IRDA_DEBUG(0, "%s(), XON/XOFF = 0x%02x,0x%02x\n", __FUNCTION__ ,
+	IRDA_DEBUG(0, "%s(), XON/XOFF = 0x%02x,0x%02x\n", __func__ ,
 		   param->pv.i & 0xff, param->pv.i >> 8);
 
 	return 0;
@@ -386,7 +386,7 @@ static int ircomm_param_enq_ack(void *instance, irda_param_t *param, int get)
 		self->settings.enqack[1] = (__u16) param->pv.i >> 8;
 	}
 
-	IRDA_DEBUG(0, "%s(), ENQ/ACK = 0x%02x,0x%02x\n", __FUNCTION__ ,
+	IRDA_DEBUG(0, "%s(), ENQ/ACK = 0x%02x,0x%02x\n", __func__ ,
 		   param->pv.i & 0xff, param->pv.i >> 8);
 
 	return 0;
@@ -401,7 +401,7 @@ static int ircomm_param_enq_ack(void *instance, irda_param_t *param, int get)
 static int ircomm_param_line_status(void *instance, irda_param_t *param,
 				    int get)
 {
-	IRDA_DEBUG(2, "%s(), not impl.\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), not impl.\n", __func__ );
 
 	return 0;
 }
@@ -462,7 +462,7 @@ static int ircomm_param_dce(void *instance, irda_param_t *param, int get)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	__u8 dce;
 
-	IRDA_DEBUG(1, "%s(), dce = 0x%02x\n", __FUNCTION__ , (__u8) param->pv.i);
+	IRDA_DEBUG(1, "%s(), dce = 0x%02x\n", __func__ , (__u8) param->pv.i);
 
 	dce = (__u8) param->pv.i;
 
@@ -474,7 +474,7 @@ static int ircomm_param_dce(void *instance, irda_param_t *param, int get)
 	/* Check if any of the settings have changed */
 	if (dce & 0x0f) {
 		if (dce & IRCOMM_DELTA_CTS) {
-			IRDA_DEBUG(2, "%s(), CTS \n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), CTS \n", __func__ );
 		}
 	}
 
diff --git a/net/irda/ircomm/ircomm_ttp.c b/net/irda/ircomm/ircomm_ttp.c
index 712eafd..6e6509f 100644
--- a/net/irda/ircomm/ircomm_ttp.c
+++ b/net/irda/ircomm/ircomm_ttp.c
@@ -78,7 +78,7 @@ int ircomm_open_tsap(struct ircomm_cb *self)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* Register callbacks */
 	irda_notify_init(&notify);
@@ -93,7 +93,7 @@ int ircomm_open_tsap(struct ircomm_cb *self)
 	self->tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT,
 				     &notify);
 	if (!self->tsap) {
-		IRDA_DEBUG(0, "%sfailed to allocate tsap\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%sfailed to allocate tsap\n", __func__ );
 		return -1;
 	}
 	self->slsap_sel = self->tsap->stsap_sel;
@@ -121,7 +121,7 @@ static int ircomm_ttp_connect_request(struct ircomm_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
@@ -145,7 +145,7 @@ static int ircomm_ttp_connect_response(struct ircomm_cb *self,
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* Don't forget to refcount it - should be NULL anyway */
 	if(userdata)
@@ -173,7 +173,7 @@ static int ircomm_ttp_data_request(struct ircomm_cb *self,
 
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), clen=%d\n", __FUNCTION__ , clen);
+	IRDA_DEBUG(2, "%s(), clen=%d\n", __func__ , clen);
 
 	/*
 	 * Insert clen field, currently we either send data only, or control
@@ -190,7 +190,7 @@ static int ircomm_ttp_data_request(struct ircomm_cb *self,
 
 	ret = irttp_data_request(self->tsap, skb);
 	if (ret) {
-		IRDA_ERROR("%s(), failed\n", __FUNCTION__);
+		IRDA_ERROR("%s(), failed\n", __func__);
 		/* irttp_data_request already free the packet */
 	}
 
@@ -208,7 +208,7 @@ static int ircomm_ttp_data_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return -1;);
@@ -231,7 +231,7 @@ static void ircomm_ttp_connect_confirm(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -240,7 +240,7 @@ static void ircomm_ttp_connect_confirm(void *instance, void *sap,
 
 	if (max_sdu_size != TTP_SAR_DISABLE) {
 		IRDA_ERROR("%s(), SAR not allowed for IrCOMM!\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out;
 	}
 
@@ -272,7 +272,7 @@ static void ircomm_ttp_connect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *)instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -281,7 +281,7 @@ static void ircomm_ttp_connect_indication(void *instance, void *sap,
 
 	if (max_sdu_size != TTP_SAR_DISABLE) {
 		IRDA_ERROR("%s(), SAR not allowed for IrCOMM!\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out;
 	}
 
@@ -331,7 +331,7 @@ static void ircomm_ttp_disconnect_indication(void *instance, void *sap,
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 	struct ircomm_info info;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
@@ -356,7 +356,7 @@ static void ircomm_ttp_flow_indication(void *instance, void *sap,
 {
 	struct ircomm_cb *self = (struct ircomm_cb *) instance;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_MAGIC, return;);
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index be627e1..d262041 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -115,7 +115,7 @@ static int __init ircomm_tty_init(void)
 		return -ENOMEM;
 	ircomm_tty = hashbin_new(HB_LOCK);
 	if (ircomm_tty == NULL) {
-		IRDA_ERROR("%s(), can't allocate hashbin!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), can't allocate hashbin!\n", __func__);
 		put_tty_driver(driver);
 		return -ENOMEM;
 	}
@@ -133,7 +133,7 @@ static int __init ircomm_tty_init(void)
 	tty_set_operations(driver, &ops);
 	if (tty_register_driver(driver)) {
 		IRDA_ERROR("%s(): Couldn't register serial driver\n",
-			   __FUNCTION__);
+			   __func__);
 		put_tty_driver(driver);
 		return -1;
 	}
@@ -142,7 +142,7 @@ static int __init ircomm_tty_init(void)
 
 static void __exit __ircomm_tty_cleanup(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -163,12 +163,12 @@ static void __exit ircomm_tty_cleanup(void)
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	ret = tty_unregister_driver(driver);
 	if (ret) {
 		IRDA_ERROR("%s(), failed to unregister driver\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
@@ -187,14 +187,14 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 	notify_t notify;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	/* Check if already open */
 	if (test_and_set_bit(ASYNC_B_INITIALIZED, &self->flags)) {
-		IRDA_DEBUG(2, "%s(), already open so break out!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), already open so break out!\n", __func__ );
 		return 0;
 	}
 
@@ -224,7 +224,7 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 	/* Connect IrCOMM link with remote device */
 	ret = ircomm_tty_attach_cable(self);
 	if (ret < 0) {
-		IRDA_ERROR("%s(), error attaching cable!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), error attaching cable!\n", __func__);
 		goto err;
 	}
 
@@ -249,7 +249,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	unsigned long	flags;
 	struct tty_struct *tty;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	tty = self->tty;
 
@@ -260,12 +260,12 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	if (filp->f_flags & O_NONBLOCK || tty->flags & (1 << TTY_IO_ERROR)){
 		/* nonblock mode is set or port is not enabled */
 		self->flags |= ASYNC_NORMAL_ACTIVE;
-		IRDA_DEBUG(1, "%s(), O_NONBLOCK requested!\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), O_NONBLOCK requested!\n", __func__ );
 		return 0;
 	}
 
 	if (tty->termios->c_cflag & CLOCAL) {
-		IRDA_DEBUG(1, "%s(), doing CLOCAL!\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), doing CLOCAL!\n", __func__ );
 		do_clocal = 1;
 	}
 
@@ -368,7 +368,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	unsigned long	flags;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	line = tty->index;
 	if ((line < 0) || (line >= IRCOMM_TTY_PORTS)) {
@@ -381,7 +381,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		/* No, so make new instance */
 		self = kzalloc(sizeof(struct ircomm_tty_cb), GFP_KERNEL);
 		if (self == NULL) {
-			IRDA_ERROR("%s(), kmalloc failed!\n", __FUNCTION__);
+			IRDA_ERROR("%s(), kmalloc failed!\n", __func__);
 			return -ENOMEM;
 		}
 
@@ -420,7 +420,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	self->tty = tty;
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
-	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __FUNCTION__ , tty->driver->name,
+	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
 		   self->line, self->open_count);
 
 	/* Not really used by us, but lets do it anyway */
@@ -442,7 +442,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 		if (wait_event_interruptible(self->close_wait, !test_bit(ASYNC_B_CLOSING, &self->flags))) {
 			IRDA_WARNING("%s - got signal while blocking on ASYNC_CLOSING!\n",
-				     __FUNCTION__);
+				     __func__);
 			return -ERESTARTSYS;
 		}
 
@@ -460,9 +460,9 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		self->settings.service_type = IRCOMM_9_WIRE; /* 9 wire as default */
 		/* Jan Kiszka -> add DSR/RI -> Conform to IrCOMM spec */
 		self->settings.dce = IRCOMM_CTS | IRCOMM_CD | IRCOMM_DSR | IRCOMM_RI; /* Default line settings */
-		IRDA_DEBUG(2, "%s(), IrCOMM device\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IrCOMM device\n", __func__ );
 	} else {
-		IRDA_DEBUG(2, "%s(), IrLPT device\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IrLPT device\n", __func__ );
 		self->service_type = IRCOMM_3_WIRE_RAW;
 		self->settings.service_type = IRCOMM_3_WIRE_RAW; /* Default */
 	}
@@ -474,7 +474,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	ret = ircomm_tty_block_til_ready(self, filp);
 	if (ret) {
 		IRDA_DEBUG(2,
-		      "%s(), returning after block_til_ready with %d\n", __FUNCTION__ ,
+		      "%s(), returning after block_til_ready with %d\n", __func__ ,
 		      ret);
 
 		return ret;
@@ -493,7 +493,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned long flags;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	if (!tty)
 		return;
@@ -506,7 +506,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	if (tty_hung_up_p(filp)) {
 		spin_unlock_irqrestore(&self->spinlock, flags);
 
-		IRDA_DEBUG(0, "%s(), returning 1\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), returning 1\n", __func__ );
 		return;
 	}
 
@@ -519,20 +519,20 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		 * serial port won't be shutdown.
 		 */
 		IRDA_DEBUG(0, "%s(), bad serial port count; "
-			   "tty->count is 1, state->count is %d\n", __FUNCTION__ ,
+			   "tty->count is 1, state->count is %d\n", __func__ ,
 			   self->open_count);
 		self->open_count = 1;
 	}
 
 	if (--self->open_count < 0) {
 		IRDA_ERROR("%s(), bad serial port count for ttys%d: %d\n",
-			   __FUNCTION__, self->line, self->open_count);
+			   __func__, self->line, self->open_count);
 		self->open_count = 0;
 	}
 	if (self->open_count) {
 		spin_unlock_irqrestore(&self->spinlock, flags);
 
-		IRDA_DEBUG(0, "%s(), open count > 0\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), open count > 0\n", __func__ );
 		return;
 	}
 
@@ -608,7 +608,7 @@ static void ircomm_tty_do_softint(struct work_struct *work)
 	unsigned long flags;
 	struct sk_buff *skb, *ctrl_skb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (!self || self->magic != IRCOMM_TTY_MAGIC)
 		return;
@@ -678,7 +678,7 @@ static int ircomm_tty_write(struct tty_struct *tty,
 	int len = 0;
 	int size;
 
-	IRDA_DEBUG(2, "%s(), count=%d, hw_stopped=%d\n", __FUNCTION__ , count,
+	IRDA_DEBUG(2, "%s(), count=%d, hw_stopped=%d\n", __func__ , count,
 		   tty->hw_stopped);
 
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -701,7 +701,7 @@ static int ircomm_tty_write(struct tty_struct *tty,
 	 * we don't mess up the original "safe skb" (see tx_data_size).
 	 * Jean II */
 	if (self->max_header_size == IRCOMM_TTY_HDR_UNINITIALISED) {
-		IRDA_DEBUG(1, "%s() : not initialised\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s() : not initialised\n", __func__);
 #ifdef IRCOMM_NO_TX_BEFORE_INIT
 		/* We didn't consume anything, TTY will retry */
 		return 0;
@@ -830,7 +830,7 @@ static int ircomm_tty_write_room(struct tty_struct *tty)
 			ret = self->max_data_size;
 		spin_unlock_irqrestore(&self->spinlock, flags);
 	}
-	IRDA_DEBUG(2, "%s(), ret=%d\n", __FUNCTION__ , ret);
+	IRDA_DEBUG(2, "%s(), ret=%d\n", __func__ , ret);
 
 	return ret;
 }
@@ -847,7 +847,7 @@ static void ircomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 	unsigned long orig_jiffies, poll_time;
 	unsigned long flags;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -882,7 +882,7 @@ static void ircomm_tty_throttle(struct tty_struct *tty)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -913,7 +913,7 @@ static void ircomm_tty_unthrottle(struct tty_struct *tty)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -928,7 +928,7 @@ static void ircomm_tty_unthrottle(struct tty_struct *tty)
 		self->settings.dte |= (IRCOMM_RTS|IRCOMM_DELTA_RTS);
 
 		ircomm_param_request(self, IRCOMM_DTE, TRUE);
-		IRDA_DEBUG(1, "%s(), FLOW_START\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), FLOW_START\n", __func__ );
 	}
 	ircomm_flow_request(self->ircomm, FLOW_START);
 }
@@ -965,7 +965,7 @@ static void ircomm_tty_shutdown(struct ircomm_tty_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	if (!test_and_clear_bit(ASYNC_B_INITIALIZED, &self->flags))
 		return;
@@ -1008,7 +1008,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned long	flags;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -1037,7 +1037,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
  */
 static void ircomm_tty_send_xchar(struct tty_struct *tty, char ch)
 {
-	IRDA_DEBUG(0, "%s(), not impl\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s(), not impl\n", __func__ );
 }
 
 /*
@@ -1081,7 +1081,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	struct tty_struct *tty;
 	int status;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -1095,14 +1095,14 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	}
 	if ((self->flags & ASYNC_CHECK_CD) && (status & IRCOMM_DELTA_CD)) {
 		IRDA_DEBUG(2,
-			   "%s(), ircomm%d CD now %s...\n", __FUNCTION__ , self->line,
+			   "%s(), ircomm%d CD now %s...\n", __func__ , self->line,
 			   (status & IRCOMM_CD) ? "on" : "off");
 
 		if (status & IRCOMM_CD) {
 			wake_up_interruptible(&self->open_wait);
 		} else {
 			IRDA_DEBUG(2,
-				   "%s(), Doing serial hangup..\n", __FUNCTION__ );
+				   "%s(), Doing serial hangup..\n", __func__ );
 			if (tty)
 				tty_hangup(tty);
 
@@ -1114,7 +1114,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 		if (tty->hw_stopped) {
 			if (status & IRCOMM_CTS) {
 				IRDA_DEBUG(2,
-					   "%s(), CTS tx start...\n", __FUNCTION__ );
+					   "%s(), CTS tx start...\n", __func__ );
 				tty->hw_stopped = 0;
 
 				/* Wake up processes blocked on open */
@@ -1126,7 +1126,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 		} else {
 			if (!(status & IRCOMM_CTS)) {
 				IRDA_DEBUG(2,
-					   "%s(), CTS tx stop...\n", __FUNCTION__ );
+					   "%s(), CTS tx stop...\n", __func__ );
 				tty->hw_stopped = 1;
 			}
 		}
@@ -1144,14 +1144,14 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
 	if (!self->tty) {
-		IRDA_DEBUG(0, "%s(), no tty!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), no tty!\n", __func__ );
 		return 0;
 	}
 
@@ -1162,7 +1162,7 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	 * params, we can just as well declare the hardware for running.
 	 */
 	if (self->tty->hw_stopped && (self->flow == FLOW_START)) {
-		IRDA_DEBUG(0, "%s(), polling for line settings!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), polling for line settings!\n", __func__ );
 		ircomm_param_request(self, IRCOMM_POLL, TRUE);
 
 		/* We can just as well declare the hardware for running */
@@ -1194,7 +1194,7 @@ static int ircomm_tty_control_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	int clen;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
@@ -1230,7 +1230,7 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 
 	switch (cmd) {
 	case FLOW_START:
-		IRDA_DEBUG(2, "%s(), hw start!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), hw start!\n", __func__ );
 		tty->hw_stopped = 0;
 
 		/* ircomm_tty_do_softint will take care of the rest */
@@ -1238,7 +1238,7 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 		break;
 	default:  /* If we get here, something is very wrong, better stop */
 	case FLOW_STOP:
-		IRDA_DEBUG(2, "%s(), hw stopped!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), hw stopped!\n", __func__ );
 		tty->hw_stopped = 1;
 		break;
 	}
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index b5a1388..9032a1d 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -129,14 +129,14 @@ static int (*state[])(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
  */
 int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	/* Check if somebody has already connected to us */
 	if (ircomm_is_connected(self->ircomm)) {
-		IRDA_DEBUG(0, "%s(), already connected!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), already connected!\n", __func__ );
 		return 0;
 	}
 
@@ -158,7 +158,7 @@ int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
  */
 void ircomm_tty_detach_cable(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -207,7 +207,7 @@ static void ircomm_tty_ias_register(struct ircomm_tty_cb *self)
 	__u8 oct_seq[6];
 	__u16 hints;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -308,16 +308,16 @@ int ircomm_tty_send_initial_parameters(struct ircomm_tty_cb *self)
 	 * Set default values, but only if the application for some reason
 	 * haven't set them already
 	 */
-	IRDA_DEBUG(2, "%s(), data-rate = %d\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s(), data-rate = %d\n", __func__ ,
 		   self->settings.data_rate);
 	if (!self->settings.data_rate)
 		self->settings.data_rate = 9600;
-	IRDA_DEBUG(2, "%s(), data-format = %d\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s(), data-format = %d\n", __func__ ,
 		   self->settings.data_format);
 	if (!self->settings.data_format)
 		self->settings.data_format = IRCOMM_WSIZE_8;  /* 8N1 */
 
-	IRDA_DEBUG(2, "%s(), flow-control = %d\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s(), flow-control = %d\n", __func__ ,
 		   self->settings.flow_control);
 	/*self->settings.flow_control = IRCOMM_RTS_CTS_IN|IRCOMM_RTS_CTS_OUT;*/
 
@@ -362,7 +362,7 @@ static void ircomm_tty_discovery_indication(discinfo_t *discovery,
 	struct ircomm_tty_cb *self;
 	struct ircomm_tty_info info;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Important note :
 	 * We need to drop all passive discoveries.
@@ -398,7 +398,7 @@ void ircomm_tty_disconnect_indication(void *instance, void *sap,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -428,7 +428,7 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) priv;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -439,13 +439,13 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(4, "%s(), got NULL value!\n", __FUNCTION__ );
+		IRDA_DEBUG(4, "%s(), got NULL value!\n", __func__ );
 		return;
 	}
 
 	switch (value->type) {
 	case IAS_OCT_SEQ:
-		IRDA_DEBUG(2, "%s(), got octet sequence\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), got octet sequence\n", __func__ );
 
 		irda_param_extract_all(self, value->t.oct_seq, value->len,
 				       &ircomm_param_info);
@@ -455,21 +455,21 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 		break;
 	case IAS_INTEGER:
 		/* Got LSAP selector */
-		IRDA_DEBUG(2, "%s(), got lsapsel = %d\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), got lsapsel = %d\n", __func__ ,
 			   value->t.integer);
 
 		if (value->t.integer == -1) {
-			IRDA_DEBUG(0, "%s(), invalid value!\n", __FUNCTION__ );
+			IRDA_DEBUG(0, "%s(), invalid value!\n", __func__ );
 		} else
 			self->dlsap_sel = value->t.integer;
 
 		ircomm_tty_do_event(self, IRCOMM_TTY_GOT_LSAPSEL, NULL, NULL);
 		break;
 	case IAS_MISSING:
-		IRDA_DEBUG(0, "%s(), got IAS_MISSING\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), got IAS_MISSING\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), got unknown type!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), got unknown type!\n", __func__ );
 		break;
 	}
 	irias_delete_value(value);
@@ -489,7 +489,7 @@ void ircomm_tty_connect_confirm(void *instance, void *sap,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -520,7 +520,7 @@ void ircomm_tty_connect_indication(void *instance, void *sap,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
 	int clen;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -549,7 +549,7 @@ void ircomm_tty_connect_indication(void *instance, void *sap,
  */
 void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -566,10 +566,10 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 	 * line.
 	 */
 	if ((self->flags & ASYNC_CTS_FLOW) && ((self->settings.dce & IRCOMM_CTS) == 0)) {
-		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __func__ );
 		return;
 	} else {
-		IRDA_DEBUG(1, "%s(), starting hardware!\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), starting hardware!\n", __func__ );
 
 		self->tty->hw_stopped = 0;
 
@@ -607,7 +607,7 @@ static void ircomm_tty_watchdog_timer_expired(void *data)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
@@ -628,7 +628,7 @@ int ircomm_tty_do_event(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	return (*state[self->state])(self, event, skb, info);
@@ -646,7 +646,7 @@ static inline void ircomm_tty_next_state(struct ircomm_tty_cb *self, IRCOMM_TTY_
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	IRDA_DEBUG(2, "%s: next state=%s, service type=%d\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: next state=%s, service type=%d\n", __func__ ,
 		   ircomm_tty_state[self->state], self->service_type);
 	*/
 	self->state = state;
@@ -665,7 +665,7 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 	switch (event) {
 	case IRCOMM_TTY_ATTACH_CABLE:
@@ -681,7 +681,7 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 
 		if (self->iriap) {
 			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 
@@ -709,7 +709,7 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
@@ -729,7 +729,7 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
@@ -739,7 +739,7 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 
 		if (self->iriap) {
 			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 
@@ -782,7 +782,7 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
@@ -802,14 +802,14 @@ static int ircomm_tty_state_query_parameters(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
 	case IRCOMM_TTY_GOT_PARAMETERS:
 		if (self->iriap) {
 			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 
@@ -840,7 +840,7 @@ static int ircomm_tty_state_query_parameters(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
@@ -860,7 +860,7 @@ static int ircomm_tty_state_query_lsap_sel(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
@@ -889,7 +889,7 @@ static int ircomm_tty_state_query_lsap_sel(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
@@ -909,7 +909,7 @@ static int ircomm_tty_state_setup(struct ircomm_tty_cb *self,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __FUNCTION__ ,
+	IRDA_DEBUG(2, "%s: state=%s, event=%s\n", __func__ ,
 		   ircomm_tty_state[self->state], ircomm_tty_event[event]);
 
 	switch (event) {
@@ -943,7 +943,7 @@ static int ircomm_tty_state_setup(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
@@ -981,13 +981,13 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 			self->settings.dce = IRCOMM_DELTA_CD;
 			ircomm_tty_check_modem_status(self);
 		} else {
-			IRDA_DEBUG(0, "%s(), hanging up!\n", __FUNCTION__ );
+			IRDA_DEBUG(0, "%s(), hanging up!\n", __func__ );
 			if (self->tty)
 				tty_hangup(self->tty);
 		}
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), unknown event: %s\n", __func__ ,
 			   ircomm_tty_event[event]);
 		ret = -EINVAL;
 	}
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index 6030947..24cb3aa 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -57,7 +57,7 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
 	unsigned cflag, cval;
 	int baud;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (!self->tty || !self->tty->termios || !self->ircomm)
 		return;
@@ -94,7 +94,7 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
 		self->settings.flow_control |= IRCOMM_RTS_CTS_IN;
 		/* This got me. Bummer. Jean II */
 		if (self->service_type == IRCOMM_3_WIRE_RAW)
-			IRDA_WARNING("%s(), enabling RTS/CTS on link that doesn't support it (3-wire-raw)\n", __FUNCTION__);
+			IRDA_WARNING("%s(), enabling RTS/CTS on link that doesn't support it (3-wire-raw)\n", __func__);
 	} else {
 		self->flags &= ~ASYNC_CTS_FLOW;
 		self->settings.flow_control &= ~IRCOMM_RTS_CTS_IN;
@@ -150,7 +150,7 @@ void ircomm_tty_set_termios(struct tty_struct *tty,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned int cflag = tty->termios->c_cflag;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if ((cflag == old_termios->c_cflag) &&
 	    (RELEVANT_IFLAG(tty->termios->c_iflag) ==
@@ -199,7 +199,7 @@ int ircomm_tty_tiocmget(struct tty_struct *tty, struct file *file)
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	unsigned int result;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (tty->flags & (1 << TTY_IO_ERROR))
 		return -EIO;
@@ -224,7 +224,7 @@ int ircomm_tty_tiocmset(struct tty_struct *tty, struct file *file,
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (tty->flags & (1 << TTY_IO_ERROR))
 		return -EIO;
@@ -266,7 +266,7 @@ static int ircomm_tty_get_serial_info(struct ircomm_tty_cb *self,
 	if (!retinfo)
 		return -EFAULT;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	memset(&info, 0, sizeof(info));
 	info.line = self->line;
@@ -302,7 +302,7 @@ static int ircomm_tty_set_serial_info(struct ircomm_tty_cb *self,
 	struct serial_struct new_serial;
 	struct ircomm_tty_cb old_state, *state;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	if (copy_from_user(&new_serial,new_info,sizeof(new_serial)))
 		return -EFAULT;
@@ -376,7 +376,7 @@ int ircomm_tty_ioctl(struct tty_struct *tty, struct file *file,
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if ((cmd != TIOCGSERIAL) && (cmd != TIOCSSERIAL) &&
 	    (cmd != TIOCSERCONFIG) && (cmd != TIOCSERGSTRUCT) &&
@@ -397,7 +397,7 @@ int ircomm_tty_ioctl(struct tty_struct *tty, struct file *file,
 		break;
 
 	case TIOCGICOUNT:
-		IRDA_DEBUG(0, "%s(), TIOCGICOUNT not impl!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), TIOCGICOUNT not impl!\n", __func__ );
 #if 0
 		save_flags(flags); cli();
 		cnow = driver->icount;
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 8718591..ea319e3 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -90,7 +90,7 @@ static void leftover_dongle(void *arg)
 
 void irda_device_cleanup(void)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	hashbin_delete(tasks, (FREE_FUNC) __irda_task_delete);
 
@@ -107,7 +107,7 @@ void irda_device_set_media_busy(struct net_device *dev, int status)
 {
 	struct irlap_cb *self;
 
-	IRDA_DEBUG(4, "%s(%s)\n", __FUNCTION__, status ? "TRUE" : "FALSE");
+	IRDA_DEBUG(4, "%s(%s)\n", __func__, status ? "TRUE" : "FALSE");
 
 	self = (struct irlap_cb *) dev->atalk_ptr;
 
@@ -147,11 +147,11 @@ int irda_device_is_receiving(struct net_device *dev)
 	struct if_irda_req req;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (!dev->do_ioctl) {
 		IRDA_ERROR("%s: do_ioctl not impl. by device driver\n",
-			   __FUNCTION__);
+			   __func__);
 		return -1;
 	}
 
@@ -191,7 +191,7 @@ static int irda_task_kick(struct irda_task *task)
 	int count = 0;
 	int timeout;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(task != NULL, return -1;);
 	IRDA_ASSERT(task->magic == IRDA_TASK_MAGIC, return -1;);
@@ -201,14 +201,14 @@ static int irda_task_kick(struct irda_task *task)
 		timeout = task->function(task);
 		if (count++ > 100) {
 			IRDA_ERROR("%s: error in task handler!\n",
-				   __FUNCTION__);
+				   __func__);
 			irda_task_delete(task);
 			return TRUE;
 		}
 	} while ((timeout == 0) && (task->state != IRDA_TASK_DONE));
 
 	if (timeout < 0) {
-		IRDA_ERROR("%s: Error executing task!\n", __FUNCTION__);
+		IRDA_ERROR("%s: Error executing task!\n", __func__);
 		irda_task_delete(task);
 		return TRUE;
 	}
@@ -241,7 +241,7 @@ static int irda_task_kick(struct irda_task *task)
 		finished = FALSE;
 	} else {
 		IRDA_DEBUG(0, "%s(), not finished, and no timeout!\n",
-			   __FUNCTION__);
+			   __func__);
 		finished = FALSE;
 	}
 
@@ -258,7 +258,7 @@ static void irda_task_timer_expired(void *data)
 {
 	struct irda_task *task;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	task = (struct irda_task *) data;
 
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 390a790..9e15c82 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -108,7 +108,7 @@ int __init iriap_init(void)
 	irias_objects = hashbin_new(HB_LOCK);
 	if (!irias_objects) {
 		IRDA_WARNING("%s: Can't allocate irias_objects hashbin!\n",
-			     __FUNCTION__);
+			     __func__);
 		hashbin_delete(iriap, NULL);
 		return -ENOMEM;
 	}
@@ -139,7 +139,7 @@ int __init iriap_init(void)
 	 */
 	server = iriap_open(LSAP_IAS, IAS_SERVER, NULL, NULL);
 	if (!server) {
-		IRDA_DEBUG(0, "%s(), unable to open server\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unable to open server\n", __func__);
 		return -1;
 	}
 	iriap_register_lsap(server, LSAP_IAS, IAS_SERVER);
@@ -171,11 +171,11 @@ struct iriap_cb *iriap_open(__u8 slsap_sel, int mode, void *priv,
 {
 	struct iriap_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	self = kzalloc(sizeof(*self), GFP_ATOMIC);
 	if (!self) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -217,7 +217,7 @@ EXPORT_SYMBOL(iriap_open);
  */
 static void __iriap_close(struct iriap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -241,7 +241,7 @@ void iriap_close(struct iriap_cb *self)
 {
 	struct iriap_cb *entry;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -262,7 +262,7 @@ static int iriap_register_lsap(struct iriap_cb *self, __u8 slsap_sel, int mode)
 {
 	notify_t notify;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	irda_notify_init(&notify);
 	notify.connect_confirm       = iriap_connect_confirm;
@@ -277,7 +277,7 @@ static int iriap_register_lsap(struct iriap_cb *self, __u8 slsap_sel, int mode)
 
 	self->lsap = irlmp_open_lsap(slsap_sel, &notify, 0);
 	if (self->lsap == NULL) {
-		IRDA_ERROR("%s: Unable to allocated LSAP!\n", __FUNCTION__);
+		IRDA_ERROR("%s: Unable to allocated LSAP!\n", __func__);
 		return -1;
 	}
 	self->slsap_sel = self->lsap->slsap_sel;
@@ -297,7 +297,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 {
 	struct iriap_cb *self;
 
-	IRDA_DEBUG(4, "%s(), reason=%s\n", __FUNCTION__, irlmp_reasons[reason]);
+	IRDA_DEBUG(4, "%s(), reason=%s\n", __func__, irlmp_reasons[reason]);
 
 	self = (struct iriap_cb *) instance;
 
@@ -313,7 +313,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 		dev_kfree_skb(skb);
 
 	if (self->mode == IAS_CLIENT) {
-		IRDA_DEBUG(4, "%s(), disconnect as client\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), disconnect as client\n", __func__);
 
 
 		iriap_do_client_event(self, IAP_LM_DISCONNECT_INDICATION,
@@ -326,7 +326,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 		if (self->confirm)
 			self->confirm(IAS_DISCONNECT, 0, NULL, self->priv);
 	} else {
-		IRDA_DEBUG(4, "%s(), disconnect as server\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), disconnect as server\n", __func__);
 		iriap_do_server_event(self, IAP_LM_DISCONNECT_INDICATION,
 				      NULL);
 		iriap_close(self);
@@ -340,7 +340,7 @@ static void iriap_disconnect_request(struct iriap_cb *self)
 {
 	struct sk_buff *tx_skb;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -349,7 +349,7 @@ static void iriap_disconnect_request(struct iriap_cb *self)
 	if (tx_skb == NULL) {
 		IRDA_DEBUG(0,
 			   "%s(), Could not allocate an sk_buff of length %d\n",
-			   __FUNCTION__, LMP_MAX_HEADER);
+			   __func__, LMP_MAX_HEADER);
 		return;
 	}
 
@@ -453,13 +453,13 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 	/* Get length, MSB first */
 	len = be16_to_cpu(get_unaligned((__be16 *)(fp+n))); n += 2;
 
-	IRDA_DEBUG(4, "%s(), len=%d\n", __FUNCTION__, len);
+	IRDA_DEBUG(4, "%s(), len=%d\n", __func__, len);
 
 	/* Get object ID, MSB first */
 	obj_id = be16_to_cpu(get_unaligned((__be16 *)(fp+n))); n += 2;
 
 	type = fp[n++];
-	IRDA_DEBUG(4, "%s(), Value type = %d\n", __FUNCTION__, type);
+	IRDA_DEBUG(4, "%s(), Value type = %d\n", __func__, type);
 
 	switch (type) {
 	case IAS_INTEGER:
@@ -468,7 +468,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 		value = irias_new_integer_value(tmp_cpu32);
 
 		/*  Legal values restricted to 0x01-0x6f, page 15 irttp */
-		IRDA_DEBUG(4, "%s(), lsap=%d\n", __FUNCTION__, value->t.integer);
+		IRDA_DEBUG(4, "%s(), lsap=%d\n", __func__, value->t.integer);
 		break;
 	case IAS_STRING:
 		charset = fp[n++];
@@ -488,7 +488,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 /*		case CS_UNICODE: */
 		default:
 			IRDA_DEBUG(0, "%s(), charset %s, not supported\n",
-				   __FUNCTION__, ias_charset_types[charset]);
+				   __func__, ias_charset_types[charset]);
 
 			/* Aborting, close connection! */
 			iriap_disconnect_request(self);
@@ -496,7 +496,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 			/* break; */
 		}
 		value_len = fp[n++];
-		IRDA_DEBUG(4, "%s(), strlen=%d\n", __FUNCTION__, value_len);
+		IRDA_DEBUG(4, "%s(), strlen=%d\n", __func__, value_len);
 
 		/* Make sure the string is null-terminated */
 		fp[n+value_len] = 0x00;
@@ -526,7 +526,7 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 	if (self->confirm)
 		self->confirm(IAS_SUCCESS, obj_id, value, self->priv);
 	else {
-		IRDA_DEBUG(0, "%s(), missing handler!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), missing handler!\n", __func__);
 		irias_delete_value(value);
 	}
 }
@@ -548,7 +548,7 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 	__be16 tmp_be16;
 	__u8 *fp;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -610,12 +610,12 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 		memcpy(fp+n, value->t.oct_seq, value->len); n+=value->len;
 		break;
 	case IAS_MISSING:
-		IRDA_DEBUG( 3, "%s: sending IAS_MISSING\n", __FUNCTION__);
+		IRDA_DEBUG( 3, "%s: sending IAS_MISSING\n", __func__);
 		skb_put(tx_skb, 1);
 		fp[n++] = value->type;
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), type not implemented!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), type not implemented!\n", __func__);
 		break;
 	}
 	iriap_do_r_connect_event(self, IAP_CALL_RESPONSE, tx_skb);
@@ -642,7 +642,7 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	__u8 *fp;
 	int n;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -697,7 +697,7 @@ void iriap_send_ack(struct iriap_cb *self)
 	struct sk_buff *tx_skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -728,7 +728,7 @@ void iriap_connect_request(struct iriap_cb *self)
 				    self->saddr, self->daddr,
 				    NULL, NULL);
 	if (ret < 0) {
-		IRDA_DEBUG(0, "%s(), connect failed!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
 		self->confirm(IAS_DISCONNECT, 0, NULL, self->priv);
 	}
 }
@@ -776,7 +776,7 @@ static void iriap_connect_indication(void *instance, void *sap,
 {
 	struct iriap_cb *self, *new;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	self = (struct iriap_cb *) instance;
 
@@ -787,14 +787,14 @@ static void iriap_connect_indication(void *instance, void *sap,
 	/* Start new server */
 	new = iriap_open(LSAP_IAS, IAS_SERVER, NULL, NULL);
 	if (!new) {
-		IRDA_DEBUG(0, "%s(), open failed\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), open failed\n", __func__);
 		goto out;
 	}
 
 	/* Now attach up the new "socket" */
 	new->lsap = irlmp_dup(self->lsap, new);
 	if (!new->lsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
 		goto out;
 	}
 
@@ -824,7 +824,7 @@ static int iriap_data_indication(void *instance, void *sap,
 	__u8  *frame;
 	__u8  opcode;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	self = (struct iriap_cb *) instance;
 
@@ -836,7 +836,7 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	if (self->mode == IAS_SERVER) {
 		/* Call server */
-		IRDA_DEBUG(4, "%s(), Calling server!\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), Calling server!\n", __func__);
 		iriap_do_r_connect_event(self, IAP_RECV_F_LST, skb);
 		goto out;
 	}
@@ -844,13 +844,13 @@ static int iriap_data_indication(void *instance, void *sap,
 	if (~opcode & IAP_LST) {
 		IRDA_WARNING("%s:, IrIAS multiframe commands or "
 			     "results is not implemented yet!\n",
-			     __FUNCTION__);
+			     __func__);
 		goto out;
 	}
 
 	/* Check for ack frames since they don't contain any data */
 	if (opcode & IAP_ACK) {
-		IRDA_DEBUG(0, "%s() Got ack frame!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s() Got ack frame!\n", __func__);
 		goto out;
 	}
 
@@ -868,7 +868,7 @@ static int iriap_data_indication(void *instance, void *sap,
 			iriap_getvaluebyclass_confirm(self, skb);
 			break;
 		case IAS_CLASS_UNKNOWN:
-			IRDA_DEBUG(1, "%s(), No such class!\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), No such class!\n", __func__);
 			/* Finished, close connection! */
 			iriap_disconnect_request(self);
 
@@ -881,7 +881,7 @@ static int iriap_data_indication(void *instance, void *sap,
 					      self->priv);
 			break;
 		case IAS_ATTRIB_UNKNOWN:
-			IRDA_DEBUG(1, "%s(), No such attribute!\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), No such attribute!\n", __func__);
 			/* Finished, close connection! */
 			iriap_disconnect_request(self);
 
@@ -896,7 +896,7 @@ static int iriap_data_indication(void *instance, void *sap,
 		}
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown op-code: %02x\n", __FUNCTION__,
+		IRDA_DEBUG(0, "%s(), Unknown op-code: %02x\n", __func__,
 			   opcode);
 		break;
 	}
@@ -918,7 +918,7 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 	__u8 *fp;
 	__u8 opcode;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -929,7 +929,7 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 	opcode = fp[0];
 	if (~opcode & 0x80) {
 		IRDA_WARNING("%s: IrIAS multiframe commands or results "
-			     "is not implemented yet!\n", __FUNCTION__);
+			     "is not implemented yet!\n", __func__);
 		return;
 	}
 	opcode &= 0x7f; /* Mask away LST bit */
@@ -937,7 +937,7 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 	switch (opcode) {
 	case GET_INFO_BASE:
 		IRDA_WARNING("%s: GetInfoBaseDetails not implemented yet!\n",
-			     __FUNCTION__);
+			     __func__);
 		break;
 	case GET_VALUE_BY_CLASS:
 		iriap_getvaluebyclass_indication(self, skb);
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index 8fb9d72..a301cbd 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -185,7 +185,7 @@ static void state_s_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 	case IAP_LM_DISCONNECT_INDICATION:
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -217,7 +217,7 @@ static void state_s_connecting(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_client_state(self, S_DISCONNECT);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -269,7 +269,7 @@ static void state_s_make_call(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_call_state(self, S_OUTSTANDING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -283,7 +283,7 @@ static void state_s_make_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_calling(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -305,7 +305,7 @@ static void state_s_outstanding(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_call_state(self, S_WAIT_FOR_CALL);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(0, "%s(), Unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -318,7 +318,7 @@ static void state_s_outstanding(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_replying(struct iriap_cb *self, IRIAP_EVENT event,
 			     struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -330,7 +330,7 @@ static void state_s_replying(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_wait_for_call(struct iriap_cb *self, IRIAP_EVENT event,
 				  struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 
@@ -343,7 +343,7 @@ static void state_s_wait_for_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 /**************************************************************************
@@ -367,7 +367,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 	case IAP_LM_CONNECT_INDICATION:
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (tx_skb == NULL) {
-			IRDA_WARNING("%s: unable to malloc!\n", __FUNCTION__);
+			IRDA_WARNING("%s: unable to malloc!\n", __func__);
 			return;
 		}
 
@@ -386,7 +386,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_r_connect_state(self, R_RECEIVING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(0, "%s(), unknown event %d\n", __func__, event);
 		break;
 	}
 }
@@ -397,7 +397,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 			 struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	switch (event) {
 	case IAP_LM_DISCONNECT_INDICATION:
@@ -406,7 +406,7 @@ static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_next_r_connect_state(self, R_WAITING);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -421,13 +421,13 @@ static void state_r_call(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_waiting(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 static void state_r_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), Not implemented\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Not implemented\n", __func__);
 }
 
 /*
@@ -439,7 +439,7 @@ static void state_r_wait_active(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 			      struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	switch (event) {
 	case IAP_RECV_F_LST:
@@ -448,7 +448,7 @@ static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 		iriap_call_indication(self, skb);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -462,7 +462,7 @@ static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self != NULL, return;);
@@ -483,7 +483,7 @@ static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 		irlmp_data_request(self->lsap, skb);
 		break;
 	default:
-		IRDA_DEBUG(0, "%s(), unknown event!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unknown event!\n", __func__);
 		break;
 	}
 }
@@ -491,7 +491,7 @@ static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_returning(struct iriap_cb *self, IRIAP_EVENT event,
 			      struct sk_buff *skb)
 {
-	IRDA_DEBUG(0, "%s(), event=%d\n", __FUNCTION__, event);
+	IRDA_DEBUG(0, "%s(), event=%d\n", __func__, event);
 
 	switch (event) {
 	case IAP_RECV_F_LST:
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index cbcf043..99ebb96 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -47,12 +47,12 @@ struct ias_object *irias_new_object( char *name, int id)
 {
 	struct ias_object *obj;
 
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	obj = kzalloc(sizeof(struct ias_object), GFP_ATOMIC);
 	if (obj == NULL) {
 		IRDA_WARNING("%s(), Unable to allocate object!\n",
-			     __FUNCTION__);
+			     __func__);
 		return NULL;
 	}
 
@@ -60,7 +60,7 @@ struct ias_object *irias_new_object( char *name, int id)
 	obj->name = kstrndup(name, IAS_MAX_CLASSNAME, GFP_ATOMIC);
 	if (!obj->name) {
 		IRDA_WARNING("%s(), Unable to allocate name!\n",
-			     __FUNCTION__);
+			     __func__);
 		kfree(obj);
 		return NULL;
 	}
@@ -73,7 +73,7 @@ struct ias_object *irias_new_object( char *name, int id)
 
 	if (obj->attribs == NULL) {
 		IRDA_WARNING("%s(), Unable to allocate attribs!\n",
-			     __FUNCTION__);
+			     __func__);
 		kfree(obj->name);
 		kfree(obj);
 		return NULL;
@@ -134,7 +134,7 @@ int irias_delete_object(struct ias_object *obj)
 	node = hashbin_remove_this(irias_objects, (irda_queue_t *) obj);
 	if (!node)
 		IRDA_DEBUG( 0, "%s(), object already removed!\n",
-			    __FUNCTION__);
+			    __func__);
 
 	/* Destroy */
 	__irias_delete_object(obj);
@@ -268,7 +268,7 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 	/* Find object */
 	obj = hashbin_lock_find(irias_objects, 0, obj_name);
 	if (obj == NULL) {
-		IRDA_WARNING("%s: Unable to find object: %s\n", __FUNCTION__,
+		IRDA_WARNING("%s: Unable to find object: %s\n", __func__,
 			     obj_name);
 		return -1;
 	}
@@ -280,14 +280,14 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 	attrib = hashbin_find(obj->attribs, 0, attrib_name);
 	if (attrib == NULL) {
 		IRDA_WARNING("%s: Unable to find attribute: %s\n",
-			     __FUNCTION__, attrib_name);
+			     __func__, attrib_name);
 		spin_unlock_irqrestore(&obj->attribs->hb_spinlock, flags);
 		return -1;
 	}
 
 	if ( attrib->value->type != new_value->type) {
 		IRDA_DEBUG( 0, "%s(), changing value type not allowed!\n",
-			    __FUNCTION__);
+			    __func__);
 		spin_unlock_irqrestore(&obj->attribs->hb_spinlock, flags);
 		return -1;
 	}
@@ -322,7 +322,7 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		return;
 	}
 
@@ -333,7 +333,7 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 	attrib->value = irias_new_integer_value(value);
 	if (!attrib->name || !attrib->value) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -366,7 +366,7 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		return;
 	}
 
@@ -376,7 +376,7 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 	attrib->value = irias_new_octseq_value( octets, len);
 	if (!attrib->name || !attrib->value) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -408,7 +408,7 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 	attrib = kzalloc(sizeof( struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		return;
 	}
 
@@ -418,7 +418,7 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 	attrib->value = irias_new_string_value(value);
 	if (!attrib->name || !attrib->value) {
 		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __FUNCTION__);
+			     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -442,7 +442,7 @@ struct ias_value *irias_new_integer_value(int integer)
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
 	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -467,7 +467,7 @@ struct ias_value *irias_new_string_value(char *string)
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
 	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -475,7 +475,7 @@ struct ias_value *irias_new_string_value(char *string)
 	value->charset = CS_ASCII;
 	value->t.string = kstrndup(string, IAS_MAX_STRING, GFP_ATOMIC);
 	if (!value->t.string) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
@@ -498,7 +498,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
 	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -510,7 +510,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 
 	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
 	if (value->t.oct_seq == NULL){
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
@@ -523,7 +523,7 @@ struct ias_value *irias_new_missing_value(void)
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
 	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -540,7 +540,7 @@ struct ias_value *irias_new_missing_value(void)
  */
 void irias_delete_value(struct ias_value *value)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(value != NULL, return;);
 
@@ -558,7 +558,7 @@ void irias_delete_value(struct ias_value *value)
 		 kfree(value->t.oct_seq);
 		 break;
 	default:
-		IRDA_DEBUG(0, "%s(), Unknown value type!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Unknown value type!\n", __func__);
 		break;
 	}
 	kfree(value);
diff --git a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
index fff52d5..6be1ec2 100644
--- a/net/irda/irlan/irlan_client.c
+++ b/net/irda/irlan/irlan_client.c
@@ -72,7 +72,7 @@ static void irlan_client_kick_timer_expired(void *data)
 {
 	struct irlan_cb *self = (struct irlan_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -91,7 +91,7 @@ static void irlan_client_kick_timer_expired(void *data)
 
 static void irlan_client_start_kick_timer(struct irlan_cb *self, int timeout)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	irda_start_timer(&self->client.kick_timer, timeout, (void *) self,
 			 irlan_client_kick_timer_expired);
@@ -105,7 +105,7 @@ static void irlan_client_start_kick_timer(struct irlan_cb *self, int timeout)
  */
 void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -117,7 +117,7 @@ void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 	if ((self->client.state != IRLAN_IDLE) ||
 	    (self->provider.access_type == ACCESS_DIRECT))
 	{
-			IRDA_DEBUG(0, "%s(), already awake!\n", __FUNCTION__ );
+			IRDA_DEBUG(0, "%s(), already awake!\n", __func__ );
 			return;
 	}
 
@@ -126,7 +126,7 @@ void irlan_client_wakeup(struct irlan_cb *self, __u32 saddr, __u32 daddr)
 	self->daddr = daddr;
 
 	if (self->disconnect_reason == LM_USER_REQUEST) {
-			IRDA_DEBUG(0, "%s(), still stopped by user\n", __FUNCTION__ );
+			IRDA_DEBUG(0, "%s(), still stopped by user\n", __func__ );
 			return;
 	}
 
@@ -153,7 +153,7 @@ void irlan_client_discovery_indication(discinfo_t *discovery,
 	struct irlan_cb *self;
 	__u32 saddr, daddr;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s()\n", __func__ );
 
 	IRDA_ASSERT(discovery != NULL, return;);
 
@@ -175,7 +175,7 @@ void irlan_client_discovery_indication(discinfo_t *discovery,
 	if (self) {
 		IRDA_ASSERT(self->magic == IRLAN_MAGIC, goto out;);
 
-		IRDA_DEBUG(1, "%s(), Found instance (%08x)!\n", __FUNCTION__ ,
+		IRDA_DEBUG(1, "%s(), Found instance (%08x)!\n", __func__ ,
 		      daddr);
 
 		irlan_client_wakeup(self, saddr, daddr);
@@ -195,7 +195,7 @@ static int irlan_client_ctrl_data_indication(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	self = (struct irlan_cb *) instance;
 
@@ -206,7 +206,7 @@ static int irlan_client_ctrl_data_indication(void *instance, void *sap,
 	irlan_do_client_event(self, IRLAN_DATA_INDICATION, skb);
 
 	/* Ready for a new command */
-	IRDA_DEBUG(2, "%s(), clearing tx_busy\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), clearing tx_busy\n", __func__ );
 	self->client.tx_busy = FALSE;
 
 	/* Check if we have some queued commands waiting to be sent */
@@ -223,7 +223,7 @@ static void irlan_client_ctrl_disconnect_indication(void *instance, void *sap,
 	struct tsap_cb *tsap;
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(4, "%s(), reason=%d\n", __FUNCTION__ , reason);
+	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
 
 	self = (struct irlan_cb *) instance;
 	tsap = (struct tsap_cb *) sap;
@@ -255,7 +255,7 @@ static void irlan_client_open_ctrl_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -275,7 +275,7 @@ static void irlan_client_open_ctrl_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
 		return;
 	}
 	self->client.tsap_ctrl = tsap;
@@ -295,7 +295,7 @@ static void irlan_client_ctrl_connect_confirm(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	self = (struct irlan_cb *) instance;
 
@@ -374,13 +374,13 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 
 	IRDA_ASSERT(skb != NULL, return;);
 
-	IRDA_DEBUG(4, "%s() skb->len=%d\n", __FUNCTION__ , (int) skb->len);
+	IRDA_DEBUG(4, "%s() skb->len=%d\n", __func__ , (int) skb->len);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
 	if (!skb) {
-		IRDA_ERROR("%s(), Got NULL skb!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), Got NULL skb!\n", __func__);
 		return;
 	}
 	frame = skb->data;
@@ -405,7 +405,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 	/* How many parameters? */
 	count = frame[1];
 
-	IRDA_DEBUG(4, "%s(), got %d parameters\n", __FUNCTION__ , count);
+	IRDA_DEBUG(4, "%s(), got %d parameters\n", __func__ , count);
 
 	ptr = frame+2;
 
@@ -413,7 +413,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 	for (i=0; i<count;i++) {
 		ret = irlan_extract_param(ptr, name, value, &val_len);
 		if (ret < 0) {
-			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __func__ );
 			break;
 		}
 		ptr += ret;
@@ -438,7 +438,7 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 	int i;
 	DECLARE_MAC_BUF(mac);
 
-	IRDA_DEBUG(4, "%s(), parm=%s\n", __FUNCTION__ , param);
+	IRDA_DEBUG(4, "%s(), parm=%s\n", __func__ , param);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -476,7 +476,7 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 		else if (strcmp(value, "HOSTED") == 0)
 			self->client.access_type = ACCESS_HOSTED;
 		else {
-			IRDA_DEBUG(2, "%s(), unknown access type!\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), unknown access type!\n", __func__ );
 		}
 	}
 	/* IRLAN version */
@@ -498,14 +498,14 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 		memcpy(&tmp_cpu, value, 2); /* Align value */
 		le16_to_cpus(&tmp_cpu);     /* Convert to host order */
 		self->client.recv_arb_val = tmp_cpu;
-		IRDA_DEBUG(2, "%s(), receive arb val=%d\n", __FUNCTION__ ,
+		IRDA_DEBUG(2, "%s(), receive arb val=%d\n", __func__ ,
 			   self->client.recv_arb_val);
 	}
 	if (strcmp(param, "MAX_FRAME") == 0) {
 		memcpy(&tmp_cpu, value, 2); /* Align value */
 		le16_to_cpus(&tmp_cpu);     /* Convert to host order */
 		self->client.max_frame = tmp_cpu;
-		IRDA_DEBUG(4, "%s(), max frame=%d\n", __FUNCTION__ ,
+		IRDA_DEBUG(4, "%s(), max frame=%d\n", __func__ ,
 			   self->client.max_frame);
 	}
 
@@ -539,7 +539,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 {
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(priv != NULL, return;);
 
@@ -552,7 +552,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 
 	/* Check if request succeeded */
 	if (result != IAS_SUCCESS) {
-		IRDA_DEBUG(2, "%s(), got NULL value!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), got NULL value!\n", __func__ );
 		irlan_do_client_event(self, IRLAN_IAS_PROVIDER_NOT_AVAIL,
 				      NULL);
 		return;
@@ -570,7 +570,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 		irias_delete_value(value);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), unknown type!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), unknown type!\n", __func__ );
 		break;
 	}
 	irlan_do_client_event(self, IRLAN_IAS_PROVIDER_NOT_AVAIL, NULL);
diff --git a/net/irda/irlan/irlan_client_event.c b/net/irda/irlan/irlan_client_event.c
index 6afcee5..8d5a8eb 100644
--- a/net/irda/irlan/irlan_client_event.c
+++ b/net/irda/irlan/irlan_client_event.c
@@ -92,7 +92,7 @@ void irlan_do_client_event(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -101,7 +101,7 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 	case IRLAN_DISCOVERY_INDICATION:
 		if (self->client.iriap) {
 			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 
@@ -114,10 +114,10 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 					      "IrLAN", "IrDA:TinyTP:LsapSel");
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -136,7 +136,7 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -154,7 +154,7 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_CONN);
 		break;
 	case IRLAN_IAS_PROVIDER_NOT_AVAIL:
-		IRDA_DEBUG(2, "%s(), IAS_PROVIDER_NOT_AVAIL\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IAS_PROVIDER_NOT_AVAIL\n", __func__ );
 		irlan_next_client_state(self, IRLAN_IDLE);
 
 		/* Give the client a kick! */
@@ -167,10 +167,10 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -189,7 +189,7 @@ static int irlan_client_state_query(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -204,10 +204,10 @@ static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -224,7 +224,7 @@ static int irlan_client_state_conn(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -244,10 +244,10 @@ static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -266,7 +266,7 @@ static int irlan_client_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_media(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -281,10 +281,10 @@ static int irlan_client_state_media(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -305,7 +305,7 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	struct qos_info qos;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -344,7 +344,7 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 			irlan_next_client_state(self, IRLAN_DATA);
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), unknown access type!\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), unknown access type!\n", __func__ );
 			break;
 		}
 		break;
@@ -353,10 +353,10 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 
@@ -376,7 +376,7 @@ static int irlan_client_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_wait(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -390,10 +390,10 @@ static int irlan_client_state_wait(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -407,7 +407,7 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	struct qos_info qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -429,7 +429,7 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 		} else if (self->client.recv_arb_val >
 			   self->provider.send_arb_val)
 		{
-			IRDA_DEBUG(2, "%s(), lost the battle :-(\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), lost the battle :-(\n", __func__ );
 		}
 		break;
 	case IRLAN_DATA_CONNECT_INDICATION:
@@ -440,10 +440,10 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	case IRLAN_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IRLAN_WATCHDOG_TIMEOUT\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -462,7 +462,7 @@ static int irlan_client_state_arb(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -476,7 +476,7 @@ static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_client_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -494,7 +494,7 @@ static int irlan_client_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_close(struct irlan_cb *self, IRLAN_EVENT event,
 				    struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (skb)
 		dev_kfree_skb(skb);
@@ -511,7 +511,7 @@ static int irlan_client_state_close(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_client_state_sync(struct irlan_cb *self, IRLAN_EVENT event,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (skb)
 		dev_kfree_skb(skb);
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index a4b56e2..8f6de17 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -124,7 +124,7 @@ static int __init irlan_init(void)
 	struct irlan_cb *new;
 	__u16 hints;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 #ifdef CONFIG_PROC_FS
 	{ struct proc_dir_entry *proc;
@@ -138,7 +138,7 @@ static int __init irlan_init(void)
 	}
 #endif /* CONFIG_PROC_FS */
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 	hints = irlmp_service_to_hint(S_LAN);
 
 	/* Register with IrLMP as a client */
@@ -181,7 +181,7 @@ static void __exit irlan_cleanup(void)
 {
 	struct irlan_cb *self, *next;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	irlmp_unregister_client(ckey);
 	irlmp_unregister_service(skey);
@@ -209,7 +209,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 	struct net_device *dev;
 	struct irlan_cb *self;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Create network device with irlan */
 	dev = alloc_irlandev(eth ? "eth%d" : "irlan%d");
@@ -254,7 +254,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 
 	if (register_netdev(dev)) {
 		IRDA_DEBUG(2, "%s(), register_netdev() failed!\n",
-			   __FUNCTION__ );
+			   __func__ );
 		self = NULL;
 		free_netdev(dev);
 	} else {
@@ -274,7 +274,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
  */
 static void __irlan_close(struct irlan_cb *self)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	ASSERT_RTNL();
 	IRDA_ASSERT(self != NULL, return;);
@@ -322,7 +322,7 @@ static void irlan_connect_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	self = (struct irlan_cb *) instance;
 	tsap = (struct tsap_cb *) sap;
@@ -334,7 +334,7 @@ static void irlan_connect_indication(void *instance, void *sap,
 	self->max_sdu_size = max_sdu_size;
 	self->max_header_size = max_header_size;
 
-	IRDA_DEBUG(0, "%s: We are now connected!\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s: We are now connected!\n", __func__);
 
 	del_timer(&self->watchdog_timer);
 
@@ -378,7 +378,7 @@ static void irlan_connect_confirm(void *instance, void *sap,
 
 	/* TODO: we could set the MTU depending on the max_sdu_size */
 
-	IRDA_DEBUG(0, "%s: We are now connected!\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s: We are now connected!\n", __func__);
 	del_timer(&self->watchdog_timer);
 
 	/*
@@ -414,7 +414,7 @@ static void irlan_disconnect_indication(void *instance,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(0, "%s(), reason=%d\n", __FUNCTION__ , reason);
+	IRDA_DEBUG(0, "%s(), reason=%d\n", __func__ , reason);
 
 	self = (struct irlan_cb *) instance;
 	tsap = (struct tsap_cb *) sap;
@@ -433,22 +433,22 @@ static void irlan_disconnect_indication(void *instance,
 
 	switch (reason) {
 	case LM_USER_REQUEST: /* User request */
-		IRDA_DEBUG(2, "%s(), User requested\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), User requested\n", __func__ );
 		break;
 	case LM_LAP_DISCONNECT: /* Unexpected IrLAP disconnect */
-		IRDA_DEBUG(2, "%s(), Unexpected IrLAP disconnect\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Unexpected IrLAP disconnect\n", __func__ );
 		break;
 	case LM_CONNECT_FAILURE: /* Failed to establish IrLAP connection */
-		IRDA_DEBUG(2, "%s(), IrLAP connect failed\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IrLAP connect failed\n", __func__ );
 		break;
 	case LM_LAP_RESET:  /* IrLAP reset */
-		IRDA_DEBUG(2, "%s(), IrLAP reset\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IrLAP reset\n", __func__ );
 		break;
 	case LM_INIT_DISCONNECT:
-		IRDA_DEBUG(2, "%s(), IrLMP connect failed\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), IrLMP connect failed\n", __func__ );
 		break;
 	default:
-		IRDA_ERROR("%s(), Unknown disconnect reason\n", __FUNCTION__);
+		IRDA_ERROR("%s(), Unknown disconnect reason\n", __func__);
 		break;
 	}
 
@@ -470,7 +470,7 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -492,7 +492,7 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
 		return;
 	}
 	self->tsap_data = tsap;
@@ -506,7 +506,7 @@ void irlan_open_data_tsap(struct irlan_cb *self)
 
 void irlan_close_tsaps(struct irlan_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -596,7 +596,7 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	if (irda_lock(&self->client.tx_busy) == FALSE)
 		return -EBUSY;
@@ -615,7 +615,7 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
 		dev_kfree_skb(skb);
 		return -1;
 	}
-	IRDA_DEBUG(2, "%s(), sending ...\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), sending ...\n", __func__ );
 
 	return irttp_data_request(self->client.tsap_ctrl, skb);
 }
@@ -628,7 +628,7 @@ int irlan_run_ctrl_tx_queue(struct irlan_cb *self)
  */
 static void irlan_ctrl_data_request(struct irlan_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Queue command */
 	skb_queue_tail(&self->client.txq, skb);
@@ -648,7 +648,7 @@ void irlan_get_provider_info(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -681,7 +681,7 @@ void irlan_open_data_channel(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -716,7 +716,7 @@ void irlan_close_data_channel(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -757,7 +757,7 @@ static void irlan_open_unicast_addr(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -799,7 +799,7 @@ void irlan_set_broadcast_filter(struct irlan_cb *self, int status)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -843,7 +843,7 @@ void irlan_set_multicast_filter(struct irlan_cb *self, int status)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -888,7 +888,7 @@ static void irlan_get_unicast_addr(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -928,7 +928,7 @@ void irlan_get_media_char(struct irlan_cb *self)
 	struct sk_buff *skb;
 	__u8 *frame;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -1016,7 +1016,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 	int n=0;
 
 	if (skb == NULL) {
-		IRDA_DEBUG(2, "%s(), Got NULL skb\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Got NULL skb\n", __func__ );
 		return 0;
 	}
 
@@ -1033,7 +1033,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 		IRDA_ASSERT(value_len > 0, return 0;);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown parameter type!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Unknown parameter type!\n", __func__ );
 		return 0;
 		break;
 	}
@@ -1043,7 +1043,7 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 
 	/* Make space for data */
 	if (skb_tailroom(skb) < (param_len+value_len+3)) {
-		IRDA_DEBUG(2, "%s(), No more space at end of skb\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), No more space at end of skb\n", __func__ );
 		return 0;
 	}
 	skb_put(skb, param_len+value_len+3);
@@ -1090,13 +1090,13 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
 	__u16 val_len;
 	int n=0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* get length of parameter name (1 byte) */
 	name_len = buf[n++];
 
 	if (name_len > 254) {
-		IRDA_DEBUG(2, "%s(), name_len > 254\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), name_len > 254\n", __func__ );
 		return -RSP_INVALID_COMMAND_FORMAT;
 	}
 
@@ -1113,7 +1113,7 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
 	le16_to_cpus(&val_len); n+=2;
 
 	if (val_len > 1016) {
-		IRDA_DEBUG(2, "%s(), parameter length to long\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), parameter length to long\n", __func__ );
 		return -RSP_INVALID_COMMAND_FORMAT;
 	}
 	*len = val_len;
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 1ab91f7..7a6b14a 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -103,7 +103,7 @@ static int irlan_eth_open(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Ready to play! */
 	netif_stop_queue(dev); /* Wait until data link is ready */
@@ -130,7 +130,7 @@ static int irlan_eth_close(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Stop device */
 	netif_stop_queue(dev);
@@ -221,7 +221,7 @@ int irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb)
 	}
 	if (skb->len < ETH_HLEN) {
 		IRDA_DEBUG(0, "%s() : IrLAN frame too short (%d)\n",
-			   __FUNCTION__, skb->len);
+			   __func__, skb->len);
 		++self->stats.rx_dropped;
 		dev_kfree_skb(skb);
 		return 0;
@@ -270,7 +270,7 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 
 	IRDA_ASSERT(dev != NULL, return;);
 
-	IRDA_DEBUG(0, "%s() : flow %s ; running %d\n", __FUNCTION__,
+	IRDA_DEBUG(0, "%s() : flow %s ; running %d\n", __func__,
 		   flow == FLOW_STOP ? "FLOW_STOP" : "FLOW_START",
 		   netif_running(dev));
 
@@ -332,11 +332,11 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Check if data channel has been connected yet */
 	if (self->client.state != IRLAN_DATA) {
-		IRDA_DEBUG(1, "%s(), delaying!\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), delaying!\n", __func__ );
 		return;
 	}
 
@@ -346,20 +346,20 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 	}
 	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __FUNCTION__ );
+		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* hardware_set_filter(NULL); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	}
 	else if (dev->mc_count) {
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __FUNCTION__ );
+		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* Walk the address list, and load the filter */
 		/* hardware_set_filter(dev->mc_list); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	}
 	else {
-		IRDA_DEBUG(4, "%s(), Clearing multicast filter\n", __FUNCTION__ );
+		IRDA_DEBUG(4, "%s(), Clearing multicast filter\n", __func__ );
 		irlan_set_multicast_filter(self, FALSE);
 	}
 
diff --git a/net/irda/irlan/irlan_event.c b/net/irda/irlan/irlan_event.c
index a9750a8..cbcb4eb 100644
--- a/net/irda/irlan/irlan_event.c
+++ b/net/irda/irlan/irlan_event.c
@@ -40,7 +40,7 @@ char *irlan_state[] = {
 
 void irlan_next_client_state(struct irlan_cb *self, IRLAN_STATE state)
 {
-	IRDA_DEBUG(2, "%s(), %s\n", __FUNCTION__ , irlan_state[state]);
+	IRDA_DEBUG(2, "%s(), %s\n", __func__ , irlan_state[state]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -50,7 +50,7 @@ void irlan_next_client_state(struct irlan_cb *self, IRLAN_STATE state)
 
 void irlan_next_provider_state(struct irlan_cb *self, IRLAN_STATE state)
 {
-	IRDA_DEBUG(2, "%s(), %s\n", __FUNCTION__ , irlan_state[state]);
+	IRDA_DEBUG(2, "%s(), %s\n", __func__ , irlan_state[state]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
diff --git a/net/irda/irlan/irlan_filter.c b/net/irda/irlan/irlan_filter.c
index 4384be9..9ff7823 100644
--- a/net/irda/irlan/irlan_filter.c
+++ b/net/irda/irlan/irlan_filter.c
@@ -145,7 +145,7 @@ void irlan_check_command_param(struct irlan_cb *self, char *param, char *value)
 {
 	__u8 *bytes;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	bytes = value;
 
@@ -158,7 +158,7 @@ void irlan_check_command_param(struct irlan_cb *self, char *param, char *value)
 	 *  This is experimental!! DB.
 	 */
 	 if (strcmp(param, "MODE") == 0) {
-		IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s()\n", __func__ );
 		self->use_udata = TRUE;
 		return;
 	}
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 13db942..3f81f81 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -70,7 +70,7 @@ static int irlan_provider_data_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	__u8 code;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	self = (struct irlan_cb *) instance;
 
@@ -99,15 +99,15 @@ static int irlan_provider_data_indication(void *instance, void *sap,
 		irlan_do_provider_event(self, IRLAN_FILTER_CONFIG_CMD, skb);
 		break;
 	case CMD_RECONNECT_DATA_CHAN:
-		IRDA_DEBUG(2, "%s(), Got RECONNECT_DATA_CHAN command\n", __FUNCTION__ );
-		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Got RECONNECT_DATA_CHAN command\n", __func__ );
+		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __func__ );
 		break;
 	case CMD_CLOSE_DATA_CHAN:
 		IRDA_DEBUG(2, "Got CLOSE_DATA_CHAN command!\n");
-		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), NOT IMPLEMENTED\n", __func__ );
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown command!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Unknown command!\n", __func__ );
 		break;
 	}
 	return 0;
@@ -129,7 +129,7 @@ static void irlan_provider_connect_indication(void *instance, void *sap,
 	struct tsap_cb *tsap;
 	__u32 saddr, daddr;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	self = (struct irlan_cb *) instance;
 	tsap = (struct tsap_cb *) sap;
@@ -182,7 +182,7 @@ static void irlan_provider_disconnect_indication(void *instance, void *sap,
 	struct irlan_cb *self;
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(4, "%s(), reason=%d\n", __FUNCTION__ , reason);
+	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
 
 	self = (struct irlan_cb *) instance;
 	tsap = (struct tsap_cb *) sap;
@@ -236,7 +236,7 @@ int irlan_provider_parse_command(struct irlan_cb *self, int cmd,
 
 	IRDA_ASSERT(skb != NULL, return -RSP_PROTOCOL_ERROR;);
 
-	IRDA_DEBUG(4, "%s(), skb->len=%d\n", __FUNCTION__ , (int)skb->len);
+	IRDA_DEBUG(4, "%s(), skb->len=%d\n", __func__ , (int)skb->len);
 
 	IRDA_ASSERT(self != NULL, return -RSP_PROTOCOL_ERROR;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -RSP_PROTOCOL_ERROR;);
@@ -266,7 +266,7 @@ int irlan_provider_parse_command(struct irlan_cb *self, int cmd,
 	for (i=0; i<count;i++) {
 		ret = irlan_extract_param(ptr, name, value, &val_len);
 		if (ret < 0) {
-			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), IrLAN, Error!\n", __func__ );
 			break;
 		}
 		ptr+=ret;
@@ -291,7 +291,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -323,7 +323,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 			irlan_insert_string_param(skb, "MEDIA", "802.5");
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), unknown media type!\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), unknown media type!\n", __func__ );
 			break;
 		}
 		irlan_insert_short_param(skb, "IRLAN_VER", 0x0101);
@@ -347,7 +347,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 			irlan_insert_string_param(skb, "ACCESS_TYPE", "HOSTED");
 			break;
 		default:
-			IRDA_DEBUG(2, "%s(), Unknown access type\n", __FUNCTION__ );
+			IRDA_DEBUG(2, "%s(), Unknown access type\n", __func__ );
 			break;
 		}
 		irlan_insert_short_param(skb, "MAX_FRAME", 0x05ee);
@@ -367,7 +367,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 		irlan_filter_request(self, skb);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown command!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Unknown command!\n", __func__ );
 		break;
 	}
 
@@ -385,7 +385,7 @@ int irlan_provider_open_ctrl_tsap(struct irlan_cb *self)
 	struct tsap_cb *tsap;
 	notify_t notify;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -406,7 +406,7 @@ int irlan_provider_open_ctrl_tsap(struct irlan_cb *self)
 
 	tsap = irttp_open_tsap(LSAP_ANY, 1, &notify);
 	if (!tsap) {
-		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), Got no tsap!\n", __func__ );
 		return -1;
 	}
 	self->provider.tsap_ctrl = tsap;
diff --git a/net/irda/irlan/irlan_provider_event.c b/net/irda/irlan/irlan_provider_event.c
index 10ece5a..01a9d7c 100644
--- a/net/irda/irlan/irlan_provider_event.c
+++ b/net/irda/irlan/irlan_provider_event.c
@@ -72,7 +72,7 @@ void irlan_do_provider_event(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -82,7 +82,7 @@ static int irlan_provider_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 	     irlan_next_provider_state( self, IRLAN_INFO);
 	     break;
 	default:
-		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(4, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -101,7 +101,7 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 {
 	int ret;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -147,7 +147,7 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -166,7 +166,7 @@ static int irlan_provider_state_info(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -186,7 +186,7 @@ static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG(2, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
@@ -205,7 +205,7 @@ static int irlan_provider_state_open(struct irlan_cb *self, IRLAN_EVENT event,
 static int irlan_provider_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 				     struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -221,7 +221,7 @@ static int irlan_provider_state_data(struct irlan_cb *self, IRLAN_EVENT event,
 		irlan_next_provider_state(self, IRLAN_IDLE);
 		break;
 	default:
-		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __FUNCTION__ , event);
+		IRDA_DEBUG( 0, "%s(), Unknown event %d\n", __func__ , event);
 		break;
 	}
 	if (skb)
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index f3236ac..e4965b7 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -88,7 +88,7 @@ int __init irlap_init(void)
 	irlap = hashbin_new(HB_LOCK);
 	if (irlap == NULL) {
 		IRDA_ERROR("%s: can't allocate irlap hashbin!\n",
-			   __FUNCTION__);
+			   __func__);
 		return -ENOMEM;
 	}
 
@@ -113,7 +113,7 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 {
 	struct irlap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* Initialize the irlap structure. */
 	self = kzalloc(sizeof(struct irlap_cb), GFP_KERNEL);
@@ -215,7 +215,7 @@ void irlap_close(struct irlap_cb *self)
 {
 	struct irlap_cb *lap;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -231,7 +231,7 @@ void irlap_close(struct irlap_cb *self)
 	/* Be sure that we manage to remove ourself from the hash */
 	lap = hashbin_remove(irlap, self->saddr, NULL);
 	if (!lap) {
-		IRDA_DEBUG(1, "%s(), Didn't find myself!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Didn't find myself!\n", __func__);
 		return;
 	}
 	__irlap_close(lap);
@@ -246,7 +246,7 @@ EXPORT_SYMBOL(irlap_close);
  */
 void irlap_connect_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -265,7 +265,7 @@ void irlap_connect_indication(struct irlap_cb *self, struct sk_buff *skb)
  */
 void irlap_connect_response(struct irlap_cb *self, struct sk_buff *userdata)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	irlap_do_event(self, CONNECT_RESPONSE, userdata, NULL);
 }
@@ -280,7 +280,7 @@ void irlap_connect_response(struct irlap_cb *self, struct sk_buff *userdata)
 void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
 			   struct qos_info *qos_user, int sniff)
 {
-	IRDA_DEBUG(3, "%s(), daddr=0x%08x\n", __FUNCTION__, daddr);
+	IRDA_DEBUG(3, "%s(), daddr=0x%08x\n", __func__, daddr);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -307,7 +307,7 @@ void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
  */
 void irlap_connect_confirm(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -344,7 +344,7 @@ void irlap_data_request(struct irlap_cb *self, struct sk_buff *skb,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
 		    return;);
@@ -391,7 +391,7 @@ void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
 	       return;);
@@ -417,7 +417,7 @@ void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 #ifdef CONFIG_IRDA_ULTRA
 void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -437,7 +437,7 @@ void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
  */
 void irlap_disconnect_request(struct irlap_cb *self)
 {
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -458,7 +458,7 @@ void irlap_disconnect_request(struct irlap_cb *self)
 		irlap_do_event(self, DISCONNECT_REQUEST, NULL, NULL);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), disconnect pending!\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(), disconnect pending!\n", __func__);
 		self->disconnect_pending = TRUE;
 		break;
 	}
@@ -472,7 +472,7 @@ void irlap_disconnect_request(struct irlap_cb *self)
  */
 void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 {
-	IRDA_DEBUG(1, "%s(), reason=%s\n", __FUNCTION__, lap_reasons[reason]);
+	IRDA_DEBUG(1, "%s(), reason=%s\n", __func__, lap_reasons[reason]);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -482,7 +482,7 @@ void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 
 	switch (reason) {
 	case LAP_RESET_INDICATION:
-		IRDA_DEBUG(1, "%s(), Sending reset request!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Sending reset request!\n", __func__);
 		irlap_do_event(self, RESET_REQUEST, NULL, NULL);
 		break;
 	case LAP_NO_RESPONSE:	   /* FALLTROUGH */
@@ -493,7 +493,7 @@ void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 						 reason, NULL);
 		break;
 	default:
-		IRDA_ERROR("%s: Unknown reason %d\n", __FUNCTION__, reason);
+		IRDA_ERROR("%s: Unknown reason %d\n", __func__, reason);
 	}
 }
 
@@ -511,7 +511,7 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
 
-	IRDA_DEBUG(4, "%s(), nslots = %d\n", __FUNCTION__, discovery->nslots);
+	IRDA_DEBUG(4, "%s(), nslots = %d\n", __func__, discovery->nslots);
 
 	IRDA_ASSERT((discovery->nslots == 1) || (discovery->nslots == 6) ||
 		    (discovery->nslots == 8) || (discovery->nslots == 16),
@@ -520,7 +520,7 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 	/* Discovery is only possible in NDM mode */
 	if (self->state != LAP_NDM) {
 		IRDA_DEBUG(4, "%s(), discovery only possible in NDM mode\n",
-			   __FUNCTION__);
+			   __func__);
 		irlap_discovery_confirm(self, NULL);
 		/* Note : in theory, if we are not in NDM, we could postpone
 		 * the discovery like we do for connection request.
@@ -543,7 +543,7 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 
 	if (self->discovery_log == NULL) {
 		IRDA_WARNING("%s(), Unable to allocate discovery log!\n",
-			     __FUNCTION__);
+			     __func__);
 		return;
 	}
 
@@ -598,7 +598,7 @@ void irlap_discovery_confirm(struct irlap_cb *self, hashbin_t *discovery_log)
  */
 void irlap_discovery_indication(struct irlap_cb *self, discovery_t *discovery)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -644,7 +644,7 @@ void irlap_status_indication(struct irlap_cb *self, int quality_of_link)
  */
 void irlap_reset_indication(struct irlap_cb *self)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -660,7 +660,7 @@ void irlap_reset_indication(struct irlap_cb *self)
  */
 void irlap_reset_confirm(void)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 }
 
 /*
@@ -760,7 +760,7 @@ int irlap_validate_nr_received(struct irlap_cb *self, int nr)
 {
 	/*  nr as expected?  */
 	if (nr == self->vs) {
-		IRDA_DEBUG(4, "%s(), expected!\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), expected!\n", __func__);
 		return NR_EXPECTED;
 	}
 
@@ -788,7 +788,7 @@ int irlap_validate_nr_received(struct irlap_cb *self, int nr)
  */
 void irlap_initiate_connection_state(struct irlap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -871,7 +871,7 @@ static void irlap_change_speed(struct irlap_cb *self, __u32 speed, int now)
 {
 	struct sk_buff *skb;
 
-	IRDA_DEBUG(0, "%s(), setting speed to %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(0, "%s(), setting speed to %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -914,7 +914,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
 	 *  user may not have set all of them.
 	 */
 	if (qos_user) {
-		IRDA_DEBUG(1, "%s(), Found user specified QoS!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Found user specified QoS!\n", __func__);
 
 		if (qos_user->baud_rate.bits)
 			self->qos_rx.baud_rate.bits &= qos_user->baud_rate.bits;
@@ -944,7 +944,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
  */
 void irlap_apply_default_connection_parameters(struct irlap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -1007,7 +1007,7 @@ void irlap_apply_default_connection_parameters(struct irlap_cb *self)
  */
 void irlap_apply_connection_parameters(struct irlap_cb *self, int now)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index 6af86eb..16c4ef0 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -217,7 +217,7 @@ static void irlap_start_poll_timer(struct irlap_cb *self, int timeout)
 	} else
 		self->fast_RR = FALSE;
 
-	IRDA_DEBUG(3, "%s(), timeout=%d (%ld)\n", __FUNCTION__, timeout, jiffies);
+	IRDA_DEBUG(3, "%s(), timeout=%d (%ld)\n", __func__, timeout, jiffies);
 #endif /* CONFIG_IRDA_FAST_RR */
 
 	if (timeout == 0)
@@ -241,7 +241,7 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 	if (!self || self->magic != LAP_MAGIC)
 		return;
 
-	IRDA_DEBUG(3, "%s(), event = %s, state = %s\n", __FUNCTION__,
+	IRDA_DEBUG(3, "%s(), event = %s, state = %s\n", __func__,
 		   irlap_event[event], irlap_state[self->state]);
 
 	ret = (*state[self->state])(self, event, skb, info);
@@ -259,7 +259,7 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 		 * try to disconnect link if we send any data frames, since
 		 * that will change the state away form XMIT
 		 */
-		IRDA_DEBUG(2, "%s() : queue len = %d\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s() : queue len = %d\n", __func__,
 			   skb_queue_len(&self->txq));
 
 		if (!skb_queue_empty(&self->txq)) {
@@ -340,7 +340,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 			 * media busy in irlap_connect_request() and
 			 * postpone the event... - Jean II */
 			IRDA_DEBUG(0, "%s(), CONNECT_REQUEST: media busy!\n",
-				   __FUNCTION__);
+				   __func__);
 
 			/* Always switch state before calling upper layers */
 			irlap_next_state(self, LAP_NDM);
@@ -367,7 +367,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 			irlap_connect_indication(self, skb);
 		} else {
 			IRDA_DEBUG(0, "%s(), SNRM frame does not "
-				   "contain an I field!\n", __FUNCTION__);
+				   "contain an I field!\n", __func__);
 		}
 		break;
 	case DISCOVERY_REQUEST:
@@ -375,7 +375,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 
 		if (self->media_busy) {
 			IRDA_DEBUG(1, "%s(), DISCOVERY_REQUEST: media busy!\n",
-				   __FUNCTION__);
+				   __func__);
 			/* irlap->log.condition = MEDIA_BUSY; */
 
 			/* This will make IrLMP try again */
@@ -441,7 +441,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		 * those cases...
 		 * Jean II
 		 */
-			IRDA_DEBUG(1, "%s(), Receiving final discovery request, missed the discovery slots :-(\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), Receiving final discovery request, missed the discovery slots :-(\n", __func__);
 
 			/* Last discovery request -> in the log */
 			irlap_discovery_indication(self, info->discovery);
@@ -520,7 +520,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		/* Only accept broadcast frames in NDM mode */
 		if (info->caddr != CBROADCAST) {
 			IRDA_DEBUG(0, "%s(), not a broadcast frame!\n",
-				   __FUNCTION__);
+				   __func__);
 		} else
 			irlap_unitdata_indication(self, skb);
 		break;
@@ -536,10 +536,10 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_send_test_frame(self, CBROADCAST, info->daddr, skb);
 		break;
 	case RECV_TEST_RSP:
-		IRDA_DEBUG(0, "%s() not implemented!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s() not implemented!\n", __func__);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
 			   irlap_event[event]);
 
 		ret = -1;
@@ -567,13 +567,13 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		IRDA_ASSERT(info != NULL, return -1;);
 		IRDA_ASSERT(info->discovery != NULL, return -1;);
 
-		IRDA_DEBUG(4, "%s(), daddr=%08x\n", __FUNCTION__,
+		IRDA_DEBUG(4, "%s(), daddr=%08x\n", __func__,
 			   info->discovery->data.daddr);
 
 		if (!self->discovery_log) {
 			IRDA_WARNING("%s: discovery log is gone! "
 				     "maybe the discovery timeout has been set"
-				     " too short?\n", __FUNCTION__);
+				     " too short?\n", __func__);
 			break;
 		}
 		hashbin_insert(self->discovery_log,
@@ -598,7 +598,7 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 
 		IRDA_ASSERT(info != NULL, return -1;);
 
-		IRDA_DEBUG(1, "%s(), Receiving discovery request (s = %d) while performing discovery :-(\n", __FUNCTION__, info->s);
+		IRDA_DEBUG(1, "%s(), Receiving discovery request (s = %d) while performing discovery :-(\n", __func__, info->s);
 
 		/* Last discovery request ? */
 		if (info->s == 0xff)
@@ -613,7 +613,7 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		 */
 		if (irda_device_is_receiving(self->netdev) && !self->add_wait) {
 			IRDA_DEBUG(2, "%s(), device is slow to answer, "
-				   "waiting some more!\n", __FUNCTION__);
+				   "waiting some more!\n", __func__);
 			irlap_start_slot_timer(self, msecs_to_jiffies(10));
 			self->add_wait = TRUE;
 			return ret;
@@ -649,7 +649,7 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
 			   irlap_event[event]);
 
 		ret = -1;
@@ -671,7 +671,7 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 	discovery_t *discovery_rsp;
 	int ret=0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -679,7 +679,7 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 	switch (event) {
 	case QUERY_TIMER_EXPIRED:
 		IRDA_DEBUG(0, "%s(), QUERY_TIMER_EXPIRED <%ld>\n",
-			   __FUNCTION__, jiffies);
+			   __func__, jiffies);
 		irlap_next_state(self, LAP_NDM);
 		break;
 	case RECV_DISCOVERY_XID_CMD:
@@ -717,7 +717,7 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -1;
@@ -738,7 +738,7 @@ static int irlap_state_conn(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __FUNCTION__, irlap_event[ event]);
+	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[ event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -799,18 +799,18 @@ static int irlap_state_conn(struct irlap_cb *self, IRLAP_EVENT event,
 		break;
 	case RECV_DISCOVERY_XID_CMD:
 		IRDA_DEBUG(3, "%s(), event RECV_DISCOVER_XID_CMD!\n",
-			   __FUNCTION__);
+			   __func__);
 		irlap_next_state(self, LAP_NDM);
 
 		break;
 	case DISCONNECT_REQUEST:
-		IRDA_DEBUG(0, "%s(), Disconnect request!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Disconnect request!\n", __func__);
 		irlap_send_dm_frame(self);
 		irlap_next_state( self, LAP_NDM);
 		irlap_disconnect_indication(self, LAP_DISC_INDICATION);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -1;
@@ -832,7 +832,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -861,7 +861,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 		self->retry_count++;
 		break;
 	case RECV_SNRM_CMD:
-		IRDA_DEBUG(4, "%s(), SNRM battle!\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), SNRM battle!\n", __func__);
 
 		IRDA_ASSERT(skb != NULL, return 0;);
 		IRDA_ASSERT(info != NULL, return 0;);
@@ -948,7 +948,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_disconnect_indication(self, LAP_DISC_INDICATION);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, %s\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -1;
@@ -966,7 +966,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_offline(struct irlap_cb *self, IRLAP_EVENT event,
 			       struct sk_buff *skb, struct irlap_info *info)
 {
-	IRDA_DEBUG( 0, "%s(), Unknown event\n", __FUNCTION__);
+	IRDA_DEBUG( 0, "%s(), Unknown event\n", __func__);
 
 	return -1;
 }
@@ -1030,7 +1030,7 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 			 */
 			if((!nextfit) && (skb->len > self->bytes_left)) {
 				IRDA_DEBUG(0, "%s(), Not allowed to transmit"
-					   " more bytes!\n", __FUNCTION__);
+					   " more bytes!\n", __func__);
 				/* Requeue the skb */
 				skb_queue_head(&self->txq, skb_get(skb));
 				/*
@@ -1082,7 +1082,7 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 #endif /* CONFIG_IRDA_FAST_RR */
 		} else {
 			IRDA_DEBUG(4, "%s(), Unable to send! remote busy?\n",
-				   __FUNCTION__);
+				   __func__);
 			skb_queue_head(&self->txq, skb_get(skb));
 
 			/*
@@ -1094,7 +1094,7 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 		break;
 	case POLL_TIMER_EXPIRED:
 		IRDA_DEBUG(3, "%s(), POLL_TIMER_EXPIRED <%ld>\n",
-			    __FUNCTION__, jiffies);
+			    __func__, jiffies);
 		irlap_send_rr_frame(self, CMD_FRAME);
 		/* Return to NRM properly - Jean II  */
 		self->window = self->window_size;
@@ -1120,7 +1120,7 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			   __FUNCTION__, irlap_event[event]);
+			   __func__, irlap_event[event]);
 
 		ret = -EINVAL;
 		break;
@@ -1138,7 +1138,7 @@ static int irlap_state_pclose(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1173,7 +1173,7 @@ static int irlap_state_pclose(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d\n", __FUNCTION__, event);
+		IRDA_DEBUG(1, "%s(), Unknown event %d\n", __func__, event);
 
 		ret = -1;
 		break;
@@ -1297,7 +1297,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			} else {
 				IRDA_DEBUG(4,
 				       "%s(), missing or duplicate frame!\n",
-					   __FUNCTION__);
+					   __func__);
 
 				/* Update Nr received */
 				irlap_update_nr_received(self, info->nr);
@@ -1367,7 +1367,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		    (nr_status == NR_UNEXPECTED))
 		{
 			IRDA_DEBUG(4, "%s(), unexpected nr and ns!\n",
-				   __FUNCTION__);
+				   __func__);
 			if (info->pf) {
 				/* Resend rejected frames */
 				irlap_resend_rejected_frames(self, CMD_FRAME);
@@ -1407,9 +1407,9 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			}
 			break;
 		}
-		IRDA_DEBUG(1, "%s(), Not implemented!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Not implemented!\n", __func__);
 		IRDA_DEBUG(1, "%s(), event=%s, ns_status=%d, nr_status=%d\n",
-		       __FUNCTION__, irlap_event[event], ns_status, nr_status);
+		       __func__, irlap_event[event], ns_status, nr_status);
 		break;
 	case RECV_UI_FRAME:
 		/* Poll bit cleared? */
@@ -1420,7 +1420,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			del_timer(&self->final_timer);
 			irlap_data_indication(self, skb, TRUE);
 			irlap_next_state(self, LAP_XMIT_P);
-			IRDA_DEBUG(1, "%s: RECV_UI_FRAME: next state %s\n", __FUNCTION__, irlap_state[self->state]);
+			IRDA_DEBUG(1, "%s: RECV_UI_FRAME: next state %s\n", __func__, irlap_state[self->state]);
 			irlap_start_poll_timer(self, self->poll_timeout);
 		}
 		break;
@@ -1475,7 +1475,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			irlap_next_state(self, LAP_NRM_P);
 		} else if (ret == NR_INVALID) {
 			IRDA_DEBUG(1, "%s(), Received RR with "
-				   "invalid nr !\n", __FUNCTION__);
+				   "invalid nr !\n", __func__);
 
 			irlap_next_state(self, LAP_RESET_WAIT);
 
@@ -1580,7 +1580,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_start_final_timer(self, 2 * self->final_timeout);
 		break;
 	case RECV_RD_RSP:
-		IRDA_DEBUG(1, "%s(), RECV_RD_RSP\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), RECV_RD_RSP\n", __func__);
 
 		irlap_flush_all_queues(self);
 		irlap_next_state(self, LAP_XMIT_P);
@@ -1589,7 +1589,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(1, "%s(), Unknown event %s\n",
-			    __FUNCTION__, irlap_event[event]);
+			    __func__, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -1609,7 +1609,7 @@ static int irlap_state_reset_wait(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(3, "%s(), event = %s\n", __FUNCTION__, irlap_event[event]);
+	IRDA_DEBUG(3, "%s(), event = %s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1635,7 +1635,7 @@ static int irlap_state_reset_wait(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state( self, LAP_PCLOSE);
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
 			   irlap_event[event]);
 
 		ret = -1;
@@ -1656,7 +1656,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(3, "%s(), event = %s\n", __FUNCTION__, irlap_event[event]);
+	IRDA_DEBUG(3, "%s(), event = %s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1714,7 +1714,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 		 * state
 		 */
 		if (!info) {
-			IRDA_DEBUG(3, "%s(), RECV_SNRM_CMD\n", __FUNCTION__);
+			IRDA_DEBUG(3, "%s(), RECV_SNRM_CMD\n", __func__);
 			irlap_initiate_connection_state(self);
 			irlap_wait_min_turn_around(self, &self->qos_tx);
 			irlap_send_ua_response_frame(self, &self->qos_rx);
@@ -1724,12 +1724,12 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 		} else {
 			IRDA_DEBUG(0,
 				   "%s(), SNRM frame contained an I field!\n",
-				   __FUNCTION__);
+				   __func__);
 		}
 		break;
 	default:
 		IRDA_DEBUG(1, "%s(), Unknown event %s\n",
-			   __FUNCTION__, irlap_event[event]);
+			   __func__, irlap_event[event]);
 
 		ret = -1;
 		break;
@@ -1749,7 +1749,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __FUNCTION__, irlap_event[event]);
+	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
@@ -1786,7 +1786,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 			 */
 			if((!nextfit) && (skb->len > self->bytes_left)) {
 				IRDA_DEBUG(0, "%s(), Not allowed to transmit"
-					   " more bytes!\n", __FUNCTION__);
+					   " more bytes!\n", __func__);
 				/* Requeue the skb */
 				skb_queue_head(&self->txq, skb_get(skb));
 
@@ -1832,7 +1832,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 				ret = -EPROTO;
 			}
 		} else {
-			IRDA_DEBUG(2, "%s(), Unable to send!\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), Unable to send!\n", __func__);
 			skb_queue_head(&self->txq, skb_get(skb));
 			ret = -EPROTO;
 		}
@@ -1848,7 +1848,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 		 * when we return... - Jean II */
 		break;
 	default:
-		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Unknown event %s\n", __func__,
 			   irlap_event[event]);
 
 		ret = -EINVAL;
@@ -1871,7 +1871,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 	int nr_status;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s(), event=%s\n", __FUNCTION__, irlap_event[ event]);
+	IRDA_DEBUG(4, "%s(), event=%s\n", __func__, irlap_event[ event]);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
@@ -1880,7 +1880,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 	case RECV_I_CMD: /* Optimize for the common case */
 		/* FIXME: must check for remote_busy below */
 		IRDA_DEBUG(4, "%s(), event=%s nr=%d, vs=%d, ns=%d, "
-			   "vr=%d, pf=%d\n", __FUNCTION__,
+			   "vr=%d, pf=%d\n", __func__,
 			   irlap_event[event], info->nr,
 			   self->vs, info->ns, self->vr, info->pf);
 
@@ -2112,21 +2112,21 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 			irlap_next_state(self, LAP_NRM_S);
 		} else {
 			IRDA_DEBUG(1, "%s(), invalid nr not implemented!\n",
-				   __FUNCTION__);
+				   __func__);
 		}
 		break;
 	case RECV_SNRM_CMD:
 		/* SNRM frame is not allowed to contain an I-field */
 		if (!info) {
 			del_timer(&self->wd_timer);
-			IRDA_DEBUG(1, "%s(), received SNRM cmd\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), received SNRM cmd\n", __func__);
 			irlap_next_state(self, LAP_RESET_CHECK);
 
 			irlap_reset_indication(self);
 		} else {
 			IRDA_DEBUG(0,
 				   "%s(), SNRM frame contained an I-field!\n",
-				   __FUNCTION__);
+				   __func__);
 
 		}
 		break;
@@ -2158,7 +2158,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		 *   which explain why we use (self->N2 / 2) here !!!
 		 * Jean II
 		 */
-		IRDA_DEBUG(1, "%s(), retry_count = %d\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), retry_count = %d\n", __func__,
 			   self->retry_count);
 
 		if (self->retry_count < (self->N2 / 2)) {
@@ -2211,7 +2211,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_send_test_frame(self, self->caddr, info->daddr, skb);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -EINVAL;
@@ -2228,7 +2228,7 @@ static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
@@ -2285,7 +2285,7 @@ static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 			break;		/* stay in SCLOSE */
 		}
 
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -EINVAL;
@@ -2301,7 +2301,7 @@ static int irlap_state_reset_check( struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(1, "%s(), event=%s\n", __FUNCTION__, irlap_event[event]);
+	IRDA_DEBUG(1, "%s(), event=%s\n", __func__, irlap_event[event]);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
@@ -2322,7 +2322,7 @@ static int irlap_state_reset_check( struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state(self, LAP_SCLOSE);
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __FUNCTION__,
+		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
 			   event, irlap_event[event]);
 
 		ret = -EINVAL;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 7c132d6..a38b231 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -102,7 +102,7 @@ void irlap_queue_xmit(struct irlap_cb *self, struct sk_buff *skb)
 	irlap_insert_info(self, skb);
 
 	if (unlikely(self->mode & IRDA_MODE_MONITOR)) {
-		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __FUNCTION__,
+		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __func__,
 			   self->netdev->name);
 		dev_kfree_skb(skb);
 		return;
@@ -182,7 +182,7 @@ static void irlap_recv_snrm_cmd(struct irlap_cb *self, struct sk_buff *skb,
 		/* Check if the new connection address is valid */
 		if ((info->caddr == 0x00) || (info->caddr == 0xfe)) {
 			IRDA_DEBUG(3, "%s(), invalid connection address!\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 
@@ -193,7 +193,7 @@ static void irlap_recv_snrm_cmd(struct irlap_cb *self, struct sk_buff *skb,
 		/* Only accept if addressed directly to us */
 		if (info->saddr != self->saddr) {
 			IRDA_DEBUG(2, "%s(), not addressed to us!\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 		irlap_do_event(self, RECV_SNRM_CMD, skb, info);
@@ -215,7 +215,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 	struct ua_frame *frame;
 	int ret;
 
-	IRDA_DEBUG(2, "%s() <%ld>\n", __FUNCTION__, jiffies);
+	IRDA_DEBUG(2, "%s() <%ld>\n", __func__, jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -290,7 +290,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	struct sk_buff *tx_skb = NULL;
 	struct disc_frame *frame;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -321,7 +321,7 @@ void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 	__u32 bcast = BROADCAST;
 	__u8 *info;
 
-	IRDA_DEBUG(4, "%s(), s=%d, S=%d, command=%d\n", __FUNCTION__,
+	IRDA_DEBUG(4, "%s(), s=%d, S=%d, command=%d\n", __func__,
 		   s, S, command);
 
 	IRDA_ASSERT(self != NULL, return;);
@@ -414,13 +414,13 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	__u8 *discovery_info;
 	char *text;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -432,12 +432,12 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	/* Make sure frame is addressed to us */
 	if ((info->saddr != self->saddr) && (info->saddr != BROADCAST)) {
 		IRDA_DEBUG(0, "%s(), frame is not addressed to us!\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
 	if ((discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC)) == NULL) {
-		IRDA_WARNING("%s: kmalloc failed!\n", __FUNCTION__);
+		IRDA_WARNING("%s: kmalloc failed!\n", __func__);
 		return;
 	}
 
@@ -445,7 +445,7 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	discovery->data.saddr = self->saddr;
 	discovery->timestamp = jiffies;
 
-	IRDA_DEBUG(4, "%s(), daddr=%08x\n", __FUNCTION__,
+	IRDA_DEBUG(4, "%s(), daddr=%08x\n", __func__,
 		   discovery->data.daddr);
 
 	discovery_info = skb_pull(skb, sizeof(struct xid_frame));
@@ -491,7 +491,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 	char *text;
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -503,7 +503,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 	/* Make sure frame is addressed to us */
 	if ((info->saddr != self->saddr) && (info->saddr != BROADCAST)) {
 		IRDA_DEBUG(0, "%s(), frame is not addressed to us!\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
@@ -536,7 +536,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		if((discovery_info == NULL) ||
 		   !pskb_may_pull(skb, 3)) {
 			IRDA_ERROR("%s: discovery frame too short!\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 
@@ -545,7 +545,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		 */
 		discovery = kmalloc(sizeof(discovery_t), GFP_ATOMIC);
 		if (!discovery) {
-			IRDA_WARNING("%s: unable to malloc!\n", __FUNCTION__);
+			IRDA_WARNING("%s: unable to malloc!\n", __func__);
 			return;
 		}
 
@@ -657,7 +657,7 @@ static void irlap_recv_rnr_frame(struct irlap_cb *self, struct sk_buff *skb,
 {
 	info->nr = skb->data[1] >> 5;
 
-	IRDA_DEBUG(4, "%s(), nr=%d, %ld\n", __FUNCTION__, info->nr, jiffies);
+	IRDA_DEBUG(4, "%s(), nr=%d, %ld\n", __func__, info->nr, jiffies);
 
 	if (command)
 		irlap_do_event(self, RECV_RNR_CMD, skb, info);
@@ -668,7 +668,7 @@ static void irlap_recv_rnr_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_rej_frame(struct irlap_cb *self, struct sk_buff *skb,
 				 struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s()\n", __func__);
 
 	info->nr = skb->data[1] >> 5;
 
@@ -682,7 +682,7 @@ static void irlap_recv_rej_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_srej_frame(struct irlap_cb *self, struct sk_buff *skb,
 				  struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s()\n", __func__);
 
 	info->nr = skb->data[1] >> 5;
 
@@ -696,7 +696,7 @@ static void irlap_recv_srej_frame(struct irlap_cb *self, struct sk_buff *skb,
 static void irlap_recv_disc_frame(struct irlap_cb *self, struct sk_buff *skb,
 				  struct irlap_info *info, int command)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Check if this is a command or a response frame */
 	if (command)
@@ -755,7 +755,7 @@ void irlap_send_data_primary(struct irlap_cb *self, struct sk_buff *skb)
 
 		irlap_send_i_frame( self, tx_skb, CMD_FRAME);
 	} else {
-		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __func__);
 		irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
 		self->window -= 1;
 	}
@@ -808,7 +808,7 @@ void irlap_send_data_primary_poll(struct irlap_cb *self, struct sk_buff *skb)
 		irlap_next_state(self, LAP_NRM_P);
 		irlap_send_i_frame(self, tx_skb, CMD_FRAME);
 	} else {
-		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __func__);
 
 		if (self->ack_required) {
 			irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
@@ -835,7 +835,7 @@ void irlap_send_data_primary_poll(struct irlap_cb *self, struct sk_buff *skb)
 	 * See max_line_capacities[][] in qos.c for details. Jean II */
 	transmission_time -= (self->final_timeout * self->bytes_left
 			      / self->line_capacity);
-	IRDA_DEBUG(4, "%s() adjusting transmission_time : ft=%d, bl=%d, lc=%d -> tt=%d\n", __FUNCTION__, self->final_timeout, self->bytes_left, self->line_capacity, transmission_time);
+	IRDA_DEBUG(4, "%s() adjusting transmission_time : ft=%d, bl=%d, lc=%d -> tt=%d\n", __func__, self->final_timeout, self->bytes_left, self->line_capacity, transmission_time);
 
 	/* We are allowed to transmit a maximum number of bytes again. */
 	self->bytes_left = self->line_capacity;
@@ -1001,7 +1001,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		/* tx_skb = skb_clone( skb, GFP_ATOMIC); */
 		tx_skb = skb_copy(skb, GFP_ATOMIC);
 		if (!tx_skb) {
-			IRDA_DEBUG(0, "%s(), unable to copy\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), unable to copy\n", __func__);
 			return;
 		}
 
@@ -1033,7 +1033,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 	 */
 	while (!skb_queue_empty(&self->txq)) {
 
-		IRDA_DEBUG(0, "%s(), sending additional frames!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), sending additional frames!\n", __func__);
 		if (self->window > 0) {
 			skb = skb_dequeue( &self->txq);
 			IRDA_ASSERT(skb != NULL, return;);
@@ -1073,7 +1073,7 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 		/* tx_skb = skb_clone( skb, GFP_ATOMIC); */
 		tx_skb = skb_copy(skb, GFP_ATOMIC);
 		if (!tx_skb) {
-			IRDA_DEBUG(0, "%s(), unable to copy\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), unable to copy\n", __func__);
 			return;
 		}
 
@@ -1096,7 +1096,7 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 void irlap_send_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 			 __u8 caddr, int command)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -1156,7 +1156,7 @@ static inline void irlap_recv_i_frame(struct irlap_cb *self,
 static void irlap_recv_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 				struct irlap_info *info)
 {
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	info->pf = skb->data[1] & PF_BIT;      /* Final bit */
 
@@ -1175,7 +1175,7 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	__u8 *frame;
 	int w, x, y, z;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -1183,7 +1183,7 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	IRDA_ASSERT(info != NULL, return;);
 
 	if (!pskb_may_pull(skb, 4)) {
-		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -1269,10 +1269,10 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
 {
 	struct test_frame *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (!pskb_may_pull(skb, sizeof(*frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __func__);
 		return;
 	}
 	frame = (struct test_frame *) skb->data;
@@ -1281,7 +1281,7 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
 	if (info->caddr == CBROADCAST) {
 		if (skb->len < sizeof(struct test_frame)) {
 			IRDA_DEBUG(0, "%s() test frame too short!\n",
-				   __FUNCTION__);
+				   __func__);
 			return;
 		}
 
@@ -1342,14 +1342,14 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * share and non linear skbs. This should never happen, so
 	 * we don't need to be clever about it. Jean II */
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		IRDA_ERROR("%s: can't clone shared skb!\n", __FUNCTION__);
+		IRDA_ERROR("%s: can't clone shared skb!\n", __func__);
 		dev_kfree_skb(skb);
 		return -1;
 	}
 
 	/* Check if frame is large enough for parsing */
 	if (!pskb_may_pull(skb, 2)) {
-		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __func__);
 		dev_kfree_skb(skb);
 		return -1;
 	}
@@ -1365,7 +1365,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 	/*  First we check if this frame has a valid connection address */
 	if ((info.caddr != self->caddr) && (info.caddr != CBROADCAST)) {
 		IRDA_DEBUG(0, "%s(), wrong connection address!\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out;
 	}
 	/*
@@ -1400,7 +1400,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 			break;
 		default:
 			IRDA_WARNING("%s: Unknown S-frame %02x received!\n",
-				__FUNCTION__, info.control);
+				__func__, info.control);
 			break;
 		}
 		goto out;
@@ -1438,7 +1438,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 		break;
 	default:
 		IRDA_WARNING("%s: Unknown frame %02x received!\n",
-				__FUNCTION__, info.control);
+				__func__, info.control);
 		break;
 	}
 out:
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 135ac69..1f81f8e 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -76,7 +76,7 @@ const char *irlmp_reasons[] = {
  */
 int __init irlmp_init(void)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 	/* Initialize the irlmp structure. */
 	irlmp = kzalloc( sizeof(struct irlmp_cb), GFP_KERNEL);
 	if (irlmp == NULL)
@@ -164,7 +164,7 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 	/* Allocate new instance of a LSAP connection */
 	self = kzalloc(sizeof(struct lsap_cb), GFP_ATOMIC);
 	if (self == NULL) {
-		IRDA_ERROR("%s: can't allocate memory\n", __FUNCTION__);
+		IRDA_ERROR("%s: can't allocate memory\n", __func__);
 		return NULL;
 	}
 
@@ -202,7 +202,7 @@ EXPORT_SYMBOL(irlmp_open_lsap);
  */
 static void __irlmp_close_lsap(struct lsap_cb *self)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -264,7 +264,7 @@ void irlmp_close_lsap(struct lsap_cb *self)
 	if (!lsap) {
 		IRDA_DEBUG(0,
 		     "%s(), Looks like somebody has removed me already!\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 	__irlmp_close_lsap(self);
@@ -291,7 +291,7 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 	 */
 	lap = kzalloc(sizeof(struct lap_cb), GFP_KERNEL);
 	if (lap == NULL) {
-		IRDA_ERROR("%s: unable to kmalloc\n", __FUNCTION__);
+		IRDA_ERROR("%s: unable to kmalloc\n", __func__);
 		return;
 	}
 
@@ -304,7 +304,7 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 #endif
 	lap->lsaps = hashbin_new(HB_LOCK);
 	if (lap->lsaps == NULL) {
-		IRDA_WARNING("%s(), unable to kmalloc lsaps\n", __FUNCTION__);
+		IRDA_WARNING("%s(), unable to kmalloc lsaps\n", __func__);
 		kfree(lap);
 		return;
 	}
@@ -336,7 +336,7 @@ void irlmp_unregister_link(__u32 saddr)
 {
 	struct lap_cb *link;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* We must remove ourselves from the hashbin *first*. This ensure
 	 * that no more LSAPs will be open on this link and no discovery
@@ -381,7 +381,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 
 	IRDA_DEBUG(2,
 	      "%s(), slsap_sel=%02x, dlsap_sel=%02x, saddr=%08x, daddr=%08x\n",
-	      __FUNCTION__, self->slsap_sel, dlsap_sel, saddr, daddr);
+	      __func__, self->slsap_sel, dlsap_sel, saddr, daddr);
 
 	if (test_bit(0, &self->connected)) {
 		ret = -EISCONN;
@@ -425,7 +425,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 		if (daddr != DEV_ADDR_ANY)
 			discovery = hashbin_find(irlmp->cachelog, daddr, NULL);
 		else {
-			IRDA_DEBUG(2, "%s(), no daddr\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), no daddr\n", __func__);
 			discovery = (discovery_t *)
 				hashbin_get_first(irlmp->cachelog);
 		}
@@ -438,7 +438,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	}
 	lap = hashbin_lock_find(irlmp->links, saddr, NULL);
 	if (lap == NULL) {
-		IRDA_DEBUG(1, "%s(), Unable to find a usable link!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unable to find a usable link!\n", __func__);
 		ret = -EHOSTUNREACH;
 		goto err;
 	}
@@ -453,14 +453,14 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 			 * disconnected yet (waiting for timeout in LAP).
 			 * Maybe we could give LAP a bit of help in this case.
 			 */
-			IRDA_DEBUG(0, "%s(), sorry, but I'm waiting for LAP to timeout!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), sorry, but I'm waiting for LAP to timeout!\n", __func__);
 			ret = -EAGAIN;
 			goto err;
 		}
 
 		/* LAP is already connected to a different node, and LAP
 		 * can only talk to one node at a time */
-		IRDA_DEBUG(0, "%s(), sorry, but link is busy!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), sorry, but link is busy!\n", __func__);
 		ret = -EBUSY;
 		goto err;
 	}
@@ -522,7 +522,7 @@ void irlmp_connect_indication(struct lsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->lap != NULL, return;);
 
 	IRDA_DEBUG(2, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __FUNCTION__, self->slsap_sel, self->dlsap_sel);
+		   __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Note : self->lap is set in irlmp_link_data_indication(),
 	 * (case CONNECT_CMD:) because we have no way to set it here.
@@ -563,7 +563,7 @@ int irlmp_connect_response(struct lsap_cb *self, struct sk_buff *userdata)
 	 * in the state machine itself. Jean II */
 
 	IRDA_DEBUG(2, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __FUNCTION__, self->slsap_sel, self->dlsap_sel);
+		   __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Make room for MUX control header (3 bytes) */
 	IRDA_ASSERT(skb_headroom(userdata) >= LMP_CONTROL_HEADER, return -1;);
@@ -589,7 +589,7 @@ void irlmp_connect_confirm(struct lsap_cb *self, struct sk_buff *skb)
 	int lap_header_size;
 	int max_seg_size;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self != NULL, return;);
@@ -603,7 +603,7 @@ void irlmp_connect_confirm(struct lsap_cb *self, struct sk_buff *skb)
 	max_header_size = LMP_HEADER + lap_header_size;
 
 	IRDA_DEBUG(2, "%s(), max_header_size=%d\n",
-		   __FUNCTION__, max_header_size);
+		   __func__, max_header_size);
 
 	/* Hide LMP_CONTROL_HEADER header from layer above */
 	skb_pull(skb, LMP_CONTROL_HEADER);
@@ -629,7 +629,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	struct lsap_cb *new;
 	unsigned long flags;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	spin_lock_irqsave(&irlmp->unconnected_lsaps->hb_spinlock, flags);
 
@@ -638,7 +638,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	if ((!hashbin_find(irlmp->unconnected_lsaps, (long) orig, NULL)) ||
 	    (orig->lap == NULL)) {
 		IRDA_DEBUG(0, "%s(), invalid LSAP (wrong state)\n",
-			   __FUNCTION__);
+			   __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
@@ -647,7 +647,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new)  {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
@@ -693,7 +693,7 @@ int irlmp_disconnect_request(struct lsap_cb *self, struct sk_buff *userdata)
 	 * and us that might mess up the hashbins below. This fixes it.
 	 * Jean II */
 	if (! test_and_clear_bit(0, &self->connected)) {
-		IRDA_DEBUG(0, "%s(), already disconnected!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), already disconnected!\n", __func__);
 		dev_kfree_skb(userdata);
 		return -1;
 	}
@@ -747,19 +747,19 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 {
 	struct lsap_cb *lsap;
 
-	IRDA_DEBUG(1, "%s(), reason=%s\n", __FUNCTION__, irlmp_reasons[reason]);
+	IRDA_DEBUG(1, "%s(), reason=%s\n", __func__, irlmp_reasons[reason]);
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
 	IRDA_DEBUG(3, "%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
-		   __FUNCTION__, self->slsap_sel, self->dlsap_sel);
+		   __func__, self->slsap_sel, self->dlsap_sel);
 
 	/* Already disconnected ?
 	 * There is a race condition between irlmp_disconnect_request()
 	 * and us that might mess up the hashbins below. This fixes it.
 	 * Jean II */
 	if (! test_and_clear_bit(0, &self->connected)) {
-		IRDA_DEBUG(0, "%s(), already disconnected!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), already disconnected!\n", __func__);
 		return;
 	}
 
@@ -792,7 +792,7 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 		self->notify.disconnect_indication(self->notify.instance,
 						   self, reason, skb);
 	} else {
-		IRDA_DEBUG(0, "%s(), no handler\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), no handler\n", __func__);
 	}
 }
 
@@ -845,7 +845,7 @@ void irlmp_do_discovery(int nslots)
 	/* Make sure the value is sane */
 	if ((nslots != 1) && (nslots != 6) && (nslots != 8) && (nslots != 16)){
 		IRDA_WARNING("%s: invalid value for number of slots!\n",
-			     __FUNCTION__);
+			     __func__);
 		nslots = sysctl_discovery_slots = 8;
 	}
 
@@ -963,7 +963,7 @@ irlmp_notify_client(irlmp_client_t *client,
 	int	number;			/* Number of nodes in the log */
 	int	i;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	/* Check if client wants or not partial/selective log (optimisation) */
 	if (!client->disco_callback)
@@ -1014,7 +1014,7 @@ void irlmp_discovery_confirm(hashbin_t *log, DISCOVERY_MODE mode)
 	irlmp_client_t *client;
 	irlmp_client_t *client_next;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(log != NULL, return;);
 
@@ -1049,7 +1049,7 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
 	irlmp_client_t *client_next;
 	int		i;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(expiries != NULL, return;);
 
@@ -1082,7 +1082,7 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
  */
 discovery_t *irlmp_get_discovery_response(void)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(irlmp != NULL, return NULL;);
 
@@ -1160,7 +1160,7 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
 {
 	int	ret;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(userdata != NULL, return -1;);
 
@@ -1184,7 +1184,7 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
  */
 void irlmp_udata_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -1211,7 +1211,7 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 	struct sk_buff *clone_skb;
 	struct lap_cb *lap;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(userdata != NULL, return -1;);
 
@@ -1262,7 +1262,7 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 #ifdef CONFIG_IRDA_ULTRA
 void irlmp_connless_data_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -1305,7 +1305,7 @@ void irlmp_status_indication(struct lap_cb *self,
 			curr->notify.status_indication(curr->notify.instance,
 						       link, lock);
 		else
-			IRDA_DEBUG(2, "%s(), no handler\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), no handler\n", __func__);
 
 		curr = next;
 	}
@@ -1333,7 +1333,7 @@ void irlmp_flow_indication(struct lap_cb *self, LOCAL_FLOW flow)
 	/* Get the number of lsap. That's the only safe way to know
 	 * that we have looped around... - Jean II */
 	lsap_todo = HASHBIN_GET_SIZE(self->lsaps);
-	IRDA_DEBUG(4, "%s() : %d lsaps to scan\n", __FUNCTION__, lsap_todo);
+	IRDA_DEBUG(4, "%s() : %d lsaps to scan\n", __func__, lsap_todo);
 
 	/* Poll lsap in order until the queue is full or until we
 	 * tried them all.
@@ -1352,14 +1352,14 @@ void irlmp_flow_indication(struct lap_cb *self, LOCAL_FLOW flow)
 		/* Uh-oh... Paranoia */
 		if(curr == NULL)
 			break;
-		IRDA_DEBUG(4, "%s() : curr is %p, next was %p and is now %p, still %d to go - queue len = %d\n", __FUNCTION__, curr, next, self->flow_next, lsap_todo, IRLAP_GET_TX_QUEUE_LEN(self->irlap));
+		IRDA_DEBUG(4, "%s() : curr is %p, next was %p and is now %p, still %d to go - queue len = %d\n", __func__, curr, next, self->flow_next, lsap_todo, IRLAP_GET_TX_QUEUE_LEN(self->irlap));
 
 		/* Inform lsap user that it can send one more packet. */
 		if (curr->notify.flow_indication != NULL)
 			curr->notify.flow_indication(curr->notify.instance,
 						     curr, flow);
 		else
-			IRDA_DEBUG(1, "%s(), no handler\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), no handler\n", __func__);
 	}
 }
 
@@ -1381,7 +1381,7 @@ __u8 *irlmp_hint_to_service(__u8 *hint)
 	 */
 	service = kmalloc(16, GFP_ATOMIC);
 	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -1482,12 +1482,12 @@ void *irlmp_register_service(__u16 hints)
 {
 	irlmp_service_t *service;
 
-	IRDA_DEBUG(4, "%s(), hints = %04x\n", __FUNCTION__, hints);
+	IRDA_DEBUG(4, "%s(), hints = %04x\n", __func__, hints);
 
 	/* Make a new registration */
 	service = kmalloc(sizeof(irlmp_service_t), GFP_ATOMIC);
 	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 	service->hints.word = hints;
@@ -1512,7 +1512,7 @@ int irlmp_unregister_service(void *handle)
 	irlmp_service_t *service;
 	unsigned long flags;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	if (!handle)
 		return -1;
@@ -1520,7 +1520,7 @@ int irlmp_unregister_service(void *handle)
 	/* Caller may call with invalid handle (it's legal) - Jean II */
 	service = hashbin_lock_find(irlmp->services, (long) handle, NULL);
 	if (!service) {
-		IRDA_DEBUG(1, "%s(), Unknown service!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unknown service!\n", __func__);
 		return -1;
 	}
 
@@ -1557,13 +1557,13 @@ void *irlmp_register_client(__u16 hint_mask, DISCOVERY_CALLBACK1 disco_clb,
 {
 	irlmp_client_t *client;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 	IRDA_ASSERT(irlmp != NULL, return NULL;);
 
 	/* Make a new registration */
 	client = kmalloc(sizeof(irlmp_client_t), GFP_ATOMIC);
 	if (!client) {
-		IRDA_DEBUG( 1, "%s(), Unable to kmalloc!\n", __FUNCTION__);
+		IRDA_DEBUG( 1, "%s(), Unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -1599,7 +1599,7 @@ int irlmp_update_client(void *handle, __u16 hint_mask,
 
 	client = hashbin_lock_find(irlmp->clients, (long) handle, NULL);
 	if (!client) {
-		IRDA_DEBUG(1, "%s(), Unknown client!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unknown client!\n", __func__);
 		return -1;
 	}
 
@@ -1622,7 +1622,7 @@ int irlmp_unregister_client(void *handle)
 {
 	struct irlmp_client *client;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	if (!handle)
 		return -1;
@@ -1630,11 +1630,11 @@ int irlmp_unregister_client(void *handle)
 	/* Caller may call with invalid handle (it's legal) - Jean II */
 	client = hashbin_lock_find(irlmp->clients, (long) handle, NULL);
 	if (!client) {
-		IRDA_DEBUG(1, "%s(), Unknown client!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unknown client!\n", __func__);
 		return -1;
 	}
 
-	IRDA_DEBUG(4, "%s(), removing client!\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s(), removing client!\n", __func__);
 	hashbin_remove_this(irlmp->clients, (irda_queue_t *) client);
 	kfree(client);
 
@@ -1663,7 +1663,7 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return TRUE;);
 	IRDA_ASSERT(slsap_sel != LSAP_ANY, return TRUE;);
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 #ifdef CONFIG_IRDA_ULTRA
 	/* Accept all bindings to the connectionless LSAP */
@@ -1790,7 +1790,7 @@ static __u8 irlmp_find_free_slsap(void)
 			/* Make sure we terminate the loop */
 			if (wrapped++) {
 				IRDA_ERROR("%s: no more free LSAPs !\n",
-					   __FUNCTION__);
+					   __func__);
 				return 0;
 			}
 		}
@@ -1805,7 +1805,7 @@ static __u8 irlmp_find_free_slsap(void)
 	/* Got it ! */
 	lsap_sel = irlmp->last_lsap_sel;
 	IRDA_DEBUG(4, "%s(), found free lsap_sel=%02x\n",
-		   __FUNCTION__, lsap_sel);
+		   __func__, lsap_sel);
 
 	return lsap_sel;
 }
@@ -1823,26 +1823,26 @@ LM_REASON irlmp_convert_lap_reason( LAP_REASON lap_reason)
 
 	switch (lap_reason) {
 	case LAP_DISC_INDICATION: /* Received a disconnect request from peer */
-		IRDA_DEBUG( 1, "%s(), LAP_DISC_INDICATION\n", __FUNCTION__);
+		IRDA_DEBUG( 1, "%s(), LAP_DISC_INDICATION\n", __func__);
 		reason = LM_USER_REQUEST;
 		break;
 	case LAP_NO_RESPONSE:    /* To many retransmits without response */
-		IRDA_DEBUG( 1, "%s(), LAP_NO_RESPONSE\n", __FUNCTION__);
+		IRDA_DEBUG( 1, "%s(), LAP_NO_RESPONSE\n", __func__);
 		reason = LM_LAP_DISCONNECT;
 		break;
 	case LAP_RESET_INDICATION:
-		IRDA_DEBUG( 1, "%s(), LAP_RESET_INDICATION\n", __FUNCTION__);
+		IRDA_DEBUG( 1, "%s(), LAP_RESET_INDICATION\n", __func__);
 		reason = LM_LAP_RESET;
 		break;
 	case LAP_FOUND_NONE:
 	case LAP_MEDIA_BUSY:
 	case LAP_PRIMARY_CONFLICT:
-		IRDA_DEBUG(1, "%s(), LAP_FOUND_NONE, LAP_MEDIA_BUSY or LAP_PRIMARY_CONFLICT\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), LAP_FOUND_NONE, LAP_MEDIA_BUSY or LAP_PRIMARY_CONFLICT\n", __func__);
 		reason = LM_CONNECT_FAILURE;
 		break;
 	default:
 		IRDA_DEBUG(1, "%s(), Unknow IrLAP disconnect reason %d!\n",
-			   __FUNCTION__, lap_reason);
+			   __func__, lap_reason);
 		reason = LM_LAP_DISCONNECT;
 		break;
 	}
diff --git a/net/irda/irlmp_event.c b/net/irda/irlmp_event.c
index 150cd3f..78cce0c 100644
--- a/net/irda/irlmp_event.c
+++ b/net/irda/irlmp_event.c
@@ -120,7 +120,7 @@ static inline void irlmp_next_lap_state(struct lap_cb *self,
 					IRLMP_STATE state)
 {
 	/*
-	IRDA_DEBUG(4, "%s(), LMP LAP = %s\n", __FUNCTION__, irlmp_state[state]);
+	IRDA_DEBUG(4, "%s(), LMP LAP = %s\n", __func__, irlmp_state[state]);
 	*/
 	self->lap_state = state;
 }
@@ -130,7 +130,7 @@ static inline void irlmp_next_lsap_state(struct lsap_cb *self,
 {
 	/*
 	IRDA_ASSERT(self != NULL, return;);
-	IRDA_DEBUG(4, "%s(), LMP LSAP = %s\n", __FUNCTION__, irlsap_state[state]);
+	IRDA_DEBUG(4, "%s(), LMP LSAP = %s\n", __func__, irlsap_state[state]);
 	*/
 	self->lsap_state = state;
 }
@@ -143,7 +143,7 @@ int irlmp_do_lsap_event(struct lsap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	IRDA_DEBUG(4, "%s(), EVENT = %s, STATE = %s\n",
-		__FUNCTION__, irlmp_event[event], irlsap_state[ self->lsap_state]);
+		__func__, irlmp_event[event], irlsap_state[ self->lsap_state]);
 
 	return (*lsap_state[self->lsap_state]) (self, event, skb);
 }
@@ -160,7 +160,7 @@ void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s(), EVENT = %s, STATE = %s\n", __FUNCTION__,
+	IRDA_DEBUG(4, "%s(), EVENT = %s, STATE = %s\n", __func__,
 		   irlmp_event[event],
 		   irlmp_state[self->lap_state]);
 
@@ -169,7 +169,7 @@ void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event,
 
 void irlmp_discovery_timer_expired(void *data)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* We always cleanup the log (active & passive discovery) */
 	irlmp_do_expiry();
@@ -184,7 +184,7 @@ void irlmp_watchdog_timer_expired(void *data)
 {
 	struct lsap_cb *self = (struct lsap_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -196,7 +196,7 @@ void irlmp_idle_timer_expired(void *data)
 {
 	struct lap_cb *self = (struct lap_cb *) data;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
@@ -256,7 +256,7 @@ irlmp_do_all_lsap_event(hashbin_t *	lsap_hashbin,
 static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 	IRDA_ASSERT(self->irlap != NULL, return;);
 
 	switch (event) {
@@ -276,7 +276,7 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 		irlap_connect_response(self->irlap, skb);
 		break;
 	case LM_LAP_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s() LS_CONNECT_REQUEST\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s() LS_CONNECT_REQUEST\n", __func__);
 
 		irlmp_next_lap_state(self, LAP_U_CONNECT);
 
@@ -285,13 +285,13 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 		break;
 	case LM_LAP_DISCONNECT_INDICATION:
 		IRDA_DEBUG(4, "%s(), Error LM_LAP_DISCONNECT_INDICATION\n",
-			   __FUNCTION__);
+			   __func__);
 
 		irlmp_next_lap_state(self, LAP_STANDBY);
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			   __FUNCTION__, irlmp_event[event]);
+			   __func__, irlmp_event[event]);
 		break;
 	}
 }
@@ -306,7 +306,7 @@ static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 				  struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s(), event=%s\n", __FUNCTION__, irlmp_event[event]);
+	IRDA_DEBUG(2, "%s(), event=%s\n", __func__, irlmp_event[event]);
 
 	switch (event) {
 	case LM_LAP_CONNECT_INDICATION:
@@ -326,7 +326,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		 * the lsaps may already have gone. This avoid getting stuck
 		 * forever in LAP_ACTIVE state - Jean II */
 		if (HASHBIN_GET_SIZE(self->lsaps) == 0) {
-			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __FUNCTION__);
+			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __func__);
 			irlmp_start_idle_timer(self, LM_IDLE_TIMEOUT);
 		}
 		break;
@@ -344,12 +344,12 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		 * the lsaps may already have gone. This avoid getting stuck
 		 * forever in LAP_ACTIVE state - Jean II */
 		if (HASHBIN_GET_SIZE(self->lsaps) == 0) {
-			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __FUNCTION__);
+			IRDA_DEBUG(0, "%s() NO LSAPs !\n",  __func__);
 			irlmp_start_idle_timer(self, LM_IDLE_TIMEOUT);
 		}
 		break;
 	case LM_LAP_DISCONNECT_INDICATION:
-		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_INDICATION\n",  __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_INDICATION\n",  __func__);
 		irlmp_next_lap_state(self, LAP_STANDBY);
 
 		/* Send disconnect event to all LSAPs using this link */
@@ -357,7 +357,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 					LM_LAP_DISCONNECT_INDICATION);
 		break;
 	case LM_LAP_DISCONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_REQUEST\n",  __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), LM_LAP_DISCONNECT_REQUEST\n",  __func__);
 
 		/* One of the LSAP did timeout or was closed, if it was
 		 * the last one, try to get out of here - Jean II */
@@ -367,7 +367,7 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			 __FUNCTION__, irlmp_event[event]);
+			 __func__, irlmp_event[event]);
 		break;
 	}
 }
@@ -381,11 +381,11 @@ static void irlmp_state_u_connect(struct lap_cb *self, IRLMP_EVENT event,
 static void irlmp_state_active(struct lap_cb *self, IRLMP_EVENT event,
 			       struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	switch (event) {
 	case LM_LAP_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LS_CONNECT_REQUEST\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), LS_CONNECT_REQUEST\n", __func__);
 
 		/*
 		 * IrLAP may have a pending disconnect. We tried to close
@@ -468,7 +468,7 @@ static void irlmp_state_active(struct lap_cb *self, IRLMP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s\n",
-			 __FUNCTION__, irlmp_event[event]);
+			 __func__, irlmp_event[event]);
 		break;
 	}
 }
@@ -490,7 +490,7 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
@@ -505,11 +505,11 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 #endif /* CONFIG_IRDA_ULTRA */
 	case LM_CONNECT_REQUEST:
-		IRDA_DEBUG(4, "%s(), LM_CONNECT_REQUEST\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), LM_CONNECT_REQUEST\n", __func__);
 
 		if (self->conn_skb) {
 			IRDA_WARNING("%s: busy with another request!\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 		/* Don't forget to refcount it (see irlmp_connect_request()) */
@@ -526,7 +526,7 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_CONNECT_INDICATION:
 		if (self->conn_skb) {
 			IRDA_WARNING("%s: busy with another request!\n",
-				     __FUNCTION__);
+				     __func__);
 			return -EBUSY;
 		}
 		/* Don't forget to refcount it (see irlap_driver_rcv()) */
@@ -552,7 +552,7 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(1, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -570,7 +570,7 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	struct lsap_cb *lsap;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
@@ -603,7 +603,7 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_WATCHDOG_TIMEOUT:
 		/* May happen, who knows...
 		 * Jean II */
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __FUNCTION__);
+		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __func__);
 
 		/* Disconnect, get out... - Jean II */
 		self->lap = NULL;
@@ -614,7 +614,7 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 		/* LM_LAP_DISCONNECT_INDICATION : Should never happen, we
 		 * are *not* yet bound to the IrLAP link. Jean II */
 		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -632,7 +632,7 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	struct sk_buff *tx_skb;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
@@ -643,16 +643,16 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	case LM_CONNECT_RESPONSE:
 		IRDA_DEBUG(0, "%s(), LM_CONNECT_RESPONSE, "
-			   "no indication issued yet\n",  __FUNCTION__);
+			   "no indication issued yet\n",  __func__);
 		/* Keep state */
 		break;
 	case LM_DISCONNECT_REQUEST:
 		IRDA_DEBUG(0, "%s(), LM_DISCONNECT_REQUEST, "
-			   "not yet bound to IrLAP connection\n",  __FUNCTION__);
+			   "not yet bound to IrLAP connection\n",  __func__);
 		/* Keep state */
 		break;
 	case LM_LAP_CONNECT_CONFIRM:
-		IRDA_DEBUG(4, "%s(), LS_CONNECT_CONFIRM\n",  __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), LS_CONNECT_CONFIRM\n",  __func__);
 		irlmp_next_lsap_state(self, LSAP_CONNECT);
 
 		tx_skb = self->conn_skb;
@@ -666,7 +666,7 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		/* Will happen in some rare cases because of a race condition.
 		 * Just make sure we don't stay there forever...
 		 * Jean II */
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __FUNCTION__);
+		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n",  __func__);
 
 		/* Go back to disconnected mode, keep the socket waiting */
 		self->lap = NULL;
@@ -680,7 +680,7 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		/* LM_LAP_DISCONNECT_INDICATION : Should never happen, we
 		 * are *not* yet bound to the IrLAP link. Jean II */
 		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -698,7 +698,7 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
@@ -722,12 +722,12 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	case LM_CONNECT_REQUEST:
 		IRDA_DEBUG(0, "%s(), LM_CONNECT_REQUEST, "
-			   "error, LSAP already connected\n", __FUNCTION__);
+			   "error, LSAP already connected\n", __func__);
 		/* Keep state */
 		break;
 	case LM_CONNECT_RESPONSE:
 		IRDA_DEBUG(0, "%s(), LM_CONNECT_RESPONSE, "
-			   "error, LSAP already connected\n", __FUNCTION__);
+			   "error, LSAP already connected\n", __func__);
 		/* Keep state */
 		break;
 	case LM_DISCONNECT_REQUEST:
@@ -740,7 +740,7 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		/* Try to close the LAP connection if its still there */
 		if (self->lap) {
 			IRDA_DEBUG(4, "%s(), trying to close IrLAP\n",
-				   __FUNCTION__);
+				   __func__);
 			irlmp_do_lap_event(self->lap,
 					   LM_LAP_DISCONNECT_REQUEST,
 					   NULL);
@@ -764,14 +764,14 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		reason = skb->data[3];
 
 		 /* Try to close the LAP connection */
-		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n", __func__);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 
 		irlmp_disconnect_indication(self, reason, skb);
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -793,7 +793,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	switch (event) {
 	case LM_CONNECT_CONFIRM:
@@ -814,7 +814,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		reason = skb->data[3];
 
 		 /* Try to close the LAP connection */
-		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n",  __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), trying to close IrLAP\n",  __func__);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 
 		irlmp_disconnect_indication(self, reason, skb);
@@ -832,7 +832,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_disconnect_indication(self, reason, skb);
 		break;
 	case LM_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s() WATCHDOG_TIMEOUT!\n", __func__);
 
 		IRDA_ASSERT(self->lap != NULL, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
@@ -842,7 +842,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
@@ -863,7 +863,7 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(irlmp != NULL, return -1;);
@@ -883,7 +883,7 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_next_lsap_state(self, LSAP_SETUP);
 		break;
 	case LM_WATCHDOG_TIMEOUT:
-		IRDA_DEBUG(0, "%s() : WATCHDOG_TIMEOUT !\n",  __FUNCTION__);
+		IRDA_DEBUG(0, "%s() : WATCHDOG_TIMEOUT !\n",  __func__);
 
 		IRDA_ASSERT(self->lap != NULL, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
@@ -902,7 +902,7 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown event %s on LSAP %#02x\n",
-			   __FUNCTION__, irlmp_event[event], self->slsap_sel);
+			   __func__, irlmp_event[event], self->slsap_sel);
 		break;
 	}
 	return ret;
diff --git a/net/irda/irlmp_frame.c b/net/irda/irlmp_frame.c
index 0a79d9a..3750884 100644
--- a/net/irda/irlmp_frame.c
+++ b/net/irda/irlmp_frame.c
@@ -44,7 +44,7 @@ inline void irlmp_send_data_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 	skb->data[1] = slsap;
 
 	if (expedited) {
-		IRDA_DEBUG(4, "%s(), sending expedited data\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), sending expedited data\n", __func__);
 		irlap_data_request(self->irlap, skb, TRUE);
 	} else
 		irlap_data_request(self->irlap, skb, FALSE);
@@ -60,7 +60,7 @@ void irlmp_send_lcf_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 {
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
@@ -95,7 +95,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	__u8   dlsap_sel;   /* Destination LSAP address */
 	__u8   *fp;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
@@ -117,7 +117,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	if ((fp[0] & CONTROL_BIT) && (fp[2] == CONNECT_CMD)) {
 		IRDA_DEBUG(3, "%s(), incoming connection, "
 			   "source LSAP=%d, dest LSAP=%d\n",
-			   __FUNCTION__, slsap_sel, dlsap_sel);
+			   __func__, slsap_sel, dlsap_sel);
 
 		/* Try to find LSAP among the unconnected LSAPs */
 		lsap = irlmp_find_lsap(self, dlsap_sel, slsap_sel, CONNECT_CMD,
@@ -125,7 +125,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 
 		/* Maybe LSAP was already connected, so try one more time */
 		if (!lsap) {
-			IRDA_DEBUG(1, "%s(), incoming connection for LSAP already connected\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), incoming connection for LSAP already connected\n", __func__);
 			lsap = irlmp_find_lsap(self, dlsap_sel, slsap_sel, 0,
 					       self->lsaps);
 		}
@@ -136,12 +136,12 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	if (lsap == NULL) {
 		IRDA_DEBUG(2, "IrLMP, Sorry, no LSAP for received frame!\n");
 		IRDA_DEBUG(2, "%s(), slsap_sel = %02x, dlsap_sel = %02x\n",
-			   __FUNCTION__, slsap_sel, dlsap_sel);
+			   __func__, slsap_sel, dlsap_sel);
 		if (fp[0] & CONTROL_BIT) {
 			IRDA_DEBUG(2, "%s(), received control frame %02x\n",
-				   __FUNCTION__, fp[2]);
+				   __func__, fp[2]);
 		} else {
-			IRDA_DEBUG(2, "%s(), received data frame\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), received data frame\n", __func__);
 		}
 		return;
 	}
@@ -160,7 +160,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 			break;
 		case DISCONNECT:
 			IRDA_DEBUG(4, "%s(), Disconnect indication!\n",
-				   __FUNCTION__);
+				   __func__);
 			irlmp_do_lsap_event(lsap, LM_DISCONNECT_INDICATION,
 					    skb);
 			break;
@@ -172,7 +172,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 			break;
 		default:
 			IRDA_DEBUG(0, "%s(), Unknown control frame %02x\n",
-				   __FUNCTION__, fp[2]);
+				   __func__, fp[2]);
 			break;
 		}
 	} else if (unreliable) {
@@ -206,7 +206,7 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	__u8   *fp;
 	unsigned long flags;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
@@ -224,13 +224,13 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 
 	if (pid & 0x80) {
 		IRDA_DEBUG(0, "%s(), extension in PID not supp!\n",
-			   __FUNCTION__);
+			   __func__);
 		return;
 	}
 
 	/* Check if frame is addressed to the connectionless LSAP */
 	if ((slsap_sel != LSAP_CONNLESS) || (dlsap_sel != LSAP_CONNLESS)) {
-		IRDA_DEBUG(0, "%s(), dropping frame!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), dropping frame!\n", __func__);
 		return;
 	}
 
@@ -254,7 +254,7 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	if (lsap)
 		irlmp_connless_data_indication(lsap, skb);
 	else {
-		IRDA_DEBUG(0, "%s(), found no matching LSAP!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), found no matching LSAP!\n", __func__);
 	}
 }
 #endif /* CONFIG_IRDA_ULTRA */
@@ -270,7 +270,7 @@ void irlmp_link_disconnect_indication(struct lap_cb *lap,
 				      LAP_REASON reason,
 				      struct sk_buff *skb)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(lap != NULL, return;);
 	IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return;);
@@ -296,7 +296,7 @@ void irlmp_link_connect_indication(struct lap_cb *self, __u32 saddr,
 				   __u32 daddr, struct qos_info *qos,
 				   struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* Copy QoS settings for this session */
 	self->qos = qos;
@@ -317,7 +317,7 @@ void irlmp_link_connect_indication(struct lap_cb *self, __u32 saddr,
 void irlmp_link_connect_confirm(struct lap_cb *self, struct qos_info *qos,
 				struct sk_buff *skb)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
@@ -383,7 +383,7 @@ void irlmp_link_discovery_indication(struct lap_cb *self,
  */
 void irlmp_link_discovery_confirm(struct lap_cb *self, hashbin_t *log)
 {
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
diff --git a/net/irda/irmod.c b/net/irda/irmod.c
index 01554b9..4c487a8 100644
--- a/net/irda/irmod.c
+++ b/net/irda/irmod.c
@@ -90,7 +90,7 @@ static int __init irda_init(void)
 {
 	int ret = 0;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s()\n", __func__);
 
 	/* Lower layer of the stack */
 	irlmp_init();
diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index bc2e15c..a00e422 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -337,27 +337,27 @@
 /* All error messages (will show up in the normal logs) */
 #define DERROR(dbg, format, args...) \
 	{if(DEBUG_##dbg) \
-		printk(KERN_INFO "irnet: %s(): " format, __FUNCTION__ , ##args);}
+		printk(KERN_INFO "irnet: %s(): " format, __func__ , ##args);}
 
 /* Normal debug message (will show up in /var/log/debug) */
 #define DEBUG(dbg, format, args...) \
 	{if(DEBUG_##dbg) \
-		printk(KERN_DEBUG "irnet: %s(): " format, __FUNCTION__ , ##args);}
+		printk(KERN_DEBUG "irnet: %s(): " format, __func__ , ##args);}
 
 /* Entering a function (trace) */
 #define DENTER(dbg, format, args...) \
 	{if(DEBUG_##dbg) \
-		printk(KERN_DEBUG "irnet: -> %s" format, __FUNCTION__ , ##args);}
+		printk(KERN_DEBUG "irnet: -> %s" format, __func__ , ##args);}
 
 /* Entering and exiting a function in one go (trace) */
 #define DPASS(dbg, format, args...) \
 	{if(DEBUG_##dbg) \
-		printk(KERN_DEBUG "irnet: <>%s" format, __FUNCTION__ , ##args);}
+		printk(KERN_DEBUG "irnet: <>%s" format, __func__ , ##args);}
 
 /* Exiting a function (trace) */
 #define DEXIT(dbg, format, args...) \
 	{if(DEBUG_##dbg) \
-		printk(KERN_DEBUG "irnet: <-%s()" format, __FUNCTION__ , ##args);}
+		printk(KERN_DEBUG "irnet: <-%s()" format, __func__ , ##args);}
 
 /* Exit a function with debug */
 #define DRETURN(ret, dbg, args...) \
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index cd9ff17..9e1fb82 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -40,7 +40,7 @@ static struct net_device * ifname_to_netdev(struct net *net, struct genl_info *i
 
 	ifname = nla_data(info->attrs[IRDA_NL_ATTR_IFNAME]);
 
-	IRDA_DEBUG(5, "%s(): Looking for %s\n", __FUNCTION__, ifname);
+	IRDA_DEBUG(5, "%s(): Looking for %s\n", __func__, ifname);
 
 	return dev_get_by_name(net, ifname);
 }
@@ -56,7 +56,7 @@ static int irda_nl_set_mode(struct sk_buff *skb, struct genl_info *info)
 
 	mode = nla_get_u32(info->attrs[IRDA_NL_ATTR_MODE]);
 
-	IRDA_DEBUG(5, "%s(): Switching to mode: %d\n", __FUNCTION__, mode);
+	IRDA_DEBUG(5, "%s(): Switching to mode: %d\n", __func__, mode);
 
 	dev = ifname_to_netdev(&init_net, info);
 	if (!dev)
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index 40c28ef..ba01938 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -232,7 +232,7 @@ static __u32 hash( const char* name)
 static void enqueue_first(irda_queue_t **queue, irda_queue_t* element)
 {
 
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	/*
 	 * Check if queue is empty.
@@ -451,7 +451,7 @@ void hashbin_insert(hashbin_t* hashbin, irda_queue_t* entry, long hashv,
 	unsigned long flags = 0;
 	int bin;
 
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	IRDA_ASSERT( hashbin != NULL, return;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return;);
@@ -564,7 +564,7 @@ void* hashbin_remove( hashbin_t* hashbin, long hashv, const char* name)
 	unsigned long flags = 0;
 	irda_queue_t* entry;
 
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	IRDA_ASSERT( hashbin != NULL, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
@@ -657,7 +657,7 @@ void* hashbin_remove_this( hashbin_t* hashbin, irda_queue_t* entry)
 	int	bin;
 	long	hashv;
 
-	IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG( 4, "%s()\n", __func__);
 
 	IRDA_ASSERT( hashbin != NULL, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 97db158..74e439e 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -95,7 +95,7 @@ int __init irttp_init(void)
 	irttp->tsaps = hashbin_new(HB_LOCK);
 	if (!irttp->tsaps) {
 		IRDA_ERROR("%s: can't allocate IrTTP hashbin!\n",
-			   __FUNCTION__);
+			   __func__);
 		kfree(irttp);
 		return -ENOMEM;
 	}
@@ -164,7 +164,7 @@ static void irttp_todo_expired(unsigned long data)
 	if (!self || self->magic != TTP_TSAP_MAGIC)
 		return;
 
-	IRDA_DEBUG(4, "%s(instance=%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(4, "%s(instance=%p)\n", __func__, self);
 
 	/* Try to make some progress, especially on Tx side - Jean II */
 	irttp_run_rx_queue(self);
@@ -205,7 +205,7 @@ void irttp_flush_queues(struct tsap_cb *self)
 {
 	struct sk_buff* skb;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
@@ -238,7 +238,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	IRDA_ASSERT(self != NULL, return NULL;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return NULL;);
 
-	IRDA_DEBUG(2, "%s(), self->rx_sdu_size=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), self->rx_sdu_size=%d\n", __func__,
 		   self->rx_sdu_size);
 
 	skb = dev_alloc_skb(TTP_HEADER + self->rx_sdu_size);
@@ -264,7 +264,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 
 	IRDA_DEBUG(2,
 		   "%s(), frame len=%d, rx_sdu_size=%d, rx_max_sdu_size=%d\n",
-		   __FUNCTION__, n, self->rx_sdu_size, self->rx_max_sdu_size);
+		   __func__, n, self->rx_sdu_size, self->rx_max_sdu_size);
 	/* Note : irttp_run_rx_queue() calculate self->rx_sdu_size
 	 * by summing the size of all fragments, so we should always
 	 * have n == self->rx_sdu_size, except in cases where we
@@ -293,7 +293,7 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 	struct sk_buff *frag;
 	__u8 *frame;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
@@ -303,7 +303,7 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 	 *  Split frame into a number of segments
 	 */
 	while (skb->len > self->max_seg_size) {
-		IRDA_DEBUG(2, "%s(), fragmenting ...\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(), fragmenting ...\n", __func__);
 
 		/* Make new segment */
 		frag = alloc_skb(self->max_seg_size+self->max_header_size,
@@ -328,7 +328,7 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 		skb_queue_tail(&self->tx_queue, frag);
 	}
 	/* Queue what is left of the original skb */
-	IRDA_DEBUG(2, "%s(), queuing last segment\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), queuing last segment\n", __func__);
 
 	frame = skb_push(skb, TTP_HEADER);
 	frame[0] = 0x00; /* Clear more bit */
@@ -359,7 +359,7 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 	else
 		self->tx_max_sdu_size = param->pv.i;
 
-	IRDA_DEBUG(1, "%s(), MaxSduSize=%d\n", __FUNCTION__, param->pv.i);
+	IRDA_DEBUG(1, "%s(), MaxSduSize=%d\n", __func__, param->pv.i);
 
 	return 0;
 }
@@ -400,13 +400,13 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 * JeanII */
 	if((stsap_sel != LSAP_ANY) &&
 	   ((stsap_sel < 0x01) || (stsap_sel >= 0x70))) {
-		IRDA_DEBUG(0, "%s(), invalid tsap!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), invalid tsap!\n", __func__);
 		return NULL;
 	}
 
 	self = kzalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
 	if (self == NULL) {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unable to kmalloc!\n", __func__);
 		return NULL;
 	}
 
@@ -438,7 +438,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 */
 	lsap = irlmp_open_lsap(stsap_sel, &ttp_notify, 0);
 	if (lsap == NULL) {
-		IRDA_WARNING("%s: unable to allocate LSAP!!\n", __FUNCTION__);
+		IRDA_WARNING("%s: unable to allocate LSAP!!\n", __func__);
 		return NULL;
 	}
 
@@ -448,7 +448,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 *  the stsap_sel we have might not be valid anymore
 	 */
 	self->stsap_sel = lsap->slsap_sel;
-	IRDA_DEBUG(4, "%s(), stsap_sel=%02x\n", __FUNCTION__, self->stsap_sel);
+	IRDA_DEBUG(4, "%s(), stsap_sel=%02x\n", __func__, self->stsap_sel);
 
 	self->notify = *notify;
 	self->lsap = lsap;
@@ -506,7 +506,7 @@ int irttp_close_tsap(struct tsap_cb *self)
 {
 	struct tsap_cb *tsap;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
@@ -516,7 +516,7 @@ int irttp_close_tsap(struct tsap_cb *self)
 		/* Check if disconnect is not pending */
 		if (!test_bit(0, &self->disconnect_pend)) {
 			IRDA_WARNING("%s: TSAP still connected!\n",
-				     __FUNCTION__);
+				     __func__);
 			irttp_disconnect_request(self, NULL, P_NORMAL);
 		}
 		self->close_pend = TRUE;
@@ -553,18 +553,18 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* Check that nothing bad happens */
 	if ((skb->len == 0) || (!self->connected)) {
 		IRDA_DEBUG(1, "%s(), No data, or not connected\n",
-			   __FUNCTION__);
+			   __func__);
 		goto err;
 	}
 
 	if (skb->len > self->max_seg_size) {
 		IRDA_DEBUG(1, "%s(), UData is too large for IrLAP!\n",
-			   __FUNCTION__);
+			   __func__);
 		goto err;
 	}
 
@@ -595,12 +595,12 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s() : queue len = %d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s() : queue len = %d\n", __func__,
 		   skb_queue_len(&self->tx_queue));
 
 	/* Check that nothing bad happens */
 	if ((skb->len == 0) || (!self->connected)) {
-		IRDA_WARNING("%s: No data, or not connected\n", __FUNCTION__);
+		IRDA_WARNING("%s: No data, or not connected\n", __func__);
 		ret = -ENOTCONN;
 		goto err;
 	}
@@ -611,7 +611,7 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	 */
 	if ((self->tx_max_sdu_size == 0) && (skb->len > self->max_seg_size)) {
 		IRDA_ERROR("%s: SAR disabled, and data is too large for IrLAP!\n",
-			   __FUNCTION__);
+			   __func__);
 		ret = -EMSGSIZE;
 		goto err;
 	}
@@ -625,7 +625,7 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	    (skb->len > self->tx_max_sdu_size))
 	{
 		IRDA_ERROR("%s: SAR enabled, but data is larger than TxMaxSduSize!\n",
-			   __FUNCTION__);
+			   __func__);
 		ret = -EMSGSIZE;
 		goto err;
 	}
@@ -704,7 +704,7 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 	int n;
 
 	IRDA_DEBUG(2, "%s() : send_credit = %d, queue_len = %d\n",
-		   __FUNCTION__,
+		   __func__,
 		   self->send_credit, skb_queue_len(&self->tx_queue));
 
 	/* Get exclusive access to the tx queue, otherwise don't touch it */
@@ -813,7 +813,7 @@ static inline void irttp_give_credit(struct tsap_cb *self)
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	IRDA_DEBUG(4, "%s() send=%d,avail=%d,remote=%d\n",
-		   __FUNCTION__,
+		   __func__,
 		   self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Give credit to peer */
@@ -862,7 +862,7 @@ static int irttp_udata_indication(void *instance, void *sap,
 	struct tsap_cb *self;
 	int err;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	self = (struct tsap_cb *) instance;
 
@@ -979,7 +979,7 @@ static void irttp_status_indication(void *instance,
 {
 	struct tsap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	self = (struct tsap_cb *) instance;
 
@@ -997,7 +997,7 @@ static void irttp_status_indication(void *instance,
 		self->notify.status_indication(self->notify.instance,
 					       link, lock);
 	else
-		IRDA_DEBUG(2, "%s(), no handler\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(), no handler\n", __func__);
 }
 
 /*
@@ -1015,7 +1015,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
-	IRDA_DEBUG(4, "%s(instance=%p)\n", __FUNCTION__, self);
+	IRDA_DEBUG(4, "%s(instance=%p)\n", __func__, self);
 
 	/* We are "polled" directly from LAP, and the LAP want to fill
 	 * its Tx window. We want to do our best to send it data, so that
@@ -1053,18 +1053,18 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
  */
 void irttp_flow_request(struct tsap_cb *self, LOCAL_FLOW flow)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	switch (flow) {
 	case FLOW_STOP:
-		IRDA_DEBUG(1, "%s(), flow stop\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), flow stop\n", __func__);
 		self->rx_sdu_busy = TRUE;
 		break;
 	case FLOW_START:
-		IRDA_DEBUG(1, "%s(), flow start\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), flow start\n", __func__);
 		self->rx_sdu_busy = FALSE;
 
 		/* Client say he can accept more data, try to free our
@@ -1073,7 +1073,7 @@ void irttp_flow_request(struct tsap_cb *self, LOCAL_FLOW flow)
 
 		break;
 	default:
-		IRDA_DEBUG(1, "%s(), Unknown flow command!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), Unknown flow command!\n", __func__);
 	}
 }
 EXPORT_SYMBOL(irttp_flow_request);
@@ -1093,7 +1093,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	__u8 *frame;
 	__u8 n;
 
-	IRDA_DEBUG(4, "%s(), max_sdu_size=%d\n", __FUNCTION__, max_sdu_size);
+	IRDA_DEBUG(4, "%s(), max_sdu_size=%d\n", __func__, max_sdu_size);
 
 	IRDA_ASSERT(self != NULL, return -EBADR;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -EBADR;);
@@ -1191,7 +1191,7 @@ static void irttp_connect_confirm(void *instance, void *sap,
 	__u8 plen;
 	__u8 n;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	self = (struct tsap_cb *) instance;
 
@@ -1215,7 +1215,7 @@ static void irttp_connect_confirm(void *instance, void *sap,
 
 	n = skb->data[0] & 0x7f;
 
-	IRDA_DEBUG(4, "%s(), Initial send_credit=%d\n", __FUNCTION__, n);
+	IRDA_DEBUG(4, "%s(), Initial send_credit=%d\n", __func__, n);
 
 	self->send_credit = n;
 	self->tx_max_sdu_size = 0;
@@ -1236,7 +1236,7 @@ static void irttp_connect_confirm(void *instance, void *sap,
 		/* Any errors in the parameter list? */
 		if (ret < 0) {
 			IRDA_WARNING("%s: error extracting parameters\n",
-				     __FUNCTION__);
+				     __func__);
 			dev_kfree_skb(skb);
 
 			/* Do not accept this connection attempt */
@@ -1246,10 +1246,10 @@ static void irttp_connect_confirm(void *instance, void *sap,
 		skb_pull(skb, IRDA_MIN(skb->len, plen+1));
 	}
 
-	IRDA_DEBUG(4, "%s() send=%d,avail=%d,remote=%d\n", __FUNCTION__,
+	IRDA_DEBUG(4, "%s() send=%d,avail=%d,remote=%d\n", __func__,
 	      self->send_credit, self->avail_credit, self->remote_credit);
 
-	IRDA_DEBUG(2, "%s(), MaxSduSize=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), MaxSduSize=%d\n", __func__,
 		   self->tx_max_sdu_size);
 
 	if (self->notify.connect_confirm) {
@@ -1288,7 +1288,7 @@ void irttp_connect_indication(void *instance, void *sap, struct qos_info *qos,
 	self->max_seg_size = max_seg_size - TTP_HEADER;
 	self->max_header_size = max_header_size+TTP_HEADER;
 
-	IRDA_DEBUG(4, "%s(), TSAP sel=%02x\n", __FUNCTION__, self->stsap_sel);
+	IRDA_DEBUG(4, "%s(), TSAP sel=%02x\n", __func__, self->stsap_sel);
 
 	/* Need to update dtsap_sel if its equal to LSAP_ANY */
 	self->dtsap_sel = lsap->dlsap_sel;
@@ -1313,7 +1313,7 @@ void irttp_connect_indication(void *instance, void *sap, struct qos_info *qos,
 		/* Any errors in the parameter list? */
 		if (ret < 0) {
 			IRDA_WARNING("%s: error extracting parameters\n",
-				     __FUNCTION__);
+				     __func__);
 			dev_kfree_skb(skb);
 
 			/* Do not accept this connection attempt */
@@ -1350,7 +1350,7 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
-	IRDA_DEBUG(4, "%s(), Source TSAP selector=%02x\n", __FUNCTION__,
+	IRDA_DEBUG(4, "%s(), Source TSAP selector=%02x\n", __func__,
 		   self->stsap_sel);
 
 	/* Any userdata supplied? */
@@ -1432,14 +1432,14 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	struct tsap_cb *new;
 	unsigned long flags;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	/* Protect our access to the old tsap instance */
 	spin_lock_irqsave(&irttp->tsaps->hb_spinlock, flags);
 
 	/* Find the old instance */
 	if (!hashbin_find(irttp->tsaps, (long) orig, NULL)) {
-		IRDA_DEBUG(0, "%s(), unable to find TSAP\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unable to find TSAP\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
@@ -1447,7 +1447,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
 	if (!new) {
-		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
@@ -1460,7 +1460,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	/* Try to dup the LSAP (may fail if we were too slow) */
 	new->lsap = irlmp_dup(orig->lsap, new);
 	if (!new->lsap) {
-		IRDA_DEBUG(0, "%s(), dup failed!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
 		kfree(new);
 		return NULL;
 	}
@@ -1495,7 +1495,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 
 	/* Already disconnected? */
 	if (!self->connected) {
-		IRDA_DEBUG(4, "%s(), already disconnected!\n", __FUNCTION__);
+		IRDA_DEBUG(4, "%s(), already disconnected!\n", __func__);
 		if (userdata)
 			dev_kfree_skb(userdata);
 		return -1;
@@ -1508,7 +1508,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 	 * Jean II */
 	if(test_and_set_bit(0, &self->disconnect_pend)) {
 		IRDA_DEBUG(0, "%s(), disconnect already pending\n",
-			   __FUNCTION__);
+			   __func__);
 		if (userdata)
 			dev_kfree_skb(userdata);
 
@@ -1527,7 +1527,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 			 *  disconnecting right now since the data will
 			 *  not have any usable connection to be sent on
 			 */
-			IRDA_DEBUG(1, "%s(): High priority!!()\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(): High priority!!()\n", __func__);
 			irttp_flush_queues(self);
 		} else if (priority == P_NORMAL) {
 			/*
@@ -1548,7 +1548,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 	 * be sent at the LMP level (so even if the peer has its Tx queue
 	 * full of data). - Jean II */
 
-	IRDA_DEBUG(1, "%s(), Disconnecting ...\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s(), Disconnecting ...\n", __func__);
 	self->connected = FALSE;
 
 	if (!userdata) {
@@ -1584,7 +1584,7 @@ void irttp_disconnect_indication(void *instance, void *sap, LM_REASON reason,
 {
 	struct tsap_cb *self;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	self = (struct tsap_cb *) instance;
 
@@ -1644,7 +1644,7 @@ static void irttp_do_data_indication(struct tsap_cb *self, struct sk_buff *skb)
 	 * give an error back
 	 */
 	if (err) {
-		IRDA_DEBUG(0, "%s() requeueing skb!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s() requeueing skb!\n", __func__);
 
 		/* Make sure we take a break */
 		self->rx_sdu_busy = TRUE;
@@ -1669,7 +1669,7 @@ void irttp_run_rx_queue(struct tsap_cb *self)
 	struct sk_buff *skb;
 	int more = 0;
 
-	IRDA_DEBUG(2, "%s() send=%d,avail=%d,remote=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s() send=%d,avail=%d,remote=%d\n", __func__,
 		   self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Get exclusive access to the rx queue, otherwise don't touch it */
@@ -1710,7 +1710,7 @@ void irttp_run_rx_queue(struct tsap_cb *self)
 			 */
 			if (self->rx_sdu_size <= self->rx_max_sdu_size) {
 				IRDA_DEBUG(4, "%s(), queueing frag\n",
-					   __FUNCTION__);
+					   __func__);
 				skb_queue_tail(&self->rx_fragments, skb);
 			} else {
 				/* Free the part of the SDU that is too big */
@@ -1740,7 +1740,7 @@ void irttp_run_rx_queue(struct tsap_cb *self)
 			/* Now we can deliver the reassembled skb */
 			irttp_do_data_indication(self, skb);
 		} else {
-			IRDA_DEBUG(1, "%s(), Truncated frame\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), Truncated frame\n", __func__);
 
 			/* Free the part of the SDU that is too big */
 			dev_kfree_skb(skb);
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 722bbe0..fc1a205 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -148,23 +148,23 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 	 */
 	if (p.pl == 0) {
 		if (p.pv.i < 0xff) {
-			IRDA_DEBUG(2, "%s(), using 1 byte\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), using 1 byte\n", __func__);
 			p.pl = 1;
 		} else if (p.pv.i < 0xffff) {
-			IRDA_DEBUG(2, "%s(), using 2 bytes\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), using 2 bytes\n", __func__);
 			p.pl = 2;
 		} else {
-			IRDA_DEBUG(2, "%s(), using 4 bytes\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), using 4 bytes\n", __func__);
 			p.pl = 4; /* Default length */
 		}
 	}
 	/* Check if buffer is long enough for insertion */
 	if (len < (2+p.pl)) {
 		IRDA_WARNING("%s: buffer too short for insertion!\n",
-			     __FUNCTION__);
+			     __func__);
 		return -1;
 	}
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
 		   p.pi, p.pl, p.pv.i);
 	switch (p.pl) {
 	case 1:
@@ -187,7 +187,7 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 		break;
 	default:
 		IRDA_WARNING("%s: length %d not supported\n",
-			     __FUNCTION__, p.pl);
+			     __func__, p.pl);
 		/* Skip parameter */
 		return -1;
 	}
@@ -218,7 +218,7 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 	if (len < (2+p.pl)) {
 		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
-			     __FUNCTION__, p.pl, len);
+			     __func__, p.pl, len);
 		return -1;
 	}
 
@@ -230,7 +230,7 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 	if (((type & PV_MASK) != PV_INTEGER) && ((type & PV_MASK) != p.pl)) {
 		IRDA_ERROR("%s: invalid parameter length! "
 			   "Expected %d bytes, but value had %d bytes!\n",
-			   __FUNCTION__, type & PV_MASK, p.pl);
+			   __func__, type & PV_MASK, p.pl);
 
 		/* Most parameters are bit/byte fields or little endian,
 		 * so it's ok to only extract a subset of it (the subset
@@ -268,13 +268,13 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 		break;
 	default:
 		IRDA_WARNING("%s: length %d not supported\n",
-			     __FUNCTION__, p.pl);
+			     __func__, p.pl);
 
 		/* Skip parameter */
 		return p.pl+2;
 	}
 
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
 		   p.pi, p.pl, p.pv.i);
 	/* Call handler for this parameter */
 	err = (*func)(self, &p, PV_PUT);
@@ -294,19 +294,19 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 	irda_param_t p;
 	int err;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	p.pi = pi;     /* In case handler needs to know */
 	p.pl = buf[1]; /* Extract length of value */
 
-	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d\n", __func__,
 		   p.pi, p.pl);
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
 		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
-			     __FUNCTION__, p.pl, len);
+			     __func__, p.pl, len);
 		return -1;
 	}
 
@@ -314,7 +314,7 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 	 * checked that the buffer is long enough */
 	strncpy(str, buf+2, p.pl);
 
-	IRDA_DEBUG(2, "%s(), str=0x%02x 0x%02x\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), str=0x%02x 0x%02x\n", __func__,
 		   (__u8) str[0], (__u8) str[1]);
 
 	/* Null terminate string */
@@ -345,11 +345,11 @@ static int irda_extract_octseq(void *self, __u8 *buf, int len, __u8 pi,
 	if (len < (2+p.pl)) {
 		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
-			     __FUNCTION__, p.pl, len);
+			     __func__, p.pl, len);
 		return -1;
 	}
 
-	IRDA_DEBUG(0, "%s(), not impl\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), not impl\n", __func__);
 
 	return p.pl+2; /* Extracted pl+2 bytes */
 }
@@ -473,7 +473,7 @@ int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 	    (pi_minor > info->tables[pi_major].len-1))
 	{
 		IRDA_DEBUG(0, "%s(), no handler for parameter=0x%02x\n",
-			   __FUNCTION__, pi);
+			   __func__, pi);
 
 		/* Skip this parameter */
 		return -1;
@@ -487,7 +487,7 @@ int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 
 	/*  Check if handler has been implemented */
 	if (!pi_minor_info->func) {
-		IRDA_MESSAGE("%s: no handler for pi=%#x\n", __FUNCTION__, pi);
+		IRDA_MESSAGE("%s: no handler for pi=%#x\n", __func__, pi);
 		/* Skip this parameter */
 		return -1;
 	}
@@ -527,7 +527,7 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 	    (pi_minor > info->tables[pi_major].len-1))
 	{
 		IRDA_DEBUG(0, "%s(), no handler for parameter=0x%02x\n",
-			   __FUNCTION__, buf[0]);
+			   __func__, buf[0]);
 
 		/* Skip this parameter */
 		return 2 + buf[n + 1];  /* Continue */
@@ -539,13 +539,13 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 	/* Find expected data type for this parameter identifier (pi)*/
 	type = pi_minor_info->type;
 
-	IRDA_DEBUG(3, "%s(), pi=[%d,%d], type=%d\n", __FUNCTION__,
+	IRDA_DEBUG(3, "%s(), pi=[%d,%d], type=%d\n", __func__,
 		   pi_major, pi_minor, type);
 
 	/*  Check if handler has been implemented */
 	if (!pi_minor_info->func) {
 		IRDA_MESSAGE("%s: no handler for pi=%#x\n",
-			     __FUNCTION__, buf[n]);
+			     __func__, buf[n]);
 		/* Skip this parameter */
 		return 2 + buf[n + 1]; /* Continue */
 	}
diff --git a/net/irda/qos.c b/net/irda/qos.c
index aeb18cf..2b00974 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -201,7 +201,7 @@ static int msb_index (__u16 word)
 	 * it's very likely the peer. - Jean II */
 	if (word == 0) {
 		IRDA_WARNING("%s(), Detected buggy peer, adjust null PV to 0x1!\n",
-			 __FUNCTION__);
+			 __func__);
 		/* The only safe choice (we don't know the array size) */
 		word = 0x1;
 	}
@@ -342,7 +342,7 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	__u32 line_capacity;
 	int index;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/*
 	 * Make sure the mintt is sensible.
@@ -352,7 +352,7 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 		int i;
 
 		IRDA_WARNING("%s(), Detected buggy peer, adjust mtt to %dus!\n",
-			 __FUNCTION__, sysctl_min_tx_turn_time);
+			 __func__, sysctl_min_tx_turn_time);
 
 		/* We don't really need bits, but easier this way */
 		i = value_highest_bit(sysctl_min_tx_turn_time, min_turn_times,
@@ -370,7 +370,7 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	{
 		IRDA_DEBUG(0,
 			   "%s(), adjusting max turn time from %d to 500 ms\n",
-			   __FUNCTION__, qos->max_turn_time.value);
+			   __func__, qos->max_turn_time.value);
 		qos->max_turn_time.value = 500;
 	}
 
@@ -386,7 +386,7 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	while ((qos->data_size.value > line_capacity) && (index > 0)) {
 		qos->data_size.value = data_sizes[index--];
 		IRDA_DEBUG(2, "%s(), reducing data size to %d\n",
-			   __FUNCTION__, qos->data_size.value);
+			   __func__, qos->data_size.value);
 	}
 #else /* Use method described in section 6.6.11 of IrLAP */
 	while (irlap_requested_line_capacity(qos) > line_capacity) {
@@ -396,14 +396,14 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 		if (qos->window_size.value > 1) {
 			qos->window_size.value--;
 			IRDA_DEBUG(2, "%s(), reducing window size to %d\n",
-				   __FUNCTION__, qos->window_size.value);
+				   __func__, qos->window_size.value);
 		} else if (index > 1) {
 			qos->data_size.value = data_sizes[index--];
 			IRDA_DEBUG(2, "%s(), reducing data size to %d\n",
-				   __FUNCTION__, qos->data_size.value);
+				   __func__, qos->data_size.value);
 		} else {
 			IRDA_WARNING("%s(), nothing more we can do!\n",
-				     __FUNCTION__);
+				     __func__);
 		}
 	}
 #endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
@@ -538,7 +538,7 @@ static int irlap_param_baud_rate(void *instance, irda_param_t *param, int get)
 	if (get) {
 		param->pv.i = self->qos_rx.baud_rate.bits;
 		IRDA_DEBUG(2, "%s(), baud rate = 0x%02x\n",
-			   __FUNCTION__, param->pv.i);
+			   __func__, param->pv.i);
 	} else {
 		/*
 		 *  Stations must agree on baud rate, so calculate
@@ -711,7 +711,7 @@ __u32 irlap_max_line_capacity(__u32 speed, __u32 max_turn_time)
 	int i,j;
 
 	IRDA_DEBUG(2, "%s(), speed=%d, max_turn_time=%d\n",
-		   __FUNCTION__, speed, max_turn_time);
+		   __func__, speed, max_turn_time);
 
 	i = value_index(speed, baud_rates, 10);
 	j = value_index(max_turn_time, max_turn_times, 4);
@@ -722,7 +722,7 @@ __u32 irlap_max_line_capacity(__u32 speed, __u32 max_turn_time)
 	line_capacity = max_line_capacities[i][j];
 
 	IRDA_DEBUG(2, "%s(), line capacity=%d bytes\n",
-		   __FUNCTION__, line_capacity);
+		   __func__, line_capacity);
 
 	return line_capacity;
 }
@@ -738,7 +738,7 @@ static __u32 irlap_requested_line_capacity(struct qos_info *qos)
 					     qos->min_turn_time.value);
 
 	IRDA_DEBUG(2, "%s(), requested line capacity=%d\n",
-		   __FUNCTION__, line_capacity);
+		   __func__, line_capacity);
 
 	return line_capacity;
 }
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index c246983..fd0995b 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -106,16 +106,16 @@ int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 		 * Nothing to worry about, but we set the default number of
 		 * BOF's
 		 */
-		IRDA_DEBUG(1, "%s(), wrong magic in skb!\n", __FUNCTION__);
+		IRDA_DEBUG(1, "%s(), wrong magic in skb!\n", __func__);
 		xbofs = 10;
 	} else
 		xbofs = cb->xbofs + cb->xbofs_delay;
 
-	IRDA_DEBUG(4, "%s(), xbofs=%d\n", __FUNCTION__, xbofs);
+	IRDA_DEBUG(4, "%s(), xbofs=%d\n", __func__, xbofs);
 
 	/* Check that we never use more than 115 + 48 xbofs */
 	if (xbofs > 163) {
-		IRDA_DEBUG(0, "%s(), too many xbofs (%d)\n", __FUNCTION__,
+		IRDA_DEBUG(0, "%s(), too many xbofs (%d)\n", __func__,
 			   xbofs);
 		xbofs = 163;
 	}
@@ -135,7 +135,7 @@ int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 		 */
 		if(n >= (buffsize-5)) {
 			IRDA_ERROR("%s(), tx buffer overflow (n=%d)\n",
-				   __FUNCTION__, n);
+				   __func__, n);
 			return n;
 		}
 
@@ -287,7 +287,7 @@ async_unwrap_bof(struct net_device *dev,
 		/* Not supposed to happen, the previous frame is not
 		 * finished - Jean II */
 		IRDA_DEBUG(1, "%s(), Discarding incomplete frame\n",
-			   __FUNCTION__);
+			   __func__);
 		stats->rx_errors++;
 		stats->rx_missed_errors++;
 		irda_device_set_media_busy(dev, TRUE);
@@ -360,7 +360,7 @@ async_unwrap_eof(struct net_device *dev,
 			/* Wrong CRC, discard frame!  */
 			irda_device_set_media_busy(dev, TRUE);
 
-			IRDA_DEBUG(1, "%s(), crc error\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), crc error\n", __func__);
 			stats->rx_errors++;
 			stats->rx_crc_errors++;
 		}
@@ -386,7 +386,7 @@ async_unwrap_ce(struct net_device *dev,
 		break;
 
 	case LINK_ESCAPE:
-		IRDA_WARNING("%s: state not defined\n", __FUNCTION__);
+		IRDA_WARNING("%s: state not defined\n", __func__);
 		break;
 
 	case BEGIN_FRAME:
@@ -421,7 +421,7 @@ async_unwrap_other(struct net_device *dev,
 #endif
 		} else {
 			IRDA_DEBUG(1, "%s(), Rx buffer overflow, aborting\n",
-				   __FUNCTION__);
+				   __func__);
 			rx_buff->state = OUTSIDE_FRAME;
 		}
 		break;
@@ -440,7 +440,7 @@ async_unwrap_other(struct net_device *dev,
 			rx_buff->state = INSIDE_FRAME;
 		} else {
 			IRDA_DEBUG(1, "%s(), Rx buffer overflow, aborting\n",
-				   __FUNCTION__);
+				   __func__);
 			rx_buff->state = OUTSIDE_FRAME;
 		}
 		break;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 46cf962..f93b576 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -185,7 +185,7 @@ static int llc_ui_release(struct socket *sock)
 	sock_hold(sk);
 	lock_sock(sk);
 	llc = llc_sk(sk);
-	dprintk("%s: closing local(%02X) remote(%02X)\n", __FUNCTION__,
+	dprintk("%s: closing local(%02X) remote(%02X)\n", __func__,
 		llc->laddr.lsap, llc->daddr.lsap);
 	if (!llc_send_disc(sk))
 		llc_ui_wait_for_disc(sk, sk->sk_rcvtimeo);
@@ -295,7 +295,7 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 	struct llc_sap *sap;
 	int rc = -EINVAL;
 
-	dprintk("%s: binding %02X\n", __FUNCTION__, addr->sllc_sap);
+	dprintk("%s: binding %02X\n", __func__, addr->sllc_sap);
 	if (unlikely(!sock_flag(sk, SOCK_ZAPPED) || addrlen != sizeof(*addr)))
 		goto out;
 	rc = -EAFNOSUPPORT;
@@ -432,7 +432,7 @@ static int llc_ui_connect(struct socket *sock, struct sockaddr *uaddr,
 	rc = llc_establish_connection(sk, llc->dev->dev_addr,
 				      addr->sllc_mac, addr->sllc_sap);
 	if (rc) {
-		dprintk("%s: llc_ui_send_conn failed :-(\n", __FUNCTION__);
+		dprintk("%s: llc_ui_send_conn failed :-(\n", __func__);
 		sock->state  = SS_UNCONNECTED;
 		sk->sk_state = TCP_CLOSE;
 		goto out;
@@ -604,7 +604,7 @@ static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int rc = -EOPNOTSUPP;
 
-	dprintk("%s: accepting on %02X\n", __FUNCTION__,
+	dprintk("%s: accepting on %02X\n", __func__,
 		llc_sk(sk)->laddr.lsap);
 	lock_sock(sk);
 	if (unlikely(sk->sk_type != SOCK_STREAM))
@@ -619,7 +619,7 @@ static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags)
 		if (rc)
 			goto out;
 	}
-	dprintk("%s: got a new connection on %02X\n", __FUNCTION__,
+	dprintk("%s: got a new connection on %02X\n", __func__,
 		llc_sk(sk)->laddr.lsap);
 	skb = skb_dequeue(&sk->sk_receive_queue);
 	rc = -EINVAL;
@@ -640,7 +640,7 @@ static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags)
 	/* put original socket back into a clean listen state. */
 	sk->sk_state = TCP_LISTEN;
 	sk->sk_ack_backlog--;
-	dprintk("%s: ok success on %02X, client on %02X\n", __FUNCTION__,
+	dprintk("%s: ok success on %02X, client on %02X\n", __func__,
 		llc_sk(sk)->addr.sllc_sap, newllc->daddr.lsap);
 frees:
 	kfree_skb(skb);
@@ -833,7 +833,7 @@ static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
 	size_t size = 0;
 	int rc = -EINVAL, copied = 0, hdrlen;
 
-	dprintk("%s: sending from %02X to %02X\n", __FUNCTION__,
+	dprintk("%s: sending from %02X to %02X\n", __func__,
 		llc->laddr.lsap, llc->daddr.lsap);
 	lock_sock(sk);
 	if (addr) {
@@ -891,7 +891,7 @@ out:
 		kfree_skb(skb);
 release:
 		dprintk("%s: failed sending from %02X to %02X: %d\n",
-			__FUNCTION__, llc->laddr.lsap, llc->daddr.lsap, rc);
+			__func__, llc->laddr.lsap, llc->daddr.lsap, rc);
 	}
 	release_sock(sk);
 	return rc ? : copied;
diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index 860140c..f728ffe 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1427,7 +1427,7 @@ static void llc_process_tmr_ev(struct sock *sk, struct sk_buff *skb)
 {
 	if (llc_sk(sk)->state == LLC_CONN_OUT_OF_SVC) {
 		printk(KERN_WARNING "%s: timer called on closed connection\n",
-		       __FUNCTION__);
+		       __func__);
 		kfree_skb(skb);
 	} else {
 		if (!sock_owned_by_user(sk))
diff --git a/net/llc/llc_c_ev.c b/net/llc/llc_c_ev.c
index c5deda2..523fdd1 100644
--- a/net/llc/llc_c_ev.c
+++ b/net/llc/llc_c_ev.c
@@ -228,7 +228,7 @@ int llc_conn_ev_rx_i_cmd_pbit_set_x_inval_ns(struct sock *sk,
 		 llc_util_ns_inside_rx_window(ns, vr, llc_sk(sk)->rw) ? 0 : 1;
 	if (!rc)
 		dprintk("%s: matched, state=%d, ns=%d, vr=%d\n",
-			__FUNCTION__, llc_sk(sk)->state, ns, vr);
+			__func__, llc_sk(sk)->state, ns, vr);
 	return rc;
 }
 
@@ -306,7 +306,7 @@ int llc_conn_ev_rx_i_rsp_fbit_set_x_inval_ns(struct sock *sk,
 		 llc_util_ns_inside_rx_window(ns, vr, llc_sk(sk)->rw) ? 0 : 1;
 	if (!rc)
 		dprintk("%s: matched, state=%d, ns=%d, vr=%d\n",
-			__FUNCTION__, llc_sk(sk)->state, ns, vr);
+			__func__, llc_sk(sk)->state, ns, vr);
 	return rc;
 }
 
@@ -511,7 +511,7 @@ int llc_conn_ev_rx_zzz_cmd_pbit_set_x_inval_nr(struct sock *sk,
 	    (LLC_PDU_TYPE_IS_I(pdu) || LLC_PDU_TYPE_IS_S(pdu)) &&
 	    nr != vs && llc_util_nr_inside_tx_window(sk, nr)) {
 		dprintk("%s: matched, state=%d, vs=%d, nr=%d\n",
-			__FUNCTION__, llc_sk(sk)->state, vs, nr);
+			__func__, llc_sk(sk)->state, vs, nr);
 		rc = 0;
 	}
 	return rc;
@@ -530,7 +530,7 @@ int llc_conn_ev_rx_zzz_rsp_fbit_set_x_inval_nr(struct sock *sk,
 	    nr != vs && llc_util_nr_inside_tx_window(sk, nr)) {
 		rc = 0;
 		dprintk("%s: matched, state=%d, vs=%d, nr=%d\n",
-			__FUNCTION__, llc_sk(sk)->state, vs, nr);
+			__func__, llc_sk(sk)->state, vs, nr);
 	}
 	return rc;
 }
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 441bc18..5ebfd93 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -73,7 +73,7 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 	 */
 	rc = llc_conn_service(skb->sk, skb);
 	if (unlikely(rc != 0)) {
-		printk(KERN_ERR "%s: llc_conn_service failed\n", __FUNCTION__);
+		printk(KERN_ERR "%s: llc_conn_service failed\n", __func__);
 		goto out_kfree_skb;
 	}
 
@@ -99,7 +99,7 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 			 * shouldn't happen
 			 */
 			printk(KERN_ERR "%s: sock_queue_rcv_skb failed!\n",
-			       __FUNCTION__);
+			       __func__);
 			kfree_skb(skb);
 		}
 		break;
@@ -132,13 +132,13 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 		 * FIXME:
 		 * RESET is not being notified to upper layers for now
 		 */
-		printk(KERN_INFO "%s: received a reset ind!\n", __FUNCTION__);
+		printk(KERN_INFO "%s: received a reset ind!\n", __func__);
 		kfree_skb(skb);
 		break;
 	default:
 		if (ev->ind_prim) {
 			printk(KERN_INFO "%s: received unknown %d prim!\n",
-				__FUNCTION__, ev->ind_prim);
+				__func__, ev->ind_prim);
 			kfree_skb(skb);
 		}
 		/* No indication */
@@ -179,12 +179,12 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 		 * FIXME:
 		 * RESET is not being notified to upper layers for now
 		 */
-		printk(KERN_INFO "%s: received a reset conf!\n", __FUNCTION__);
+		printk(KERN_INFO "%s: received a reset conf!\n", __func__);
 		break;
 	default:
 		if (ev->cfm_prim) {
 			printk(KERN_INFO "%s: received unknown %d prim!\n",
-					__FUNCTION__, ev->cfm_prim);
+					__func__, ev->cfm_prim);
 			break;
 		}
 		goto out_skb_put; /* No confirmation */
@@ -759,7 +759,7 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	if (!sock_owned_by_user(sk))
 		llc_conn_rcv(sk, skb);
 	else {
-		dprintk("%s: adding to backlog...\n", __FUNCTION__);
+		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
 		sk_add_backlog(sk, skb);
 	}
@@ -807,7 +807,7 @@ static int llc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		else
 			goto out_kfree_skb;
 	} else {
-		printk(KERN_ERR "%s: invalid skb in backlog\n", __FUNCTION__);
+		printk(KERN_ERR "%s: invalid skb in backlog\n", __func__);
 		goto out_kfree_skb;
 	}
 out:
@@ -874,7 +874,7 @@ struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority, struct pr
 #ifdef LLC_REFCNT_DEBUG
 	atomic_inc(&llc_sock_nr);
 	printk(KERN_DEBUG "LLC socket %p created in %s, now we have %d alive\n", sk,
-		__FUNCTION__, atomic_read(&llc_sock_nr));
+		__func__, atomic_read(&llc_sock_nr));
 #endif
 out:
 	return sk;
@@ -894,7 +894,7 @@ void llc_sk_free(struct sock *sk)
 	/* Stop all (possibly) running timers */
 	llc_conn_ac_stop_all_timers(sk, NULL);
 #ifdef DEBUG_LLC_CONN_ALLOC
-	printk(KERN_INFO "%s: unackq=%d, txq=%d\n", __FUNCTION__,
+	printk(KERN_INFO "%s: unackq=%d, txq=%d\n", __func__,
 		skb_queue_len(&llc->pdu_unack_q),
 		skb_queue_len(&sk->sk_write_queue));
 #endif
@@ -904,13 +904,13 @@ void llc_sk_free(struct sock *sk)
 #ifdef LLC_REFCNT_DEBUG
 	if (atomic_read(&sk->sk_refcnt) != 1) {
 		printk(KERN_DEBUG "Destruction of LLC sock %p delayed in %s, cnt=%d\n",
-			sk, __FUNCTION__, atomic_read(&sk->sk_refcnt));
+			sk, __func__, atomic_read(&sk->sk_refcnt));
 		printk(KERN_DEBUG "%d LLC sockets are still alive\n",
 			atomic_read(&llc_sock_nr));
 	} else {
 		atomic_dec(&llc_sock_nr);
 		printk(KERN_DEBUG "LLC socket %p released in %s, %d are still alive\n", sk,
-			__FUNCTION__, atomic_read(&llc_sock_nr));
+			__func__, atomic_read(&llc_sock_nr));
 	}
 #endif
 	sock_put(sk);
diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index c40c9b2..b9143d2 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -154,7 +154,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * receives, do not try to analyse it.
 	 */
 	if (unlikely(skb->pkt_type == PACKET_OTHERHOST)) {
-		dprintk("%s: PACKET_OTHERHOST\n", __FUNCTION__);
+		dprintk("%s: PACKET_OTHERHOST\n", __func__);
 		goto drop;
 	}
 	skb = skb_share_check(skb, GFP_ATOMIC);
@@ -167,7 +167,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	       goto handle_station;
 	sap = llc_sap_find(pdu->dsap);
 	if (unlikely(!sap)) {/* unknown SAP */
-		dprintk("%s: llc_sap_find(%02X) failed!\n", __FUNCTION__,
+		dprintk("%s: llc_sap_find(%02X) failed!\n", __func__,
 			pdu->dsap);
 		goto drop;
 	}
diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index 0d6824b..6777050 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -165,7 +165,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 		break;
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
-		       dev->name, __FUNCTION__, type);
+		       dev->name, __func__, type);
 	}
 	ieee80211_debugfs_change_if_type(sdata, oldtype);
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1aaa2e8..e58cc65 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -619,8 +619,8 @@ void _dbprintk(const char *fmt, ...)
 {
 }
 
-#define kenter(FMT,...)	dbgprintk("==> %s("FMT")",__FUNCTION__ ,##__VA_ARGS__)
-#define kleave(FMT,...)	dbgprintk("<== %s()"FMT"",__FUNCTION__ ,##__VA_ARGS__)
+#define kenter(FMT,...)	dbgprintk("==> %s("FMT")",__func__ ,##__VA_ARGS__)
+#define kleave(FMT,...)	dbgprintk("<== %s()"FMT"",__func__ ,##__VA_ARGS__)
 #define kdebug(FMT,...)	dbgprintk("    "FMT ,##__VA_ARGS__)
 #define kproto(FMT,...)	dbgprintk("### "FMT ,##__VA_ARGS__)
 #define knet(FMT,...)	dbgprintk("@@@ "FMT ,##__VA_ARGS__)
@@ -671,8 +671,8 @@ do {							\
 } while (0)
 
 #else
-#define _enter(FMT,...)	_dbprintk("==> %s("FMT")",__FUNCTION__ ,##__VA_ARGS__)
-#define _leave(FMT,...)	_dbprintk("<== %s()"FMT"",__FUNCTION__ ,##__VA_ARGS__)
+#define _enter(FMT,...)	_dbprintk("==> %s("FMT")",__func__ ,##__VA_ARGS__)
+#define _leave(FMT,...)	_dbprintk("<== %s()"FMT"",__func__ ,##__VA_ARGS__)
 #define _debug(FMT,...)	_dbprintk("    "FMT ,##__VA_ARGS__)
 #define _proto(FMT,...)	_dbprintk("### "FMT ,##__VA_ARGS__)
 #define _net(FMT,...)	_dbprintk("@@@ "FMT ,##__VA_ARGS__)
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index d29f792..422c98a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1330,7 +1330,7 @@ void sctp_assoc_sync_pmtu(struct sctp_association *asoc)
 	}
 
 	SCTP_DEBUG_PRINTK("%s: asoc:%p, pmtu:%d, frag_point:%d\n",
-			  __FUNCTION__, asoc, asoc->pathmtu, asoc->frag_point);
+			  __func__, asoc, asoc->pathmtu, asoc->frag_point);
 }
 
 /* Should we send a SACK to update our peer? */
@@ -1370,7 +1370,7 @@ void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned len)
 	}
 
 	SCTP_DEBUG_PRINTK("%s: asoc %p rwnd increased by %d to (%u, %u) "
-			  "- %u\n", __FUNCTION__, asoc, len, asoc->rwnd,
+			  "- %u\n", __func__, asoc, len, asoc->rwnd,
 			  asoc->rwnd_over, asoc->a_rwnd);
 
 	/* Send a window update SACK if the rwnd has increased by at least the
@@ -1381,7 +1381,7 @@ void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned len)
 	if (sctp_peer_needs_update(asoc)) {
 		asoc->a_rwnd = asoc->rwnd;
 		SCTP_DEBUG_PRINTK("%s: Sending window update SACK- asoc: %p "
-				  "rwnd: %u a_rwnd: %u\n", __FUNCTION__,
+				  "rwnd: %u a_rwnd: %u\n", __func__,
 				  asoc, asoc->rwnd, asoc->a_rwnd);
 		sack = sctp_make_sack(asoc);
 		if (!sack)
@@ -1410,7 +1410,7 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned len)
 		asoc->rwnd = 0;
 	}
 	SCTP_DEBUG_PRINTK("%s: asoc %p rwnd decreased by %d to (%u, %u)\n",
-			  __FUNCTION__, asoc, len, asoc->rwnd,
+			  __func__, asoc, len, asoc->rwnd,
 			  asoc->rwnd_over);
 }
 
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 4d3128f..e1f3550 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -189,7 +189,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 				    msecs_to_jiffies(sinfo->sinfo_timetolive);
 		msg->can_abandon = 1;
 		SCTP_DEBUG_PRINTK("%s: msg:%p expires_at: %ld jiffies:%ld\n",
-				  __FUNCTION__, msg, msg->expires_at, jiffies);
+				  __func__, msg, msg->expires_at, jiffies);
 	}
 
 	max = asoc->frag_point;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 57fe2f8..4db5a75 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -409,7 +409,7 @@ void sctp_icmp_proto_unreachable(struct sock *sk,
 			   struct sctp_association *asoc,
 			   struct sctp_transport *t)
 {
-	SCTP_DEBUG_PRINTK("%s\n",  __FUNCTION__);
+	SCTP_DEBUG_PRINTK("%s\n",  __func__);
 
 	sctp_do_sm(SCTP_EVENT_T_OTHER,
 		   SCTP_ST_OTHER(SCTP_EVENT_ICMP_PROTO_UNREACH),
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 87f9405..0d96155 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -223,7 +223,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport,
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
 			  "src:" NIP6_FMT " dst:" NIP6_FMT "\n",
-			  __FUNCTION__, skb, skb->len,
+			  __func__, skb, skb->len,
 			  NIP6(fl.fl6_src), NIP6(fl.fl6_dst));
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
@@ -248,7 +248,7 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 
 
 	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " ",
-			  __FUNCTION__, NIP6(fl.fl6_dst));
+			  __func__, NIP6(fl.fl6_dst));
 
 	if (saddr) {
 		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
@@ -310,7 +310,7 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
 
 	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p "
 			  "daddr:" NIP6_FMT " ",
-			  __FUNCTION__, asoc, dst, NIP6(daddr->v6.sin6_addr));
+			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
 
 	if (!asoc) {
 		ipv6_get_saddr(dst, &daddr->v6.sin6_addr,&saddr->v6.sin6_addr);
@@ -348,7 +348,7 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
 	} else {
 		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
 		       "address for the dest:" NIP6_FMT "\n",
-		       __FUNCTION__, asoc, NIP6(daddr->v6.sin6_addr));
+		       __func__, asoc, NIP6(daddr->v6.sin6_addr));
 	}
 
 	rcu_read_unlock();
diff --git a/net/sctp/output.c b/net/sctp/output.c
index aa700fe..cf4f9fb 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -74,7 +74,7 @@ struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
 {
 	struct sctp_chunk *chunk = NULL;
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p vtag:0x%x\n", __FUNCTION__,
+	SCTP_DEBUG_PRINTK("%s: packet:%p vtag:0x%x\n", __func__,
 			  packet, vtag);
 
 	packet->vtag = vtag;
@@ -106,7 +106,7 @@ struct sctp_packet *sctp_packet_init(struct sctp_packet *packet,
 	struct sctp_association *asoc = transport->asoc;
 	size_t overhead;
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p transport:%p\n", __FUNCTION__,
+	SCTP_DEBUG_PRINTK("%s: packet:%p transport:%p\n", __func__,
 			  packet, transport);
 
 	packet->transport = transport;
@@ -138,7 +138,7 @@ void sctp_packet_free(struct sctp_packet *packet)
 {
 	struct sctp_chunk *chunk, *tmp;
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p\n", __FUNCTION__, packet);
+	SCTP_DEBUG_PRINTK("%s: packet:%p\n", __func__, packet);
 
 	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
 		list_del_init(&chunk->list);
@@ -162,7 +162,7 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	sctp_xmit_t retval;
 	int error = 0;
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __FUNCTION__,
+	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __func__,
 			  packet, chunk);
 
 	switch ((retval = (sctp_packet_append_chunk(packet, chunk)))) {
@@ -264,7 +264,7 @@ sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
 	size_t pmtu;
 	int too_big;
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __FUNCTION__, packet,
+	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __func__, packet,
 			  chunk);
 
 	/* Try to bundle AUTH chunk */
@@ -372,7 +372,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	unsigned char *auth = NULL;	/* pointer to auth in skb data */
 	__u32 cksum_buf_len = sizeof(struct sctphdr);
 
-	SCTP_DEBUG_PRINTK("%s: packet:%p\n", __FUNCTION__, packet);
+	SCTP_DEBUG_PRINTK("%s: packet:%p\n", __func__, packet);
 
 	/* Do NOT generate a chunkless packet. */
 	if (list_empty(&packet->chunk_list))
@@ -677,7 +677,7 @@ static sctp_xmit_t sctp_packet_append_data(struct sctp_packet *packet,
 				  "transport: %p, cwnd: %d, "
 				  "ssthresh: %d, flight_size: %d, "
 				  "pba: %d\n",
-				  __FUNCTION__, transport,
+				  __func__, transport,
 				  transport->cwnd,
 				  transport->ssthresh,
 				  transport->flight_size,
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index fd4deef..392012f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -469,7 +469,7 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 
 	SCTP_DEBUG_PRINTK("%s: transport: %p, reason: %d, "
 			  "cwnd: %d, ssthresh: %d, flight_size: %d, "
-			  "pba: %d\n", __FUNCTION__,
+			  "pba: %d\n", __func__,
 			  transport, reason,
 			  transport->cwnd, transport->ssthresh,
 			  transport->flight_size,
@@ -1206,10 +1206,10 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	sctp_generate_fwdtsn(q, sack_ctsn);
 
 	SCTP_DEBUG_PRINTK("%s: sack Cumulative TSN Ack is 0x%x.\n",
-			  __FUNCTION__, sack_ctsn);
+			  __func__, sack_ctsn);
 	SCTP_DEBUG_PRINTK("%s: Cumulative TSN Ack of association, "
 			  "%p is 0x%x. Adv peer ack point: 0x%x\n",
-			  __FUNCTION__, asoc, ctsn, asoc->adv_peer_ack_point);
+			  __func__, asoc, ctsn, asoc->adv_peer_ack_point);
 
 	/* See if all chunks are acked.
 	 * Make sure the empty queue handler will get run later.
@@ -1444,7 +1444,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			if (tchunk->tsn_gap_acked) {
 				SCTP_DEBUG_PRINTK("%s: Receiver reneged on "
 						  "data TSN: 0x%x\n",
-						  __FUNCTION__,
+						  __func__,
 						  tsn);
 				tchunk->tsn_gap_acked = 0;
 
@@ -1561,7 +1561,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			    (sack_ctsn+2 == q->asoc->next_tsn)) {
 				SCTP_DEBUG_PRINTK("%s: SACK received for zero "
 						  "window probe: %u\n",
-						  __FUNCTION__, sack_ctsn);
+						  __func__, sack_ctsn);
 				q->asoc->overall_error_count = 0;
 				transport->error_count = 0;
 			}
@@ -1626,7 +1626,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 
 				SCTP_DEBUG_PRINTK(
 					"%s: TSN 0x%x missing counter: %d\n",
-					__FUNCTION__, tsn,
+					__func__, tsn,
 					chunk->tsn_missing_report);
 			}
 		}
@@ -1649,7 +1649,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 
 		SCTP_DEBUG_PRINTK("%s: transport: %p, cwnd: %d, "
 				  "ssthresh: %d, flight_size: %d, pba: %d\n",
-				  __FUNCTION__, transport, transport->cwnd,
+				  __func__, transport, transport->cwnd,
 				  transport->ssthresh, transport->flight_size,
 				  transport->partial_bytes_acked);
 	}
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 8d9d929..2d8777f 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -451,7 +451,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		fl.fl4_src = saddr->v4.sin_addr.s_addr;
 
 	SCTP_DEBUG_PRINTK("%s: DST:%u.%u.%u.%u, SRC:%u.%u.%u.%u - ",
-			  __FUNCTION__, NIPQUAD(fl.fl4_dst),
+			  __func__, NIPQUAD(fl.fl4_dst),
 			  NIPQUAD(fl.fl4_src));
 
 	if (!ip_route_output_key(&init_net, &rt, &fl)) {
@@ -827,7 +827,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 {
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
 			  "src:%u.%u.%u.%u, dst:%u.%u.%u.%u\n",
-			  __FUNCTION__, skb, skb->len,
+			  __func__, skb, skb->len,
 			  NIPQUAD(((struct rtable *)skb->dst)->rt_src),
 			  NIPQUAD(((struct rtable *)skb->dst)->rt_dst));
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 28eb38e..02bf32c 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -243,7 +243,7 @@ void sctp_generate_t3_rtx_event(unsigned long peer)
 
 	sctp_bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
-		SCTP_DEBUG_PRINTK("%s:Sock is busy.\n", __FUNCTION__);
+		SCTP_DEBUG_PRINTK("%s:Sock is busy.\n", __func__);
 
 		/* Try again later.  */
 		if (!mod_timer(&transport->T3_rtx_timer, jiffies + (HZ/20)))
@@ -283,7 +283,7 @@ static void sctp_generate_timeout_event(struct sctp_association *asoc,
 	sctp_bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		SCTP_DEBUG_PRINTK("%s:Sock is busy: timer %d\n",
-				  __FUNCTION__,
+				  __func__,
 				  timeout_type);
 
 		/* Try again later.  */
@@ -361,7 +361,7 @@ void sctp_generate_heartbeat_event(unsigned long data)
 
 	sctp_bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
-		SCTP_DEBUG_PRINTK("%s:Sock is busy.\n", __FUNCTION__);
+		SCTP_DEBUG_PRINTK("%s:Sock is busy.\n", __func__);
 
 		/* Try again later.  */
 		if (!mod_timer(&transport->hb_timer, jiffies + (HZ/20)))
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ade0cbd..c0c6bee 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1124,7 +1124,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 				printk(KERN_WARNING
 				    "%s association %p could not find address "
 				    NIP6_FMT "\n",
-				    __FUNCTION__,
+				    __func__,
 				    asoc,
 				    NIP6(from_addr.v6.sin6_addr));
 		} else {
@@ -1132,7 +1132,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 				printk(KERN_WARNING
 				    "%s association %p could not find address "
 				    NIPQUAD_FMT "\n",
-				    __FUNCTION__,
+				    __func__,
 				    asoc,
 				    NIPQUAD(from_addr.v4.sin_addr.s_addr));
 		}
@@ -1150,7 +1150,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 	    time_after(jiffies, hbinfo->sent_at + max_interval)) {
 		SCTP_DEBUG_PRINTK("%s: HEARTBEAT ACK with invalid timestamp "
 				  "received for transport: %p\n",
-				   __FUNCTION__, link);
+				   __func__, link);
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
@@ -3668,7 +3668,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(const struct sctp_endpoint *ep,
 	skb_pull(chunk->skb, len);
 
 	tsn = ntohl(fwdtsn_hdr->new_cum_tsn);
-	SCTP_DEBUG_PRINTK("%s: TSN 0x%x.\n", __FUNCTION__, tsn);
+	SCTP_DEBUG_PRINTK("%s: TSN 0x%x.\n", __func__, tsn);
 
 	/* The TSN is too high--silently discard the chunk and count on it
 	 * getting retransmitted later.
@@ -3728,7 +3728,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 	skb_pull(chunk->skb, len);
 
 	tsn = ntohl(fwdtsn_hdr->new_cum_tsn);
-	SCTP_DEBUG_PRINTK("%s: TSN 0x%x.\n", __FUNCTION__, tsn);
+	SCTP_DEBUG_PRINTK("%s: TSN 0x%x.\n", __func__, tsn);
 
 	/* The TSN is too high--silently discard the chunk and count on it
 	 * getting retransmitted later.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9398926..1316694 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -525,7 +525,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 	ep = sp->ep;
 
 	SCTP_DEBUG_PRINTK("%s: (sk: %p, addrs: %p, addrcnt: %d)\n",
-			  __FUNCTION__, sk, addrs, addrcnt);
+			  __func__, sk, addrs, addrcnt);
 
 	list_for_each(pos, &ep->asocs) {
 		asoc = list_entry(pos, struct sctp_association, asocs);
@@ -711,7 +711,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 	ep = sp->ep;
 
 	SCTP_DEBUG_PRINTK("%s: (sk: %p, addrs: %p, addrcnt: %d)\n",
-			  __FUNCTION__, sk, addrs, addrcnt);
+			  __func__, sk, addrs, addrcnt);
 
 	list_for_each(pos, &ep->asocs) {
 		asoc = list_entry(pos, struct sctp_association, asocs);
@@ -1197,7 +1197,7 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
 	struct sockaddr *kaddrs;
 
 	SCTP_DEBUG_PRINTK("%s - sk %p addrs %p addrs_size %d\n",
-			  __FUNCTION__, sk, addrs, addrs_size);
+			  __func__, sk, addrs, addrs_size);
 
 	if (unlikely(addrs_size <= 0))
 		return -EINVAL;
@@ -3280,7 +3280,7 @@ SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
 	sctp_lock_sock(sk);
 
 	SCTP_DEBUG_PRINTK("%s - sk: %p, sockaddr: %p, addr_len: %d\n",
-			  __FUNCTION__, sk, addr, addr_len);
+			  __func__, sk, addr, addr_len);
 
 	/* Validate addr_len before calling common connect/connectx routine. */
 	af = sctp_get_af_specific(addr->sa_family);
@@ -3801,7 +3801,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 		goto out;
 	}
 
-	SCTP_DEBUG_PRINTK("%s: sk: %p asoc: %p\n", __FUNCTION__, sk, asoc);
+	SCTP_DEBUG_PRINTK("%s: sk: %p asoc: %p\n", __func__, sk, asoc);
 
 	retval = sctp_do_peeloff(asoc, &newsock);
 	if (retval < 0)
@@ -3815,7 +3815,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 	}
 
 	SCTP_DEBUG_PRINTK("%s: sk: %p asoc: %p newsk: %p sd: %d\n",
-			  __FUNCTION__, sk, asoc, newsock->sk, retval);
+			  __func__, sk, asoc, newsock->sk, retval);
 
 	/* Return the fd mapped to the new socket.  */
 	peeloff.sd = retval;
@@ -6186,7 +6186,7 @@ static int sctp_wait_for_connect(struct sctp_association *asoc, long *timeo_p)
 	long current_timeo = *timeo_p;
 	DEFINE_WAIT(wait);
 
-	SCTP_DEBUG_PRINTK("%s: asoc=%p, timeo=%ld\n", __FUNCTION__, asoc,
+	SCTP_DEBUG_PRINTK("%s: asoc=%p, timeo=%ld\n", __func__, asoc,
 			  (long)(*timeo_p));
 
 	/* Increment the association's refcnt.  */
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index d9f8af8..f4938f6 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -260,7 +260,7 @@ void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
 	if (unlikely(pmtu < SCTP_DEFAULT_MINSEGMENT)) {
 		printk(KERN_WARNING "%s: Reported pmtu %d too low, "
 		       "using default minimum of %d\n",
-		       __FUNCTION__, pmtu,
+		       __func__, pmtu,
 		       SCTP_DEFAULT_MINSEGMENT);
 		/* Use default minimum segment size and disable
 		 * pmtu discovery on this transport.
@@ -388,7 +388,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
 	tp->rto_pending = 0;
 
 	SCTP_DEBUG_PRINTK("%s: transport: %p, rtt: %d, srtt: %d "
-			  "rttvar: %d, rto: %ld\n", __FUNCTION__,
+			  "rttvar: %d, rto: %ld\n", __func__,
 			  tp, rtt, tp->srtt, tp->rttvar, tp->rto);
 }
 
@@ -434,7 +434,7 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		SCTP_DEBUG_PRINTK("%s: SLOW START: transport: %p, "
 				  "bytes_acked: %d, cwnd: %d, ssthresh: %d, "
 				  "flight_size: %d, pba: %d\n",
-				  __FUNCTION__,
+				  __func__,
 				  transport, bytes_acked, cwnd,
 				  ssthresh, flight_size, pba);
 	} else {
@@ -460,7 +460,7 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		SCTP_DEBUG_PRINTK("%s: CONGESTION AVOIDANCE: "
 				  "transport: %p, bytes_acked: %d, cwnd: %d, "
 				  "ssthresh: %d, flight_size: %d, pba: %d\n",
-				  __FUNCTION__,
+				  __func__,
 				  transport, bytes_acked, cwnd,
 				  ssthresh, flight_size, pba);
 	}
@@ -546,7 +546,7 @@ void sctp_transport_lower_cwnd(struct sctp_transport *transport,
 
 	transport->partial_bytes_acked = 0;
 	SCTP_DEBUG_PRINTK("%s: transport: %p reason: %d cwnd: "
-			  "%d ssthresh: %d\n", __FUNCTION__,
+			  "%d ssthresh: %d\n", __func__,
 			  transport, reason,
 			  transport->cwnd, transport->ssthresh);
 }
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6dac387..5828e5c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -625,7 +625,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
 	if (!gss_auth->mech) {
 		printk(KERN_WARNING "%s: Pseudoflavor %d not found!\n",
-				__FUNCTION__, flavor);
+				__func__, flavor);
 		goto err_free;
 	}
 	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c6a7f1..13a3718 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -43,7 +43,7 @@
 
 #define dprint_status(t)					\
 	dprintk("RPC: %5u %s (status %d)\n", t->tk_pid,		\
-			__FUNCTION__, t->tk_status)
+			__func__, t->tk_status)
 
 /*
  * All RPC clients are linked into this list
@@ -372,7 +372,7 @@ out_no_path:
 out_no_stats:
 	kfree(new);
 out_no_clnt:
-	dprintk("RPC:       %s: returned error %d\n", __FUNCTION__, err);
+	dprintk("RPC:       %s: returned error %d\n", __func__, err);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(rpc_clone_client);
@@ -756,7 +756,7 @@ call_reserveresult(struct rpc_task *task)
 		}
 
 		printk(KERN_ERR "%s: status=%d, but no request slot, exiting\n",
-				__FUNCTION__, status);
+				__func__, status);
 		rpc_exit(task, -EIO);
 		return;
 	}
@@ -767,7 +767,7 @@ call_reserveresult(struct rpc_task *task)
 	 */
 	if (task->tk_rqstp) {
 		printk(KERN_ERR "%s: status=%d, request allocated anyway\n",
-				__FUNCTION__, status);
+				__func__, status);
 		xprt_release(task);
 	}
 
@@ -779,7 +779,7 @@ call_reserveresult(struct rpc_task *task)
 		break;
 	default:
 		printk(KERN_ERR "%s: unrecognized error %d, exiting\n",
-				__FUNCTION__, status);
+				__func__, status);
 		break;
 	}
 	rpc_exit(task, status);
@@ -1327,7 +1327,7 @@ call_verify(struct rpc_task *task)
 		 *   undefined results
 		 */
 		dprintk("RPC: %5u %s: XDR representation not a multiple of"
-		       " 4 bytes: 0x%x\n", task->tk_pid, __FUNCTION__,
+		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
 		       task->tk_rqstp->rq_rcv_buf.len);
 		goto out_eio;
 	}
@@ -1337,7 +1337,7 @@ call_verify(struct rpc_task *task)
 
 	if ((n = ntohl(*p++)) != RPC_REPLY) {
 		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
-				task->tk_pid, __FUNCTION__, n);
+				task->tk_pid, __func__, n);
 		goto out_garbage;
 	}
 	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
@@ -1349,13 +1349,13 @@ call_verify(struct rpc_task *task)
 			case RPC_MISMATCH:
 				dprintk("RPC: %5u %s: RPC call version "
 						"mismatch!\n",
-						task->tk_pid, __FUNCTION__);
+						task->tk_pid, __func__);
 				error = -EPROTONOSUPPORT;
 				goto out_err;
 			default:
 				dprintk("RPC: %5u %s: RPC call rejected, "
 						"unknown error: %x\n",
-						task->tk_pid, __FUNCTION__, n);
+						task->tk_pid, __func__, n);
 				goto out_eio;
 		}
 		if (--len < 0)
@@ -1369,7 +1369,7 @@ call_verify(struct rpc_task *task)
 				break;
 			task->tk_cred_retry--;
 			dprintk("RPC: %5u %s: retry stale creds\n",
-					task->tk_pid, __FUNCTION__);
+					task->tk_pid, __func__);
 			rpcauth_invalcred(task);
 			/* Ensure we obtain a new XID! */
 			xprt_release(task);
@@ -1382,7 +1382,7 @@ call_verify(struct rpc_task *task)
 				break;
 			task->tk_garb_retry--;
 			dprintk("RPC: %5u %s: retry garbled creds\n",
-					task->tk_pid, __FUNCTION__);
+					task->tk_pid, __func__);
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
@@ -1391,16 +1391,16 @@ call_verify(struct rpc_task *task)
 			break;
 		default:
 			dprintk("RPC: %5u %s: unknown auth error: %x\n",
-					task->tk_pid, __FUNCTION__, n);
+					task->tk_pid, __func__, n);
 			error = -EIO;
 		}
 		dprintk("RPC: %5u %s: call rejected %d\n",
-				task->tk_pid, __FUNCTION__, n);
+				task->tk_pid, __func__, n);
 		goto out_err;
 	}
 	if (!(p = rpcauth_checkverf(task, p))) {
 		dprintk("RPC: %5u %s: auth check failed\n",
-				task->tk_pid, __FUNCTION__);
+				task->tk_pid, __func__);
 		goto out_garbage;		/* bad verifier, retry */
 	}
 	len = p - (__be32 *)iov->iov_base - 1;
@@ -1411,14 +1411,14 @@ call_verify(struct rpc_task *task)
 		return p;
 	case RPC_PROG_UNAVAIL:
 		dprintk("RPC: %5u %s: program %u is unsupported by server %s\n",
-				task->tk_pid, __FUNCTION__,
+				task->tk_pid, __func__,
 				(unsigned int)task->tk_client->cl_prog,
 				task->tk_client->cl_server);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
 		dprintk("RPC: %5u %s: program %u, version %u unsupported by "
-				"server %s\n", task->tk_pid, __FUNCTION__,
+				"server %s\n", task->tk_pid, __func__,
 				(unsigned int)task->tk_client->cl_prog,
 				(unsigned int)task->tk_client->cl_vers,
 				task->tk_client->cl_server);
@@ -1427,7 +1427,7 @@ call_verify(struct rpc_task *task)
 	case RPC_PROC_UNAVAIL:
 		dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
 				"version %u on server %s\n",
-				task->tk_pid, __FUNCTION__,
+				task->tk_pid, __func__,
 				task->tk_msg.rpc_proc,
 				task->tk_client->cl_prog,
 				task->tk_client->cl_vers,
@@ -1436,11 +1436,11 @@ call_verify(struct rpc_task *task)
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
 		dprintk("RPC: %5u %s: server saw garbage\n",
-				task->tk_pid, __FUNCTION__);
+				task->tk_pid, __func__);
 		break;			/* retry */
 	default:
 		dprintk("RPC: %5u %s: server accept status: %x\n",
-				task->tk_pid, __FUNCTION__, n);
+				task->tk_pid, __func__, n);
 		/* Also retry */
 	}
 
@@ -1449,7 +1449,7 @@ out_garbage:
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
 		dprintk("RPC: %5u %s: retrying\n",
-				task->tk_pid, __FUNCTION__);
+				task->tk_pid, __func__);
 		task->tk_action = call_bind;
 out_retry:
 		return ERR_PTR(-EAGAIN);
@@ -1459,11 +1459,11 @@ out_eio:
 out_err:
 	rpc_exit(task, error);
 	dprintk("RPC: %5u %s: call failed with error %d\n", task->tk_pid,
-			__FUNCTION__, error);
+			__func__, error);
 	return ERR_PTR(error);
 out_overflow:
 	dprintk("RPC: %5u %s: server reply was truncated.\n", task->tk_pid,
-			__FUNCTION__);
+			__func__);
 	goto out_garbage;
 }
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 1b395a4..5a9b0e7 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -479,13 +479,13 @@ rpc_lookup_parent(char *path, struct nameidata *nd)
 	mnt = rpc_get_mount();
 	if (IS_ERR(mnt)) {
 		printk(KERN_WARNING "%s: %s failed to mount "
-			       "pseudofilesystem \n", __FILE__, __FUNCTION__);
+			       "pseudofilesystem \n", __FILE__, __func__);
 		return PTR_ERR(mnt);
 	}
 
 	if (vfs_path_lookup(mnt->mnt_root, mnt, path, LOOKUP_PARENT, nd)) {
 		printk(KERN_WARNING "%s: %s failed to find path %s\n",
-				__FILE__, __FUNCTION__, path);
+				__FILE__, __func__, path);
 		rpc_put_mount();
 		return -ENOENT;
 	}
@@ -604,7 +604,7 @@ rpc_populate(struct dentry *parent,
 out_bad:
 	mutex_unlock(&dir->i_mutex);
 	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
-			__FILE__, __FUNCTION__, parent->d_name.name);
+			__FILE__, __func__, parent->d_name.name);
 	return -ENOMEM;
 }
 
@@ -623,7 +623,7 @@ __rpc_mkdir(struct inode *dir, struct dentry *dentry)
 	return 0;
 out_err:
 	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
-			__FILE__, __FUNCTION__, dentry->d_name.name);
+			__FILE__, __func__, dentry->d_name.name);
 	return -ENOMEM;
 }
 
@@ -715,7 +715,7 @@ err_depopulate:
 err_dput:
 	dput(dentry);
 	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
-			__FILE__, __FUNCTION__, path, error);
+			__FILE__, __func__, path, error);
 	dentry = ERR_PTR(error);
 	goto out;
 }
@@ -804,7 +804,7 @@ err_dput:
 	dput(dentry);
 	dentry = ERR_PTR(-ENOMEM);
 	printk(KERN_WARNING "%s: %s() failed to create pipe %s/%s (errno = %d)\n",
-			__FILE__, __FUNCTION__, parent->d_name.name, name,
+			__FILE__, __func__, parent->d_name.name, name,
 			-ENOMEM);
 	goto out;
 }
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 3164a08..56aa018 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -224,7 +224,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 	int status;
 
 	dprintk("RPC:       %s(" NIPQUAD_FMT ", %u, %u, %d)\n",
-		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+		__func__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
 				sizeof(*sin), prot, 2, 0);
@@ -283,7 +283,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpcb_info *info;
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
-		task->tk_pid, __FUNCTION__,
+		task->tk_pid, __func__,
 		clnt->cl_server, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
 	/* Autobind on cloned rpc clients is discouraged */
@@ -292,7 +292,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (xprt_test_and_set_binding(xprt)) {
 		status = -EAGAIN;	/* tell caller to check again */
 		dprintk("RPC: %5u %s: waiting for another binder\n",
-			task->tk_pid, __FUNCTION__);
+			task->tk_pid, __func__);
 		goto bailout_nowake;
 	}
 
@@ -304,7 +304,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (xprt_bound(xprt)) {
 		status = 0;
 		dprintk("RPC: %5u %s: already bound\n",
-			task->tk_pid, __FUNCTION__);
+			task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
 
@@ -321,27 +321,27 @@ void rpcb_getport_async(struct rpc_task *task)
 	default:
 		status = -EAFNOSUPPORT;
 		dprintk("RPC: %5u %s: bad address family\n",
-				task->tk_pid, __FUNCTION__);
+				task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
 	if (info[xprt->bind_index].rpc_proc == NULL) {
 		xprt->bind_index = 0;
 		status = -EPFNOSUPPORT;
 		dprintk("RPC: %5u %s: no more getport versions available\n",
-			task->tk_pid, __FUNCTION__);
+			task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
 	bind_version = info[xprt->bind_index].rpc_vers;
 
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
-		task->tk_pid, __FUNCTION__, bind_version);
+		task->tk_pid, __func__, bind_version);
 
 	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
 				bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
-			task->tk_pid, __FUNCTION__, PTR_ERR(rpcb_clnt));
+			task->tk_pid, __func__, PTR_ERR(rpcb_clnt));
 		goto bailout_nofree;
 	}
 
@@ -349,7 +349,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (!map) {
 		status = -ENOMEM;
 		dprintk("RPC: %5u %s: no memory available\n",
-			task->tk_pid, __FUNCTION__);
+			task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
 	map->r_prog = clnt->cl_prog;
@@ -366,7 +366,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (IS_ERR(child)) {
 		status = -EIO;
 		dprintk("RPC: %5u %s: rpc_run_task failed\n",
-			task->tk_pid, __FUNCTION__);
+			task->tk_pid, __func__);
 		goto bailout;
 	}
 	rpc_put_task(child);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 30e7ac2..613daf8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1359,7 +1359,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
 	dprintk("RPC:       %s "NIPQUAD_FMT":%u: %s (%d)\n",
-			__FUNCTION__, NIPQUAD(myaddr.sin_addr),
+			__func__, NIPQUAD(myaddr.sin_addr),
 			port, err ? "failed" : "ok", err);
 	return err;
 }
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index b8788fd..ae58435 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2176,7 +2176,7 @@ static int __init af_unix_init(void)
 	rc = proto_register(&unix_proto, 1);
 	if (rc != 0) {
 		printk(KERN_CRIT "%s: Cannot create unix_sock SLAB cache!\n",
-		       __FUNCTION__);
+		       __func__);
 		goto out;
 	}
 
-- 
1.5.4.3.500.g83a2c



