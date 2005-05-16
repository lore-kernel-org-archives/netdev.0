From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] document that 8139TOO supports 8129/8130
Date: Mon, 16 May 2005 21:13:03 +0200
Message-ID: <20050516191303.GF5112@stusta.de>
References: <20050513040445.GD3603@stusta.de> <4287C637.4030206@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4287C637.4030206@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2005 at 05:59:19PM -0400, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >+	  the RTL 8129/81308139 chips. If you have one of those, say Y and
> 
> typo:  "81308139"

It wasn't easy to make a mistake in such a simple patch.  ;-)

Fixed patch below.

cu
Adrian


<--  snip  -->


The 8129/8130 support is a sub-option that is not visible if the user 
hasn't enabled the 8139 support.

Let's make it a bit easier for users to find the driver for their nic.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.12-rc4-mm1-full/drivers/net/Kconfig.old	2005-05-13 05:54:05.000000000 +0200
+++ linux-2.6.12-rc4-mm1-full/drivers/net/Kconfig	2005-05-13 06:00:21.000000000 +0200
@@ -1484,14 +1484,14 @@
 	  will be called 8139cp.  This is recommended.
 
 config 8139TOO
-	tristate "RealTek RTL-8139 PCI Fast Ethernet Adapter support"
+	tristate "RealTek RTL-8129/8130/8139 PCI Fast Ethernet Adapter support"
 	depends on NET_PCI && PCI
 	select CRC32
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the RTL8139 chips. If you have one of those, say Y and read
-	  the Ethernet-HOWTO <http://www.tldp.org/docs.html#howto>.
+	  the RTL 8129/8130/8139 chips. If you have one of those, say Y and
+	  read the Ethernet-HOWTO <http://www.tldp.org/docs.html#howto>.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called 8139too.  This is recommended.
