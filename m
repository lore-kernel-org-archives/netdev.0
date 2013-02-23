From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] vxlan: remove depends on CONFIG_EXPERIMENTAL
Date: Fri, 22 Feb 2013 23:25:38 -0800
Message-ID: <20130223072538.GA4770@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 56c2d75..87f1d39 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -150,7 +150,7 @@ config MACVTAP
 
 config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
-       depends on EXPERIMENTAL && INET
+       depends on INET
        ---help---
 	  This allows one to create vxlan virtual interfaces that provide
 	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
