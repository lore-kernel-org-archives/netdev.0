From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH 5/5] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option
Date: Wed, 07 Feb 2007 22:18:50 +0900
Message-ID: <20070207214526.90C3.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:36804 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161046AbXBGNTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 08:19:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CONFIG_NET_KEY_MIGRATE option which makes it possible for user
application to send or receive MIGRATE message to/from PF_KEY socket.

Signed-off-by: Shinta Sugimoto <shinta.sugimoto@ericsson.com>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/Kconfig |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 39d1cc4..fbaab2f 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -41,4 +41,14 @@ config NET_KEY
 
 	  Say Y unless you know what you are doing.
 
+config NET_KEY_MIGRATE
+	bool "PF_KEY MIGRATE (EXPERIMENTAL)"
+	depends on NET_KEY && EXPERIMENTAL
+	select XFRM_MIGRATE
+	---help---
+	  Add a PF_KEY MIGRATE message to PF_KEYv2 socket family.
+	  The PF_KEY MIGRATE message is used to dynamically update
+	  locator(s) of a given IPsec security association.  This feature
+	  is required, for instance, in a Mobile IPv6 environment where
+	  a mobile node changes its attachment point to the Internet.
 
-- 
1.4.2



