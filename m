From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 06/20] drivers/net/ethernet/stmicro/stmmac: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:30 -0800
Message-ID: <1358879444-25834-7-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 1164930..c0ea838 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -26,8 +26,8 @@ config STMMAC_PLATFORM
 	  If unsure, say N.
 
 config STMMAC_PCI
-	bool "STMMAC PCI bus support (EXPERIMENTAL)"
-	depends on STMMAC_ETH && PCI && EXPERIMENTAL
+	bool "STMMAC PCI bus support"
+	depends on STMMAC_ETH && PCI
 	---help---
 	  This is to select the Synopsys DWMAC available on PCI devices,
 	  if you have a controller with this interface, say Y or M here.
-- 
1.7.9.5
