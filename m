From: Gabriel C <nix.or.die@googlemail.com>
Subject: [PATCH] IP_VS should depend on EXPERIMENTAL ?
Date: Fri, 20 Jul 2007 13:44:26 +0200
Message-ID: <46A0A01A.7030403@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fonzie.hosting9000.com ([85.214.50.12]:43905 "EHLO
	fonzie.hosting9000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbXGTLqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 07:46:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

IP_VS has :

..

tristate "IP virtual server support (EXPERIMENTAL)"

..

but it does not depend on EXPERIMENTAL.


Signed-off-by: Gabriel Craciunescu <nix.or.die@googlemail.com>

---

 net/ipv4/ipvs/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 09d0c3f..3c594ec 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -3,7 +3,7 @@
 #
 menuconfig IP_VS
 	tristate "IP virtual server support (EXPERIMENTAL)"
-	depends on NETFILTER
+	depends on NETFILTER && EXPERIMENTAL
 	---help---
 	  IP Virtual Server support will let you build a high-performance
 	  virtual server based on cluster of two or more real servers. This
