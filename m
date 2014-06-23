From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCHv3 0/6] rtlwifi: Fix incorrect MSR mask
Date: Mon, 23 Jun 2014 23:48:16 +0200
Message-ID: <1403560098-7520-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Peter Wu <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>,
	Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

An error was found in many rtlwifi drivers where an invalid mask was used,
(bt_msr & 0xfc) will never match 0x3. This has been corrected by supplying
a valid mask as a macro. Drivers which did not have this bug are still
modified for consistency.

Rickard Strandqvist (1):
  rtlwifi: Fix media status register mask AND Replace magic number by macro

 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h |    1 +
 drivers/staging/rtl8821ae/rtl8821ae/hw.c     |    2 +-
 drivers/staging/rtl8821ae/rtl8821ae/reg.h    |    1 +
 13 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
