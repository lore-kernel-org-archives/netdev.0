From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 19/44] [IPV6] MIP6: Add routing header type 2 definition.
Date: Thu, 24 Aug 2006 00:02:20 +0900
Message-ID: <1156345366676-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:2697 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964930AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add routing header type 2 definition for Mobile IPv6.
Based on MIPL2 kernel patch.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 297853c..14be2db 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -29,6 +29,7 @@ struct in6_ifreq {
 
 #define IPV6_SRCRT_STRICT	0x01	/* this hop must be a neighbor	*/
 #define IPV6_SRCRT_TYPE_0	0	/* IPv6 type 0 Routing Header	*/
+#define IPV6_SRCRT_TYPE_2	2	/* IPv6 type 2 Routing Header	*/
 
 /*
  *	routing header
@@ -73,6 +74,18 @@ struct rt0_hdr {
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
1.4.0

