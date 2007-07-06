From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] make all initialized struct seq_operations const
Date: Fri, 6 Jul 2007 15:25:43 +0200
Message-ID: <20070706132543.GA13101@muff.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:12334 "EHLO mail.macqel.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbXGFNZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 09:25:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

Make all initialized struct seq_operations in net/ const

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

diff -r 6c0a10cc415a net/802/tr.c
--- a/net/802/tr.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/802/tr.c	Fri Jul  6 15:17:53 2007 +0200
@@ -567,7 +567,7 @@ static int rif_seq_show(struct seq_file 
 }
 
 
-static struct seq_operations rif_seq_ops = {
+static const struct seq_operations rif_seq_ops = {
 	.start = rif_seq_start,
 	.next  = rif_seq_next,
 	.stop  = rif_seq_stop,
diff -r 6c0a10cc415a net/8021q/vlanproc.c
--- a/net/8021q/vlanproc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/8021q/vlanproc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -69,7 +69,7 @@ static const char name_conf[]	 = "config
  *	Generic /proc/net/vlan/<file> file and inode operations
  */
 
-static struct seq_operations vlan_seq_ops = {
+static const struct seq_operations vlan_seq_ops = {
 	.start = vlan_seq_start,
 	.next = vlan_seq_next,
 	.stop = vlan_seq_stop,
diff -r 6c0a10cc415a net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/appletalk/aarp.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1024,7 +1024,7 @@ static int aarp_seq_show(struct seq_file
 	return 0;
 }
 
-static struct seq_operations aarp_seq_ops = {
+static const struct seq_operations aarp_seq_ops = {
 	.start  = aarp_seq_start,
 	.next   = aarp_seq_next,
 	.stop   = aarp_seq_stop,
diff -r 6c0a10cc415a net/appletalk/atalk_proc.c
--- a/net/appletalk/atalk_proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/appletalk/atalk_proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -204,21 +204,21 @@ out:
 	return 0;
 }
 
-static struct seq_operations atalk_seq_interface_ops = {
+static const struct seq_operations atalk_seq_interface_ops = {
 	.start  = atalk_seq_interface_start,
 	.next   = atalk_seq_interface_next,
 	.stop   = atalk_seq_interface_stop,
 	.show   = atalk_seq_interface_show,
 };
 
-static struct seq_operations atalk_seq_route_ops = {
+static const struct seq_operations atalk_seq_route_ops = {
 	.start  = atalk_seq_route_start,
 	.next   = atalk_seq_route_next,
 	.stop   = atalk_seq_route_stop,
 	.show   = atalk_seq_route_show,
 };
 
-static struct seq_operations atalk_seq_socket_ops = {
+static const struct seq_operations atalk_seq_socket_ops = {
 	.start  = atalk_seq_socket_start,
 	.next   = atalk_seq_socket_next,
 	.stop   = atalk_seq_socket_stop,
diff -r 6c0a10cc415a net/atm/br2684.c
--- a/net/atm/br2684.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/atm/br2684.c	Fri Jul  6 15:17:53 2007 +0200
@@ -772,7 +772,7 @@ static int br2684_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations br2684_seq_ops = {
+static const struct seq_operations br2684_seq_ops = {
 	.start = br2684_seq_start,
 	.next  = br2684_seq_next,
 	.stop  = br2684_seq_stop,
diff -r 6c0a10cc415a net/atm/clip.c
--- a/net/atm/clip.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/atm/clip.c	Fri Jul  6 15:17:53 2007 +0200
@@ -928,7 +928,7 @@ static int clip_seq_show(struct seq_file
 	return 0;
 }
 
-static struct seq_operations arp_seq_ops = {
+static const struct seq_operations arp_seq_ops = {
 	.start	= clip_seq_start,
 	.next	= neigh_seq_next,
 	.stop	= neigh_seq_stop,
diff -r 6c0a10cc415a net/atm/lec.c
--- a/net/atm/lec.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/atm/lec.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1174,7 +1174,7 @@ static int lec_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations lec_seq_ops = {
+static const struct seq_operations lec_seq_ops = {
 	.start = lec_seq_start,
 	.next = lec_seq_next,
 	.stop = lec_seq_stop,
diff -r 6c0a10cc415a net/atm/mpoa_proc.c
--- a/net/atm/mpoa_proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/atm/mpoa_proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -177,7 +177,7 @@ static int mpc_show(struct seq_file *m, 
 	return 0;
 }
 
-static struct seq_operations mpc_op = {
+static const struct seq_operations mpc_op = {
 	.start =	mpc_start,
 	.next =		mpc_next,
 	.stop =		mpc_stop,
diff -r 6c0a10cc415a net/atm/proc.c
--- a/net/atm/proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/atm/proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -260,7 +260,7 @@ static int atm_dev_seq_show(struct seq_f
 	return 0;
 }
 
-static struct seq_operations atm_dev_seq_ops = {
+static const struct seq_operations atm_dev_seq_ops = {
 	.start	= atm_dev_seq_start,
 	.next	= atm_dev_seq_next,
 	.stop	= atm_dev_seq_stop,
@@ -295,7 +295,7 @@ static int pvc_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations pvc_seq_ops = {
+static const struct seq_operations pvc_seq_ops = {
 	.start	= vcc_seq_start,
 	.next	= vcc_seq_next,
 	.stop	= vcc_seq_stop,
@@ -329,7 +329,7 @@ static int vcc_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations vcc_seq_ops = {
+static const struct seq_operations vcc_seq_ops = {
 	.start	= vcc_seq_start,
 	.next	= vcc_seq_next,
 	.stop	= vcc_seq_stop,
@@ -364,7 +364,7 @@ static int svc_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations svc_seq_ops = {
+static const struct seq_operations svc_seq_ops = {
 	.start	= vcc_seq_start,
 	.next	= vcc_seq_next,
 	.stop	= vcc_seq_stop,
diff -r 6c0a10cc415a net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ax25/af_ax25.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1924,7 +1924,7 @@ static int ax25_info_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations ax25_info_seqops = {
+static const struct seq_operations ax25_info_seqops = {
 	.start = ax25_info_start,
 	.next = ax25_info_next,
 	.stop = ax25_info_stop,
diff -r 6c0a10cc415a net/ax25/ax25_route.c
--- a/net/ax25/ax25_route.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ax25/ax25_route.c	Fri Jul  6 15:17:53 2007 +0200
@@ -320,7 +320,7 @@ static int ax25_rt_seq_show(struct seq_f
 	return 0;
 }
 
-static struct seq_operations ax25_rt_seqops = {
+static const struct seq_operations ax25_rt_seqops = {
 	.start = ax25_rt_seq_start,
 	.next = ax25_rt_seq_next,
 	.stop = ax25_rt_seq_stop,
diff -r 6c0a10cc415a net/ax25/ax25_uid.c
--- a/net/ax25/ax25_uid.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ax25/ax25_uid.c	Fri Jul  6 15:17:53 2007 +0200
@@ -185,7 +185,7 @@ static int ax25_uid_seq_show(struct seq_
 	return 0;
 }
 
-static struct seq_operations ax25_uid_seqops = {
+static const struct seq_operations ax25_uid_seqops = {
 	.start = ax25_uid_seq_start,
 	.next = ax25_uid_seq_next,
 	.stop = ax25_uid_seq_stop,
diff -r 6c0a10cc415a net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/decnet/af_decnet.c	Fri Jul  6 15:17:53 2007 +0200
@@ -2304,7 +2304,7 @@ static int dn_socket_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations dn_socket_seq_ops = {
+static const struct seq_operations dn_socket_seq_ops = {
 	.start	= dn_socket_seq_start,
 	.next	= dn_socket_seq_next,
 	.stop	= dn_socket_seq_stop,
diff -r 6c0a10cc415a net/decnet/dn_dev.c
--- a/net/decnet/dn_dev.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/decnet/dn_dev.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1419,7 +1419,7 @@ static int dn_dev_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations dn_dev_seq_ops = {
+static const struct seq_operations dn_dev_seq_ops = {
 	.start	= dn_dev_seq_start,
 	.next	= dn_dev_seq_next,
 	.stop	= dn_dev_seq_stop,
diff -r 6c0a10cc415a net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/decnet/dn_neigh.c	Fri Jul  6 15:17:53 2007 +0200
@@ -569,7 +569,7 @@ static void *dn_neigh_seq_start(struct s
 			       NEIGH_SEQ_NEIGH_ONLY);
 }
 
-static struct seq_operations dn_neigh_seq_ops = {
+static const struct seq_operations dn_neigh_seq_ops = {
 	.start = dn_neigh_seq_start,
 	.next  = neigh_seq_next,
 	.stop  = neigh_seq_stop,
diff -r 6c0a10cc415a net/decnet/dn_route.c
--- a/net/decnet/dn_route.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/decnet/dn_route.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1726,7 +1726,7 @@ static int dn_rt_cache_seq_show(struct s
 	return 0;
 }
 
-static struct seq_operations dn_rt_cache_seq_ops = {
+static const struct seq_operations dn_rt_cache_seq_ops = {
 	.start	= dn_rt_cache_seq_start,
 	.next	= dn_rt_cache_seq_next,
 	.stop	= dn_rt_cache_seq_stop,
diff -r 6c0a10cc415a net/ipv4/ipvs/ip_vs_app.c
--- a/net/ipv4/ipvs/ip_vs_app.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/ipvs/ip_vs_app.c	Fri Jul  6 15:17:53 2007 +0200
@@ -549,7 +549,7 @@ static int ip_vs_app_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations ip_vs_app_seq_ops = {
+static const struct seq_operations ip_vs_app_seq_ops = {
 	.start = ip_vs_app_seq_start,
 	.next  = ip_vs_app_seq_next,
 	.stop  = ip_vs_app_seq_stop,
diff -r 6c0a10cc415a net/ipv4/ipvs/ip_vs_conn.c
--- a/net/ipv4/ipvs/ip_vs_conn.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/ipvs/ip_vs_conn.c	Fri Jul  6 15:17:53 2007 +0200
@@ -745,7 +745,7 @@ static int ip_vs_conn_seq_show(struct se
 	return 0;
 }
 
-static struct seq_operations ip_vs_conn_seq_ops = {
+static const struct seq_operations ip_vs_conn_seq_ops = {
 	.start = ip_vs_conn_seq_start,
 	.next  = ip_vs_conn_seq_next,
 	.stop  = ip_vs_conn_seq_stop,
diff -r 6c0a10cc415a net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/ipvs/ip_vs_ctl.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1783,7 +1783,7 @@ static int ip_vs_info_seq_show(struct se
 	return 0;
 }
 
-static struct seq_operations ip_vs_info_seq_ops = {
+static const struct seq_operations ip_vs_info_seq_ops = {
 	.start = ip_vs_info_seq_start,
 	.next  = ip_vs_info_seq_next,
 	.stop  = ip_vs_info_seq_stop,
diff -r 6c0a10cc415a net/ipv4/netfilter/ipt_CLUSTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c	Fri Jul  6 15:17:53 2007 +0200
@@ -647,7 +647,7 @@ static int clusterip_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations clusterip_seq_ops = {
+static const struct seq_operations clusterip_seq_ops = {
 	.start	= clusterip_seq_start,
 	.next	= clusterip_seq_next,
 	.stop	= clusterip_seq_stop,
diff -r 6c0a10cc415a net/ipv4/netfilter/ipt_recent.c
--- a/net/ipv4/netfilter/ipt_recent.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/netfilter/ipt_recent.c	Fri Jul  6 15:17:53 2007 +0200
@@ -373,7 +373,7 @@ static int recent_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations recent_seq_ops = {
+static const struct seq_operations recent_seq_ops = {
 	.start		= recent_seq_start,
 	.next		= recent_seq_next,
 	.stop		= recent_seq_stop,
diff -r 6c0a10cc415a net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c	Fri Jul  6 15:17:53 2007 +0200
@@ -169,7 +169,7 @@ static int ct_seq_show(struct seq_file *
 	return 0;
 }
 
-static struct seq_operations ct_seq_ops = {
+static const struct seq_operations ct_seq_ops = {
 	.start = ct_seq_start,
 	.next  = ct_seq_next,
 	.stop  = ct_seq_stop,
@@ -266,7 +266,7 @@ static int exp_seq_show(struct seq_file 
 	return seq_putc(s, '\n');
 }
 
-static struct seq_operations exp_seq_ops = {
+static const struct seq_operations exp_seq_ops = {
 	.start = exp_seq_start,
 	.next = exp_seq_next,
 	.stop = exp_seq_stop,
@@ -354,7 +354,7 @@ static int ct_cpu_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations ct_cpu_seq_ops = {
+static const struct seq_operations ct_cpu_seq_ops = {
 	.start  = ct_cpu_seq_start,
 	.next   = ct_cpu_seq_next,
 	.stop   = ct_cpu_seq_stop,
diff -r 6c0a10cc415a net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv6/addrconf.c	Fri Jul  6 15:17:53 2007 +0200
@@ -2782,7 +2782,7 @@ static int if6_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations if6_seq_ops = {
+static const struct seq_operations if6_seq_ops = {
 	.start	= if6_seq_start,
 	.next	= if6_seq_next,
 	.show	= if6_seq_show,
diff -r 6c0a10cc415a net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv6/anycast.c	Fri Jul  6 15:17:53 2007 +0200
@@ -539,7 +539,7 @@ static int ac6_seq_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations ac6_seq_ops = {
+static const struct seq_operations ac6_seq_ops = {
 	.start	=	ac6_seq_start,
 	.next	=	ac6_seq_next,
 	.stop	=	ac6_seq_stop,
diff -r 6c0a10cc415a net/ipv6/ip6_flowlabel.c
--- a/net/ipv6/ip6_flowlabel.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv6/ip6_flowlabel.c	Fri Jul  6 15:17:53 2007 +0200
@@ -648,7 +648,7 @@ static int ip6fl_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations ip6fl_seq_ops = {
+static const struct seq_operations ip6fl_seq_ops = {
 	.start	=	ip6fl_seq_start,
 	.next	=	ip6fl_seq_next,
 	.stop	=	ip6fl_seq_stop,
diff -r 6c0a10cc415a net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv6/mcast.c	Fri Jul  6 15:17:53 2007 +0200
@@ -2423,7 +2423,7 @@ static int igmp6_mc_seq_show(struct seq_
 	return 0;
 }
 
-static struct seq_operations igmp6_mc_seq_ops = {
+static const struct seq_operations igmp6_mc_seq_ops = {
 	.start	=	igmp6_mc_seq_start,
 	.next	=	igmp6_mc_seq_next,
 	.stop	=	igmp6_mc_seq_stop,
@@ -2597,7 +2597,7 @@ static int igmp6_mcf_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations igmp6_mcf_seq_ops = {
+static const struct seq_operations igmp6_mcf_seq_ops = {
 	.start	=	igmp6_mcf_seq_start,
 	.next	=	igmp6_mcf_seq_next,
 	.stop	=	igmp6_mcf_seq_stop,
diff -r 6c0a10cc415a net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipv6/raw.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1256,7 +1256,7 @@ static int raw6_seq_show(struct seq_file
 	return 0;
 }
 
-static struct seq_operations raw6_seq_ops = {
+static const struct seq_operations raw6_seq_ops = {
 	.start =	raw6_seq_start,
 	.next =		raw6_seq_next,
 	.stop =		raw6_seq_stop,
diff -r 6c0a10cc415a net/ipx/ipx_proc.c
--- a/net/ipx/ipx_proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/ipx/ipx_proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -286,21 +286,21 @@ out:
 	return 0;
 }
 
-static struct seq_operations ipx_seq_interface_ops = {
+static const struct seq_operations ipx_seq_interface_ops = {
 	.start  = ipx_seq_interface_start,
 	.next   = ipx_seq_interface_next,
 	.stop   = ipx_seq_interface_stop,
 	.show   = ipx_seq_interface_show,
 };
 
-static struct seq_operations ipx_seq_route_ops = {
+static const struct seq_operations ipx_seq_route_ops = {
 	.start  = ipx_seq_route_start,
 	.next   = ipx_seq_route_next,
 	.stop   = ipx_seq_route_stop,
 	.show   = ipx_seq_route_show,
 };
 
-static struct seq_operations ipx_seq_socket_ops = {
+static const struct seq_operations ipx_seq_socket_ops = {
 	.start  = ipx_seq_socket_start,
 	.next   = ipx_seq_socket_next,
 	.stop   = ipx_seq_interface_stop,
diff -r 6c0a10cc415a net/irda/discovery.c
--- a/net/irda/discovery.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/discovery.c	Fri Jul  6 15:17:53 2007 +0200
@@ -395,7 +395,7 @@ static int discovery_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations discovery_seq_ops = {
+static const struct seq_operations discovery_seq_ops = {
 	.start  = discovery_seq_start,
 	.next   = discovery_seq_next,
 	.stop   = discovery_seq_stop,
diff -r 6c0a10cc415a net/irda/ircomm/ircomm_core.c
--- a/net/irda/ircomm/ircomm_core.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/ircomm/ircomm_core.c	Fri Jul  6 15:17:53 2007 +0200
@@ -562,7 +562,7 @@ static int ircomm_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations ircomm_seq_ops = {
+static const struct seq_operations ircomm_seq_ops = {
 	.start  = ircomm_seq_start,
 	.next   = ircomm_seq_next,
 	.stop   = ircomm_seq_stop,
diff -r 6c0a10cc415a net/irda/iriap.c
--- a/net/irda/iriap.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/iriap.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1066,7 +1066,7 @@ static int irias_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations irias_seq_ops = {
+static const struct seq_operations irias_seq_ops = {
 	.start  = irias_seq_start,
 	.next   = irias_seq_next,
 	.stop   = irias_seq_stop,
diff -r 6c0a10cc415a net/irda/irlan/irlan_common.c
--- a/net/irda/irlan/irlan_common.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/irlan/irlan_common.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1217,7 +1217,7 @@ static int irlan_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations irlan_seq_ops = {
+static const struct seq_operations irlan_seq_ops = {
 	.start = irlan_seq_start,
 	.next  = irlan_seq_next,
 	.stop  = irlan_seq_stop,
diff -r 6c0a10cc415a net/irda/irlap.c
--- a/net/irda/irlap.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/irlap.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1210,7 +1210,7 @@ static int irlap_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations irlap_seq_ops = {
+static const struct seq_operations irlap_seq_ops = {
 	.start  = irlap_seq_start,
 	.next   = irlap_seq_next,
 	.stop   = irlap_seq_stop,
diff -r 6c0a10cc415a net/irda/irlmp.c
--- a/net/irda/irlmp.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/irlmp.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1994,7 +1994,7 @@ static int irlmp_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations irlmp_seq_ops = {
+static const struct seq_operations irlmp_seq_ops = {
 	.start  = irlmp_seq_start,
 	.next   = irlmp_seq_next,
 	.stop   = irlmp_seq_stop,
diff -r 6c0a10cc415a net/irda/irttp.c
--- a/net/irda/irttp.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/irda/irttp.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1866,7 +1866,7 @@ static int irttp_seq_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations irttp_seq_ops = {
+static const struct seq_operations irttp_seq_ops = {
 	.start  = irttp_seq_start,
 	.next   = irttp_seq_next,
 	.stop   = irttp_seq_stop,
diff -r 6c0a10cc415a net/llc/llc_proc.c
--- a/net/llc/llc_proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/llc/llc_proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -184,14 +184,14 @@ out:
 	return 0;
 }
 
-static struct seq_operations llc_seq_socket_ops = {
+static const struct seq_operations llc_seq_socket_ops = {
 	.start  = llc_seq_start,
 	.next   = llc_seq_next,
 	.stop   = llc_seq_stop,
 	.show   = llc_seq_socket_show,
 };
 
-static struct seq_operations llc_seq_core_ops = {
+static const struct seq_operations llc_seq_core_ops = {
 	.start  = llc_seq_start,
 	.next   = llc_seq_next,
 	.stop   = llc_seq_stop,
diff -r 6c0a10cc415a net/netfilter/nf_conntrack_expect.c
--- a/net/netfilter/nf_conntrack_expect.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nf_conntrack_expect.c	Fri Jul  6 15:17:53 2007 +0200
@@ -425,7 +425,7 @@ static int exp_seq_show(struct seq_file 
 	return seq_putc(s, '\n');
 }
 
-static struct seq_operations exp_seq_ops = {
+static const struct seq_operations exp_seq_ops = {
 	.start = exp_seq_start,
 	.next = exp_seq_next,
 	.stop = exp_seq_stop,
diff -r 6c0a10cc415a net/netfilter/nf_conntrack_standalone.c
--- a/net/netfilter/nf_conntrack_standalone.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nf_conntrack_standalone.c	Fri Jul  6 15:17:53 2007 +0200
@@ -190,7 +190,7 @@ static int ct_seq_show(struct seq_file *
 	return 0;
 }
 
-static struct seq_operations ct_seq_ops = {
+static const struct seq_operations ct_seq_ops = {
 	.start = ct_seq_start,
 	.next  = ct_seq_next,
 	.stop  = ct_seq_stop,
@@ -294,7 +294,7 @@ static int ct_cpu_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations ct_cpu_seq_ops = {
+static const struct seq_operations ct_cpu_seq_ops = {
 	.start	= ct_cpu_seq_start,
 	.next	= ct_cpu_seq_next,
 	.stop	= ct_cpu_seq_stop,
diff -r 6c0a10cc415a net/netfilter/nf_log.c
--- a/net/netfilter/nf_log.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nf_log.c	Fri Jul  6 15:17:53 2007 +0200
@@ -140,7 +140,7 @@ static int seq_show(struct seq_file *s, 
 	return seq_printf(s, "%2lld %s\n", *pos, logger->name);
 }
 
-static struct seq_operations nflog_seq_ops = {
+static const struct seq_operations nflog_seq_ops = {
 	.start	= seq_start,
 	.next	= seq_next,
 	.stop	= seq_stop,
diff -r 6c0a10cc415a net/netfilter/nf_queue.c
--- a/net/netfilter/nf_queue.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nf_queue.c	Fri Jul  6 15:17:53 2007 +0200
@@ -319,7 +319,7 @@ static int seq_show(struct seq_file *s, 
 	return ret;
 }
 
-static struct seq_operations nfqueue_seq_ops = {
+static const struct seq_operations nfqueue_seq_ops = {
 	.start	= seq_start,
 	.next	= seq_next,
 	.stop	= seq_stop,
diff -r 6c0a10cc415a net/netfilter/nfnetlink_log.c
--- a/net/netfilter/nfnetlink_log.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nfnetlink_log.c	Fri Jul  6 15:17:53 2007 +0200
@@ -962,7 +962,7 @@ static int seq_show(struct seq_file *s, 
 			  inst->flushtimeout, atomic_read(&inst->use));
 }
 
-static struct seq_operations nful_seq_ops = {
+static const struct seq_operations nful_seq_ops = {
 	.start	= seq_start,
 	.next	= seq_next,
 	.stop	= seq_stop,
diff -r 6c0a10cc415a net/netfilter/nfnetlink_queue.c
--- a/net/netfilter/nfnetlink_queue.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/nfnetlink_queue.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1050,7 +1050,7 @@ static int seq_show(struct seq_file *s, 
 			  atomic_read(&inst->use));
 }
 
-static struct seq_operations nfqnl_seq_ops = {
+static const struct seq_operations nfqnl_seq_ops = {
 	.start	= seq_start,
 	.next	= seq_next,
 	.stop	= seq_stop,
diff -r 6c0a10cc415a net/netfilter/x_tables.c
--- a/net/netfilter/x_tables.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/x_tables.c	Fri Jul  6 15:17:53 2007 +0200
@@ -744,7 +744,7 @@ static int xt_name_seq_show(struct seq_f
 		return 0;
 }
 
-static struct seq_operations xt_tgt_seq_ops = {
+static const struct seq_operations xt_tgt_seq_ops = {
 	.start	= xt_tgt_seq_start,
 	.next	= xt_tgt_seq_next,
 	.stop	= xt_tgt_seq_stop,
diff -r 6c0a10cc415a net/netfilter/xt_hashlimit.c
--- a/net/netfilter/xt_hashlimit.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netfilter/xt_hashlimit.c	Fri Jul  6 15:17:53 2007 +0200
@@ -694,7 +694,7 @@ static int dl_seq_show(struct seq_file *
 	return 0;
 }
 
-static struct seq_operations dl_seq_ops = {
+static const struct seq_operations dl_seq_ops = {
 	.start = dl_seq_start,
 	.next  = dl_seq_next,
 	.stop  = dl_seq_stop,
diff -r 6c0a10cc415a net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netlink/af_netlink.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1713,7 +1713,7 @@ static int netlink_seq_show(struct seq_f
 	return 0;
 }
 
-static struct seq_operations netlink_seq_ops = {
+static const struct seq_operations netlink_seq_ops = {
 	.start  = netlink_seq_start,
 	.next   = netlink_seq_next,
 	.stop   = netlink_seq_stop,
diff -r 6c0a10cc415a net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netrom/af_netrom.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1328,7 +1328,7 @@ static int nr_info_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations nr_info_seqops = {
+static const struct seq_operations nr_info_seqops = {
 	.start = nr_info_start,
 	.next = nr_info_next,
 	.stop = nr_info_stop,
diff -r 6c0a10cc415a net/netrom/nr_route.c
--- a/net/netrom/nr_route.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/netrom/nr_route.c	Fri Jul  6 15:17:53 2007 +0200
@@ -922,7 +922,7 @@ static int nr_node_show(struct seq_file 
 	return 0;
 }
 
-static struct seq_operations nr_node_seqops = {
+static const struct seq_operations nr_node_seqops = {
 	.start = nr_node_start,
 	.next = nr_node_next,
 	.stop = nr_node_stop,
@@ -1006,7 +1006,7 @@ static int nr_neigh_show(struct seq_file
 	return 0;
 }
 
-static struct seq_operations nr_neigh_seqops = {
+static const struct seq_operations nr_neigh_seqops = {
 	.start = nr_neigh_start,
 	.next = nr_neigh_next,
 	.stop = nr_neigh_stop,
diff -r 6c0a10cc415a net/packet/af_packet.c
--- a/net/packet/af_packet.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/packet/af_packet.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1928,7 +1928,7 @@ static int packet_seq_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations packet_seq_ops = {
+static const struct seq_operations packet_seq_ops = {
 	.start	= packet_seq_start,
 	.next	= packet_seq_next,
 	.stop	= packet_seq_stop,
diff -r 6c0a10cc415a net/rose/af_rose.c
--- a/net/rose/af_rose.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/rose/af_rose.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1454,7 +1454,7 @@ static int rose_info_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations rose_info_seqops = {
+static const struct seq_operations rose_info_seqops = {
 	.start = rose_info_start,
 	.next = rose_info_next,
 	.stop = rose_info_stop,
diff -r 6c0a10cc415a net/rose/rose_route.c
--- a/net/rose/rose_route.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/rose/rose_route.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1118,7 +1118,7 @@ static int rose_node_show(struct seq_fil
 	return 0;
 }
 
-static struct seq_operations rose_node_seqops = {
+static const struct seq_operations rose_node_seqops = {
 	.start = rose_node_start,
 	.next = rose_node_next,
 	.stop = rose_node_stop,
@@ -1200,7 +1200,7 @@ static int rose_neigh_show(struct seq_fi
 }
 
 
-static struct seq_operations rose_neigh_seqops = {
+static const struct seq_operations rose_neigh_seqops = {
 	.start = rose_neigh_start,
 	.next = rose_neigh_next,
 	.stop = rose_neigh_stop,
@@ -1284,7 +1284,7 @@ static int rose_route_show(struct seq_fi
 	return 0;
 }
 
-static struct seq_operations rose_route_seqops = {
+static const struct seq_operations rose_route_seqops = {
 	.start = rose_route_start,
 	.next = rose_route_next,
 	.stop = rose_route_stop,
diff -r 6c0a10cc415a net/rxrpc/ar-proc.c
--- a/net/rxrpc/ar-proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/rxrpc/ar-proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -104,7 +104,7 @@ static int rxrpc_call_seq_show(struct se
 	return 0;
 }
 
-static struct seq_operations rxrpc_call_seq_ops = {
+static const struct seq_operations rxrpc_call_seq_ops = {
 	.start  = rxrpc_call_seq_start,
 	.next   = rxrpc_call_seq_next,
 	.stop   = rxrpc_call_seq_stop,
@@ -206,7 +206,7 @@ static int rxrpc_connection_seq_show(str
 	return 0;
 }
 
-static struct seq_operations rxrpc_connection_seq_ops = {
+static const struct seq_operations rxrpc_connection_seq_ops = {
 	.start  = rxrpc_connection_seq_start,
 	.next   = rxrpc_connection_seq_next,
 	.stop   = rxrpc_connection_seq_stop,
diff -r 6c0a10cc415a net/sctp/proc.c
--- a/net/sctp/proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/sctp/proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -250,7 +250,7 @@ static int sctp_eps_seq_show(struct seq_
 	return 0;
 }
 
-static struct seq_operations sctp_eps_ops = {
+static const struct seq_operations sctp_eps_ops = {
 	.start = sctp_eps_seq_start,
 	.next  = sctp_eps_seq_next,
 	.stop  = sctp_eps_seq_stop,
@@ -361,7 +361,7 @@ static int sctp_assocs_seq_show(struct s
 	return 0;
 }
 
-static struct seq_operations sctp_assoc_ops = {
+static const struct seq_operations sctp_assoc_ops = {
 	.start = sctp_assocs_seq_start,
 	.next  = sctp_assocs_seq_next,
 	.stop  = sctp_assocs_seq_stop,
diff -r 6c0a10cc415a net/sunrpc/cache.c
--- a/net/sunrpc/cache.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/sunrpc/cache.c	Fri Jul  6 15:17:53 2007 +0200
@@ -1210,7 +1210,7 @@ static int c_show(struct seq_file *m, vo
 	return cd->cache_show(m, cd, cp);
 }
 
-static struct seq_operations cache_content_op = {
+static const struct seq_operations cache_content_op = {
 	.start	= c_start,
 	.next	= c_next,
 	.stop	= c_stop,
diff -r 6c0a10cc415a net/unix/af_unix.c
--- a/net/unix/af_unix.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/unix/af_unix.c	Fri Jul  6 15:17:53 2007 +0200
@@ -2048,7 +2048,7 @@ static int unix_seq_show(struct seq_file
 	return 0;
 }
 
-static struct seq_operations unix_seq_ops = {
+static const struct seq_operations unix_seq_ops = {
 	.start  = unix_seq_start,
 	.next   = unix_seq_next,
 	.stop   = unix_seq_stop,
diff -r 6c0a10cc415a net/wanrouter/wanproc.c
--- a/net/wanrouter/wanproc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/wanrouter/wanproc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -164,14 +164,14 @@ static int status_show(struct seq_file *
 	return 0;
 }
 
-static struct seq_operations config_op = {
+static const struct seq_operations config_op = {
 	.start	= r_start,
 	.next	= r_next,
 	.stop	= r_stop,
 	.show	= config_show,
 };
 
-static struct seq_operations status_op = {
+static const struct seq_operations status_op = {
 	.start	= r_start,
 	.next	= r_next,
 	.stop	= r_stop,
diff -r 6c0a10cc415a net/x25/x25_proc.c
--- a/net/x25/x25_proc.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/net/x25/x25_proc.c	Fri Jul  6 15:17:53 2007 +0200
@@ -234,21 +234,21 @@ out:
 	return 0;
 }
 
-static struct seq_operations x25_seq_route_ops = {
+static const struct seq_operations x25_seq_route_ops = {
 	.start  = x25_seq_route_start,
 	.next   = x25_seq_route_next,
 	.stop   = x25_seq_route_stop,
 	.show   = x25_seq_route_show,
 };
 
-static struct seq_operations x25_seq_socket_ops = {
+static const struct seq_operations x25_seq_socket_ops = {
 	.start  = x25_seq_socket_start,
 	.next   = x25_seq_socket_next,
 	.stop   = x25_seq_socket_stop,
 	.show   = x25_seq_socket_show,
 };
 
-static struct seq_operations x25_seq_forward_ops = {
+static const struct seq_operations x25_seq_forward_ops = {
 	.start  = x25_seq_forward_start,
 	.next   = x25_seq_forward_next,
 	.stop   = x25_seq_forward_stop,
