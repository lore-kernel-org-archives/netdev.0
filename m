From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 8/8] Makefile: drop -D__CHECK_ENDIAN__ from cflags
Date: Thu, 15 Dec 2016 08:00:09 +0100
Message-ID: <DF6B4348-C994-47D1-89C9-1BE16062C2B3@holtmann.org>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
 <1481778865-27667-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Vince Bridgers <vbridger@opensource.altera.com>,
        Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Int
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1481778865-27667-9-git-send-email-mst@redhat.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

> That's the default now, no need for makefiles to set it.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> drivers/bluetooth/Makefile                                | 2 --
> drivers/net/can/Makefile                                  | 1 -
> drivers/net/ethernet/altera/Makefile                      | 1 -
> drivers/net/ethernet/atheros/alx/Makefile                 | 1 -
> drivers/net/ethernet/freescale/Makefile                   | 2 --
> drivers/net/wireless/ath/Makefile                         | 2 --
> drivers/net/wireless/ath/wil6210/Makefile                 | 2 --
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile | 2 --
> drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile | 1 -
> drivers/net/wireless/intel/iwlegacy/Makefile              | 2 --
> drivers/net/wireless/intel/iwlwifi/Makefile               | 2 +-
> drivers/net/wireless/intel/iwlwifi/dvm/Makefile           | 2 +-
> drivers/net/wireless/intel/iwlwifi/mvm/Makefile           | 2 +-
> drivers/net/wireless/intersil/orinoco/Makefile            | 3 ---
> drivers/net/wireless/mediatek/mt7601u/Makefile            | 2 --
> drivers/net/wireless/realtek/rtlwifi/Makefile             | 2 --
> drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile    | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile   | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile  | 2 --
> drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile   | 2 --
> drivers/net/wireless/ti/wl1251/Makefile                   | 2 --
> drivers/net/wireless/ti/wlcore/Makefile                   | 2 --
> drivers/staging/rtl8188eu/Makefile                        | 2 +-
> drivers/staging/rtl8192e/Makefile                         | 2 --
> drivers/staging/rtl8192e/rtl8192e/Makefile                | 2 --
> net/bluetooth/Makefile                                    | 2 --
> net/ieee802154/Makefile                                   | 2 --
> net/mac80211/Makefile                                     | 2 +-
> net/mac802154/Makefile                                    | 2 --
> net/wireless/Makefile                                     | 2 --
> 38 files changed, 5 insertions(+), 68 deletions(-)

for drivers/bluetooth, net/bluetooth, net/ieee802154 and net/mac802154

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel

