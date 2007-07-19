From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] [NET]: Whitespace fixes
Date: Thu, 19 Jul 2007 11:21:33 +0900 (JST)
Message-ID: <20070719.112133.94748123.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48167 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbXGSCUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 22:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider pulling the following commits from
	net-2.6-20070719-whitespace-20070719
branch at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Thanks.

HEADLINES
---------

    [NET] AX25: Fix whitespace errors.
    [NET] BLUETOOTH: Fix whitespace errors.
    [NET] CORE: Fix whitespace errors.
    [NET] DCCP: Fix whitespace errors.
    [NET] IPV4: Fix whitespace errors.
    [NET] NETFILTER: Fix whitespace errors.
    [NET] NETROM: Fix whitespace errors.
    [NET] PACKET: Fix whitespace errors.
    [NET] RFKILL: Fix whitespace errors.
    [NET] ROSE: Fix whitespace errors.
    [NET] RXRPC: Fix whitespace errors.
    [NET] SCTP: Fix whitespace errors.
    [NET] SUNRPC: Fix whitespace errors.
    [NET] TIPC: Fix whitespace errors.
    [NET] XFRM: Fix whitespace errors.

DIFFSTAT
--------

 net/ax25/af_ax25.c                      |    2 +-
 net/bluetooth/hci_core.c                |    2 +-
 net/core/dev.c                          |    2 +-
 net/core/rtnetlink.c                    |    2 +-
 net/core/sock.c                         |    2 +-
 net/dccp/ccids/lib/loss_interval.c      |    2 +-
 net/ipv4/fib_frontend.c                 |    2 +-
 net/ipv4/ip_forward.c                   |    2 +-
 net/ipv4/tcp_output.c                   |    2 +-
 net/netfilter/nf_conntrack_standalone.c |    2 +-
 net/netfilter/nf_log.c                  |    2 +-
 net/netrom/af_netrom.c                  |    2 +-
 net/packet/af_packet.c                  |    2 +-
 net/rfkill/rfkill-input.c               |    2 +-
 net/rose/af_rose.c                      |    2 +-
 net/rxrpc/af_rxrpc.c                    |   10 +++++-----
 net/sctp/sm_statefuns.c                 |    2 +-
 net/sctp/socket.c                       |    4 ++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c   |    2 +-
 net/tipc/socket.c                       |   12 ++++++------
 net/xfrm/xfrm_policy.c                  |    2 +-
 net/xfrm/xfrm_state.c                   |    2 +-
 22 files changed, 32 insertions(+), 32 deletions(-)

CHANGESETS
----------

commit bd3b071b91a8acfe93b01567f556c879db049f99
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:43:13 2007 +0900

    [NET] AX25: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index c83cf84..dae2a42 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1262,7 +1262,7 @@ static int __must_check ax25_connect(struct socket *sock,
 
 		for (;;) {
 			prepare_to_wait(sk->sk_sleep, &wait,
-			                TASK_INTERRUPTIBLE);
+					TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
 			if (!signal_pending(current)) {

---
commit 00ae02f31519e8d6e374424bbdf0c7381489e416
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:43:16 2007 +0900

    [NET] BLUETOOTH: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index f6d867e..63caa41 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -982,7 +982,7 @@ int hci_recv_fragment(struct hci_dev *hdev, int type, void *data, int count)
 
 			skb->dev = (void *) hdev;
 			bt_cb(skb)->pkt_type = type;
-	
+
 			__reassembly(hdev, type) = skb;
 
 			scb = (void *) skb->cb;

---
commit 40b77c943468236c6dfad3e7b94348fe70c70331
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:43:23 2007 +0900

    [NET] CORE: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/dev.c b/net/core/dev.c
index 6357f54..38212c3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2629,7 +2629,7 @@ void __dev_set_rx_mode(struct net_device *dev)
 		return;
 
 	if (!netif_device_present(dev))
-	        return;
+		return;
 
 	if (dev->set_rx_mode)
 		dev->set_rx_mode(dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 864cbdf..06eccca 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -98,7 +98,7 @@ int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 }
 
 int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-			         struct rtattr *rta, int len)
+				 struct rtattr *rta, int len)
 {
 	if (RTA_PAYLOAD(rta) < len)
 		return -1;
diff --git a/net/core/sock.c b/net/core/sock.c
index 091032a..1d55fbd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -217,7 +217,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 			warned++;
 			printk(KERN_INFO "sock_set_timeout: `%s' (pid %d) "
 			       "tries to set negative timeout\n",
-			        current->comm, current->pid);
+				current->comm, current->pid);
 		return 0;
 	}
 	*timeo_p = MAX_SCHEDULE_TIMEOUT;

