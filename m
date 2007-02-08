From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH (3/5)] [XFRM]: CONFIG_XFRM_MIGRATE option
Date: Thu, 08 Feb 2007 12:09:56 +0900
Message-ID: <20070208113236.1948.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:39541 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422869AbXBHDJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 22:09:57 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CONFIG_XFRM_MIGRATE option which makes it possible for for user
application to send or receive MIGRATE message to/from netlink socket.

Signed-off-by: Shinta Sugimoto <shinta.sugimoto@ericsson.com>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/Kconfig |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 0faab63..d385a78 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -24,6 +24,17 @@ config XFRM_SUB_POLICY
 
 	  If unsure, say N.
 
+config XFRM_MIGRATE
+	bool "Transformation migrate database (EXPERIMENTAL)"
+	depends on XFRM && EXPERIMENTAL
+	---help---
+	  A feature to update locator(s) of a given IPsec security
+	  association dynamically.  This feature is required, for
+	  instance, in a Mobile IPv6 environment with IPsec configuration
+	  where mobile nodes change their attachment point to the Internet.
+
+	  If unsure, say N.
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM
-- 
1.4.2


