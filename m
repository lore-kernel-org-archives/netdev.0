From: akpm@linux-foundation.org
Subject: [patch nacked? 1/4] e1000e: make E1000E default to the same kconfig setting as E1000
Date: Wed, 30 Jul 2008 12:40:46 -0700
Message-ID: <200807301940.m6UJek20012676@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58661 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753037AbYG3TmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Make E1000E default to the same kconfig setting as E1000.  So people's
machines don't stop working when they use oldconfig.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Jeff Garzik <jeff@garzik.org>
Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/Kconfig~e1000e-make-e1000e-default-to-the-same-kconfig-setting-as-e1000 drivers/net/Kconfig
--- a/drivers/net/Kconfig~e1000e-make-e1000e-default-to-the-same-kconfig-setting-as-e1000
+++ a/drivers/net/Kconfig
@@ -1952,6 +1952,7 @@ config E1000_DISABLE_PACKET_SPLIT
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
+	default E1000
 	---help---
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
 	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
_
