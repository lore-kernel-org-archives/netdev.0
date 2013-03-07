From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH v2] CAIF: fix indentation for function arguments
Date: Thu,  7 Mar 2013 07:39:57 +0200
Message-ID: <1362634797-28720-1-git-send-email-silviupopescu1990@gmail.com>
Cc: sjur.brandeland@stericsson.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This lines up function arguments on second and subsequent lines at the
first column after the openning parenthesis of the first line.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/caif/caif_dev.c     |    9 +++++----
 net/caif/caif_socket.c  |   22 +++++++++++-----------
 net/caif/caif_usb.c     |    4 ++--
 net/caif/cfcnfg.c       |   19 +++++++++----------
 net/caif/cfctrl.c       |   14 +++++++-------
 net/caif/cffrml.c       |    4 ++--
 net/caif/cfmuxl.c       |    4 ++--
 net/caif/cfpkt_skbuff.c |    8 ++++----
 net/caif/cfrfml.c       |    4 ++--
 net/caif/cfserl.c       |    4 ++--
 net/caif/cfsrvl.c       |   13 ++++++-------
 net/caif/chnl_net.c     |    6 +++---
 12 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 21760f0..df6d56d 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -301,10 +301,11 @@ static void dev_flowctrl(struct net_device *dev, int on)
 }
 
 void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *caifdev,
-			struct cflayer *link_support, int head_room,
-			struct cflayer **layer, int (**rcv_func)(
-				struct sk_buff *, struct net_device *,
-				struct packet_type *, struct net_device *))
+		     struct cflayer *link_support, int head_room,
+		     struct cflayer **layer,
+		     int (**rcv_func)(struct sk_buff *, struct net_device *,
+				      struct packet_type *,
+				      struct net_device *))
 {
 	struct caif_device_entry *caifd;
 	enum cfcnfg_phy_preference pref;
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 095259f..1d337e0 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -197,8 +197,8 @@ static void cfsk_put(struct cflayer *layr)
 
 /* Packet Control Callback function called from CAIF */
 static void caif_ctrl_cb(struct cflayer *layr,
-				enum caif_ctrlcmd flow,
-				int phyid)
+			 enum caif_ctrlcmd flow,
+			 int phyid)
 {
 	struct caifsock *cf_sk = container_of(layr, struct caifsock, layer);
 	switch (flow) {
@@ -274,7 +274,7 @@ static void caif_check_flow_release(struct sock *sk)
  * changed locking, address handling and added MSG_TRUNC.
  */
 static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *m, size_t len, int flags)
+			       struct msghdr *m, size_t len, int flags)
 
 {
 	struct sock *sk = sock->sk;
@@ -346,8 +346,8 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
  * changed locking calls, changed address handling.
  */
 static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *msg, size_t size,
-				int flags)
+			       struct msghdr *msg, size_t size,
+			       int flags)
 {
 	struct sock *sk = sock->sk;
 	int copied = 0;
@@ -462,7 +462,7 @@ out:
  * CAIF flow-on and sock_writable.
  */
 static long caif_wait_for_flow_on(struct caifsock *cf_sk,
-				int wait_writeable, long timeo, int *err)
+				  int wait_writeable, long timeo, int *err)
 {
 	struct sock *sk = &cf_sk->sk;
 	DEFINE_WAIT(wait);
@@ -516,7 +516,7 @@ static int transmit_skb(struct sk_buff *skb, struct caifsock *cf_sk,
 
 /* Copied from af_unix:unix_dgram_sendmsg, and adapted to CAIF */
 static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			struct msghdr *msg, size_t len)
+			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
@@ -591,7 +591,7 @@ err:
  * and other minor adaptations.
  */
 static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
-				struct msghdr *msg, size_t len)
+			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
@@ -670,7 +670,7 @@ out_err:
 }
 
 static int setsockopt(struct socket *sock,
-			int lvl, int opt, char __user *ov, unsigned int ol)
+		      int lvl, int opt, char __user *ov, unsigned int ol)
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
@@ -932,7 +932,7 @@ static int caif_release(struct socket *sock)
 
 /* Copied from af_unix.c:unix_poll(), added CAIF tx_flow handling */
 static unsigned int caif_poll(struct file *file,
-				struct socket *sock, poll_table *wait)
+			      struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
 	unsigned int mask;
@@ -1022,7 +1022,7 @@ static void caif_sock_destructor(struct sock *sk)
 }
 
 static int caif_create(struct net *net, struct socket *sock, int protocol,
-			int kern)
+		       int kern)
 {
 	struct sock *sk = NULL;
 	struct caifsock *cf_sk = NULL;
diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index ef8ebaa..d76278d 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -75,7 +75,7 @@ static int cfusbl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 }
 
 static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-					int phyid)
