From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/4] net: replace %p6 with %pI6
Date: Wed, 29 Oct 2008 11:35:41 -0700
Message-ID: <1225305341.5688.38.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:25580 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196AbYJ2Smz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:42:55 -0400
Received: by yx-out-2324.google.com with SMTP id 8so49863yxm.1
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 11:42:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/firmware/iscsi_ibft.c                  |    2 +-
 drivers/infiniband/core/sysfs.c                |    2 +-
 drivers/infiniband/hw/mthca/mthca_mcg.c        |    4 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |    4 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   12 ++++----
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   30 ++++++++++++------------
 drivers/infiniband/ulp/srp/ib_srp.c            |    6 ++--
 drivers/net/mlx4/mcg.c                         |    4 +-
 drivers/scsi/iscsi_tcp.c                       |    2 +-
 fs/lockd/host.c                                |    2 +-
 fs/nfs/super.c                                 |    2 +-
 include/linux/sunrpc/svc_xprt.h                |    2 +-
 include/net/ip_vs.h                            |    2 +-
 include/net/netfilter/nf_conntrack_tuple.h     |    2 +-
 include/net/sctp/sctp.h                        |    2 +-
 net/bridge/netfilter/ebt_log.c                 |    2 +-
 net/ipv4/tcp_input.c                           |    2 +-
 net/ipv4/tcp_timer.c                           |    2 +-
 net/ipv6/addrlabel.c                           |   10 ++++----
 net/ipv6/ah6.c                                 |    2 +-
 net/ipv6/esp6.c                                |    2 +-
 net/ipv6/exthdrs.c                             |    2 +-
 net/ipv6/icmp.c                                |    2 +-
 net/ipv6/ip6mr.c                               |    2 +-
 net/ipv6/ipcomp6.c                             |    2 +-
 net/ipv6/ndisc.c                               |    2 +-
 net/ipv6/netfilter/ip6t_LOG.c                  |    2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/ipv6/tcp_ipv6.c                            |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c                |    4 +-
 net/netfilter/ipvs/ip_vs_core.c                |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |    4 +-
 net/netfilter/ipvs/ip_vs_proto.c               |    6 ++--
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c        |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                |    8 +++---
 net/netfilter/nf_conntrack_ftp.c               |    2 +-
 net/netfilter/nf_conntrack_h323_main.c         |    4 +-
 net/netfilter/xt_hashlimit.c                   |    2 +-
 net/netfilter/xt_recent.c                      |    2 +-
 net/netlabel/netlabel_addrlist.c               |    2 +-
 net/sctp/ipv6.c                                |   18 +++++++-------
 net/sctp/sm_statefuns.c                        |    2 +-
 net/sunrpc/clnt.c                              |    2 +-
 net/sunrpc/rpcb_clnt.c                         |    2 +-
 net/sunrpc/svcauth_unix.c                      |    4 +-
 net/sunrpc/xprtsock.c                          |    8 +++---
 net/xfrm/xfrm_policy.c                         |    4 +-
 net/xfrm/xfrm_state.c                          |    4 +-
 security/selinux/avc.c                         |    2 +-
 49 files changed, 100 insertions(+), 100 deletions(-)

diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index 0a64720..acb82af 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -290,7 +290,7 @@ static ssize_t sprintf_ipaddr(char *buf, u8 *ip)
 		/*
 		 * IPv6
 		 */
-		str += sprintf(str, "%p6", ip);
+		str += sprintf(str, "%pI6", ip);
 	}
 	str += sprintf(str, "\n");
 	return str - buf;
