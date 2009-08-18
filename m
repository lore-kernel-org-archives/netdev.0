From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net: fix ks8851 build errors
Date: Tue, 18 Aug 2009 15:27:05 -0700
Message-ID: <20090818152705.64557a0b.randy.dunlap@oracle.com>
References: <20090818184215.fdf1c7ae.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37630 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbZHRWZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 18:25:59 -0400
In-Reply-To: <20090818184215.fdf1c7ae.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build errors due to missing Kconfig selects:

ks8851.c:(.text+0x7d2ee): undefined reference to `crc32_le'
ks8851.c:(.text+0x7d2f5): undefined reference to `bitrev32'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20090818.orig/drivers/net/Kconfig
+++ linux-next-20090818/drivers/net/Kconfig
@@ -1733,6 +1733,8 @@ config KS8851
        tristate "Micrel KS8851 SPI"
        depends on SPI
        select MII
+	select CRC32
+	select BITREVERSE
        help
          SPI driver for Micrel KS8851 SPI attached network chip.
 



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
