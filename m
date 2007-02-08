From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH (5/5)] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option
Date: Thu, 08 Feb 2007 12:10:05 +0900
Message-ID: <20070208113249.194E.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:39554 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422904AbXBHDKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 22:10:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CONFIG_NET_KEY_MIGRATE option which makes it possible for user
application to send or receive MIGRATE message to/from PF_KEY socket.

Signed-off-by: Shinta Sugimoto <shinta.sugimoto@ericsson.com>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/Kconfig |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index d385a78..577a4f8 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -45,4 +45,19 @@ config NET_KEY
 
 	  Say Y unless you know what you are doing.
 
+config NET_KEY_MIGRATE
+	bool "PF_KEY MIGRATE (EXPERIMENTAL)"
+	depends on NET_KEY && EXPERIMENTAL
+	select XFRM_MIGRATE
+	---help---
+	  Add a PF_KEY MIGRATE message to PF_KEYv2 socket family.
+	  The PF_KEY MIGRATE message is used to dynamically update
+	  locator(s) of a given IPsec security association.
+	  This feature is required, for instance, in a Mobile IPv6
+	  environment with IPsec configuration where mobile nodes
+	  change their attachment point to the Internet.  Detail
+	  information can be found in the internet-draft
+	  <draft-sugimoto-mip6-pfkey-migrate>.
+
+	  If unsure, say N.
 
-- 
1.4.2


