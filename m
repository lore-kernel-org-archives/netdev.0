From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 4/5] m68k/mac: Export Peripheral System Controller (PSC) base address to modules
Date: Tue, 29 Sep 2015 10:24:05 +0200
Message-ID: <1443515046-13968-5-git-send-email-geert@linux-m68k.org>
References: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Joshua Thompson <funaho@jurai.org>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from laurent.telenet-ops.be ([195.130.137.89]:47715 "EHLO
	laurent.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933004AbbI2IYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 04:24:10 -0400
In-Reply-To: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_MACMACE=m:

    ERROR: psc [drivers/net/ethernet/apple/macmace.ko] undefined!

Add the missing export to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
I'm OK with this going in through the netdev tree, as "net: macmace:
Allow modular build" depends on it.
---
 arch/m68k/mac/psc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/m68k/mac/psc.c b/arch/m68k/mac/psc.c
index cd38f29955c87421..2290c0cae48beb8a 100644
--- a/arch/m68k/mac/psc.c
+++ b/arch/m68k/mac/psc.c
@@ -29,6 +29,7 @@
 
 int psc_present;
 volatile __u8 *psc;
+EXPORT_SYMBOL_GPL(psc);
 
 /*
  * Debugging dump, used in various places to see what's going on.
-- 
1.9.1
