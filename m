From: "Nikolova, Tatyana E" <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH V2 1/4] RDMA/cma: Add IPv6 support for iWARP.
Date: Wed, 12 Jun 2013 19:56:37 +0000
Message-ID: <13AA599688F47243B14FCFCCC2C803BB0D814E35@FMSMSX104.amr.corp.intel.com>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com>
 <1371037302-3586-2-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org" <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"Lacombe, John S" <john.s.lacombe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1371037302-3586-2-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Steve,

I reviewed the iWarp IPv6 nes patch.

Thanks,
Tatyana

-----Original Message-----
From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Vipul Pandya
Sent: Wednesday, June 12, 2013 6:42 AM
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org; roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; Hefty, Sean; hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org; Latif, Faisal; akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org; sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org; nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH V2 1/4] RDMA/cma: Add IPv6 support for iWARP.

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

This patch modifies the type of local_addr and remote_addr fields in struct
iw_cm_id from struct sockaddr_in to struct sockaddr_storage to hold IPv6 and
IPv4 addresses uniformly. It changes the references of local_addr and
remote_addr in RDMA/cxgb4, RDMA/cxgb3, RDMA/nes and amso drivers such that build
failure is avoided. However to be able to actully run the traffic over IPv6
address respective drivers have to add supportive code.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
V2: Used local variables instead of typecasting in patch 1/4.

 drivers/infiniband/core/cma.c          |  69 ++++++++-------
 drivers/infiniband/hw/amso1100/c2_ae.c |  18 ++--
 drivers/infiniband/hw/amso1100/c2_cm.c |  16 +++-
 drivers/infiniband/hw/cxgb3/iwch_cm.c  |  46 ++++++----
 drivers/infiniband/hw/cxgb4/cm.c       |  55 ++++++------
 drivers/infiniband/hw/nes/nes_cm.c     | 148 ++++++++++++++++++---------------
 include/rdma/iw_cm.h                   |   8 +-
 7 files changed, 205 insertions(+), 155 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 34fbc2f..72b15c1 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1335,8 +1335,9 @@ static int cma_iw_handler(struct iw_cm_id *iw_id, struct iw_cm_event *iw_event)
 {
 	struct rdma_id_private *id_priv = iw_id->context;
 	struct rdma_cm_event event;
-	struct sockaddr_in *sin;
 	int ret = 0;
+	struct sockaddr *laddr = (struct sockaddr *)&iw_event->local_addr;
+	struct sockaddr *raddr = (struct sockaddr *)&iw_event->remote_addr;
 
 	if (cma_disable_callback(id_priv, RDMA_CM_CONNECT))
 		return 0;
@@ -1347,10 +1348,10 @@ static int cma_iw_handler(struct iw_cm_id *iw_id, struct iw_cm_event *iw_event)
 		event.event = RDMA_CM_EVENT_DISCONNECTED;
 		break;
 	case IW_CM_EVENT_CONNECT_REPLY:
-		sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
-		*sin = iw_event->local_addr;
-		sin = (struct sockaddr_in *) &id_priv->id.route.addr.dst_addr;
-		*sin = iw_event->remote_addr;
+		memcpy(&id_priv->id.route.addr.src_addr, laddr,
+		       ip_addr_size(laddr));
+		memcpy(&id_priv->id.route.addr.dst_addr, raddr,
+		       ip_addr_size(raddr));
 		switch (iw_event->status) {
 		case 0:
 			event.event = RDMA_CM_EVENT_ESTABLISHED;
@@ -1400,11 +1401,12 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 {
 	struct rdma_cm_id *new_cm_id;
 	struct rdma_id_private *listen_id, *conn_id;
-	struct sockaddr_in *sin;
 	struct net_device *dev = NULL;
 	struct rdma_cm_event event;
 	int ret;
 	struct ib_device_attr attr;
+	struct sockaddr *laddr = (struct sockaddr *)&iw_event->local_addr;
+	struct sockaddr *raddr = (struct sockaddr *)&iw_event->remote_addr;
 
 	listen_id = cm_id->context;
 	if (cma_disable_callback(listen_id, RDMA_CM_LISTEN))
@@ -1422,14 +1424,7 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 	mutex_lock_nested(&conn_id->handler_mutex, SINGLE_DEPTH_NESTING);
 	conn_id->state = RDMA_CM_CONNECT;
 
-	dev = ip_dev_find(&init_net, iw_event->local_addr.sin_addr.s_addr);
-	if (!dev) {
-		ret = -EADDRNOTAVAIL;
-		mutex_unlock(&conn_id->handler_mutex);
-		rdma_destroy_id(new_cm_id);
-		goto out;
-	}
-	ret = rdma_copy_addr(&conn_id->id.route.addr.dev_addr, dev, NULL);
+	ret = rdma_translate_ip(laddr, &conn_id->id.route.addr.dev_addr);
 	if (ret) {
 		mutex_unlock(&conn_id->handler_mutex);
 		rdma_destroy_id(new_cm_id);
@@ -1447,10 +1442,8 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 	cm_id->context = conn_id;
 	cm_id->cm_handler = cma_iw_handler;
 
-	sin = (struct sockaddr_in *) &new_cm_id->route.addr.src_addr;
-	*sin = iw_event->local_addr;
-	sin = (struct sockaddr_in *) &new_cm_id->route.addr.dst_addr;
-	*sin = iw_event->remote_addr;
+	memcpy(&new_cm_id->route.addr.src_addr, laddr, ip_addr_size(laddr));
+	memcpy(&new_cm_id->route.addr.dst_addr, raddr, ip_addr_size(raddr));
 
 	ret = ib_query_device(conn_id->id.device, &attr);
 	if (ret) {
@@ -1526,8 +1519,9 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 static int cma_iw_listen(struct rdma_id_private *id_priv, int backlog)
 {
 	int ret;
-	struct sockaddr_in *sin;
 	struct iw_cm_id	*id;
+	struct sockaddr *src_addr = (struct sockaddr *)
+				    &id_priv->id.route.addr.src_addr;
 
 	id = iw_create_cm_id(id_priv->id.device,
 			     iw_conn_req_handler,
@@ -1537,8 +1531,8 @@ static int cma_iw_listen(struct rdma_id_private *id_priv, int backlog)
 
 	id_priv->cm_id.iw = id;
 
-	sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
-	id_priv->cm_id.iw->local_addr = *sin;
+	memcpy(&id_priv->cm_id.iw->local_addr, src_addr,
+	       ip_addr_size(src_addr));
 
 	ret = iw_cm_listen(id_priv->cm_id.iw, backlog);
 
@@ -2128,13 +2122,28 @@ int rdma_set_afonly(struct rdma_cm_id *id, int afonly)
 }
 EXPORT_SYMBOL(rdma_set_afonly);
 
+static inline void set_port(struct sockaddr *sa, u16 port)
+{
+	struct sockaddr_in *sa_in = (struct sockaddr_in *)sa;
+	struct sockaddr_in6 *sa_in6 = (struct sockaddr_in6 *)sa;
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		sa_in->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		sa_in6->sin6_port = htons(port);
+		break;
+	}
+}
+
 static void cma_bind_port(struct rdma_bind_list *bind_list,
 			  struct rdma_id_private *id_priv)
 {
-	struct sockaddr_in *sin;
+	struct sockaddr *src_addr = (struct sockaddr *)
+				    &id_priv->id.route.addr.src_addr;
 
-	sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
-	sin->sin_port = htons(bind_list->port);
+	set_port(src_addr, bind_list->port);
 	id_priv->bind_list = bind_list;
 	hlist_add_head(&id_priv->node, &bind_list->owners);
 }
@@ -2658,9 +2667,12 @@ static int cma_connect_iw(struct rdma_id_private *id_priv,
 			  struct rdma_conn_param *conn_param)
 {
 	struct iw_cm_id *cm_id;
-	struct sockaddr_in* sin;
 	int ret;
 	struct iw_cm_conn_param iw_param;
+	struct sockaddr *src_addr = (struct sockaddr *)
+				    &id_priv->id.route.addr.src_addr;
+	struct sockaddr *dst_addr = (struct sockaddr *)
+				    &id_priv->id.route.addr.dst_addr;
 
 	cm_id = iw_create_cm_id(id_priv->id.device, cma_iw_handler, id_priv);
 	if (IS_ERR(cm_id))
@@ -2668,11 +2680,8 @@ static int cma_connect_iw(struct rdma_id_private *id_priv,
 
 	id_priv->cm_id.iw = cm_id;
 
-	sin = (struct sockaddr_in*) &id_priv->id.route.addr.src_addr;
-	cm_id->local_addr = *sin;
-
-	sin = (struct sockaddr_in*) &id_priv->id.route.addr.dst_addr;
-	cm_id->remote_addr = *sin;
+	memcpy(&cm_id->local_addr, src_addr, ip_addr_size(src_addr));
+	memcpy(&cm_id->remote_addr, dst_addr, ip_addr_size(dst_addr));
 
 	ret = cma_modify_qp_rtr(id_priv, conn_param);
 	if (ret)
diff --git a/drivers/infiniband/hw/amso1100/c2_ae.c b/drivers/infiniband/hw/amso1100/c2_ae.c
index 706cf97..d5d1929 100644
--- a/drivers/infiniband/hw/amso1100/c2_ae.c
+++ b/drivers/infiniband/hw/amso1100/c2_ae.c
@@ -155,6 +155,8 @@ void c2_ae_event(struct c2_dev *c2dev, u32 mq_index)
 	enum c2_event_id event_id;
 	unsigned long flags;
 	int status;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_event.local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_event.remote_addr;
 
 	/*
 	 * retrieve the message
@@ -206,10 +208,10 @@ void c2_ae_event(struct c2_dev *c2dev, u32 mq_index)
 		case CCAE_ACTIVE_CONNECT_RESULTS:
 			res = &wr->ae.ae_active_connect_results;
 			cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
-			cm_event.local_addr.sin_addr.s_addr = res->laddr;
-			cm_event.remote_addr.sin_addr.s_addr = res->raddr;
-			cm_event.local_addr.sin_port = res->lport;
-			cm_event.remote_addr.sin_port =	res->rport;
+			laddr->sin_addr.s_addr = res->laddr;
+			raddr->sin_addr.s_addr = res->raddr;
+			laddr->sin_port = res->lport;
+			raddr->sin_port = res->rport;
 			if (status == 0) {
 				cm_event.private_data_len =
 					be32_to_cpu(res->private_data_length);
@@ -281,10 +283,10 @@ void c2_ae_event(struct c2_dev *c2dev, u32 mq_index)
 		}
 		cm_event.event = IW_CM_EVENT_CONNECT_REQUEST;
 		cm_event.provider_data = (void*)(unsigned long)req->cr_handle;
-		cm_event.local_addr.sin_addr.s_addr = req->laddr;
-		cm_event.remote_addr.sin_addr.s_addr = req->raddr;
-		cm_event.local_addr.sin_port = req->lport;
-		cm_event.remote_addr.sin_port = req->rport;
+		laddr->sin_addr.s_addr = req->laddr;
+		raddr->sin_addr.s_addr = req->raddr;
+		laddr->sin_port = req->lport;
+		raddr->sin_port = req->rport;
 		cm_event.private_data_len =
 			be32_to_cpu(req->private_data_length);
 		cm_event.private_data = req->private_data;
diff --git a/drivers/infiniband/hw/amso1100/c2_cm.c b/drivers/infiniband/hw/amso1100/c2_cm.c
index 95f58ab..23bfa94 100644
--- a/drivers/infiniband/hw/amso1100/c2_cm.c
+++ b/drivers/infiniband/hw/amso1100/c2_cm.c
@@ -46,6 +46,10 @@ int c2_llp_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *iw_param)
 	struct c2wr_qp_connect_req *wr;	/* variable size needs a malloc. */
 	struct c2_vq_req *vq_req;
 	int err;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
+
+	if (cm_id->remote_addr.ss_family != AF_INET)
+		return -ENOSYS;
 
 	ibqp = c2_get_qp(cm_id->device, iw_param->qpn);
 	if (!ibqp)
@@ -91,8 +95,8 @@ int c2_llp_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *iw_param)
 	wr->rnic_handle = c2dev->adapter_handle;
 	wr->qp_handle = qp->adapter_handle;
 
-	wr->remote_addr = cm_id->remote_addr.sin_addr.s_addr;
-	wr->remote_port = cm_id->remote_addr.sin_port;
+	wr->remote_addr = raddr->sin_addr.s_addr;
+	wr->remote_port = raddr->sin_port;
 
 	/*
 	 * Move any private data from the callers's buf into
@@ -135,6 +139,10 @@ int c2_llp_service_create(struct iw_cm_id *cm_id, int backlog)
 	struct c2wr_ep_listen_create_rep *reply;
 	struct c2_vq_req *vq_req;
 	int err;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+
+	if (cm_id->local_addr.ss_family != AF_INET)
+		return -ENOSYS;
 
 	c2dev = to_c2dev(cm_id->device);
 	if (c2dev == NULL)
@@ -153,8 +161,8 @@ int c2_llp_service_create(struct iw_cm_id *cm_id, int backlog)
 	c2_wr_set_id(&wr, CCWR_EP_LISTEN_CREATE);
 	wr.hdr.context = (u64) (unsigned long) vq_req;
 	wr.rnic_handle = c2dev->adapter_handle;
-	wr.local_addr = cm_id->local_addr.sin_addr.s_addr;
-	wr.local_port = cm_id->local_addr.sin_port;
+	wr.local_addr = laddr->sin_addr.s_addr;
+	wr.local_port = laddr->sin_port;
 	wr.backlog = cpu_to_be32(backlog);
 	wr.user_context = (u64) (unsigned long) cm_id;
 
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 3e094cd..095bb04 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -721,8 +721,10 @@ static void connect_reply_upcall(struct iwch_ep *ep, int status)
 	memset(&event, 0, sizeof(event));
 	event.event = IW_CM_EVENT_CONNECT_REPLY;
 	event.status = status;
-	event.local_addr = ep->com.local_addr;
-	event.remote_addr = ep->com.remote_addr;
+	memcpy(&event.local_addr, &ep->com.local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&event.remote_addr, &ep->com.remote_addr,
+	       sizeof(ep->com.remote_addr));
 
 	if ((status == 0) || (status == -ECONNREFUSED)) {
 		event.private_data_len = ep->plen;
@@ -747,8 +749,10 @@ static void connect_request_upcall(struct iwch_ep *ep)
 	PDBG("%s ep %p tid %d\n", __func__, ep, ep->hwtid);
 	memset(&event, 0, sizeof(event));
 	event.event = IW_CM_EVENT_CONNECT_REQUEST;
-	event.local_addr = ep->com.local_addr;
-	event.remote_addr = ep->com.remote_addr;
+	memcpy(&event.local_addr, &ep->com.local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&event.remote_addr, &ep->com.remote_addr,
+	       sizeof(ep->com.local_addr));
 	event.private_data_len = ep->plen;
 	event.private_data = ep->mpa_pkt + sizeof(struct mpa_message);
 	event.provider_data = ep;
@@ -1872,8 +1876,9 @@ err:
 static int is_loopback_dst(struct iw_cm_id *cm_id)
 {
 	struct net_device *dev;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
 
-	dev = ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
+	dev = ip_dev_find(&init_net, raddr->sin_addr.s_addr);
 	if (!dev)
 		return 0;
 	dev_put(dev);
@@ -1886,6 +1891,13 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct iwch_ep *ep;
 	struct rtable *rt;
 	int err = 0;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
+
+	if (cm_id->remote_addr.ss_family != PF_INET) {
+		err = -ENOSYS;
+		goto out;
+	}
 
 	if (is_loopback_dst(cm_id)) {
 		err = -ENOSYS;
@@ -1929,11 +1941,9 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 
 	/* find a route */
-	rt = find_route(h->rdev.t3cdev_p,
-			cm_id->local_addr.sin_addr.s_addr,
-			cm_id->remote_addr.sin_addr.s_addr,
-			cm_id->local_addr.sin_port,
-			cm_id->remote_addr.sin_port, IPTOS_LOWDELAY);
+	rt = find_route(h->rdev.t3cdev_p, laddr->sin_addr.s_addr,
+			raddr->sin_addr.s_addr, laddr->sin_port,
+			raddr->sin_port, IPTOS_LOWDELAY);
 	if (!rt) {
 		printk(KERN_ERR MOD "%s - cannot find route.\n", __func__);
 		err = -EHOSTUNREACH;
@@ -1941,7 +1951,7 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst, NULL,
-			     &cm_id->remote_addr.sin_addr.s_addr);
+			     &raddr->sin_addr.s_addr);
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
@@ -1950,8 +1960,10 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 
 	state_set(&ep->com, CONNECTING);
 	ep->tos = IPTOS_LOWDELAY;
-	ep->com.local_addr = cm_id->local_addr;
-	ep->com.remote_addr = cm_id->remote_addr;
+	memcpy(&ep->com.local_addr, &cm_id->local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&ep->com.remote_addr, &cm_id->remote_addr,
+	       sizeof(ep->com.remote_addr));
 
 	/* send connect request to rnic */
 	err = send_connect(ep);
@@ -1979,6 +1991,11 @@ int iwch_create_listen(struct iw_cm_id *cm_id, int backlog)
 
 	might_sleep();
 
+	if (cm_id->local_addr.ss_family != PF_INET) {
+		err = -ENOSYS;
+		goto fail1;
+	}
+
 	ep = alloc_ep(sizeof(*ep), GFP_KERNEL);
 	if (!ep) {
 		printk(KERN_ERR MOD "%s - cannot alloc ep.\n", __func__);
@@ -1990,7 +2007,8 @@ int iwch_create_listen(struct iw_cm_id *cm_id, int backlog)
 	cm_id->add_ref(cm_id);
 	ep->com.cm_id = cm_id;
 	ep->backlog = backlog;
-	ep->com.local_addr = cm_id->local_addr;
+	memcpy(&ep->com.local_addr, &cm_id->local_addr,
+	       sizeof(ep->com.local_addr));
 
 	/*
 	 * Allocate a server TID.
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 65c30ea..76d8812 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -952,8 +952,10 @@ static void connect_reply_upcall(struct c4iw_ep *ep, int status)
 	memset(&event, 0, sizeof(event));
 	event.event = IW_CM_EVENT_CONNECT_REPLY;
 	event.status = status;
-	event.local_addr = ep->com.local_addr;
-	event.remote_addr = ep->com.remote_addr;
+	memcpy(&event.local_addr, &ep->com.local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&event.remote_addr, &ep->com.remote_addr,
+	       sizeof(ep->com.remote_addr));
 
 	if ((status == 0) || (status == -ECONNREFUSED)) {
 		if (!ep->tried_with_mpa_v1) {
@@ -989,8 +991,10 @@ static void connect_request_upcall(struct c4iw_ep *ep)
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	memset(&event, 0, sizeof(event));
 	event.event = IW_CM_EVENT_CONNECT_REQUEST;
-	event.local_addr = ep->com.local_addr;
-	event.remote_addr = ep->com.remote_addr;
+	memcpy(&event.local_addr, &ep->com.local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&event.remote_addr, &ep->com.remote_addr,
+	       sizeof(ep->com.remote_addr));
 	event.provider_data = ep;
 	if (!ep->tried_with_mpa_v1) {
 		/* this means MPA_v2 is used */
@@ -1568,6 +1572,10 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	struct net_device *pdev;
 	int step;
 	struct neighbour *neigh;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)
+				    &ep->com.cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)
+				    &ep->com.cm_id->remote_addr;
 
 	PDBG("%s qp %p cm_id %p\n", __func__, ep->com.qp, ep->com.cm_id);
 	init_timer(&ep->timer);
@@ -1585,10 +1593,8 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 
 	/* find a route */
 	rt = find_route(ep->com.dev,
-			ep->com.cm_id->local_addr.sin_addr.s_addr,
-			ep->com.cm_id->remote_addr.sin_addr.s_addr,
-			ep->com.cm_id->local_addr.sin_port,
-			ep->com.cm_id->remote_addr.sin_port, 0);
+			laddr->sin_addr.s_addr, raddr->sin_addr.s_addr,
+			laddr->sin_port, raddr->sin_port, 0);
 	if (!rt) {
 		pr_err("%s - cannot find route.\n", __func__);
 		err = -EHOSTUNREACH;
@@ -1596,8 +1602,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	}
 	ep->dst = &rt->dst;
 
-	neigh = dst_neigh_lookup(ep->dst,
-			&ep->com.cm_id->remote_addr.sin_addr.s_addr);
+	neigh = dst_neigh_lookup(ep->dst, &raddr->sin_addr.s_addr);
 	if (!neigh) {
 		pr_err("%s - cannot alloc neigh.\n", __func__);
 		err = -ENOMEM;
@@ -1607,8 +1612,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	/* get a l2t entry */
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		PDBG("%s LOOPBACK\n", __func__);
-		pdev = ip_dev_find(&init_net,
-				ep->com.cm_id->remote_addr.sin_addr.s_addr);
+		pdev = ip_dev_find(&init_net, raddr->sin_addr.s_addr);
 		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
 				neigh, pdev, 0);
 		pi = (struct port_info *)netdev_priv(pdev);
@@ -2518,6 +2522,8 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct c4iw_ep *ep;
 	struct rtable *rt;
 	int err = 0;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
 
 	if ((conn_param->ord > c4iw_max_read_depth) ||
 	    (conn_param->ird > c4iw_max_read_depth)) {
@@ -2562,17 +2568,12 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	insert_handle(dev, &dev->atid_idr, ep, ep->atid);
 
 	PDBG("%s saddr 0x%x sport 0x%x raddr 0x%x rport 0x%x\n", __func__,
-	     ntohl(cm_id->local_addr.sin_addr.s_addr),
-	     ntohs(cm_id->local_addr.sin_port),
-	     ntohl(cm_id->remote_addr.sin_addr.s_addr),
-	     ntohs(cm_id->remote_addr.sin_port));
+	     ntohl(laddr->sin_addr.s_addr), ntohs(laddr->sin_port),
+	     ntohl(raddr->sin_addr.s_addr), ntohs(raddr->sin_port));
 
 	/* find a route */
-	rt = find_route(dev,
-			cm_id->local_addr.sin_addr.s_addr,
-			cm_id->remote_addr.sin_addr.s_addr,
-			cm_id->local_addr.sin_port,
-			cm_id->remote_addr.sin_port, 0);
+	rt = find_route(dev, laddr->sin_addr.s_addr, raddr->sin_addr.s_addr,
+			laddr->sin_port, raddr->sin_port, 0);
 	if (!rt) {
 		printk(KERN_ERR MOD "%s - cannot find route.\n", __func__);
 		err = -EHOSTUNREACH;
@@ -2580,8 +2581,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
-	err = import_ep(ep, cm_id->remote_addr.sin_addr.s_addr,
-			ep->dst, ep->com.dev, true);
+	err = import_ep(ep, raddr->sin_addr.s_addr, ep->dst, ep->com.dev, true);
 	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		goto fail4;
@@ -2593,8 +2593,10 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 
 	state_set(&ep->com, CONNECTING);
 	ep->tos = 0;
-	ep->com.local_addr = cm_id->local_addr;
-	ep->com.remote_addr = cm_id->remote_addr;
+	memcpy(&ep->com.local_addr, &cm_id->local_addr,
+	       sizeof(ep->com.local_addr));
+	memcpy(&ep->com.remote_addr, &cm_id->remote_addr,
+	       sizeof(ep->com.remote_addr));
 
 	/* send connect request to rnic */
 	err = send_connect(ep);
@@ -2633,7 +2635,8 @@ int c4iw_create_listen(struct iw_cm_id *cm_id, int backlog)
 	ep->com.cm_id = cm_id;
 	ep->com.dev = dev;
 	ep->backlog = backlog;
-	ep->com.local_addr = cm_id->local_addr;
+	memcpy(&ep->com.local_addr, &cm_id->local_addr,
+	       sizeof(ep->com.local_addr));
 
 	/*
 	 * Allocate a server TID.
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 24b9f1a..588a0fe 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -2998,6 +2998,8 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	u8 *start_ptr = &start_addr;
 	u8 **start_buff = &start_ptr;
 	u16 buff_len = 0;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
 
 	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
 	if (!ibqp)
@@ -3062,8 +3064,7 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	/* setup our first outgoing iWarp send WQE (the IETF frame response) */
 	wqe = &nesqp->hwqp.sq_vbase[0];
 
-	if (cm_id->remote_addr.sin_addr.s_addr !=
-	    cm_id->local_addr.sin_addr.s_addr) {
+	if (raddr->sin_addr.s_addr != laddr->sin_addr.s_addr) {
 		u64temp = (unsigned long)nesqp;
 		nesibdev = nesvnic->nesibdev;
 		nespd = nesqp->nespd;
@@ -3132,13 +3133,10 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 
 	nes_cm_init_tsa_conn(nesqp, cm_node);
 
-	nesqp->nesqp_context->tcpPorts[0] =
-		cpu_to_le16(ntohs(cm_id->local_addr.sin_port));
-	nesqp->nesqp_context->tcpPorts[1] =
-		cpu_to_le16(ntohs(cm_id->remote_addr.sin_port));
+	nesqp->nesqp_context->tcpPorts[0] = cpu_to_le16(ntohs(laddr->sin_port));
+	nesqp->nesqp_context->tcpPorts[1] = cpu_to_le16(ntohs(raddr->sin_port));
 
-	nesqp->nesqp_context->ip0 =
-			cpu_to_le32(ntohl(cm_id->remote_addr.sin_addr.s_addr));
+	nesqp->nesqp_context->ip0 = cpu_to_le32(ntohl(raddr->sin_addr.s_addr));
 
 	nesqp->nesqp_context->misc2 |= cpu_to_le32(
 		(u32)PCI_FUNC(nesdev->pcidev->devfn) <<
@@ -3162,9 +3160,9 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	memset(&nes_quad, 0, sizeof(nes_quad));
 	nes_quad.DstIpAdrIndex =
 		cpu_to_le32((u32)PCI_FUNC(nesdev->pcidev->devfn) << 24);
-	nes_quad.SrcIpadr = cm_id->remote_addr.sin_addr.s_addr;
-	nes_quad.TcpPorts[0] = cm_id->remote_addr.sin_port;
-	nes_quad.TcpPorts[1] = cm_id->local_addr.sin_port;
+	nes_quad.SrcIpadr = raddr->sin_addr.s_addr;
+	nes_quad.TcpPorts[0] = raddr->sin_port;
+	nes_quad.TcpPorts[1] = laddr->sin_port;
 
 	/* Produce hash key */
 	crc_value = get_crc_value(&nes_quad);
@@ -3180,10 +3178,8 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	nes_debug(NES_DBG_CM, "QP%u, Destination IP = 0x%08X:0x%04X, local = "
 		  "0x%08X:0x%04X, rcv_nxt=0x%08X, snd_nxt=0x%08X, mpa + "
 		  "private data length=%u.\n", nesqp->hwqp.qp_id,
-		  ntohl(cm_id->remote_addr.sin_addr.s_addr),
-		  ntohs(cm_id->remote_addr.sin_port),
-		  ntohl(cm_id->local_addr.sin_addr.s_addr),
-		  ntohs(cm_id->local_addr.sin_port),
+		  ntohl(raddr->sin_addr.s_addr), ntohs(raddr->sin_port),
+		  ntohl(laddr->sin_addr.s_addr), ntohs(laddr->sin_port),
 		  le32_to_cpu(nesqp->nesqp_context->rcv_nxt),
 		  le32_to_cpu(nesqp->nesqp_context->snd_nxt),
 		  buff_len);
@@ -3263,7 +3259,11 @@ int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct nes_cm_node *cm_node;
 	struct nes_cm_info cm_info;
 	int apbvt_set = 0;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
 
+	if (cm_id->remote_addr.ss_family != AF_INET)
+		return -ENOSYS;
 	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
 	if (!ibqp)
 		return -EINVAL;
@@ -3277,16 +3277,14 @@ int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	if (!nesdev)
 		return -EINVAL;
 
-	if (!(cm_id->local_addr.sin_port) || !(cm_id->remote_addr.sin_port))
+	if (!laddr->sin_port || !raddr->sin_port)
 		return -EINVAL;
 
 	nes_debug(NES_DBG_CM, "QP%u, current IP = 0x%08X, Destination IP = "
 		  "0x%08X:0x%04X, local = 0x%08X:0x%04X.\n", nesqp->hwqp.qp_id,
-		  ntohl(nesvnic->local_ipaddr),
-		  ntohl(cm_id->remote_addr.sin_addr.s_addr),
-		  ntohs(cm_id->remote_addr.sin_port),
-		  ntohl(cm_id->local_addr.sin_addr.s_addr),
-		  ntohs(cm_id->local_addr.sin_port));
+		  ntohl(nesvnic->local_ipaddr), ntohl(raddr->sin_addr.s_addr),
+		  ntohs(raddr->sin_port), ntohl(laddr->sin_addr.s_addr),
+		  ntohs(laddr->sin_port));
 
 	atomic_inc(&cm_connects);
 	nesqp->active_conn = 1;
@@ -3306,18 +3304,18 @@ int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	nes_debug(NES_DBG_CM, "mpa private data len =%u\n",
 		  conn_param->private_data_len);
 
-	if (cm_id->local_addr.sin_addr.s_addr !=
-	    cm_id->remote_addr.sin_addr.s_addr) {
-		nes_manage_apbvt(nesvnic, ntohs(cm_id->local_addr.sin_port),
-				 PCI_FUNC(nesdev->pcidev->devfn), NES_MANAGE_APBVT_ADD);
+	if (laddr->sin_addr.s_addr != raddr->sin_addr.s_addr) {
+		nes_manage_apbvt(nesvnic, ntohs(laddr->sin_port),
+				 PCI_FUNC(nesdev->pcidev->devfn),
+				 NES_MANAGE_APBVT_ADD);
 		apbvt_set = 1;
 	}
 
 	/* set up the connection params for the node */
-	cm_info.loc_addr = htonl(cm_id->local_addr.sin_addr.s_addr);
-	cm_info.loc_port = htons(cm_id->local_addr.sin_port);
-	cm_info.rem_addr = htonl(cm_id->remote_addr.sin_addr.s_addr);
-	cm_info.rem_port = htons(cm_id->remote_addr.sin_port);
+	cm_info.loc_addr = htonl(laddr->sin_addr.s_addr);
+	cm_info.loc_port = htons(laddr->sin_port);
+	cm_info.rem_addr = htonl(raddr->sin_addr.s_addr);
+	cm_info.rem_port = htons(raddr->sin_port);
 	cm_info.cm_id = cm_id;
 	cm_info.conn_type = NES_CM_IWARP_CONN_TYPE;
 
@@ -3329,7 +3327,7 @@ int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 					  &cm_info);
 	if (!cm_node) {
 		if (apbvt_set)
-			nes_manage_apbvt(nesvnic, ntohs(cm_id->local_addr.sin_port),
+			nes_manage_apbvt(nesvnic, ntohs(laddr->sin_port),
 					 PCI_FUNC(nesdev->pcidev->devfn),
 					 NES_MANAGE_APBVT_DEL);
 
@@ -3355,10 +3353,13 @@ int nes_create_listen(struct iw_cm_id *cm_id, int backlog)
 	struct nes_cm_listener *cm_node;
 	struct nes_cm_info cm_info;
 	int err;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
 
 	nes_debug(NES_DBG_CM, "cm_id = %p, local port = 0x%04X.\n",
-			cm_id, ntohs(cm_id->local_addr.sin_port));
+		  cm_id, ntohs(laddr->sin_port));
 
+	if (cm_id->local_addr.ss_family != AF_INET)
+		return -ENOSYS;
 	nesvnic = to_nesvnic(cm_id->device);
 	if (!nesvnic)
 		return -EINVAL;
@@ -3367,11 +3368,11 @@ int nes_create_listen(struct iw_cm_id *cm_id, int backlog)
 			nesvnic, nesvnic->netdev, nesvnic->netdev->name);
 
 	nes_debug(NES_DBG_CM, "nesvnic->local_ipaddr=0x%08x, sin_addr.s_addr=0x%08x\n",
-			nesvnic->local_ipaddr, cm_id->local_addr.sin_addr.s_addr);
+			nesvnic->local_ipaddr, laddr->sin_addr.s_addr);
 
 	/* setup listen params in our api call struct */
 	cm_info.loc_addr = nesvnic->local_ipaddr;
-	cm_info.loc_port = cm_id->local_addr.sin_port;
+	cm_info.loc_port = laddr->sin_port;
 	cm_info.backlog = backlog;
 	cm_info.cm_id = cm_id;
 
@@ -3388,8 +3389,7 @@ int nes_create_listen(struct iw_cm_id *cm_id, int backlog)
 	cm_id->provider_data = cm_node;
 
 	if (!cm_node->reused_node) {
-		err = nes_manage_apbvt(nesvnic,
-				       ntohs(cm_id->local_addr.sin_port),
+		err = nes_manage_apbvt(nesvnic, ntohs(laddr->sin_port),
 				       PCI_FUNC(nesvnic->nesdev->pcidev->devfn),
 				       NES_MANAGE_APBVT_ADD);
 		if (err) {
@@ -3487,6 +3487,10 @@ static void cm_event_connected(struct nes_cm_event *event)
 	struct nes_v4_quad nes_quad;
 	u32 crc_value;
 	int ret;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
+	struct sockaddr_in *cm_event_laddr = (struct sockaddr_in *)
+					     &cm_event.local_addr;
 
 	/* get all our handles */
 	cm_node = event->cm_node;
@@ -3502,21 +3506,15 @@ static void cm_event_connected(struct nes_cm_event *event)
 	atomic_inc(&cm_connecteds);
 	nes_debug(NES_DBG_CM, "QP%u attempting to connect to  0x%08X:0x%04X on"
 		  " local port 0x%04X. jiffies = %lu.\n",
-		  nesqp->hwqp.qp_id,
-		  ntohl(cm_id->remote_addr.sin_addr.s_addr),
-		  ntohs(cm_id->remote_addr.sin_port),
-		  ntohs(cm_id->local_addr.sin_port),
-		  jiffies);
+		  nesqp->hwqp.qp_id, ntohl(raddr->sin_addr.s_addr),
+		  ntohs(raddr->sin_port), ntohs(laddr->sin_port), jiffies);
 
 	nes_cm_init_tsa_conn(nesqp, cm_node);
 
 	/* set the QP tsa context */
-	nesqp->nesqp_context->tcpPorts[0] =
-		cpu_to_le16(ntohs(cm_id->local_addr.sin_port));
-	nesqp->nesqp_context->tcpPorts[1] =
-		cpu_to_le16(ntohs(cm_id->remote_addr.sin_port));
-	nesqp->nesqp_context->ip0 =
-			cpu_to_le32(ntohl(cm_id->remote_addr.sin_addr.s_addr));
+	nesqp->nesqp_context->tcpPorts[0] = cpu_to_le16(ntohs(laddr->sin_port));
+	nesqp->nesqp_context->tcpPorts[1] = cpu_to_le16(ntohs(raddr->sin_port));
+	nesqp->nesqp_context->ip0 = cpu_to_le32(ntohl(raddr->sin_addr.s_addr));
 
 	nesqp->nesqp_context->misc2 |= cpu_to_le32(
 			(u32)PCI_FUNC(nesdev->pcidev->devfn) <<
@@ -3544,9 +3542,9 @@ static void cm_event_connected(struct nes_cm_event *event)
 
 	nes_quad.DstIpAdrIndex =
 		cpu_to_le32((u32)PCI_FUNC(nesdev->pcidev->devfn) << 24);
-	nes_quad.SrcIpadr = cm_id->remote_addr.sin_addr.s_addr;
-	nes_quad.TcpPorts[0] = cm_id->remote_addr.sin_port;
-	nes_quad.TcpPorts[1] = cm_id->local_addr.sin_port;
+	nes_quad.SrcIpadr = raddr->sin_addr.s_addr;
+	nes_quad.TcpPorts[0] = raddr->sin_port;
+	nes_quad.TcpPorts[1] = laddr->sin_port;
 
 	/* Produce hash key */
 	crc_value = get_crc_value(&nes_quad);
@@ -3565,8 +3563,8 @@ static void cm_event_connected(struct nes_cm_event *event)
 	cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
 	cm_event.status = 0;
 	cm_event.provider_data = cm_id->provider_data;
-	cm_event.local_addr.sin_family = AF_INET;
-	cm_event.local_addr.sin_port = cm_id->local_addr.sin_port;
+	cm_event_laddr->sin_family = AF_INET;
+	cm_event_laddr->sin_port = laddr->sin_port;
 	cm_event.remote_addr = cm_id->remote_addr;
 
 	cm_event.private_data = (void *)event->cm_node->mpa_frame_buf;
@@ -3574,7 +3572,7 @@ static void cm_event_connected(struct nes_cm_event *event)
 	cm_event.ird = cm_node->ird_size;
 	cm_event.ord = cm_node->ord_size;
 
-	cm_event.local_addr.sin_addr.s_addr = event->cm_info.rem_addr;
+	cm_event_laddr->sin_addr.s_addr = event->cm_info.rem_addr;
 	ret = cm_id->event_handler(cm_id, &cm_event);
 	nes_debug(NES_DBG_CM, "OFA CM event_handler returned, ret=%d\n", ret);
 
@@ -3601,6 +3599,10 @@ static void cm_event_connect_error(struct nes_cm_event *event)
 	struct iw_cm_event cm_event;
 	/* struct nes_cm_info cm_info; */
 	int ret;
+	struct sockaddr_in *cm_event_laddr = (struct sockaddr_in *)
+					     &cm_event.local_addr;
+	struct sockaddr_in *cm_event_raddr = (struct sockaddr_in *)
+					     &cm_event.remote_addr;
 
 	if (!event->cm_node)
 		return;
@@ -3627,9 +3629,9 @@ static void cm_event_connect_error(struct nes_cm_event *event)
 	cm_event.private_data = NULL;
 	cm_event.private_data_len = 0;
 
-	nes_debug(NES_DBG_CM, "call CM_EVENT REJECTED, local_addr=%08x, "
-		  "remove_addr=%08x\n", cm_event.local_addr.sin_addr.s_addr,
-		  cm_event.remote_addr.sin_addr.s_addr);
+	nes_debug(NES_DBG_CM, "call CM_EVENT REJECTED, local_addr=%08x, remove_addr=%08x\n"
+		  , cm_event_laddr->sin_addr.s_addr
+		  , cm_event_raddr->sin_addr.s_addr);
 
 	ret = cm_id->event_handler(cm_id, &cm_event);
 	nes_debug(NES_DBG_CM, "OFA CM event_handler returned, ret=%d\n", ret);
@@ -3709,6 +3711,10 @@ static void cm_event_mpa_req(struct nes_cm_event *event)
 	struct iw_cm_event cm_event;
 	int ret;
 	struct nes_cm_node *cm_node;
+	struct sockaddr_in *cm_event_laddr = (struct sockaddr_in *)
+					     &cm_event.local_addr;
+	struct sockaddr_in *cm_event_raddr = (struct sockaddr_in *)
+					     &cm_event.remote_addr;
 
 	cm_node = event->cm_node;
 	if (!cm_node)
@@ -3723,13 +3729,13 @@ static void cm_event_mpa_req(struct nes_cm_event *event)
 	cm_event.status = 0;
 	cm_event.provider_data = (void *)cm_node;
 
-	cm_event.local_addr.sin_family = AF_INET;
-	cm_event.local_addr.sin_port = htons(event->cm_info.loc_port);
-	cm_event.local_addr.sin_addr.s_addr = htonl(event->cm_info.loc_addr);
+	cm_event_laddr->sin_family = AF_INET;
+	cm_event_laddr->sin_port = htons(event->cm_info.loc_port);
+	cm_event_laddr->sin_addr.s_addr = htonl(event->cm_info.loc_addr);
 
-	cm_event.remote_addr.sin_family = AF_INET;
-	cm_event.remote_addr.sin_port = htons(event->cm_info.rem_port);
-	cm_event.remote_addr.sin_addr.s_addr = htonl(event->cm_info.rem_addr);
+	cm_event_raddr->sin_family = AF_INET;
+	cm_event_raddr->sin_port = htons(event->cm_info.rem_port);
+	cm_event_raddr->sin_addr.s_addr = htonl(event->cm_info.rem_addr);
 	cm_event.private_data = cm_node->mpa_frame_buf;
 	cm_event.private_data_len = (u8)cm_node->mpa_frame_size;
 	cm_event.ird = cm_node->ird_size;
@@ -3749,6 +3755,10 @@ static void cm_event_mpa_reject(struct nes_cm_event *event)
 	struct iw_cm_event cm_event;
 	struct nes_cm_node *cm_node;
 	int ret;
+	struct sockaddr_in *cm_event_laddr = (struct sockaddr_in *)
+					     &cm_event.local_addr;
+	struct sockaddr_in *cm_event_raddr = (struct sockaddr_in *)
+					     &cm_event.remote_addr;
 
 	cm_node = event->cm_node;
 	if (!cm_node)
@@ -3763,21 +3773,21 @@ static void cm_event_mpa_reject(struct nes_cm_event *event)
 	cm_event.status = -ECONNREFUSED;
 	cm_event.provider_data = cm_id->provider_data;
 
-	cm_event.local_addr.sin_family = AF_INET;
-	cm_event.local_addr.sin_port = htons(event->cm_info.loc_port);
-	cm_event.local_addr.sin_addr.s_addr = htonl(event->cm_info.loc_addr);
+	cm_event_laddr->sin_family = AF_INET;
+	cm_event_laddr->sin_port = htons(event->cm_info.loc_port);
+	cm_event_laddr->sin_addr.s_addr = htonl(event->cm_info.loc_addr);
 
-	cm_event.remote_addr.sin_family = AF_INET;
-	cm_event.remote_addr.sin_port = htons(event->cm_info.rem_port);
-	cm_event.remote_addr.sin_addr.s_addr = htonl(event->cm_info.rem_addr);
+	cm_event_raddr->sin_family = AF_INET;
+	cm_event_raddr->sin_port = htons(event->cm_info.rem_port);
+	cm_event_raddr->sin_addr.s_addr = htonl(event->cm_info.rem_addr);
 
 	cm_event.private_data = cm_node->mpa_frame_buf;
 	cm_event.private_data_len = (u8)cm_node->mpa_frame_size;
 
 	nes_debug(NES_DBG_CM, "call CM_EVENT_MPA_REJECTED, local_addr=%08x, "
 		  "remove_addr=%08x\n",
-		  cm_event.local_addr.sin_addr.s_addr,
-		  cm_event.remote_addr.sin_addr.s_addr);
+		  cm_event_laddr->sin_addr.s_addr,
+		  cm_event_raddr->sin_addr.s_addr);
 
 	ret = cm_id->event_handler(cm_id, &cm_event);
 	if (ret)
diff --git a/include/rdma/iw_cm.h b/include/rdma/iw_cm.h
index 1a046b1..1017e0b 100644
--- a/include/rdma/iw_cm.h
+++ b/include/rdma/iw_cm.h
@@ -49,8 +49,8 @@ enum iw_cm_event_type {
 struct iw_cm_event {
 	enum iw_cm_event_type event;
 	int			 status;
-	struct sockaddr_in local_addr;
-	struct sockaddr_in remote_addr;
+	struct sockaddr_storage local_addr;
+	struct sockaddr_storage remote_addr;
 	void *private_data;
 	void *provider_data;
 	u8 private_data_len;
@@ -83,8 +83,8 @@ struct iw_cm_id {
 	iw_cm_handler		cm_handler;      /* client callback function */
 	void		        *context;	 /* client cb context */
 	struct ib_device	*device;
-	struct sockaddr_in      local_addr;
-	struct sockaddr_in	remote_addr;
+	struct sockaddr_storage local_addr;
+	struct sockaddr_storage	remote_addr;
 	void			*provider_data;	 /* provider private data */
 	iw_event_handler        event_handler;   /* cb for provider
 						    events */
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
