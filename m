From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 8/20] [PATCH] [IPV6] MIP6: Add home address option definition.
Date: Sat, 29 Jul 2006 18:38:34 +0900
Message-ID: <11541659141888-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:42627 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422714AbWG2Jif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:35 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add home address option definition for Mobile IPv6.
Based on MIPL2 kernel patch.
---
 include/linux/in6.h  |    1 +
 include/linux/ipv6.h |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 304aaed..086ec2a 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -142,6 +142,7 @@ #define IPV6_TLV_PAD0		0
 #define IPV6_TLV_PADN		1
 #define IPV6_TLV_ROUTERALERT	5
 #define IPV6_TLV_JUMBO		194
+#define IPV6_TLV_HAO		201	/* home address option */
 
 /*
  *	IPV6 socket options
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 9152d4b..43e2e70 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -87,6 +87,16 @@ struct rt2_hdr {
 #define rt2_type		rt_hdr.type
 };
 
+/*
+ *	home address option in destination options header
+ */
+
+struct destopt_hao {
+	__u8			type;
+	__u8			length;
+	struct in6_addr		addr;
+} __attribute__ ((__packed__));
+
 struct ipv6_auth_hdr {
 	__u8  nexthdr;
 	__u8  hdrlen;           /* This one is measured in 32 bit units! */
-- 
1.4.1

