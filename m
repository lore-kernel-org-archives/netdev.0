From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 10/20] drivers/net/ppp: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:34 -0800
Message-ID: <1358879444-25834-11-git-send-email-keescook@chromium.org>
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
 drivers/net/ppp/Kconfig |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp/Kconfig b/drivers/net/ppp/Kconfig
index 3d9ef4f..1373c6d 100644
--- a/drivers/net/ppp/Kconfig
+++ b/drivers/net/ppp/Kconfig
@@ -82,8 +82,8 @@ config PPP_FILTER
 	  If unsure, say N.
 
 config PPP_MPPE
-	tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
-	depends on PPP && EXPERIMENTAL
+	tristate "PPP MPPE compression (encryption)"
+	depends on PPP
 	select CRYPTO
 	select CRYPTO_SHA1
 	select CRYPTO_ARC4
@@ -96,8 +96,8 @@ config PPP_MPPE
 	  configuring PPTP clients and servers to utilize this method.
 
 config PPP_MULTILINK
-	bool "PPP multilink support (EXPERIMENTAL)"
-	depends on PPP && EXPERIMENTAL
+	bool "PPP multilink support"
+	depends on PPP
 	---help---
 	  PPP multilink is a protocol (defined in RFC 1990) which allows you
 	  to combine several (logical or physical) lines into one logical PPP
@@ -118,8 +118,8 @@ config PPPOATM
 	  changes its encapsulation unilaterally.
 
 config PPPOE
-	tristate "PPP over Ethernet (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && PPP
+	tristate "PPP over Ethernet"
+	depends on PPP
 	---help---
 	  Support for PPP over Ethernet.
 
@@ -130,8 +130,8 @@ config PPPOE
 	  the heading "Kernel mode PPPoE").
 
 config PPTP
-	tristate "PPP over IPv4 (PPTP) (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && PPP && NET_IPGRE_DEMUX
+	tristate "PPP over IPv4 (PPTP)"
+	depends on PPP && NET_IPGRE_DEMUX
 	---help---
 	  Support for PPP over IPv4.(Point-to-Point Tunneling Protocol)
 
@@ -141,8 +141,8 @@ config PPTP
 	  utilize this module.
 
 config PPPOL2TP
-	tristate "PPP over L2TP (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && L2TP && PPP
+	tristate "PPP over L2TP"
+	depends on L2TP && PPP
 	---help---
 	  Support for PPP-over-L2TP socket family. L2TP is a protocol
 	  used by ISPs and enterprises to tunnel PPP traffic over UDP
-- 
1.7.9.5
