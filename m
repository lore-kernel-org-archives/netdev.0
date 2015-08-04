From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers 2015-08-04
Date: Tue, 04 Aug 2015 19:54:09 +0300
Message-ID: <87zj27yoy6.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are few small fixes I would like to get to 4.2. Please let me know
if there are any problems.

Kalle

The following changes since commit df2cd4586f177acf9493dee079fc7d18268c5f54:

  Merge tag 'iwlwifi-for-kalle-2015-06-12' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-07-17 11:19:08 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-08-04

for you to fetch changes up to 741e3b9902d11585e18bfc7f8d47e913616bb070:

  rtlwifi: rtl8723be: Add module parameter for MSI interrupts (2015-08-03 11:26:24 +0300)

----------------------------------------------------------------
iwlwifi:

* a fix for the stuck TFD queue mechanism - it was producing
  noisy false alarms
* a fix for the NIC prepare flow that prevented the driver
  from being able to access the device on certain systems
* a fix for the scan prority handling which allows the
  regular scan to run even if a scheduled scan is already
  running

rsi:

* fix firmware load DMA regression

b43:

* fix extpa_gain check for 2GHz

rtlwifi:

* fix NULL dereference when PCI driver used as an AP
* add missing module parameter declaration for rtl8723be_mod_params.msi_support

----------------------------------------------------------------
Avraham Stern (1):
      iwlwifi: mvm: Fix regular scan priority

Emmanuel Grumbach (2):
      iwlwifi: pcie: fix prepare card flow
      iwlwifi: pcie: fix stuck queue detection for sleeping clients

Hauke Mehrtens (1):
      b43: fix extpa_gain check for 2GHz

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-07-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: rtl8723be: Add module parameter for MSI interrupts

Luis Felipe Dominguez Vega (1):
      rtlwifi: Fix NULL dereference when PCI driver used as an AP

Mike Looijmans (1):
      rsi: Fix failure to load firmware after memory leak fix and fix the leak

 drivers/net/wireless/b43/tables_nphy.c      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c     |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c   |   22 +++++++++++++++++++---
 drivers/net/wireless/iwlwifi/pcie/tx.c      |   15 +++++++++++++--
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c |    8 +++++++-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c  |    4 ++++
 drivers/net/wireless/rtlwifi/core.c         |    7 +++++--
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c |    1 +
 8 files changed, 51 insertions(+), 10 deletions(-)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