+			   int phyid)
 {
 	if (layr->up && layr->up->ctrlcmd)
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
@@ -121,7 +121,7 @@ static struct packet_type caif_usb_type __read_mostly = {
 };
 
 static int cfusbl_device_notify(struct notifier_block *me, unsigned long what,
-			      void *arg)
+				void *arg)
 {
 	struct net_device *dev = arg;
 	struct caif_dev_common common;
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index f1dbddb..246ac3a 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -61,11 +61,11 @@ struct cfcnfg {
 };
 
 static void cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id,
-			     enum cfctrl_srv serv, u8 phyid,
-			     struct cflayer *adapt_layer);
+			      enum cfctrl_srv serv, u8 phyid,
+			      struct cflayer *adapt_layer);
 static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id);
 static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
-			     struct cflayer *adapt_layer);
+			      struct cflayer *adapt_layer);
 static void cfctrl_resp_func(void);
 static void cfctrl_enum_resp(void);
 
@@ -131,7 +131,7 @@ static void cfctrl_resp_func(void)
 }
 
 static struct cfcnfg_phyinfo *cfcnfg_get_phyinfo_rcu(struct cfcnfg *cnfg,
-							u8 phyid)
+						     u8 phyid)
 {
 	struct cfcnfg_phyinfo *phy;
 
@@ -216,8 +216,8 @@ static const int protohead[CFCTRL_SRV_MASK] = {
 
 
 static int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
-				   struct caif_connect_request *s,
-				   struct cfctrl_link_param *l)
+					  struct caif_connect_request *s,
+					  struct cfctrl_link_param *l)
 {
 	struct dev_info *dev_info;
 	enum cfcnfg_phy_preference pref;
@@ -301,8 +301,7 @@ static int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
 
 int caif_connect_client(struct net *net, struct caif_connect_request *conn_req,
 			struct cflayer *adap_layer, int *ifindex,
-				int *proto_head,
-				int *proto_tail)
+			int *proto_head, int *proto_tail)
 {
 	struct cflayer *frml;
 	struct cfcnfg_phyinfo *phy;
@@ -364,7 +363,7 @@ unlock:
 EXPORT_SYMBOL(caif_connect_client);
 
 static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
-			     struct cflayer *adapt_layer)
+			      struct cflayer *adapt_layer)
 {
 	if (adapt_layer != NULL && adapt_layer->ctrlcmd != NULL)
 		adapt_layer->ctrlcmd(adapt_layer,
@@ -526,7 +525,7 @@ out_err:
 EXPORT_SYMBOL(cfcnfg_add_phy_layer);
 
 int cfcnfg_set_phy_state(struct cfcnfg *cnfg, struct cflayer *phy_layer,
-		bool up)
+			 bool up)
 {
 	struct cfcnfg_phyinfo *phyinfo;
 
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index a376ec1..9cd057c 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -20,12 +20,12 @@
 
 #ifdef CAIF_NO_LOOP
 static int handle_loop(struct cfctrl *ctrl,
-			      int cmd, struct cfpkt *pkt){
+		       int cmd, struct cfpkt *pkt){
 	return -1;
 }
 #else
 static int handle_loop(struct cfctrl *ctrl,
-		int cmd, struct cfpkt *pkt);
+		       int cmd, struct cfpkt *pkt);
 #endif
 static int cfctrl_recv(struct cflayer *layr, struct cfpkt *pkt);
 static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
@@ -72,7 +72,7 @@ void cfctrl_remove(struct cflayer *layer)
 }
 
 static bool param_eq(const struct cfctrl_link_param *p1,
-			const struct cfctrl_link_param *p2)
+		     const struct cfctrl_link_param *p2)
 {
 	bool eq =
 	    p1->linktype == p2->linktype &&
@@ -197,8 +197,8 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 }
 
 int cfctrl_linkup_request(struct cflayer *layer,
-			   struct cfctrl_link_param *param,
-			   struct cflayer *user_layer)
+			  struct cfctrl_link_param *param,
+			  struct cflayer *user_layer)
 {
 	struct cfctrl *cfctrl = container_obj(layer);
 	u32 tmp32;
@@ -301,7 +301,7 @@ int cfctrl_linkup_request(struct cflayer *layer,
 }
 
 int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
-				struct cflayer *client)
+			struct cflayer *client)
 {
 	int ret;
 	struct cfpkt *pkt;
@@ -555,7 +555,7 @@ error:
 }
 
 static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-			int phyid)
+			   int phyid)
 {
 	struct cfctrl *this = container_obj(layr);
 	switch (ctrl) {
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 0a7df7e..204c5e2 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -28,7 +28,7 @@ struct cffrml {
 static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt);
 static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid);
+			   int phyid);
 
 static u32 cffrml_rcv_error;
 static u32 cffrml_rcv_checsum_error;
@@ -167,7 +167,7 @@ static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 }
 
 static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-					int phyid)
