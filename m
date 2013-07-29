From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] pktgen: Require CONFIG_INET due to use of IPv4 checksum function
Date: Mon, 29 Jul 2013 13:44:15 +0200
Message-ID: <ac3413a475e921b6ea915ecd1c610e6df07484f7.1375098208.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38851 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab3G2LoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 07:44:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike for IPv6, the IPv4 checksum functions are only available
if CONFIG_INET is set.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/Kconfig b/net/Kconfig
index 3770249..37162eb 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -281,7 +281,7 @@ menu "Network testing"
 
 config NET_PKTGEN
 	tristate "Packet Generator (USE WITH CAUTION)"
-	depends on PROC_FS
+	depends on INET && PROC_FS
 	---help---
 	  This module will inject preconfigured packets, at a configurable
 	  rate, out of a given interface.  It is used for network interface
-- 
1.8.3.1
