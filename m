From: akpm@linux-foundation.org
Subject: [patch 5/8] hysdn: no longer broken on SMP
Date: Wed, 14 May 2008 16:19:44 -0700
Message-ID: <200805142319.m4ENJigG026563@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, kkeil@suse.de,
	mark.asselstine@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45700 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754241AbYENXUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

With the cli/sti code sorted out we think this driver is OK for use on SMP
systems.

Acked-by: Mark Asselstine <mark.asselstine@windriver.com>
Acked-by: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hysdn/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hysdn/Kconfig~hysdn-no-longer-broken-on-smp drivers/isdn/hysdn/Kconfig
--- a/drivers/isdn/hysdn/Kconfig~hysdn-no-longer-broken-on-smp
+++ a/drivers/isdn/hysdn/Kconfig
@@ -3,7 +3,7 @@
 #
 config HYSDN
 	tristate "Hypercope HYSDN cards (Champ, Ergo, Metro) support (module only)"
-	depends on m && PROC_FS && PCI && BROKEN_ON_SMP
+	depends on m && PROC_FS && PCI
 	help
 	  Say Y here if you have one of Hypercope's active PCI ISDN cards
 	  Champ, Ergo and Metro. You will then get a module called hysdn.
_
