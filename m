From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3.8 0/5 V2] Fixes for WARNINGS due to unchecked DMA mapping calls
Date: Thu, 27 Dec 2012 10:37:27 -0600
Message-ID: <1356626252-4058-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:59091 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072Ab2L0Qhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 11:37:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Beginning with kernel 3.8, the DMA mapping systems begins issuing a WARNING for
the first call that maps DMA and fails to call dma_mapping_error() to check
the result. This set of patches adds the appropriate checks to the rtlwifi
family of drivers.

V2 fixes a copy-and-paste error in patch 4/5. All others are unchanged.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

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
