From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: ec_bhf: Add runtime dependencies
Date: Mon, 26 May 2014 21:26:14 +0200
Message-ID: <20140526212614.6e2610b0@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Darek Marcinkiewicz <reksio@newterm.pl>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49072 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728AbaEZT0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 15:26:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ec_bhf driver is specific to the Beckhoff CX5020, an embedded PC
based on a 32-bit Intel Atom CPU. So we can add a dependency on
X86_32, with COMPILE_TEST as an alternative to still allow for broader
build-testing.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Darek Marcinkiewicz <reksio@newterm.pl>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.15-rc7.orig/drivers/net/ethernet/Kconfig	2014-05-26 09:24:00.555619955 +0200
+++ linux-3.15-rc7/drivers/net/ethernet/Kconfig	2014-05-26 21:01:32.971410992 +0200
@@ -39,6 +39,7 @@ source "drivers/net/ethernet/cisco/Kconf
 config CX_ECAT
 	tristate "Beckhoff CX5020 EtherCAT master support"
 	depends on PCI
+	depends on X86_32 || COMPILE_TEST
 	---help---
 	  Driver for EtherCAT master module located on CCAT FPGA
 	  that can be found on Beckhoff CX5020, and possibly other of CX


-- 
Jean Delvare
SUSE L3 Support
