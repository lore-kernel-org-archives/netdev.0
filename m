From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14] fec_8xx: make CONFIG_FEC_8XX depend on CONFIG_8xx
Date: Sat, 5 Nov 2005 21:57:04 -0500
Message-ID: <20051106025701.GA9698@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932217AbVKFC5j@vger.kernel.org>
To: linuxppc-embedded@ozlabs.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make CONFIG_FEC_8XX depend on CONFIG_8xx.  This keeps allmodconfig from
breaking on non-8xx (PPC) platforms.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/fec_8xx/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fec_8xx/Kconfig b/drivers/net/fec_8xx/Kconfig
index 4560026..a84c232 100644
--- a/drivers/net/fec_8xx/Kconfig
+++ b/drivers/net/fec_8xx/Kconfig
@@ -1,6 +1,6 @@
 config FEC_8XX
 	tristate "Motorola 8xx FEC driver"
-	depends on NET_ETHERNET
+	depends on NET_ETHERNET && 8xx
 	select MII
 
 config FEC_8XX_GENERIC_PHY
-- 
John W. Linville
linville@tuxdriver.com