diff --git a/drivers/infiniband/core/sysfs.c b/drivers/infiniband/core/sysfs.c
index e985193..4f4d1bb 100644
--- a/drivers/infiniband/core/sysfs.c
+++ b/drivers/infiniband/core/sysfs.c
@@ -262,7 +262,7 @@ static ssize_t show_port_gid(struct ib_port *p, struct port_attribute *attr,
 	if (ret)
 		return ret;
 
-	return sprintf(buf, "%p6\n", gid.raw);
+	return sprintf(buf, "%pI6\n", gid.raw);
 }
 
 static ssize_t show_port_pkey(struct ib_port *p, struct port_attribute *attr,
diff --git a/drivers/infiniband/hw/mthca/mthca_mcg.c b/drivers/infiniband/hw/mthca/mthca_mcg.c
index 693bed0..d4c8105 100644
--- a/drivers/infiniband/hw/mthca/mthca_mcg.c
+++ b/drivers/infiniband/hw/mthca/mthca_mcg.c
@@ -87,7 +87,7 @@ static int find_mgm(struct mthca_dev *dev,
 	}
 
 	if (0)
-		mthca_dbg(dev, "Hash for %p6 is %04x\n", gid, *hash);
+		mthca_dbg(dev, "Hash for %pI6 is %04x\n", gid, *hash);
 
 	*index = *hash;
 	*prev  = -1;
@@ -254,7 +254,7 @@ int mthca_multicast_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 		goto out;
 
 	if (index == -1) {
-		mthca_err(dev, "MGID %p6 not found\n", gid->raw);
+		mthca_err(dev, "MGID %pI6 not found\n", gid->raw);
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index d98d87b..47d588b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1128,7 +1128,7 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 		goto err_send_cm;
 	}
 
-	ipoib_dbg(priv, "Request connection 0x%x for gid %p6 qpn 0x%x\n",
+	ipoib_dbg(priv, "Request connection 0x%x for gid %pI6 qpn 0x%x\n",
 		  p->qp->qp_num, pathrec->dgid.raw, qpn);
 
 	return 0;
@@ -1276,7 +1276,7 @@ void ipoib_cm_destroy_tx(struct ipoib_cm_tx *tx)
 	if (test_and_clear_bit(IPOIB_FLAG_INITIALIZED, &tx->flags)) {
 		list_move(&tx->list, &priv->cm.reap_list);
 		queue_work(ipoib_workqueue, &priv->cm.reap_task);
-		ipoib_dbg(priv, "Reap connection for gid %p6\n",
+		ipoib_dbg(priv, "Reap connection for gid %pI6\n",
 			  tx->neigh->dgid.raw);
 		tx->neigh = NULL;
 	}
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index e7f4f94..b3a6718 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -359,7 +359,7 @@ void ipoib_mark_paths_invalid(struct net_device *dev)
 	spin_lock_irq(&priv->lock);
 
 	list_for_each_entry_safe(path, tp, &priv->path_list, list) {
-		ipoib_dbg(priv, "mark path LID 0x%04x GID %p6 invalid\n",
+		ipoib_dbg(priv, "mark path LID 0x%04x GID %pI6 invalid\n",
 			be16_to_cpu(path->pathrec.dlid),
 			path->pathrec.dgid.raw);
 		path->valid =  0;
@@ -413,10 +413,10 @@ static void path_rec_completion(int status,
 	unsigned long flags;
 
 	if (!status)
-		ipoib_dbg(priv, "PathRec LID 0x%04x for GID %p6\n",
+		ipoib_dbg(priv, "PathRec LID 0x%04x for GID %pI6\n",
 			  be16_to_cpu(pathrec->dlid), pathrec->dgid.raw);
 	else
-		ipoib_dbg(priv, "PathRec status %d for GID %p6\n",
+		ipoib_dbg(priv, "PathRec status %d for GID %pI6\n",
 			  status, path->pathrec.dgid.raw);
 
 	skb_queue_head_init(&skqueue);
@@ -527,7 +527,7 @@ static int path_rec_start(struct net_device *dev,
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	ipoib_dbg(priv, "Start path record lookup for %p6\n",
+	ipoib_dbg(priv, "Start path record lookup for %pI6\n",
 		  path->pathrec.dgid.raw);
 
 	init_completion(&path->done);
@@ -764,7 +764,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
 			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
-				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %p6\n",
+				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %pI6\n",
 					   skb->dst ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
 					   IPOIB_QPN(phdr->hwaddr),
@@ -844,7 +844,7 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 	else
 		return;
 	ipoib_dbg(priv,
-		  "neigh_cleanup for %06x %p6\n",
+		  "neigh_cleanup for %06x %pI6\n",
 		  IPOIB_QPN(n->ha),
 		  n->ha + 4);
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 0de79cf..a2eb3b9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -71,7 +71,7 @@ static void ipoib_mcast_free(struct ipoib_mcast *mcast)
 	struct ipoib_neigh *neigh, *tmp;
 	int tx_dropped = 0;
 
-	ipoib_dbg_mcast(netdev_priv(dev), "deleting multicast group %p6\n",
+	ipoib_dbg_mcast(netdev_priv(dev), "deleting multicast group %pI6\n",
 			mcast->mcmember.mgid.raw);
 
 	spin_lock_irq(&priv->lock);
@@ -204,7 +204,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 
 	if (!test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
 		if (test_and_set_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags)) {
-			ipoib_warn(priv, "multicast group %p6 already attached\n",
+			ipoib_warn(priv, "multicast group %pI6 already attached\n",
 				   mcast->mcmember.mgid.raw);
 
 			return 0;
@@ -213,7 +213,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 		ret = ipoib_mcast_attach(dev, be16_to_cpu(mcast->mcmember.mlid),
 					 &mcast->mcmember.mgid, set_qkey);
 		if (ret < 0) {
-			ipoib_warn(priv, "couldn't attach QP to multicast group %p6\n",
+			ipoib_warn(priv, "couldn't attach QP to multicast group %pI6\n",
 				   mcast->mcmember.mgid.raw);
 
 			clear_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags);
@@ -245,7 +245,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 			mcast->ah = ah;
 			spin_unlock_irq(&priv->lock);
 
-			ipoib_dbg_mcast(priv, "MGID %p6 AV %p, LID 0x%04x, SL %d\n",
+			ipoib_dbg_mcast(priv, "MGID %pI6 AV %p, LID 0x%04x, SL %d\n",
 					mcast->mcmember.mgid.raw,
 					mcast->ah->ah,
 					be16_to_cpu(mcast->mcmember.mlid),
@@ -291,7 +291,7 @@ ipoib_mcast_sendonly_join_complete(int status,
 
 	if (status) {
 		if (mcast->logcount++ < 20)
-			ipoib_dbg_mcast(netdev_priv(dev), "multicast join failed for %p6, status %d\n",
+			ipoib_dbg_mcast(netdev_priv(dev), "multicast join failed for %pI6, status %d\n",
 					mcast->mcmember.mgid.raw, status);
 
 		/* Flush out any queued packets */
@@ -351,7 +351,7 @@ static int ipoib_mcast_sendonly_join(struct ipoib_mcast *mcast)
 		ipoib_warn(priv, "ib_sa_join_multicast failed (ret = %d)\n",
 			   ret);
 	} else {
-		ipoib_dbg_mcast(priv, "no multicast record for %p6, starting join\n",
+		ipoib_dbg_mcast(priv, "no multicast record for %pI6, starting join\n",
 				mcast->mcmember.mgid.raw);
 	}
 
@@ -380,7 +380,7 @@ static int ipoib_mcast_join_complete(int status,
 	struct net_device *dev = mcast->dev;
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	ipoib_dbg_mcast(priv, "join completion for %p6 (status %d)\n",
+	ipoib_dbg_mcast(priv, "join completion for %pI6 (status %d)\n",
 			mcast->mcmember.mgid.raw, status);
 
 	/* We trap for port events ourselves. */
@@ -410,10 +410,10 @@ static int ipoib_mcast_join_complete(int status,
 
 	if (mcast->logcount++ < 20) {
 		if (status == -ETIMEDOUT) {
-			ipoib_dbg_mcast(priv, "multicast join failed for %p6, status %d\n",
+			ipoib_dbg_mcast(priv, "multicast join failed for %pI6, status %d\n",
 					mcast->mcmember.mgid.raw, status);
 		} else {
-			ipoib_warn(priv, "multicast join failed for %p6, status %d\n",
+			ipoib_warn(priv, "multicast join failed for %pI6, status %d\n",
 				   mcast->mcmember.mgid.raw, status);
 		}
 	}
@@ -446,7 +446,7 @@ static void ipoib_mcast_join(struct net_device *dev, struct ipoib_mcast *mcast,
 	ib_sa_comp_mask comp_mask;
 	int ret = 0;
 
-	ipoib_dbg_mcast(priv, "joining MGID %p6\n", mcast->mcmember.mgid.raw);
+	ipoib_dbg_mcast(priv, "joining MGID %pI6\n", mcast->mcmember.mgid.raw);
 
 	rec.mgid     = mcast->mcmember.mgid;
 	rec.port_gid = priv->local_gid;
@@ -631,7 +631,7 @@ static int ipoib_mcast_leave(struct net_device *dev, struct ipoib_mcast *mcast)
 		ib_sa_free_multicast(mcast->mc);
 
 	if (test_and_clear_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags)) {
-		ipoib_dbg_mcast(priv, "leaving MGID %p6\n",
+		ipoib_dbg_mcast(priv, "leaving MGID %pI6\n",
 				mcast->mcmember.mgid.raw);
 
 		/* Remove ourselves from the multicast group */
@@ -663,7 +663,7 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 	mcast = __ipoib_mcast_find(dev, mgid);
 	if (!mcast) {
 		/* Let's create a new send only group now */
-		ipoib_dbg_mcast(priv, "setting up send only multicast group for %p6\n",
+		ipoib_dbg_mcast(priv, "setting up send only multicast group for %pI6\n",
 				mgid);
 
 		mcast = ipoib_mcast_alloc(dev, 0);
@@ -797,13 +797,13 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 			/* ignore group which is directly joined by userspace */
 			if (test_bit(IPOIB_FLAG_UMCAST, &priv->flags) &&
 			    !ib_sa_get_mcmember_rec(priv->ca, priv->port, &mgid, &rec)) {
-				ipoib_dbg_mcast(priv, "ignoring multicast entry for mgid %p6\n",
+				ipoib_dbg_mcast(priv, "ignoring multicast entry for mgid %pI6\n",
 						mgid.raw);
 				continue;
 			}
 
 			/* Not found or send-only group, let's add a new entry */
-			ipoib_dbg_mcast(priv, "adding multicast entry for mgid %p6\n",
+			ipoib_dbg_mcast(priv, "adding multicast entry for mgid %pI6\n",
 					mgid.raw);
 
 			nmcast = ipoib_mcast_alloc(dev, 0);
@@ -837,7 +837,7 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 	list_for_each_entry_safe(mcast, tmcast, &priv->multicast_list, list) {
 		if (!test_bit(IPOIB_MCAST_FLAG_FOUND, &mcast->flags) &&
 		    !test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
-			ipoib_dbg_mcast(priv, "deleting multicast group %p6\n",
+			ipoib_dbg_mcast(priv, "deleting multicast group %pI6\n",
 					mcast->mcmember.mgid.raw);
 
 			rb_erase(&mcast->rb_node, &priv->multicast_tree);
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index bc82531..7c13db8 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -1514,7 +1514,7 @@ static ssize_t show_dgid(struct device *dev, struct device_attribute *attr,
 	    target->state == SRP_TARGET_REMOVED)
 		return -ENODEV;
 
-	return sprintf(buf, "%p6\n", target->path.dgid.raw);
+	return sprintf(buf, "%pI6\n", target->path.dgid.raw);
 }
 
 static ssize_t show_orig_dgid(struct device *dev,
@@ -1526,7 +1526,7 @@ static ssize_t show_orig_dgid(struct device *dev,
 	    target->state == SRP_TARGET_REMOVED)
 		return -ENODEV;
 
-	return sprintf(buf, "%p6\n", target->orig_dgid);
+	return sprintf(buf, "%pI6\n", target->orig_dgid);
 }
 
 static ssize_t show_zero_req_lim(struct device *dev,
@@ -1867,7 +1867,7 @@ static ssize_t srp_create_target(struct device *dev,
 
 	shost_printk(KERN_DEBUG, target->scsi_host, PFX
 		     "new target: id_ext %016llx ioc_guid %016llx pkey %04x "
-		     "service_id %016llx dgid %p6\n",
+		     "service_id %016llx dgid %pI6\n",
 	       (unsigned long long) be64_to_cpu(target->id_ext),
 	       (unsigned long long) be64_to_cpu(target->ioc_guid),
 	       be16_to_cpu(target->path.pkey),
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 6f79e84..b162206 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -118,7 +118,7 @@ static int find_mgm(struct mlx4_dev *dev,
 		return err;
 
 	if (0)
-		mlx4_dbg(dev, "Hash for %p6 is %04x\n", gid, *hash);
+		mlx4_dbg(dev, "Hash for %pI6 is %04x\n", gid, *hash);
 
 	*index = *hash;
 	*prev  = -1;
@@ -267,7 +267,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 		goto out;
 
 	if (index == -1) {
-		mlx4_err(dev, "MGID %p6 not found\n", gid);
+		mlx4_err(dev, "MGID %pI6 not found\n", gid);
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index ef929ae..24d0902 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -1608,7 +1608,7 @@ static int iscsi_tcp_get_addr(struct iscsi_conn *conn, struct socket *sock,
 	case AF_INET6:
 		sin6 = (struct sockaddr_in6 *)addr;
 		spin_lock_bh(&conn->session->lock);
-		sprintf(buf, "%p6", &sin6->sin6_addr);
+		sprintf(buf, "%pI6", &sin6->sin6_addr);
 		*port = be16_to_cpu(sin6->sin6_port);
 		spin_unlock_bh(&conn->session->lock);
 		break;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 344e6b4..c8ab7d7 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -122,7 +122,7 @@ static void nlm_display_address(const struct sockaddr *sap,
 			snprintf(buf, len, NIPQUAD_FMT,
 				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
 		else
-			snprintf(buf, len, "%p6", &sin6->sin6_addr);
+			snprintf(buf, len, "%pI6", &sin6->sin6_addr);
 		break;
 	default:
 		snprintf(buf, len, "unsupported address family");
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5fe7721..eb391d8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -468,7 +468,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	}
 	case AF_INET6: {
 		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-		seq_printf(m, ",mountaddr=%p6", &sin6->sin6_addr);
+		seq_printf(m, ",mountaddr=%pI6", &sin6->sin6_addr);
 		break;
 	}
 	default:
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 42e01c9..51cb75e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -145,7 +145,7 @@ static inline char *__svc_print_addr(struct sockaddr *addr,
 		break;
 
 	case AF_INET6:
-		snprintf(buf, len, "%p6, port=%u",
+		snprintf(buf, len, "%pI6, port=%u",
 			 &((struct sockaddr_in6 *)addr)->sin6_addr,
 			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
 		break;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 6a66920..af48cad 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -87,7 +87,7 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 	int len;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		len = snprintf(&buf[*idx], buf_len - *idx, "[%p6]",
+		len = snprintf(&buf[*idx], buf_len - *idx, "[%pI6]",
 			       &addr->in6) + 1;
 	else
 #endif
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index 303efaf..42f1fc9 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -122,7 +122,7 @@ static inline void nf_ct_dump_tuple_ip(const struct nf_conntrack_tuple *t)
 static inline void nf_ct_dump_tuple_ipv6(const struct nf_conntrack_tuple *t)
 {
 #ifdef DEBUG
-	printk("tuple %p: %u %p6 %hu -> %p6 %hu\n",
+	printk("tuple %p: %u %pI6 %hu -> %pI6 %hu\n",
 	       t, t->dst.protonum,
 	       t->src.u3.all, ntohs(t->src.u.all),
 	       t->dst.u3.all, ntohs(t->dst.u.all));
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 85e9157..5d0aa80 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -285,7 +285,7 @@ extern int sctp_debug_flag;
 	if (sctp_debug_flag) { \
 		if (saddr->sa.sa_family == AF_INET6) { \
 			printk(KERN_DEBUG \
-			       lead %p6 trail, \
+			       lead %pI6 trail, \
 			       leadparm, \
 			       &saddr->v6.sin6_addr, \
 			       otherparms); \
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 3654f3e..5e7cff3 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -133,7 +133,7 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 			printk(" INCOMPLETE IPv6 header");
 			goto out;
 		}
-		printk(" IPv6 SRC=%p6 IPv6 DST=%p6, IPv6 priority=0x%01X, Next Header=%d",
+		printk(" IPv6 SRC=%pI6 IPv6 DST=%pI6, IPv6 priority=0x%01X, Next Header=%d",
 		       &ih->saddr, &ih->daddr, ih->priority, ih->nexthdr);
 		nexthdr = ih->nexthdr;
 		offset_ph = ipv6_skip_exthdr(skb, sizeof(_iph), &nexthdr);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 191c06b..04909e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2346,7 +2346,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	else if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
-		printk(KERN_DEBUG "Undo %s %p6/%u c%u l%u ss%u/%u p%u\n",
+		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
 		       &np->daddr, ntohs(inet->dport),
 		       tp->snd_cwnd, tcp_left_out(tp),
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4e6ee52..979c9d6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -306,7 +306,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %p6:%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %pI6:%u/%u shrinks window %u:%u. Repaired.\n",
 			       &np->daddr, ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index d280366..6ff73c4 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -186,7 +186,7 @@ u32 ipv6_addr_label(struct net *net,
 	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
 	rcu_read_unlock();
 
-	ADDRLABEL(KERN_DEBUG "%s(addr=%p6, type=%d, ifindex=%d) => %08x\n",
+	ADDRLABEL(KERN_DEBUG "%s(addr=%pI6, type=%d, ifindex=%d) => %08x\n",
 		  __func__, addr, type, ifindex, label);
 
 	return label;
@@ -201,7 +201,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	struct ip6addrlbl_entry *newp;
 	int addrtype;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d, label=%u)\n",
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%pI6, prefixlen=%d, ifindex=%d, label=%u)\n",
 		  __func__, prefix, prefixlen, ifindex, (unsigned int)label);
 
 	addrtype = ipv6_addr_type(prefix) & (IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK);
@@ -289,7 +289,7 @@ static int ip6addrlbl_add(struct net *net,
 	struct ip6addrlbl_entry *newp;
 	int ret = 0;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%pI6, prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
 		  __func__, prefix, prefixlen, ifindex, (unsigned int)label,
 		  replace);
 
@@ -313,7 +313,7 @@ static int __ip6addrlbl_del(struct net *net,
 	struct hlist_node *pos, *n;
 	int ret = -ESRCH;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d)\n",
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%pI6, prefixlen=%d, ifindex=%d)\n",
 		  __func__, prefix, prefixlen, ifindex);
 
 	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
@@ -337,7 +337,7 @@ static int ip6addrlbl_del(struct net *net,
 	struct in6_addr prefix_buf;
 	int ret;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d)\n",
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%pI6, prefixlen=%d, ifindex=%d)\n",
 		  __func__, prefix, prefixlen, ifindex);
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 9bc43f2..7a8a013 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -419,7 +419,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/%p6\n",
+	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/%pI6\n",
 		 ntohl(ah->spi), &iph->daddr);
 
 	xfrm_state_put(x);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ec4be18..c02a630 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -367,7 +367,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%p6\n",
+	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
 			ntohl(esph->spi), &iph->daddr);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a890514..1c7f400 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -219,7 +219,7 @@ static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
 
 	if (!(ipv6_addr_type(&hao->addr) & IPV6_ADDR_UNICAST)) {
 		LIMIT_NETDEBUG(
-			KERN_DEBUG "hao is not an unicast addr: %p6\n", &hao->addr);
+			KERN_DEBUG "hao is not an unicast addr: %pI6\n", &hao->addr);
 		goto discard;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1b72446..1677105 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -680,7 +680,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		skb->csum = ~csum_unfold(csum_ipv6_magic(saddr, daddr, skb->len,
 					     IPPROTO_ICMPV6, 0));
 		if (__skb_checksum_complete(skb)) {
-			LIMIT_NETDEBUG(KERN_DEBUG "ICMPv6 checksum failed [%p6 > %p6]\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "ICMPv6 checksum failed [%pI6 > %pI6]\n",
 				       saddr, daddr);
 			goto discard_it;
 		}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 798e6a2..c491fb9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -297,7 +297,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc6_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%p6 %p6 %-3d %8ld %8ld %8ld",
+		seq_printf(seq, "%pI6 %pI6 %-3d %8ld %8ld %8ld",
 			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
 			   mfc->mf6c_parent,
 			   mfc->mfc_un.res.pkt,
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 9566d8f..d4576a9 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -67,7 +67,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%p6\n",
+	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%pI6\n",
 			spi, &iph->daddr);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 191bb07..2a6752d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -647,7 +647,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
-			ND_PRINTK1(KERN_DEBUG "%s(): trying to ucast probe in NUD_INVALID: %p6\n",
+			ND_PRINTK1(KERN_DEBUG "%s(): trying to ucast probe in NUD_INVALID: %pI6\n",
 				   __func__, target);
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index a61ce30..02885e8 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -61,7 +61,7 @@ static void dump_packet(const struct nf_loginfo *info,
 	}
 
 	/* Max length: 88 "SRC=0000.0000.0000.0000.0000.0000.0000.0000 DST=0000.0000.0000.0000.0000.0000.0000.0000 " */
-	printk("SRC=%p6 DST=%p6 ", &ih->saddr, &ih->daddr);
+	printk("SRC=%pI6 DST=%pI6 ", &ih->saddr, &ih->daddr);
 
 	/* Max length: 44 "LEN=65535 TC=255 HOPLIMIT=255 FLOWLBL=FFFFF " */
 	printk("LEN=%Zu TC=%u HOPLIMIT=%u FLOWLBL=%u ",
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index b165a27..727b953 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -56,7 +56,7 @@ static bool ipv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int ipv6_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "src=%p6 dst=%p6 ",
+	return seq_printf(s, "src=%pI6 dst=%pI6 ",
 			  tuple->src.u3.ip6, tuple->dst.u3.ip6);
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 483550c..9842764 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -872,7 +872,7 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash %s for (%p6, %u)->(%p6, %u)\n",
+			printk(KERN_INFO "MD5 Hash %s for (%pI6, %u)->(%pI6, %u)\n",
 			       genhash ? "failed" : "mismatch",
 			       &ip6h->saddr, ntohs(th->source),
 			       &ip6h->daddr, ntohs(th->dest));
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 89bf65b..60aba45 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -820,7 +820,7 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq, "%-3s %p6 %04X %p6 %04X %p6 %04X %-11s %7lu\n",
+			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
@@ -881,7 +881,7 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq, "%-3s %p6 %04X %p6 %04X %p6 %04X %-11s %-6s %7lu\n",
+			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9400587..c3c6844 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -805,7 +805,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %p6->%p6\n",
+	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6->%pI6\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
@@ -1175,7 +1175,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %p6->%p6\n",
+	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6->%pI6\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 28c47c0..76db27e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1867,7 +1867,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
-				seq_printf(seq, "%s  [%p6]:%04X %s ",
+				seq_printf(seq, "%s  [%pI6]:%04X %s ",
 					   ip_vs_proto_name(svc->protocol),
 					   &svc->addr.in6,
 					   ntohs(svc->port),
@@ -1895,7 +1895,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 #ifdef CONFIG_IP_VS_IPV6
 			if (dest->af == AF_INET6)
 				seq_printf(seq,
-					   "  -> [%p6]:%04X"
+					   "  -> [%pI6]:%04X"
 					   "      %-7s %-6d %-10d %-10d\n",
 					   &dest->addr.in6,
 					   ntohs(dest->port),
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index d7ce4f1..54cd67f 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -203,7 +203,7 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%s %p6->%p6 frag",
+		sprintf(buf, "%s %pI6->%pI6 frag",
 			pp->name, &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
@@ -211,10 +211,10 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %p6->%p6",
+			sprintf(buf, "%s TRUNCATED %pI6->%pI6",
 				pp->name, &ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %p6:%u->%p6:%u",
+			sprintf(buf, "%s %pI6:%u->%pI6:%u",
 				pp->name,
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 59f2d11..6ede888 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -154,7 +154,7 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else
-		sprintf(buf, "%s %p6->%p6",
+		sprintf(buf, "%s %pI6->%pI6",
 			pp->name, &ih->saddr, &ih->daddr);
 
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index be34c33..fc342dd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -141,12 +141,12 @@ __ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
 								 NULL, &fl);
 			if (!rt) {
 				spin_unlock(&dest->dst_lock);
-				IP_VS_DBG_RL("ip6_route_output error, dest: %p6\n",
+				IP_VS_DBG_RL("ip6_route_output error, dest: %pI6\n",
 					     &dest->addr.in6);
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
-			IP_VS_DBG(10, "new dst %p6, refcnt=%d\n",
+			IP_VS_DBG(10, "new dst %pI6, refcnt=%d\n",
 				  &dest->addr.in6,
 				  atomic_read(&rt->u.dst.__refcnt));
 		}
@@ -166,7 +166,7 @@ __ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
 
 		rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
 		if (!rt) {
-			IP_VS_DBG_RL("ip6_route_output error, dest: %p6\n",
+			IP_VS_DBG_RL("ip6_route_output error, dest: %pI6\n",
 				     &cp->daddr.in6);
 			return NULL;
 		}
@@ -300,7 +300,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
 	if (!rt) {
-		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, dest: %p6\n",
+		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, dest: %pI6\n",
 			     &iph->daddr);
 		goto tx_error_icmp;
 	}
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index a90d463..493d773 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -467,7 +467,7 @@ static int help(struct sk_buff *skb,
 				 NIPQUAD(cmd.u3.ip),
 				 NIPQUAD(ct->tuplehash[dir].tuple.src.u3.ip));
 		} else {
-			pr_debug("conntrack_ftp: NOT RECORDING: %p6 != %p6\n",
+			pr_debug("conntrack_ftp: NOT RECORDING: %pI6 != %pI6\n",
 				 cmd.u3.ip6, 
 				 ct->tuplehash[dir].tuple.src.u3.ip6);
 		}
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 29e49b1..99bc803 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -850,7 +850,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set destCallSignalAddress %p6:%hu->%p6:%hu\n",
+		pr_debug("nf_ct_q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
@@ -866,7 +866,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set sourceCallSignalAddress %p6:%hu->%p6:%hu\n",
+		pr_debug("nf_ct_q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index f04c6ed..6379717 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -904,7 +904,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				 ent->rateinfo.cost);
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	case NFPROTO_IPV6:
-		return seq_printf(s, "%ld %p6:%u->%p6:%u %u %u %u\n",
+		return seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip6.src,
 				 ntohs(ent->dst.src_port),
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index a377ea3..b785727 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -426,7 +426,7 @@ static int recent_seq_show(struct seq_file *seq, void *v)
 			   "oldest_pkt: %u", NIPQUAD(e->addr.ip), e->ttl,
 			   e->stamps[i], e->index);
 	else
-		seq_printf(seq, "src=%p6 ttl: %u last_seen: %lu oldest_pkt: %u",
+		seq_printf(seq, "src=%pI6 ttl: %u last_seen: %lu oldest_pkt: %u",
 			   &e->addr.in6, e->ttl, e->stamps[i], e->index);
 	for (i = 0; i < e->nstamps; i++)
 		seq_printf(seq, "%s %lu", i ? "," : "", e->stamps[i]);
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index 614c95e..8b1c58b 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -370,7 +370,7 @@ void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 
 	if (dev != NULL)
 		audit_log_format(audit_buf, " netif=%s", dev);
-	audit_log_format(audit_buf, " %s=%p6", dir, addr);
+	audit_log_format(audit_buf, " %s=%pI6", dir, addr);
 	if (ntohl(mask->s6_addr32[3]) != 0xffffffff) {
 		u32 mask_len = 0;
 		u32 mask_val;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e82668b..ceaa4aa 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -223,7 +223,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%p6 dst:%p6\n",
+	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI6 dst:%pI6\n",
 			  __func__, skb, skb->len,
 			  &fl.fl6_src, &fl.fl6_dst);
 
@@ -251,18 +251,18 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 		fl.oif = daddr->v6.sin6_scope_id;
 

-	SCTP_DEBUG_PRINTK("%s: DST=%p6 ", __func__, &fl.fl6_dst);
+	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl.fl6_dst);
 
 	if (saddr) {
 		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("SRC=%p6 - ", &fl.fl6_src);
+		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl.fl6_src);
 	}
 
 	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
-		SCTP_DEBUG_PRINTK("rt6_dst:%p6 rt6_src:%p6\n",
+		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
 			&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
 		return dst;
 	}
@@ -309,7 +309,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 
-	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%p6 ",
+	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%pI6 ",
 			  __func__, asoc, dst, &daddr->v6.sin6_addr);
 
 	if (!asoc) {
@@ -318,7 +318,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 				   &daddr->v6.sin6_addr,
 				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: %p6\n",
+		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: %pI6\n",
 				  &saddr->v6.sin6_addr);
 		return;
 	}
@@ -347,10 +347,10 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 
 	if (baddr) {
 		memcpy(saddr, baddr, sizeof(union sctp_addr));
-		SCTP_DEBUG_PRINTK("saddr: %p6\n", &saddr->v6.sin6_addr);
+		SCTP_DEBUG_PRINTK("saddr: %pI6\n", &saddr->v6.sin6_addr);
 	} else {
 		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
-		       "address for the dest:%p6\n",
+		       "address for the dest:%pI6\n",
 		       __func__, asoc, &daddr->v6.sin6_addr);
 	}
 
@@ -720,7 +720,7 @@ static int sctp_v6_is_ce(const struct sk_buff *skb)
 /* Dump the v6 addr to the seq file. */
 static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 {
-	seq_printf(seq, "%p6 ", &addr->v6.sin6_addr);
+	seq_printf(seq, "%pI6 ", &addr->v6.sin6_addr);
 }
 
 static void sctp_v6_ecn_capable(struct sock *sk)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9f37096..d07b484 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1123,7 +1123,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 		if (from_addr.sa.sa_family == AF_INET6) {
 			if (net_ratelimit())
 				printk(KERN_WARNING
-				    "%s association %p could not find address %p6\n",
+				    "%s association %p could not find address %pI6\n",
 				    __func__,
 				    asoc,
 				    &from_addr.v6.sin6_addr);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 26f61fd..8f06749 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -278,7 +278,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		case AF_INET6: {
 			struct sockaddr_in6 *sin =
 					(struct sockaddr_in6 *)args->address;
-			snprintf(servername, sizeof(servername), "%p6",
+			snprintf(servername, sizeof(servername), "%pI6",
 				 &sin->sin6_addr);
 			break;
 		}
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 968ec1f..4c8adad 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -305,7 +305,7 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
 		snprintf(buf, sizeof(buf), "::.%u.%u",
 				port >> 8, port & 0xff);
 	else
-		snprintf(buf, sizeof(buf), "%p6.%u.%u",
+		snprintf(buf, sizeof(buf), "%pI6.%u.%u",
 			 &address_to_register->sin6_addr,
 			 port >> 8, port & 0xff);
 	map->r_addr = buf;
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index eb640c1..16f714a 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -168,7 +168,7 @@ static void ip_map_request(struct cache_detail *cd,
 				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
 				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
 	} else {
-		snprintf(text_addr, 40, "%p6", &im->m_addr);
+		snprintf(text_addr, 40, "%pI6", &im->m_addr);
 	}
 	qword_add(bpp, blen, im->m_class);
 	qword_add(bpp, blen, text_addr);
@@ -286,7 +286,7 @@ static int ip_map_show(struct seq_file *m,
 			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
 			dom);
 	} else {
-		seq_printf(m, "%s %p6 %s\n", im->m_class, &addr, dom);
+		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);
 	}
 	return 0;
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3c9aff5..f9ce3c9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -341,7 +341,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(40, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 40, "%p6",&addr->sin6_addr);
+		snprintf(buf, 40, "%pI6",&addr->sin6_addr);
 	}
 	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
 
@@ -356,7 +356,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(64, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 64, "addr=%p6 port=%u proto=%s",
+		snprintf(buf, 64, "addr=%pI6 port=%u proto=%s",
 				&addr->sin6_addr,
 				ntohs(addr->sin6_port),
 				protocol);
@@ -378,7 +378,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(50, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 50, "%p6.%u.%u",
+		snprintf(buf, 50, "%pI6.%u.%u",
 			 &addr->sin6_addr,
 			 ntohs(addr->sin6_port) >> 8,
 			 ntohs(addr->sin6_port) & 0xff);
@@ -1407,7 +1407,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
-	dprintk("RPC:       xs_bind6 %p6:%u: %s (%d)\n",
+	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
 		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
 	return err;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f052b06..80b13ee 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2467,11 +2467,11 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 					 sel->prefixlen_d);
 		break;
 	case AF_INET6:
-		audit_log_format(audit_buf, " src=%p6", sel->saddr.a6);
+		audit_log_format(audit_buf, " src=%pI6", sel->saddr.a6);
 		if (sel->prefixlen_s != 128)
 			audit_log_format(audit_buf, " src_prefixlen=%d",
 					 sel->prefixlen_s);
-		audit_log_format(audit_buf, " dst=%p6", sel->daddr.a6);
+		audit_log_format(audit_buf, " dst=%pI6", sel->daddr.a6);
 		if (sel->prefixlen_d != 128)
 			audit_log_format(audit_buf, " dst_prefixlen=%d",
 					 sel->prefixlen_d);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7944861..304eca4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2115,7 +2115,7 @@ static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
 				 NIPQUAD(x->id.daddr.a4));
 		break;
 	case AF_INET6:
-		audit_log_format(audit_buf, " src=%p6 dst=%p6",
+		audit_log_format(audit_buf, " src=%pI6 dst=%pI6",
 				 x->props.saddr.a6, x->id.daddr.a6);
 		break;
 	}
@@ -2140,7 +2140,7 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 	case AF_INET6:
 		iph6 = ipv6_hdr(skb);
 		audit_log_format(audit_buf,
-				 " src=%p6 dst=%p6 flowlbl=0x%x%02x%02x",
+				 " src=%pI6 dst=%pI6 flowlbl=0x%x%02x%02x",
 				 &iph6->saddr,&iph6->daddr,
 				 iph6->flow_lbl[0] & 0x0f,
 				 iph6->flow_lbl[1],
diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index c91008f..ed6af12 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -495,7 +495,7 @@ static inline void avc_print_ipv6_addr(struct audit_buffer *ab,
 				       char *name1, char *name2)
 {
 	if (!ipv6_addr_any(addr))
-		audit_log_format(ab, " %s=%p6", name1, addr);
+		audit_log_format(ab, " %s=%pI6", name1, addr);
 	if (port)
 		audit_log_format(ab, " %s=%d", name2, ntohs(port));
 }
-- 
1.6.0.3.756.gb776d


