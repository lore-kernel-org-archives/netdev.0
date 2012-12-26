From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V3.8 0/5] Fixes for WARNINGS due to unchecked DMA mapping calls
Date: Wed, 26 Dec 2012 16:08:06 -0600
Message-ID: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Beginning with kernel 3.8, the DMA mapping systems begins issuing a WARNING for
the first call that maps DMA and fails to call dma_mapping_error() to check
the result. This set of patches adds the appropriate checks to the rtlwifi
family of drivers.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Larry Finger (5):
  rtlwifi: Fix warning for unchecked pci_map_single() call
  rtlwifi: rtl8192ce: Fix warning for unchecked pci_map_single() call
  rtlwifi: rtl8192de: Fix warning for unchecked pci_map_single() call
  rtlwifi: rtl8192se: Fix warning for unchecked pci_map_single() call
  rtlwifi: rtl8723ae: Fix warning for unchecked pci_map_single() call

 drivers/net/wireless/rtlwifi/pci.c           |    6 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |   11 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c |   10 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |   13 ++++++++++++-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |   12 ++++++++++++
 5 files changed, 51 insertions(+), 1 deletion(-)

-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
