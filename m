From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 8/8] Makefile: drop -D__CHECK_ENDIAN__ from cflags
Date: Thu, 15 Dec 2016 08:43:44 +0200
Message-ID: <87inqllmjj.fsf@purkki.adurom.net>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
 <1481778865-27667-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
 Stanislaw Gruszka <sgruszka@redhat.com>, Gustavo Padovan <gustavo@padovan.org>,
 Arend van Spriel <arend.vanspriel@broadcom.com>,
 Luca Coelho <luciano.coelho@intel.com>,
 "David S. Mi  ller" <"d avem"@davemloft.net>, devel@driverdev.osuosl.org,
 Jakub Kicinski <kubakici@wp.pl>, Stefan Schmidt <stefan@osg.samsung.com>,
 linux-mediatek@lists.infradead.org, wil6210@qca.qualcomm.com,
 Chris Snook <chris.snook@gmail.com>, Wolfgang Grandegger <wg@grandegger.com>,
 Jay Cliburn <jcliburn@gmail.com>, linux-wpan@vger.kernel.org,
 Johan Hedberg <johan.hedberg@gmail.com>,
 Johannes Berg <johannes.berg@intel.com>,
 Intel Linux Wireless <linuxwifi@intel.com>,
 Alexander Aring <aar@pengutronix.de>, Marcel Holtmann <marcel@holtmann.org>,
 Hante Meuleman <hante.meuleman@broadcom.com>, linux-can@vger.kernel.org,
 Marc Kleine-Budde <mkl@pengutronix.de>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1481778865-27667-9-git-send-email-mst@redhat.com> (Michael S.
 Tsirkin's message of "Thu, 15 Dec 2016 07:15:30 +0200")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:

> That's the default now, no need for makefiles to set it.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/bluetooth/Makefile                                | 2 --
>  drivers/net/can/Makefile                                  | 1 -
>  drivers/net/ethernet/altera/Makefile                      | 1 -
>  drivers/net/ethernet/atheros/alx/Makefile                 | 1 -
>  drivers/net/ethernet/freescale/Makefile                   | 2 --
>  drivers/net/wireless/ath/Makefile                         | 2 --
>  drivers/net/wireless/ath/wil6210/Makefile                 | 2 --
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile | 2 --
>  drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile | 1 -
>  drivers/net/wireless/intel/iwlegacy/Makefile              | 2 --
>  drivers/net/wireless/intel/iwlwifi/Makefile               | 2 +-
>  drivers/net/wireless/intel/iwlwifi/dvm/Makefile           | 2 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/Makefile           | 2 +-
>  drivers/net/wireless/intersil/orinoco/Makefile            | 3 ---
>  drivers/net/wireless/mediatek/mt7601u/Makefile            | 2 --
>  drivers/net/wireless/realtek/rtlwifi/Makefile             | 2 --
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile    | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile   | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile  | 2 --
>  drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile   | 2 --
>  drivers/net/wireless/ti/wl1251/Makefile                   | 2 --
>  drivers/net/wireless/ti/wlcore/Makefile                   | 2 --
>  drivers/staging/rtl8188eu/Makefile                        | 2 +-
>  drivers/staging/rtl8192e/Makefile                         | 2 --
>  drivers/staging/rtl8192e/rtl8192e/Makefile                | 2 --
>  net/bluetooth/Makefile                                    | 2 --
>  net/ieee802154/Makefile                                   | 2 --
>  net/mac80211/Makefile                                     | 2 +-
>  net/mac802154/Makefile                                    | 2 --
>  net/wireless/Makefile                                     | 2 --
>  38 files changed, 5 insertions(+), 68 deletions(-)

For drivers/net/wireless:

Acked-by: Kalle Valo <kvalo@codeaurora.org>

-- 
Kalle Valo
