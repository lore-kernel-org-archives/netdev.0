From: Andreas Ruprecht <rupran@einserver.de>
Subject: [PATCH 2/2] net: wireless: rtlwifi: rtl8192ee: Fix compilation of the driver
Date: Mon, 24 Nov 2014 19:34:32 +0100
Message-ID: <1416854072-14794-3-git-send-email-rupran@einserver.de>
References: <1416854072-14794-1-git-send-email-rupran@einserver.de>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andreas Ruprecht <rupran@einserver.de>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416854072-14794-1-git-send-email-rupran@einserver.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the Makefile for this driver, the wrong Kconfig option is used
to trigger the compilation of the object file. This leads to the
driver only being included into the kernel when both CONFIG_RTL8821AE
and CONFIG_RTL8192AE are set to "y".

Signed-off-by: Andreas Ruprecht <rupran@einserver.de>
---
 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/Makefile b/drivers/net/wireless/rtlwifi/rtl8192ee/Makefile
index 6bd46a9..0315eed 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/Makefile
@@ -11,6 +11,6 @@ rtl8192ee-objs :=		\
 		trx.o		\
 
 
-obj-$(CONFIG_RTL8821AE) += rtl8192ee.o
+obj-$(CONFIG_RTL8192EE) += rtl8192ee.o
 
 ccflags-y += -D__CHECK_ENDIAN__
-- 
1.9.1
