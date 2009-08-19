From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH v2] net: fix ks8851 build errors
Date: Wed, 19 Aug 2009 08:52:02 -0700
Message-ID: <20090819085202.810630a2.randy.dunlap@oracle.com>
References: <20090818184215.fdf1c7ae.sfr@canb.auug.org.au>
	<20090818152705.64557a0b.randy.dunlap@oracle.com>
	<20090818.201200.69809801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090818.201200.69809801.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build errors due to missing Kconfig select of CRC32:

ks8851.c:(.text+0x7d2ee): undefined reference to `crc32_le'
ks8851.c:(.text+0x7d2f5): undefined reference to `bitrev32'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20090818.orig/drivers/net/Kconfig
+++ linux-next-20090818/drivers/net/Kconfig
@@ -1733,6 +1733,7 @@ config KS8851
        tristate "Micrel KS8851 SPI"
        depends on SPI
        select MII
+	select CRC32
        help
          SPI driver for Micrel KS8851 SPI attached network chip.
 




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
