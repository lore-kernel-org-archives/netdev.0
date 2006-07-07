From: akpm@osdl.org
Subject: [patch 8/9] smsc-ircc2: fix section reference mismatches
Date: Thu, 06 Jul 2006 23:58:27 -0700
Message-ID: <200607070658.k676wRh5030383@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, dtor@insightbb.com,
	dtor@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7618 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751221AbWGGG6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:34 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dtor@insightbb.com>

subsystem_configurations array is only used by an __init function,
therefore it should be marked __initdata, not __devinitdata.

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/irda/smsc-ircc2.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches
+++ a/drivers/net/irda/smsc-ircc2.c
@@ -2353,7 +2353,7 @@ static int __init smsc_superio_lpc(unsig
 #ifdef CONFIG_PCI
 #define PCIID_VENDOR_INTEL 0x8086
 #define PCIID_VENDOR_ALI 0x10b9
-static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __devinitdata = {
+static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __initdata = {
 	{
 		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
_