+			   int phyid)
 {
 	if (layr->up && layr->up->ctrlcmd)
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 94b0861..154d9f8 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -42,7 +42,7 @@ struct cfmuxl {
 static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt);
 static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid);
+			   int phyid);
 static struct cflayer *get_up(struct cfmuxl *muxl, u16 id);
 
 struct cflayer *cfmuxl_create(void)
@@ -244,7 +244,7 @@ static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 }
 
 static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid)
+			   int phyid)
 {
 	struct cfmuxl *muxl = container_obj(layr);
 	struct cflayer *layer;
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 863dedd..e8f9c14 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -266,8 +266,8 @@ inline u16 cfpkt_getlen(struct cfpkt *pkt)
 }
 
 inline u16 cfpkt_iterate(struct cfpkt *pkt,
-			    u16 (*iter_func)(u16, void *, u16),
-			    u16 data)
+			 u16 (*iter_func)(u16, void *, u16),
+			 u16 data)
 {
 	/*
 	 * Don't care about the performance hit of linearizing,
@@ -307,8 +307,8 @@ int cfpkt_setlen(struct cfpkt *pkt, u16 len)
 }
 
 struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
-			     struct cfpkt *addpkt,
-			     u16 expectlen)
+			   struct cfpkt *addpkt,
+			   u16 expectlen)
 {
 	struct sk_buff *dst = pkt_to_skb(dstpkt);
 	struct sk_buff *add = pkt_to_skb(addpkt);
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 2b563ad..db51830 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -43,7 +43,7 @@ static void cfrfml_release(struct cflayer *layer)
 }
 
 struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info,
-					int mtu_size)
+			      int mtu_size)
 {
 	int tmp;
 	struct cfrfml *this = kzalloc(sizeof(struct cfrfml), GFP_ATOMIC);
@@ -69,7 +69,7 @@ struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info,
 }
 
 static struct cfpkt *rfm_append(struct cfrfml *rfml, char *seghead,
-			struct cfpkt *pkt, int *err)
+				struct cfpkt *pkt, int *err)
 {
 	struct cfpkt *tmppkt;
 	*err = -EPROTO;
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 8e68b97..147c232 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -29,7 +29,7 @@ struct cfserl {
 static int cfserl_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfserl_transmit(struct cflayer *layr, struct cfpkt *pkt);
 static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid);
+			   int phyid);
 
 struct cflayer *cfserl_create(int instance, bool use_stx)
 {
@@ -182,7 +182,7 @@ static int cfserl_transmit(struct cflayer *layer, struct cfpkt *newpkt)
 }
 
 static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid)
+			   int phyid)
 {
 	layr->up->ctrlcmd(layr->up, ctrl, phyid);
 }
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index ba217e9..95f7f5e 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -25,7 +25,7 @@
 #define container_obj(layr) container_of(layr, struct cfsrvl, layer)
 
 static void cfservl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
-				int phyid)
+			    int phyid)
 {
 	struct cfsrvl *service = container_obj(layr);
 
@@ -158,10 +158,9 @@ static void cfsrvl_release(struct cflayer *layer)
 }
 
 void cfsrvl_init(struct cfsrvl *service,
-			u8 channel_id,
-			struct dev_info *dev_info,
-			bool supports_flowctrl
-			)
+		 u8 channel_id,
+		 struct dev_info *dev_info,
+		 bool supports_flowctrl)
 {
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	service->open = false;
@@ -207,8 +206,8 @@ void caif_free_client(struct cflayer *adap_layer)
 EXPORT_SYMBOL(caif_free_client);
 
 void caif_client_register_refcnt(struct cflayer *adapt_layer,
-					void (*hold)(struct cflayer *lyr),
-					void (*put)(struct cflayer *lyr))
+				 void (*hold)(struct cflayer *lyr),
+				 void (*put)(struct cflayer *lyr))
 {
 	struct cfsrvl *service;
 
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index e597733..26a4e4e 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -167,7 +167,7 @@ static void chnl_put(struct cflayer *lyr)
 }
 
 static void chnl_flowctrl_cb(struct cflayer *layr, enum caif_ctrlcmd flow,
-				int phyid)
+			     int phyid)
 {
 	struct chnl_net *priv = container_of(layr, struct chnl_net, chnl);
 	pr_debug("NET flowctrl func called flow: %s\n",
@@ -443,7 +443,7 @@ nla_put_failure:
 }
 
 static void caif_netlink_parms(struct nlattr *data[],
-				struct caif_connect_request *conn_req)
+			       struct caif_connect_request *conn_req)
 {
 	if (!data) {
 		pr_warn("no params data found\n");
@@ -488,7 +488,7 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipcaif_changelink(struct net_device *dev, struct nlattr *tb[],
-				struct nlattr *data[])
+			     struct nlattr *data[])
 {
 	struct chnl_net *caifdev;
 	ASSERT_RTNL();
-- 
1.7.9.5
