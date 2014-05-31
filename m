From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH v2] net: ec_bhf: Add runtime dependencies
Date: Sat, 31 May 2014 17:32:27 +0200
Message-ID: <20140531173227.693f6429@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Darek Marcinkiewicz <reksio@newterm.pl>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50234 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbaEaPcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2014 11:32:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ec_bhf driver is specific to the Beckhoff CX embedded PC series.
These are based on Intel x86 CPU. So we can add a dependency on
X86, with COMPILE_TEST as an alternative to still allow for broader
build-testing.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Darek Marcinkiewicz <reksio@newterm.pl>
Cc: David S. Miller <davem@davemloft.net>
---
Changes since v1:
 * Depend on X86 instead of X86_32.

 drivers/net/ethernet/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.15-rc7.orig/drivers/net/ethernet/Kconfig	2014-05-30 12:45:25.185014302 +0200
+++ linux-3.15-rc7/drivers/net/ethernet/Kconfig	2014-05-31 17:25:40.286213925 +0200
@@ -39,6 +39,7 @@ source "drivers/net/ethernet/cisco/Kconf
 config CX_ECAT
 	tristate "Beckhoff CX5020 EtherCAT master support"
 	depends on PCI
+	depends on X86 || COMPILE_TEST
 	---help---
 	  Driver for EtherCAT master module located on CCAT FPGA
 	  that can be found on Beckhoff CX5020, and possibly other of CX

-- 
Jean Delvare
SUSE L3 Support
