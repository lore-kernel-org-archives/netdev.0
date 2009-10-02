From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] net: mark net_proto_ops as const
Date: Fri, 02 Oct 2009 16:25:21 -0700
Message-ID: <20091002232721.385245919@vyatta.com>
References: <20091002232520.925496630@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bernard Pidoux F6BVP <f6bvp-GANU6spQydw@public.gmane.org>, Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Qinghuang Feng <qhfeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Christine Caulfield <christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Ursula Braun <ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hendrik Brueckner <brueckner-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Matthias Urlichs <matthias-+qxcz+fHsVSELgA04lAiVw@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Smith <markzzzsmith-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	"Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	James Chapman <jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org>, Henner Eisen
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=cons-proto-family.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

All users of structure net_proto_ops should be declared const.

---
 drivers/isdn/mISDN/socket.c       |    3 +--
 drivers/net/pppox.c               |    2 +-
 include/net/bluetooth/bluetooth.h |    2 +-
 net/appletalk/ddp.c               |    2 +-
 net/atm/pvc.c                     |    2 +-
 net/atm/svc.c                     |    2 +-
 net/ax25/af_ax25.c                |    2 +-
 net/bluetooth/af_bluetooth.c      |    4 ++--
 net/bluetooth/bnep/sock.c         |    2 +-
 net/bluetooth/cmtp/sock.c         |    2 +-
 net/bluetooth/hci_sock.c          |    2 +-
 net/bluetooth/hidp/sock.c         |    2 +-
 net/bluetooth/l2cap.c             |    2 +-
 net/bluetooth/rfcomm/sock.c       |    2 +-
 net/bluetooth/sco.c               |    2 +-
 net/can/af_can.c                  |    2 +-
 net/decnet/af_decnet.c            |    2 +-
 net/econet/af_econet.c            |    2 +-
 net/ieee802154/af_ieee802154.c    |    2 +-
 net/ipv4/af_inet.c                |    2 +-
 net/ipv6/af_inet6.c               |    2 +-
 net/ipx/af_ipx.c                  |    2 +-
 net/irda/af_irda.c                |    2 +-
 net/iucv/af_iucv.c                |    2 +-
 net/key/af_key.c                  |    2 +-
 net/llc/af_llc.c                  |    2 +-
 net/netlink/af_netlink.c          |    2 +-
 net/netrom/af_netrom.c            |    2 +-
 net/packet/af_packet.c            |    2 +-
 net/phonet/af_phonet.c            |    2 +-
 net/rds/af_rds.c                  |    2 +-
 net/rose/af_rose.c                |    2 +-
 net/rxrpc/af_rxrpc.c              |    2 +-
 net/unix/af_unix.c                |    2 +-
 net/x25/af_x25.c                  |    2 +-
 35 files changed, 36 insertions(+), 37 deletions(-)

--- a/drivers/isdn/mISDN/socket.c	2009-10-02 16:20:02.320291655 -0700
+++ b/drivers/isdn/mISDN/socket.c	2009-10-02 16:20:43.210280312 -0700
@@ -808,8 +808,7 @@ mISDN_sock_create(struct net *net, struc
 	return err;
 }
 
