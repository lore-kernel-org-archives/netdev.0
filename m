From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 08/20] drivers/net/hippi: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:32 -0800
Message-ID: <1358879444-25834-9-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: Jes Sorensen <jes@trained-monkey.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/hippi/Kconfig |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hippi/Kconfig b/drivers/net/hippi/Kconfig
index 95eb34f..f71515d 100644
--- a/drivers/net/hippi/Kconfig
+++ b/drivers/net/hippi/Kconfig
@@ -3,8 +3,8 @@
 #
 
 config HIPPI
-	bool "HIPPI driver support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && INET && PCI
+	bool "HIPPI driver support"
+	depends on INET && PCI
 	---help---
 	  HIgh Performance Parallel Interface (HIPPI) is a 800Mbit/sec and
 	  1600Mbit/sec dual-simplex switched or point-to-point network. HIPPI
@@ -18,7 +18,7 @@ config HIPPI
 if HIPPI
 
 config ROADRUNNER
-	tristate "Essential RoadRunner HIPPI PCI adapter support (EXPERIMENTAL)"
+	tristate "Essential RoadRunner HIPPI PCI adapter support"
 	depends on PCI
 	---help---
 	  Say Y here if this is your PCI HIPPI network card.
@@ -27,7 +27,7 @@ config ROADRUNNER
 	  will be called rrunner.  If unsure, say N.
 
 config ROADRUNNER_LARGE_RINGS
-	bool "Use large TX/RX rings (EXPERIMENTAL)"
+	bool "Use large TX/RX rings"
 	depends on ROADRUNNER
 	---help---
 	  If you say Y here, the RoadRunner driver will preallocate up to 2 MB
-- 
1.7.9.5
