From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.7] TMS380 needs firmware loader
Date: Wed, 16 Jun 2004 14:30:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616143042.5c295fa3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: MIke Phillips <mikep@linuxtr.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This driver calls request_firmware so firmware loader it looks like it
needs the firmware loader.  Build tested only.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
--- a/drivers/net/tokenring/Kconfig	2004-06-16 14:28:48 -07:00
+++ b/drivers/net/tokenring/Kconfig	2004-06-16 14:28:48 -07:00
@@ -85,6 +85,7 @@
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
 	depends on TR && (PCI || ISA)
+	select FW_LOADER
 	---help---
 	  This driver provides generic support for token ring adapters
 	  based on the Texas Instruments TMS380 series chipsets.  This