---
commit 23248005fbe5fa32a3f6d00cdec1ecfb115d28eb
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:43:28 2007 +0900

    [NET] DCCP: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 515225f..dd0fc99 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -227,7 +227,7 @@ void dccp_li_update_li(struct sock *sk,
 		       struct list_head *li_hist_list,
 		       struct list_head *hist_list,
 		       struct timeval *last_feedback, u16 s, u32 bytes_recv,
-                       u32 previous_x_recv, u64 seq_loss, u8 win_loss)
+		       u32 previous_x_recv, u64 seq_loss, u8 win_loss)
 {
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;

---
commit 9c681b43fae1e402e39d157feaa5df454b9e4f1f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:43:47 2007 +0900

    [NET] IPV4: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2eb909b..eff6bce 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -817,7 +817,7 @@ static void nl_fib_input(struct sock *sk, int len)
 static void nl_fib_lookup_init(void)
 {
       netlink_kernel_create(NETLINK_FIB_LOOKUP, 0, nl_fib_input, NULL,
-      			    THIS_MODULE);
+			    THIS_MODULE);
 }
 
 static void fib_disable_ip(struct net_device *dev, int force)
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 9cb04df..8c95cf0 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -86,7 +86,7 @@ int ip_forward(struct sk_buff *skb)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->u.dst) &&
-	             (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
+		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->u.dst)));
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20aea15..666d8a5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1615,7 +1615,7 @@ u32 __tcp_select_window(struct sock *sk)
 		if (window <= free_space - mss || window > free_space)
 			window = (free_space/mss)*mss;
 		else if (mss == full_space &&
-		         free_space > window + full_space/2)
+			 free_space > window + full_space/2)
 			window = free_space;
 	}
 

---
commit a5d292646ebf2ee51086f59899a377c85e5d50b2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:21 2007 +0900

    [NET] NETFILTER: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index ffb6ff8..f752293 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -181,7 +181,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 
 	if (seq_printf(s, "use=%u\n", atomic_read(&conntrack->ct_general.use)))
 		return -ENOSPC;
-	
+
 	return 0;
 }
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 9498579..d67c4fb 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -9,7 +9,7 @@
 
 #include "nf_internals.h"
 
-/* Internal logging interface, which relies on the real 
+/* Internal logging interface, which relies on the real
    LOG target modules */
 
 #define NF_LOG_PREFIXLEN		128

