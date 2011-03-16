From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: 2.6.38 Compile Failure e1000e Module
Date: Wed, 16 Mar 2011 08:21:05 -0700
Message-ID: <20110316082105.c911bb1c.randy.dunlap@oracle.com>
References: <20110316103318.19bd03e4.frank.peters@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	davem@davemloft.net
To: Frank Peters <frank.peters@comcast.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110316103318.19bd03e4.frank.peters@comcast.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
Please test this patch:


From: Randy Dunlap <randy.dunlap@oracle.com>

e1000e needs to select CRC32 for CRC support.
This patch fixes the build error:
ERROR: "crc32_le" [drivers/net/e1000e/e1000e.ko] undefined!

Reported-by: Frank Peters <frank.peters@comcast.net>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- lnx-2638.orig/drivers/net/Kconfig
+++ lnx-2638/drivers/net/Kconfig
@@ -2099,6 +2099,7 @@ config E1000
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
+	select CRC32
 	---help---
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
 	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
