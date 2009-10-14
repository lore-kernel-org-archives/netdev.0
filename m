From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] net: ks8851_mll uses mii interfaces
Date: Wed, 14 Oct 2009 14:59:05 -0700
Message-ID: <20091014145905.219416bb.randy.dunlap@oracle.com>
References: <200910140436.n9E4aF9G001644@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Choi <david.choi@micrel.com>
To: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761947AbZJNWBv@vger.kernel.org>
In-Reply-To: <200910140436.n9E4aF9G001644@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

ks8851_mll uses mii interfaces so it needs to select MII.

ks8851_mll.c:(.text+0xf95ac): undefined reference to `generic_mii_ioctl'
ks8851_mll.c:(.text+0xf96a0): undefined reference to `mii_ethtool_gset'
ks8851_mll.c:(.text+0xf96fa): undefined reference to `mii_ethtool_sset'
ks8851_mll.c:(.text+0xf9754): undefined reference to `mii_link_ok'
ks8851_mll.c:(.text+0xf97ae): undefined reference to `mii_nway_restart'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: David Choi <david.choi@micrel.com>
---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- mmotm-2009-1013-2113.orig/drivers/net/Kconfig
+++ mmotm-2009-1013-2113/drivers/net/Kconfig
@@ -1741,6 +1741,7 @@ config KS8851
 config KS8851_MLL
 	tristate "Micrel KS8851 MLL"
 	depends on HAS_IOMEM
+	select MII
 	help
 	  This platform driver is for Micrel KS8851 Address/data bus
 	  multiplexed network chip.
