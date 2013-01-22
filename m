From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/20] drivers/net/ethernet/microchip: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:27 -0800
Message-ID: <1358879444-25834-4-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/microchip/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index 8163fd0..afaf0c0 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_MICROCHIP
 	bool "Microchip devices"
 	default y
-	depends on SPI && EXPERIMENTAL
+	depends on SPI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -20,7 +20,7 @@ if NET_VENDOR_MICROCHIP
 
 config ENC28J60
 	tristate "ENC28J60 support"
-	depends on SPI && EXPERIMENTAL
+	depends on SPI
 	select CRC32
 	---help---
 	  Support for the Microchip EN28J60 ethernet chip.
-- 
1.7.9.5
