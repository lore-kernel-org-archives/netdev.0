From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 00/11] constify net pci_device_id
Date: Mon, 17 Jul 2017 23:39:48 +0530
Message-ID: <1500314995-3181-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
        kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

Arvind Yadav (11):
  [PATCH 01/11] rtlwifi: rtl8192de: constify pci_device_id.
  [PATCH 02/11] rtlwifi: rtl8192se: constify pci_device_id.
  [PATCH 03/11] rtlwifi: rtl8821ae: constify pci_device_id.
  [PATCH 04/11] rtlwifi: rtl8723ae: constify pci_device_id.
  [PATCH 05/11] rtlwifi: rtl8723be: constify pci_device_id.
  [PATCH 06/11] rtlwifi: rtl8188ee: constify pci_device_id.
  [PATCH 07/11] rtlwifi: rtl8192ee: constify pci_device_id.
  [PATCH 08/11] net: cadence: macb: constify pci_device_id.
  [PATCH 09/11] net: ec_bhf: constify pci_device_id.
  [PATCH 10/11] net: qtnfmac: constify pci_device_id.
  [PATCH 11/11] net: brcmfmac: constify pci_device_id.

 drivers/net/ethernet/cadence/macb_pci.c                 | 2 +-
 drivers/net/ethernet/ec_bhf.c                           | 2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c | 2 +-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c     | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c     | 2 +-
 11 files changed, 11 insertions(+), 11 deletions(-)

-- 
2.7.4