---
commit 639fc4c381456df0564b23540e0f60b0af83093b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:32 2007 +0900

    [NET] NETROM: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 5d66490..dc92732 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -720,7 +720,7 @@ static int nr_connect(struct socket *sock, struct sockaddr *uaddr,
 
 		for (;;) {
 			prepare_to_wait(sk->sk_sleep, &wait,
-			                TASK_INTERRUPTIBLE);
+					TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
 			if (!signal_pending(current)) {

---
commit db0c58f998eeb552fb47b82915005259a83613ae
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:35 2007 +0900

    [NET] PACKET: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7c27bd3..1322d62 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -108,7 +108,7 @@ Outgoing, dev->hard_header!=NULL
 Incoming, dev->hard_header==NULL
    mac_header -> UNKNOWN position. It is very likely, that it points to ll
 		 header.  PPP makes it, that is wrong, because introduce
-                 assymetry between rx and tx paths.
+		 assymetry between rx and tx paths.
    data       -> data
 
 Outgoing, dev->hard_header==NULL

---
commit 2b81bff416c4413333b19af627e11fddc620bd84
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:38 2007 +0900

    [NET] RFKILL: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index 230e35c..9f746be 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -83,7 +83,7 @@ static DEFINE_RFKILL_TASK(rfkill_wlan, RFKILL_TYPE_WLAN);
 static DEFINE_RFKILL_TASK(rfkill_bt, RFKILL_TYPE_BLUETOOTH);
 
 static void rfkill_event(struct input_handle *handle, unsigned int type,
-		        unsigned int code, int down)
+			unsigned int code, int down)
 {
 	if (type == EV_KEY && down == 1) {
 		switch (code) {

---
commit 6140efb536e7758cd300461981634ebfd4f51efa
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:40 2007 +0900

    [NET] ROSE: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index f4d3aba..976c3cc 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -816,7 +816,7 @@ rose_try_next_neigh:
 
 		for (;;) {
 			prepare_to_wait(sk->sk_sleep, &wait,
-			                TASK_INTERRUPTIBLE);
+					TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
 			if (!signal_pending(current)) {

---
commit 1c899641acd18b8d9d8a61dcb5dd8826fc6c87ea
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:44 2007 +0900

    [NET] RXRPC: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 2c57df9..46f6d57 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -805,26 +805,26 @@ static int __init af_rxrpc_init(void)
 	}
 
 	ret = proto_register(&rxrpc_proto, 1);
-        if (ret < 0) {
-                printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
+	if (ret < 0) {
+		printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
 		goto error_proto;
 	}
 
 	ret = sock_register(&rxrpc_family_ops);
 	if (ret < 0) {
-                printk(KERN_CRIT "RxRPC: Cannot register socket family\n");
+		printk(KERN_CRIT "RxRPC: Cannot register socket family\n");
 		goto error_sock;
 	}
 
 	ret = register_key_type(&key_type_rxrpc);
 	if (ret < 0) {
-                printk(KERN_CRIT "RxRPC: Cannot register client key type\n");
+		printk(KERN_CRIT "RxRPC: Cannot register client key type\n");
 		goto error_key_type;
 	}
 
 	ret = register_key_type(&key_type_rxrpc_s);
 	if (ret < 0) {
-                printk(KERN_CRIT "RxRPC: Cannot register server key type\n");
+		printk(KERN_CRIT "RxRPC: Cannot register server key type\n");
 		goto error_key_type_s;
 	}
 

---
commit 9cbcbf4e010ec253df686257f99c819da9b895da
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:50 2007 +0900

    [NET] SCTP: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f02ce3d..fd2dfdd 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1779,7 +1779,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_d(const struct sctp_endpoint *ep,
 					     SCTP_COMM_UP, 0,
 					     asoc->c.sinit_num_ostreams,
 					     asoc->c.sinit_max_instreams,
-                                             NULL, GFP_ATOMIC);
+					     NULL, GFP_ATOMIC);
 		if (!ev)
 			goto nomem;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b1917f6..ee88f2e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4803,7 +4803,7 @@ static int sctp_getsockopt_partial_delivery_point(struct sock *sk, int len,
 						  char __user *optval,
 						  int __user *optlen)
 {
-        u32 val;
+	u32 val;
 
 	if (len < sizeof(u32))
 		return -EINVAL;
@@ -4827,7 +4827,7 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 				    char __user *optval,
 				    int __user *optlen)
 {
-        int val;
+	int val;
 
 	if (len < sizeof(int))
 		return -EINVAL;

---
commit fb1416a59b070d2dea280bfac3313bf3b8a17cd2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:53 2007 +0900

    [NET] SUNRPC: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index f441aa0..bfb6a29 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -67,7 +67,7 @@ krb5_encrypt(
 
 	if (crypto_blkcipher_ivsize(tfm) > 16) {
 		dprintk("RPC:       gss_k5encrypt: tfm iv size to large %d\n",
-		         crypto_blkcipher_ivsize(tfm));
+			 crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
 

---
commit 8238745a39606738c1d8d39f2052959b3e594b04
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:44:56 2007 +0900

    [NET] TIPC: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4a8f37f..8411017 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1629,8 +1629,8 @@ static struct proto_ops msg_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_msg,
 	.recvmsg	= recv_msg,
-        .mmap		= sock_no_mmap,
-        .sendpage	= sock_no_sendpage
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage
 };
 
 static struct proto_ops packet_ops = {
@@ -1650,8 +1650,8 @@ static struct proto_ops packet_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_packet,
 	.recvmsg	= recv_msg,
-        .mmap		= sock_no_mmap,
-        .sendpage	= sock_no_sendpage
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage
 };
 
 static struct proto_ops stream_ops = {
@@ -1671,8 +1671,8 @@ static struct proto_ops stream_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_stream,
 	.recvmsg	= recv_stream,
-        .mmap		= sock_no_mmap,
-        .sendpage	= sock_no_sendpage
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage
 };
 
 static struct net_proto_family tipc_family_ops = {

---
commit 7dc12d6dd6cc1aa489c6f3e34a75e8023c945da8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 19 10:45:15 2007 +0900

    [NET] XFRM: Fix whitespace errors.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b48f06f..cfaf17c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -857,7 +857,7 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 					       pol, NULL);
 				return err;
 			}
-                }
+		}
 		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry,
 					     xfrm_policy_bydst[dir].table + i,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e070c3f..38f90ca 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -407,7 +407,7 @@ xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
 					       AUDIT_MAC_IPSEC_DELSA,
-                                               0, NULL, x);
+					       0, NULL, x);
 
 				return err;
 			}

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
