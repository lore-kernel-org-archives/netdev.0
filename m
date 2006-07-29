From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/20] [PATCH] [IPV6] MIP6: Add routing header type 2 definition.
Date: Sat, 29 Jul 2006 18:38:19 +0900
Message-ID: <11541658993896-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:37507 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422710AbWG2JiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:20 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add routing header type 2 definition for Mobile IPv6.
Based on MIPL2 kernel patch.
---
 include/linux/ipv6.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1263d8c..9152d4b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -30,6 +30,7 @@ struct in6_ifreq {
 
 #define IPV6_SRCRT_STRICT	0x01	/* this hop must be a neighbor	*/
 #define IPV6_SRCRT_TYPE_0	0	/* IPv6 type 0 Routing Header	*/
+#define IPV6_SRCRT_TYPE_2	2	/* IPv6 type 2 Routing Header	*/
 
 /*
  *	routing header
@@ -74,6 +75,18 @@ struct rt0_hdr {
 #define rt0_type		rt_hdr.type
 };
 
+/*
+ *	routing header type 2
+ */
+
+struct rt2_hdr {
+	struct ipv6_rt_hdr	rt_hdr;
+	__u32			reserved;
+	struct in6_addr		addr;
+
+#define rt2_type		rt_hdr.type
+};
+
 struct ipv6_auth_hdr {
 	__u8  nexthdr;
 	__u8  hdrlen;           /* This one is measured in 32 bit units! */
-- 
1.4.1

