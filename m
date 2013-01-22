From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 01/20] drivers/net/ethernet/fujitsu: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:25 -0800
Message-ID: <1358879444-25834-2-git-send-email-keescook@chromium.org>
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
 drivers/net/ethernet/fujitsu/Kconfig |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index aca1568..555527f 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_FUJITSU
 	bool "Fujitsu devices"
 	default y
-	depends on ISA || PCMCIA || (ISA && EXPERIMENTAL)
+	depends on ISA || PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -18,8 +18,8 @@ config NET_VENDOR_FUJITSU
 if NET_VENDOR_FUJITSU
 
 config AT1700
-	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on ISA && EXPERIMENTAL
+	tristate "AT1700/1720 support"
+	depends on ISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
-- 
1.7.9.5
