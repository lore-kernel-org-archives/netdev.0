From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 04/20] drivers/net/ethernet/racal: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:28 -0800
Message-ID: <1358879444-25834-5-git-send-email-keescook@chromium.org>
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
 drivers/net/ethernet/racal/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/racal/Kconfig b/drivers/net/ethernet/racal/Kconfig
index 01969e0..53c6af1 100644
--- a/drivers/net/ethernet/racal/Kconfig
+++ b/drivers/net/ethernet/racal/Kconfig
@@ -19,8 +19,8 @@ config NET_VENDOR_RACAL
 if NET_VENDOR_RACAL
 
 config NI5010
-	tristate "NI5010 support (EXPERIMENTAL)"
-	depends on ISA && EXPERIMENTAL && BROKEN_ON_SMP
+	tristate "NI5010 support"
+	depends on ISA && BROKEN_ON_SMP
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
-- 
1.7.9.5
