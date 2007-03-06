From: akpm@linux-foundation.org
Subject: [patch 16/19] __devinit & __devexit cleanups for de2104x driver
Date: Tue, 06 Mar 2007 02:42:00 -0800
Message-ID: <200703061042.l26Ag0C5019781@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	prarit@redhat.com, val_henson@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34746 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934073AbXCFKnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:43:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Prarit Bhargava <prarit@redhat.com>

Fixes MODPOST warnings similar to:

WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to
.init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to
.exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/de2104x.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/tulip/de2104x.c~__devinit-__devexit-cleanups-for-de2104x-driver drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c~__devinit-__devexit-cleanups-for-de2104x-driver
+++ a/drivers/net/tulip/de2104x.c
@@ -1685,7 +1685,7 @@ static const struct ethtool_ops de_ethto
 	.get_regs		= de_get_regs,
 };
 
-static void __init de21040_get_mac_address (struct de_private *de)
+static void __devinit de21040_get_mac_address (struct de_private *de)
 {
 	unsigned i;
 
@@ -1703,7 +1703,7 @@ static void __init de21040_get_mac_addre
 	}
 }
 
-static void __init de21040_get_media_info(struct de_private *de)
+static void __devinit de21040_get_media_info(struct de_private *de)
 {
 	unsigned int i;
 
@@ -1765,7 +1765,7 @@ static unsigned __devinit tulip_read_eep
 	return retval;
 }
 
-static void __init de21041_get_srom_info (struct de_private *de)
+static void __devinit de21041_get_srom_info (struct de_private *de)
 {
 	unsigned i, sa_offset = 0, ofs;
 	u8 ee_data[DE_EEPROM_SIZE + 6] = {};
_
