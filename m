From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: net-2.6.20 patch] remove unused exports
Date: Tue, 21 Nov 2006 20:42:05 +0100
Message-ID: <20061121194205.GI5200@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:4361 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1031346AbWKUTmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 14:42:05 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thie patch removes the following not or no longer used exports:
- drivers/char/random.c: secure_tcp_sequence_number
- net/dccp/options.c: sysctl_dccp_feat_sequence_window
- net/netlink/af_netlink.c: netlink_set_err

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/char/random.c    |    2 --
 net/dccp/options.c       |    2 --
 net/netlink/af_netlink.c |    1 -
 3 files changed, 5 deletions(-)

--- linux-2.6.19-rc5-mm2/net/netlink/af_netlink.c.old	2006-11-21 19:15:12.000000000 +0100
+++ linux-2.6.19-rc5-mm2/net/netlink/af_netlink.c	2006-11-21 19:15:19.000000000 +0100
@@ -1827,7 +1827,6 @@
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
 EXPORT_SYMBOL(netlink_register_notifier);
-EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_unicast);
 EXPORT_SYMBOL(netlink_unregister_notifier);
--- linux-2.6.19-rc5-mm2/drivers/char/random.c.old	2006-11-21 19:19:34.000000000 +0100
+++ linux-2.6.19-rc5-mm2/drivers/char/random.c	2006-11-21 19:19:45.000000000 +0100
@@ -1556,8 +1556,6 @@
 	return seq;
 }
 
-EXPORT_SYMBOL(secure_tcp_sequence_number);
-
 /* Generate secure starting point for ephemeral IPV4 transport port search */
 u32 secure_ipv4_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
 {
--- linux-2.6.19-rc5-mm2/net/dccp/options.c.old	2006-11-21 20:02:28.000000000 +0100
+++ linux-2.6.19-rc5-mm2/net/dccp/options.c	2006-11-21 20:02:34.000000000 +0100
@@ -29,8 +29,6 @@
 int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
 int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
-EXPORT_SYMBOL_GPL(sysctl_dccp_feat_sequence_window);
-
 void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;

