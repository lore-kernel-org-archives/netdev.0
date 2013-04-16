From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 05/10] openvswitch: Use ETH_ALEN to define ethernet addresses
Date: Tue, 16 Apr 2013 14:00:14 -0700
Message-ID: <1366146019-9015-6-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:44763 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965214Ab3DPVAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:21 -0400
Received: by mail-pd0-f198.google.com with SMTP id 5so730070pdd.5
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:20 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/openvswitch.h |   13 +++++++------
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
1.7.10.4