-static struct
-net_proto_family mISDN_sock_family_ops = {
+static const struct net_proto_family mISDN_sock_family_ops = {
 	.owner  = THIS_MODULE,
 	.family = PF_ISDN,
 	.create = mISDN_sock_create,
--- a/drivers/net/pppox.c	2009-10-01 19:03:16.918349768 -0700
+++ b/drivers/net/pppox.c	2009-10-02 16:20:43.210280312 -0700
@@ -125,7 +125,7 @@ out:
 	return rc;
 }
 
-static struct net_proto_family pppox_proto_family = {
+static const struct net_proto_family pppox_proto_family = {
 	.family	= PF_PPPOX,
 	.create	= pppox_create,
 	.owner	= THIS_MODULE,
--- a/include/net/bluetooth/bluetooth.h	2009-10-01 19:03:17.038350923 -0700
+++ b/include/net/bluetooth/bluetooth.h	2009-10-02 16:20:43.210280312 -0700
@@ -121,7 +121,7 @@ struct bt_sock_list {
 	rwlock_t          lock;
 };
 
-int  bt_sock_register(int proto, struct net_proto_family *ops);
+int  bt_sock_register(int proto, const struct net_proto_family *ops);
 int  bt_sock_unregister(int proto);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
--- a/net/appletalk/ddp.c	2009-10-01 19:03:16.634348458 -0700
+++ b/net/appletalk/ddp.c	2009-10-02 16:20:43.210280312 -0700
@@ -1821,7 +1821,7 @@ static int atalk_compat_ioctl(struct soc
 #endif
 
 
-static struct net_proto_family atalk_family_ops = {
+static const struct net_proto_family atalk_family_ops = {
 	.family		= PF_APPLETALK,
 	.create		= atalk_create,
 	.owner		= THIS_MODULE,
--- a/net/atm/pvc.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/atm/pvc.c	2009-10-02 16:20:43.210280312 -0700
@@ -137,7 +137,7 @@ static int pvc_create(struct net *net, s
 }
 
 
-static struct net_proto_family pvc_family_ops = {
+static const struct net_proto_family pvc_family_ops = {
 	.family = PF_ATMPVC,
 	.create = pvc_create,
 	.owner = THIS_MODULE,
--- a/net/atm/svc.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/atm/svc.c	2009-10-02 16:20:43.210280312 -0700
@@ -666,7 +666,7 @@ static int svc_create(struct net *net, s
 }
 
 
-static struct net_proto_family svc_family_ops = {
+static const struct net_proto_family svc_family_ops = {
 	.family = PF_ATMSVC,
 	.create = svc_create,
 	.owner = THIS_MODULE,
--- a/net/ax25/af_ax25.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/ax25/af_ax25.c	2009-10-02 16:20:43.210280312 -0700
@@ -1961,7 +1961,7 @@ static const struct file_operations ax25
 
 #endif
 
-static struct net_proto_family ax25_family_ops = {
+static const struct net_proto_family ax25_family_ops = {
 	.family =	PF_AX25,
 	.create =	ax25_create,
 	.owner	=	THIS_MODULE,
--- a/net/bluetooth/af_bluetooth.c	2009-10-01 19:03:16.854348407 -0700
+++ b/net/bluetooth/af_bluetooth.c	2009-10-02 16:20:43.210280312 -0700
@@ -45,7 +45,7 @@
 
 /* Bluetooth sockets */
 #define BT_MAX_PROTO	8
-static struct net_proto_family *bt_proto[BT_MAX_PROTO];
+static const struct net_proto_family *bt_proto[BT_MAX_PROTO];
 static DEFINE_RWLOCK(bt_proto_lock);
 
 static struct lock_class_key bt_lock_key[BT_MAX_PROTO];
@@ -86,7 +86,7 @@ static inline void bt_sock_reclassify_lo
 				bt_key_strings[proto], &bt_lock_key[proto]);
 }
 
-int bt_sock_register(int proto, struct net_proto_family *ops)
+int bt_sock_register(int proto, const struct net_proto_family *ops)
 {
 	int err = 0;
 
--- a/net/bluetooth/bnep/sock.c	2009-10-01 19:03:16.898350369 -0700
+++ b/net/bluetooth/bnep/sock.c	2009-10-02 16:20:43.210280312 -0700
@@ -222,7 +222,7 @@ static int bnep_sock_create(struct net *
 	return 0;
 }
 
-static struct net_proto_family bnep_sock_family_ops = {
+static const struct net_proto_family bnep_sock_family_ops = {
 	.family = PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create = bnep_sock_create
--- a/net/bluetooth/cmtp/sock.c	2009-10-01 19:03:16.874349134 -0700
+++ b/net/bluetooth/cmtp/sock.c	2009-10-02 16:20:43.220342414 -0700
@@ -217,7 +217,7 @@ static int cmtp_sock_create(struct net *
 	return 0;
 }
 
-static struct net_proto_family cmtp_sock_family_ops = {
+static const struct net_proto_family cmtp_sock_family_ops = {
 	.family	= PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create	= cmtp_sock_create
--- a/net/bluetooth/hci_sock.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/bluetooth/hci_sock.c	2009-10-02 16:20:43.220342414 -0700
@@ -687,7 +687,7 @@ static int hci_sock_dev_event(struct not
 	return NOTIFY_DONE;
 }
 
-static struct net_proto_family hci_sock_family_ops = {
+static const struct net_proto_family hci_sock_family_ops = {
 	.family	= PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create	= hci_sock_create,
--- a/net/bluetooth/hidp/sock.c	2009-10-01 19:03:16.794397698 -0700
+++ b/net/bluetooth/hidp/sock.c	2009-10-02 16:20:43.220342414 -0700
@@ -268,7 +268,7 @@ static int hidp_sock_create(struct net *
 	return 0;
 }
 
-static struct net_proto_family hidp_sock_family_ops = {
+static const struct net_proto_family hidp_sock_family_ops = {
 	.family	= PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create	= hidp_sock_create
--- a/net/bluetooth/l2cap.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/bluetooth/l2cap.c	2009-10-02 16:20:43.220342414 -0700
@@ -3916,7 +3916,7 @@ static const struct proto_ops l2cap_sock
 	.getsockopt	= l2cap_sock_getsockopt
 };
 
-static struct net_proto_family l2cap_sock_family_ops = {
+static const struct net_proto_family l2cap_sock_family_ops = {
 	.family	= PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create	= l2cap_sock_create,
--- a/net/bluetooth/rfcomm/sock.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/bluetooth/rfcomm/sock.c	2009-10-02 16:20:43.220342414 -0700
@@ -1101,7 +1101,7 @@ static const struct proto_ops rfcomm_soc
 	.mmap		= sock_no_mmap
 };
 
-static struct net_proto_family rfcomm_sock_family_ops = {
+static const struct net_proto_family rfcomm_sock_family_ops = {
 	.family		= PF_BLUETOOTH,
 	.owner		= THIS_MODULE,
 	.create		= rfcomm_sock_create
--- a/net/bluetooth/sco.c	2009-10-02 16:20:02.440301882 -0700
+++ b/net/bluetooth/sco.c	2009-10-02 16:20:43.220342414 -0700
@@ -993,7 +993,7 @@ static const struct proto_ops sco_sock_o
 	.getsockopt	= sco_sock_getsockopt
 };
 
-static struct net_proto_family sco_sock_family_ops = {
+static const struct net_proto_family sco_sock_family_ops = {
 	.family	= PF_BLUETOOTH,
 	.owner	= THIS_MODULE,
 	.create	= sco_sock_create,
--- a/net/can/af_can.c	2009-10-01 19:03:16.437350580 -0700
+++ b/net/can/af_can.c	2009-10-02 16:20:43.220342414 -0700
@@ -842,7 +842,7 @@ static struct packet_type can_packet __r
 	.func = can_rcv,
 };
 
-static struct net_proto_family can_family_ops __read_mostly = {
+static const struct net_proto_family can_family_ops __read_mostly = {
 	.family = PF_CAN,
 	.create = can_create,
 	.owner  = THIS_MODULE,
--- a/net/decnet/af_decnet.c	2009-10-02 16:20:02.450290721 -0700
+++ b/net/decnet/af_decnet.c	2009-10-02 16:20:43.220342414 -0700
@@ -2325,7 +2325,7 @@ static const struct file_operations dn_s
 };
 #endif
 
-static struct net_proto_family	dn_family_ops = {
+static const struct net_proto_family	dn_family_ops = {
 	.family =	AF_DECnet,
 	.create =	dn_create,
 	.owner	=	THIS_MODULE,
--- a/net/econet/af_econet.c	2009-10-01 19:03:16.381348558 -0700
+++ b/net/econet/af_econet.c	2009-10-02 16:20:43.220342414 -0700
@@ -742,7 +742,7 @@ static int econet_ioctl(struct socket *s
 	return 0;
 }
 
-static struct net_proto_family econet_family_ops = {
+static const struct net_proto_family econet_family_ops = {
 	.family =	PF_ECONET,
 	.create =	econet_create,
 	.owner	=	THIS_MODULE,
--- a/net/ieee802154/af_ieee802154.c	2009-10-01 19:03:16.534350765 -0700
+++ b/net/ieee802154/af_ieee802154.c	2009-10-02 16:20:43.220342414 -0700
@@ -285,7 +285,7 @@ out:
 	return rc;
 }
 
-static struct net_proto_family ieee802154_family_ops = {
+static const struct net_proto_family ieee802154_family_ops = {
 	.family		= PF_IEEE802154,
 	.create		= ieee802154_create,
 	.owner		= THIS_MODULE,
--- a/net/ipv4/af_inet.c	2009-10-02 16:20:02.450290721 -0700
+++ b/net/ipv4/af_inet.c	2009-10-02 16:20:43.220342414 -0700
@@ -931,7 +931,7 @@ static const struct proto_ops inet_sockr
 #endif
 };
 
-static struct net_proto_family inet_family_ops = {
+static const struct net_proto_family inet_family_ops = {
 	.family = PF_INET,
 	.create = inet_create,
 	.owner	= THIS_MODULE,
--- a/net/ipv6/af_inet6.c	2009-10-01 19:03:16.558349136 -0700
+++ b/net/ipv6/af_inet6.c	2009-10-02 16:20:43.220342414 -0700
@@ -552,7 +552,7 @@ const struct proto_ops inet6_dgram_ops =
 #endif
 };
 
-static struct net_proto_family inet6_family_ops = {
+static const struct net_proto_family inet6_family_ops = {
 	.family = PF_INET6,
 	.create = inet6_create,
 	.owner	= THIS_MODULE,
--- a/net/ipx/af_ipx.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/ipx/af_ipx.c	2009-10-02 16:20:43.220342414 -0700
@@ -1927,7 +1927,7 @@ static int ipx_compat_ioctl(struct socke
  * Socket family declarations
  */
 
-static struct net_proto_family ipx_family_ops = {
+static const struct net_proto_family ipx_family_ops = {
 	.family		= PF_IPX,
 	.create		= ipx_create,
 	.owner		= THIS_MODULE,
--- a/net/irda/af_irda.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/irda/af_irda.c	2009-10-02 16:20:43.220342414 -0700
@@ -2463,7 +2463,7 @@ bed:
 	return 0;
 }
 
-static struct net_proto_family irda_family_ops = {
+static const struct net_proto_family irda_family_ops = {
 	.family = PF_IRDA,
 	.create = irda_create,
 	.owner	= THIS_MODULE,
--- a/net/iucv/af_iucv.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/iucv/af_iucv.c	2009-10-02 16:20:43.220342414 -0700
@@ -1715,7 +1715,7 @@ static const struct proto_ops iucv_sock_
 	.getsockopt	= iucv_sock_getsockopt,
 };
 
-static struct net_proto_family iucv_sock_family_ops = {
+static const struct net_proto_family iucv_sock_family_ops = {
 	.family	= AF_IUCV,
 	.owner	= THIS_MODULE,
 	.create	= iucv_sock_create,
--- a/net/key/af_key.c	2009-10-01 19:03:16.477349034 -0700
+++ b/net/key/af_key.c	2009-10-02 16:20:43.230306460 -0700
@@ -3644,7 +3644,7 @@ static const struct proto_ops pfkey_ops 
 	.recvmsg	=	pfkey_recvmsg,
 };
 
-static struct net_proto_family pfkey_family_ops = {
+static const struct net_proto_family pfkey_family_ops = {
 	.family	=	PF_KEY,
 	.create	=	pfkey_create,
 	.owner	=	THIS_MODULE,
--- a/net/llc/af_llc.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/llc/af_llc.c	2009-10-02 16:20:43.230306460 -0700
@@ -1092,7 +1092,7 @@ out:
 	return rc;
 }
 
-static struct net_proto_family llc_ui_family_ops = {
+static const struct net_proto_family llc_ui_family_ops = {
 	.family = PF_LLC,
 	.create = llc_ui_create,
 	.owner	= THIS_MODULE,
--- a/net/netlink/af_netlink.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/netlink/af_netlink.c	2009-10-02 16:20:43.230306460 -0700
@@ -2050,7 +2050,7 @@ static const struct proto_ops netlink_op
 	.sendpage =	sock_no_sendpage,
 };
 
-static struct net_proto_family netlink_family_ops = {
+static const struct net_proto_family netlink_family_ops = {
 	.family = PF_NETLINK,
 	.create = netlink_create,
 	.owner	= THIS_MODULE,	/* for consistency 8) */
--- a/net/netrom/af_netrom.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/netrom/af_netrom.c	2009-10-02 16:20:43.230306460 -0700
@@ -1372,7 +1372,7 @@ static const struct file_operations nr_i
 };
 #endif	/* CONFIG_PROC_FS */
 
-static struct net_proto_family nr_family_ops = {
+static const struct net_proto_family nr_family_ops = {
 	.family		=	PF_NETROM,
 	.create		=	nr_create,
 	.owner		=	THIS_MODULE,
--- a/net/packet/af_packet.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/packet/af_packet.c	2009-10-02 16:20:43.230306460 -0700
@@ -2363,7 +2363,7 @@ static const struct proto_ops packet_ops
 	.sendpage =	sock_no_sendpage,
 };
 
-static struct net_proto_family packet_family_ops = {
+static const struct net_proto_family packet_family_ops = {
 	.family =	PF_PACKET,
 	.create =	packet_create,
 	.owner	=	THIS_MODULE,
--- a/net/phonet/af_phonet.c	2009-10-01 19:03:16.674395303 -0700
+++ b/net/phonet/af_phonet.c	2009-10-02 16:20:43.230306460 -0700
@@ -118,7 +118,7 @@ out:
 	return err;
 }
 
-static struct net_proto_family phonet_proto_family = {
+static const struct net_proto_family phonet_proto_family = {
 	.family = PF_PHONET,
 	.create = pn_socket_create,
 	.owner = THIS_MODULE,
--- a/net/rds/af_rds.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/rds/af_rds.c	2009-10-02 16:20:43.230306460 -0700
@@ -431,7 +431,7 @@ void rds_sock_put(struct rds_sock *rs)
 	sock_put(rds_rs_to_sk(rs));
 }
 
-static struct net_proto_family rds_family_ops = {
+static const struct net_proto_family rds_family_ops = {
 	.family =	AF_RDS,
 	.create =	rds_create,
 	.owner	=	THIS_MODULE,
--- a/net/rose/af_rose.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/rose/af_rose.c	2009-10-02 16:20:43.230306460 -0700
@@ -1509,7 +1509,7 @@ static const struct file_operations rose
 };
 #endif	/* CONFIG_PROC_FS */
 
-static struct net_proto_family rose_family_ops = {
+static const struct net_proto_family rose_family_ops = {
 	.family		=	PF_ROSE,
 	.create		=	rose_create,
 	.owner		=	THIS_MODULE,
--- a/net/rxrpc/af_rxrpc.c	2009-10-02 16:20:02.460301560 -0700
+++ b/net/rxrpc/af_rxrpc.c	2009-10-02 16:20:43.230306460 -0700
@@ -777,7 +777,7 @@ static struct proto rxrpc_proto = {
 	.max_header	= sizeof(struct rxrpc_header),
 };
 
-static struct net_proto_family rxrpc_family_ops = {
+static const struct net_proto_family rxrpc_family_ops = {
 	.family	= PF_RXRPC,
 	.create = rxrpc_create,
 	.owner	= THIS_MODULE,
--- a/net/unix/af_unix.c	2009-10-01 19:03:16.518348870 -0700
+++ b/net/unix/af_unix.c	2009-10-02 16:20:43.230306460 -0700
@@ -2214,7 +2214,7 @@ static const struct file_operations unix
 
 #endif
 
-static struct net_proto_family unix_family_ops = {
+static const struct net_proto_family unix_family_ops = {
 	.family = PF_UNIX,
 	.create = unix_create,
 	.owner	= THIS_MODULE,
--- a/net/x25/af_x25.c	2009-10-02 16:20:02.470281669 -0700
+++ b/net/x25/af_x25.c	2009-10-02 16:20:43.230306460 -0700
@@ -1476,7 +1476,7 @@ static int x25_ioctl(struct socket *sock
 	return rc;
 }
 
-static struct net_proto_family x25_family_ops = {
+static const struct net_proto_family x25_family_ops = {
 	.family =	AF_X25,
 	.create =	x25_create,
 	.owner	=	THIS_MODULE,

-- 


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
