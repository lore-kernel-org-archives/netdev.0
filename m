From: akpm@osdl.org
Subject: [patch 1/9] git-net: NET_TCPPROBE Kconfig fix
Date: Thu, 08 Jun 2006 22:20:50 -0700
Message-ID: <200606090520.k595Kpba032080@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18652 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965165AbWFIFV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:21:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Dave Jones <davej@redhat.com>

Just spotted this typo in a new option.

Signed-off-by: Dave Jones <davej@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/Kconfig~git-net-net_tcpprobe-kconfig-fix net/Kconfig
--- devel/net/Kconfig~git-net-net_tcpprobe-kconfig-fix	2006-06-07 23:58:31.000000000 -0700
+++ devel-akpm/net/Kconfig	2006-06-07 23:58:31.000000000 -0700
@@ -227,7 +227,7 @@ config NET_TCPPROBE
 	depends on INET && EXPERIMENTAL && PROC_FS && KPROBES
 	---help---
 	This module allows for capturing the changes to TCP connection
-	state in response to incoming patckets. It is used for debugging
+	state in response to incoming packets. It is used for debugging
 	TCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 
_
