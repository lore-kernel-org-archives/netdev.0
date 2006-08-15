From: akpm@osdl.org
Subject: [patch 16/41] ibmtr section fix
Date: Mon, 14 Aug 2006 23:00:05 -0700
Message-ID: <200608150600.k7F60506012648@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64402 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965156AbWHOGBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:50 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_mem_base from .text between 'ibmtr_probe1' (at offset 0x6e6) and 'ibmtr_probe_card'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_mem_base from .text between 'ibmtr_probe1' (at offset 0x74a) and 'ibmtr_probe_card'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_mem_base from .text between 'ibmtr_probe1' (at offset 0x7fd) and 'ibmtr_probe_card'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tokenring/ibmtr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/tokenring/ibmtr.c~ibmtr-section-fix drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c~ibmtr-section-fix
+++ a/drivers/net/tokenring/ibmtr.c
@@ -140,7 +140,7 @@ in the event that chatty debug messages 
 
 /* version and credits */
 #ifndef PCMCIA
-static char version[] __initdata =
+static char version[] __devinitdata =
     "\nibmtr.c: v1.3.57   8/ 7/94 Peter De Schrijver and Mark Swanson\n"
     "         v2.1.125 10/20/98 Paul Norton    <pnorton@ieee.org>\n"
     "         v2.2.0   12/30/98 Joel Sloan     <jjs@c-me.com>\n"
@@ -216,7 +216,7 @@ static int __devinitdata turbo_irq[IBMTR
 static int __devinitdata turbo_searched = 0;
 
 #ifndef PCMCIA
-static __u32 ibmtr_mem_base __initdata = 0xd0000;
+static __u32 ibmtr_mem_base __devinitdata = 0xd0000;
 #endif
 
 static void __devinit PrtChanID(char *pcid, short stride)
_
