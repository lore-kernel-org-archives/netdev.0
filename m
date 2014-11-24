From: Andreas Ruprecht <rupran@einserver.de>
Subject: [PATCH 0/2] net: wireless: rtlwifi: Fix issues with Makefiles
Date: Mon, 24 Nov 2014 19:34:30 +0100
Message-ID: <1416854072-14794-1-git-send-email-rupran@einserver.de>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andreas Ruprecht <rupran@einserver.de>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series fixes two issues in the Makefiles for different
rtlwifi drivers.

The first one lead to object files for the drivers always being
included in obj-m even if the corresponding Kconfig option is set to
'y'.

The second one is likely to be a copy-and-paste mistake, which
prevents compilation of the rtl8192ee driver unless the
completely unrelated Kconfig option for the rtl8821ae driver
(CONFIG_RTL8821AE) is also enabled.

Andreas Ruprecht (2):
  net: wireless: rtlwifi: Do not always include drivers in obj-m
  net: wireless: rtlwifi: rtl8192ee: Fix compilation of the driver

 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile | 5 +----
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile | 3 ---
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile | 3 ---
 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile | 3 ---
 4 files changed, 1 insertion(+), 13 deletions(-)

--
1.9.1
