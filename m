From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 5/6] openvswitch: Use ETH_ALEN to define ethernet addresses
Date: Fri, 29 Mar 2013 14:46:51 +0100
Message-ID: <3348fe6e7b59989e48124130190221b520b01b99.1364563347.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:52017
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756067Ab3C2NrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:47:02 -0400
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/openvswitch.h | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index 67d6c7b..8b9d721 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -20,6 +20,7 @@
 #define _LINUX_OPENVSWITCH_H 1
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 /**
  * struct ovs_header - header for OVS Generic Netlink messages.
@@ -269,8 +270,8 @@ enum ovs_frag_type {
 #define OVS_FRAG_TYPE_MAX (__OVS_FRAG_TYPE_MAX - 1)
 
 struct ovs_key_ethernet {
-	__u8	 eth_src[6];
-	__u8	 eth_dst[6];
+	__u8	 eth_src[ETH_ALEN];
+	__u8	 eth_dst[ETH_ALEN];
 };
 
 struct ovs_key_ipv4 {
@@ -316,14 +317,14 @@ struct ovs_key_arp {
 	__be32 arp_sip;
 	__be32 arp_tip;
 	__be16 arp_op;
-	__u8   arp_sha[6];
-	__u8   arp_tha[6];
+	__u8   arp_sha[ETH_ALEN];
+	__u8   arp_tha[ETH_ALEN];
 };
 
 struct ovs_key_nd {
 	__u32 nd_target[4];
-	__u8  nd_sll[6];
-	__u8  nd_tll[6];
+	__u8  nd_sll[ETH_ALEN];
+	__u8  nd_tll[ETH_ALEN];
 };
 
 /**
-- 
1.7.11.7
