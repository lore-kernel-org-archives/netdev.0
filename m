From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 18/44] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Thu, 24 Aug 2006 00:02:19 +0900
Message-ID: <11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:3209 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964936AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453661207-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add Kconfig to enable Mobile IPv6.
Based on MIPL2 kernel patch.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 5067665..82ea1dc 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -97,6 +97,15 @@ config INET6_IPCOMP
 
 	  If unsure, say Y.
 
+config IPV6_MIP6
+	bool "IPv6: Mobility (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	select XFRM
+	---help---
+	  Support for IPv6 Mobility described in RFC 3775.
+
+	  If unsure, say N.
+
 config INET6_XFRM_TUNNEL
 	tristate
 	select INET6_TUNNEL
-- 
1.4.0

