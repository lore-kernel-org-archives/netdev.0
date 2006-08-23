From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 24/44] [IPV6] MIP6: Add home address option definition.
Date: Thu, 24 Aug 2006 00:02:25 +0900
Message-ID: <11563453662956-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:4745 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964938AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add home address option definition for Mobile IPv6.
Based on MIPL2 kernel patch.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
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
index 14be2db..c1601ef 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -86,6 +86,16 @@ struct rt2_hdr {
 #define rt2_type		rt_hdr.type
 };
 
+/*
+ *	home address option in destination options header
+ */
+
+struct ipv6_destopt_hao {
+	__u8			type;
+	__u8			length;
+	struct in6_addr		addr;
+} __attribute__ ((__packed__));
+
 struct ipv6_auth_hdr {
 	__u8  nexthdr;
 	__u8  hdrlen;           /* This one is measured in 32 bit units! */
-- 
1.4.0

