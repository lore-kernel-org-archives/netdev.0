From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 196/493] net/wireless: remove use of __devinit
Date: Mon, 19 Nov 2012 14:03:42 -0600
Message-ID: <50AA909E.6020005@lwfinger.net>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-196-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Dan Williams <dcbw@redhat.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Luciano Coelho <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	b43-dev@lists.infradead.org, brcm80211-dev-list@broadcom.com,
	libertas-dev@lists.infradead.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:41091 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2KSUDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 15:03:49 -0500
In-Reply-To: <1353349642-3677-196-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2012 12:22 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devinit is no longer
> needed.
>
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: Jiri Slaby <jirislaby@gmail.com>
> Cc: Nick Kossifidis <mickflemm@gmail.com>
> Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
> Cc: Simon Kelley <simon@thekelleys.org.uk>
> Cc: Stefano Brivio <stefano.brivio@polimi.it>
> Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
> Cc: Dan Williams <dcbw@redhat.com>
> Cc: Christian Lamparter <chunkeey@googlemail.com>
> Cc: Herton Ronaldo Krzesinski <herton@canonical.com>
> Cc: Hin-Tak Leung <htl10@users.sourceforge.net>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
> Cc: Luciano Coelho <coelho@ti.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: ath5k-devel@lists.ath5k.org
> Cc: b43-dev@lists.infradead.org
> Cc: brcm80211-dev-list@broadcom.com
> Cc: libertas-dev@lists.infradead.org
> ---
>   drivers/net/wireless/adm8211.c                        | 2 +-
>   drivers/net/wireless/airo.c                           | 2 +-
>   drivers/net/wireless/ath/ath5k/base.c                 | 4 ++--
>   drivers/net/wireless/ath/ath5k/led.c                  | 2 +-
>   drivers/net/wireless/ath/ath5k/pci.c                  | 2 +-
>   drivers/net/wireless/atmel_pci.c                      | 2 +-
>   drivers/net/wireless/b43/pcmcia.c                     | 2 +-
>   drivers/net/wireless/b43/sdio.c                       | 2 +-
>   drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 2 +-
>   drivers/net/wireless/ipw2x00/ipw2200.c                | 4 ++--
>   drivers/net/wireless/libertas/if_spi.c                | 2 +-
>   drivers/net/wireless/mwl8k.c                          | 2 +-
>   drivers/net/wireless/p54/p54pci.c                     | 2 +-
>   drivers/net/wireless/p54/p54spi.c                     | 2 +-
>   drivers/net/wireless/p54/p54usb.c                     | 2 +-
>   drivers/net/wireless/rtl818x/rtl8180/dev.c            | 2 +-
>   drivers/net/wireless/rtl818x/rtl8187/dev.c            | 2 +-
>   drivers/net/wireless/rtlwifi/pci.c                    | 2 +-
>   drivers/net/wireless/rtlwifi/pci.h                    | 2 +-
>   drivers/net/wireless/rtlwifi/usb.c                    | 2 +-
>   drivers/net/wireless/rtlwifi/usb.h                    | 2 +-
>   drivers/net/wireless/ti/wl1251/spi.c                  | 2 +-
>   drivers/net/wireless/ti/wl12xx/main.c                 | 2 +-
>   drivers/net/wireless/ti/wl18xx/main.c                 | 2 +-
>   drivers/net/wireless/ti/wlcore/main.c                 | 2 +-
>   drivers/net/wireless/ti/wlcore/sdio.c                 | 2 +-
>   drivers/net/wireless/ti/wlcore/spi.c                  | 2 +-
>   drivers/net/wireless/ti/wlcore/wlcore.h               | 2 +-
>   28 files changed, 30 insertions(+), 30 deletions(-)

ACKed-by: Larry Finger <Larry.Finger.net> for the rtl8187 and rtlwifi parts.

>
> diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
> index a05bac2..bd89a29 100644
> --- a/drivers/net/wireless/adm8211.c
> +++ b/drivers/net/wireless/adm8211.c
> @@ -1761,7 +1761,7 @@ static const struct ieee80211_ops adm8211_ops = {
>   	.get_tsf		= adm8211_get_tsft
>   };
>
> -static int __devinit adm8211_probe(struct pci_dev *pdev,
> +static int adm8211_probe(struct pci_dev *pdev,
>   				   const struct pci_device_id *id)
>   {
>   	struct ieee80211_hw *dev;
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index af1096b..b010f41 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -5584,7 +5584,7 @@ static void timer_func( struct net_device *dev ) {
>   }
>
>   #ifdef CONFIG_PCI
> -static int __devinit airo_pci_probe(struct pci_dev *pdev,
> +static int airo_pci_probe(struct pci_dev *pdev,
>   				    const struct pci_device_id *pent)
>   {
>   	struct net_device *dev;
> diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
> index 9f31cfa..026ae8a 100644
> --- a/drivers/net/wireless/ath/ath5k/base.c
> +++ b/drivers/net/wireless/ath/ath5k/base.c
> @@ -2434,7 +2434,7 @@ static const struct ieee80211_iface_combination if_comb = {
>   	.num_different_channels = 1,
>   };
>
> -int __devinit
> +int
>   ath5k_init_ah(struct ath5k_hw *ah, const struct ath_bus_ops *bus_ops)
>   {
>   	struct ieee80211_hw *hw = ah->hw;
> @@ -2860,7 +2860,7 @@ static void ath5k_reset_work(struct work_struct *work)
>   	mutex_unlock(&ah->lock);
>   }
>
> -static int __devinit
> +static int
>   ath5k_init(struct ieee80211_hw *hw)
>   {
>
> diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
> index b9f708a..f77ef36 100644
> --- a/drivers/net/wireless/ath/ath5k/led.c
> +++ b/drivers/net/wireless/ath/ath5k/led.c
> @@ -158,7 +158,7 @@ void ath5k_unregister_leds(struct ath5k_hw *ah)
>   	ath5k_unregister_led(&ah->tx_led);
>   }
>
> -int __devinit ath5k_init_leds(struct ath5k_hw *ah)
> +int ath5k_init_leds(struct ath5k_hw *ah)
>   {
>   	int ret = 0;
>   	struct ieee80211_hw *hw = ah->hw;
> diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
> index c3ba483..1a78ba3 100644
> --- a/drivers/net/wireless/ath/ath5k/pci.c
> +++ b/drivers/net/wireless/ath/ath5k/pci.c
> @@ -155,7 +155,7 @@ static const struct ath_bus_ops ath_pci_bus_ops = {
>   * PCI Initialization *
>   \********************/
>
> -static int __devinit
> +static int
>   ath5k_pci_probe(struct pci_dev *pdev,
>   		const struct pci_device_id *id)
>   {
> diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
> index fbe6580..1c12fec 100644
> --- a/drivers/net/wireless/atmel_pci.c
> +++ b/drivers/net/wireless/atmel_pci.c
> @@ -49,7 +49,7 @@ static struct pci_driver atmel_driver = {
>   };
>
>
> -static int __devinit atmel_pci_probe(struct pci_dev *pdev,
> +static int atmel_pci_probe(struct pci_dev *pdev,
>   				     const struct pci_device_id *pent)
>   {
>   	struct net_device *dev;
> diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
> index 3477213..3506cca 100644
> --- a/drivers/net/wireless/b43/pcmcia.c
> +++ b/drivers/net/wireless/b43/pcmcia.c
> @@ -60,7 +60,7 @@ static int b43_pcmcia_resume(struct pcmcia_device *dev)
>   # define b43_pcmcia_resume		NULL
>   #endif /* CONFIG_PM */
>
> -static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
> +static int b43_pcmcia_probe(struct pcmcia_device *dev)
>   {
>   	struct ssb_bus *ssb;
>   	int err = -ENOMEM;
> diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
> index 80b0755..d2b1f98 100644
> --- a/drivers/net/wireless/b43/sdio.c
> +++ b/drivers/net/wireless/b43/sdio.c
> @@ -93,7 +93,7 @@ void b43_sdio_free_irq(struct b43_wldev *dev)
>   	sdio->irq_handler = NULL;
>   }
>
> -static int __devinit b43_sdio_probe(struct sdio_func *func,
> +static int b43_sdio_probe(struct sdio_func *func,
>   				    const struct sdio_device_id *id)
>   {
>   	struct b43_sdio *sdio;
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> index cdd5aa2..7e65f9a 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> @@ -1093,7 +1093,7 @@ fail:
>    *
>    * Perimeter lock is initialized in the course of this function.
>    */
> -static int __devinit brcms_bcma_probe(struct bcma_device *pdev)
> +static int brcms_bcma_probe(struct bcma_device *pdev)
>   {
>   	struct brcms_info *wl;
>   	struct ieee80211_hw *hw;
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
> index b809b99..3f099a6 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2200.c
> @@ -10774,7 +10774,7 @@ static void ipw_bg_link_down(struct work_struct *work)
>   	mutex_unlock(&priv->mutex);
>   }
>
> -static int __devinit ipw_setup_deferred_work(struct ipw_priv *priv)
> +static int ipw_setup_deferred_work(struct ipw_priv *priv)
>   {
>   	int ret = 0;
>
> @@ -11722,7 +11722,7 @@ static const struct net_device_ops ipw_netdev_ops = {
>   	.ndo_validate_addr	= eth_validate_addr,
>   };
>
> -static int __devinit ipw_pci_probe(struct pci_dev *pdev,
> +static int ipw_pci_probe(struct pci_dev *pdev,
>   				   const struct pci_device_id *ent)
>   {
>   	int err = 0;
> diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
> index 98cccc7..abc32e3 100644
> --- a/drivers/net/wireless/libertas/if_spi.c
> +++ b/drivers/net/wireless/libertas/if_spi.c
> @@ -1124,7 +1124,7 @@ static void if_spi_resume_worker(struct work_struct *work)
>   	}
>   }
>
> -static int __devinit if_spi_probe(struct spi_device *spi)
> +static int if_spi_probe(struct spi_device *spi)
>   {
>   	struct if_spi_card *card;
>   	struct lbs_private *priv = NULL;
> diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
> index c26cfaa..1bbdc63 100644
> --- a/drivers/net/wireless/mwl8k.c
> +++ b/drivers/net/wireless/mwl8k.c
> @@ -5755,7 +5755,7 @@ err_free_cookie:
>
>   	return rc;
>   }
> -static int __devinit mwl8k_probe(struct pci_dev *pdev,
> +static int mwl8k_probe(struct pci_dev *pdev,
>   				 const struct pci_device_id *id)
>   {
>   	static int printed_version;
> diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
> index b382469..e5b29e9 100644
> --- a/drivers/net/wireless/p54/p54pci.c
> +++ b/drivers/net/wireless/p54/p54pci.c
> @@ -540,7 +540,7 @@ out:
>   	pci_dev_put(pdev);
>   }
>
> -static int __devinit p54p_probe(struct pci_dev *pdev,
> +static int p54p_probe(struct pci_dev *pdev,
>   				const struct pci_device_id *id)
>   {
>   	struct p54p_priv *priv;
> diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
> index 51129f4..d75ab3e 100644
> --- a/drivers/net/wireless/p54/p54spi.c
> +++ b/drivers/net/wireless/p54/p54spi.c
> @@ -595,7 +595,7 @@ static void p54spi_op_stop(struct ieee80211_hw *dev)
>   	cancel_work_sync(&priv->work);
>   }
>
> -static int __devinit p54spi_probe(struct spi_device *spi)
> +static int p54spi_probe(struct spi_device *spi)
>   {
>   	struct p54s_priv *priv = NULL;
>   	struct ieee80211_hw *hw;
> diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
> index 0463ac2..000f7ba 100644
> --- a/drivers/net/wireless/p54/p54usb.c
> +++ b/drivers/net/wireless/p54/p54usb.c
> @@ -986,7 +986,7 @@ static int p54u_load_firmware(struct ieee80211_hw *dev,
>   	return err;
>   }
>
> -static int __devinit p54u_probe(struct usb_interface *intf,
> +static int p54u_probe(struct usb_interface *intf,
>   				const struct usb_device_id *id)
>   {
>   	struct usb_device *udev = interface_to_usbdev(intf);
> diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
> index b117541..6a5c0b8 100644
> --- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
> +++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
> @@ -901,7 +901,7 @@ static void rtl8180_eeprom_register_write(struct eeprom_93cx6 *eeprom)
>   	udelay(10);
>   }
>
> -static int __devinit rtl8180_probe(struct pci_dev *pdev,
> +static int rtl8180_probe(struct pci_dev *pdev,
>   				   const struct pci_device_id *id)
>   {
>   	struct ieee80211_hw *dev;
> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
> index 9892310..f879bc3 100644
> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
> @@ -1411,7 +1411,7 @@ static void rtl8187_eeprom_register_write(struct eeprom_93cx6 *eeprom)
>   	udelay(10);
>   }
>
> -static int __devinit rtl8187_probe(struct usb_interface *intf,
> +static int rtl8187_probe(struct usb_interface *intf,
>   				   const struct usb_device_id *id)
>   {
>   	struct usb_device *udev = interface_to_usbdev(intf);
> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> index f38e30a..f2bd68e 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -1756,7 +1756,7 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
>   	return true;
>   }
>
> -int __devinit rtl_pci_probe(struct pci_dev *pdev,
> +int rtl_pci_probe(struct pci_dev *pdev,
>   			    const struct pci_device_id *id)
>   {
>   	struct ieee80211_hw *hw = NULL;
> diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
> index f71b12a..5eee0fa 100644
> --- a/drivers/net/wireless/rtlwifi/pci.h
> +++ b/drivers/net/wireless/rtlwifi/pci.h
> @@ -236,7 +236,7 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw);
>
>   extern struct rtl_intf_ops rtl_pci_ops;
>
> -int __devinit rtl_pci_probe(struct pci_dev *pdev,
> +int rtl_pci_probe(struct pci_dev *pdev,
>   			    const struct pci_device_id *id);
>   void rtl_pci_disconnect(struct pci_dev *pdev);
>   int rtl_pci_suspend(struct device *dev);
> diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
> index e3ea4b3..29f0969 100644
> --- a/drivers/net/wireless/rtlwifi/usb.c
> +++ b/drivers/net/wireless/rtlwifi/usb.c
> @@ -940,7 +940,7 @@ static struct rtl_intf_ops rtl_usb_ops = {
>   	.waitq_insert = rtl_usb_tx_chk_waitq_insert,
>   };
>
> -int __devinit rtl_usb_probe(struct usb_interface *intf,
> +int rtl_usb_probe(struct usb_interface *intf,
>   			const struct usb_device_id *id)
>   {
>   	int err;
> diff --git a/drivers/net/wireless/rtlwifi/usb.h b/drivers/net/wireless/rtlwifi/usb.h
> index 43846b3..5235136 100644
> --- a/drivers/net/wireless/rtlwifi/usb.h
> +++ b/drivers/net/wireless/rtlwifi/usb.h
> @@ -156,7 +156,7 @@ struct rtl_usb_priv {
>
>
>
> -int __devinit rtl_usb_probe(struct usb_interface *intf,
> +int rtl_usb_probe(struct usb_interface *intf,
>   			    const struct usb_device_id *id);
>   void rtl_usb_disconnect(struct usb_interface *intf);
>   int rtl_usb_suspend(struct usb_interface *pusb_intf, pm_message_t message);
> diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
> index 3ec61b9..640a3d5 100644
> --- a/drivers/net/wireless/ti/wl1251/spi.c
> +++ b/drivers/net/wireless/ti/wl1251/spi.c
> @@ -237,7 +237,7 @@ static const struct wl1251_if_operations wl1251_spi_ops = {
>   	.power = wl1251_spi_set_power,
>   };
>
> -static int __devinit wl1251_spi_probe(struct spi_device *spi)
> +static int wl1251_spi_probe(struct spi_device *spi)
>   {
>   	struct wl12xx_platform_data *pdata;
>   	struct ieee80211_hw *hw;
> diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
> index bc522b6..c10e691 100644
> --- a/drivers/net/wireless/ti/wl12xx/main.c
> +++ b/drivers/net/wireless/ti/wl12xx/main.c
> @@ -1696,7 +1696,7 @@ static int wl12xx_setup(struct wl1271 *wl)
>   	return 0;
>   }
>
> -static int __devinit wl12xx_probe(struct platform_device *pdev)
> +static int wl12xx_probe(struct platform_device *pdev)
>   {
>   	struct wl1271 *wl;
>   	struct ieee80211_hw *hw;
> diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
> index 2d037d5..7171c93 100644
> --- a/drivers/net/wireless/ti/wl18xx/main.c
> +++ b/drivers/net/wireless/ti/wl18xx/main.c
> @@ -1499,7 +1499,7 @@ static int wl18xx_setup(struct wl1271 *wl)
>   	return 0;
>   }
>
> -static int __devinit wl18xx_probe(struct platform_device *pdev)
> +static int wl18xx_probe(struct platform_device *pdev)
>   {
>   	struct wl1271 *wl;
>   	struct ieee80211_hw *hw;
> diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
> index 25530c8..2dd4ada 100644
> --- a/drivers/net/wireless/ti/wlcore/main.c
> +++ b/drivers/net/wireless/ti/wlcore/main.c
> @@ -5659,7 +5659,7 @@ out:
>   	complete_all(&wl->nvs_loading_complete);
>   }
>
> -int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
> +int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
>   {
>   	int ret;
>
> diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
> index 830bf0d..6fa2a01 100644
> --- a/drivers/net/wireless/ti/wlcore/sdio.c
> +++ b/drivers/net/wireless/ti/wlcore/sdio.c
> @@ -214,7 +214,7 @@ static struct wl1271_if_operations sdio_ops = {
>   	.set_block_size = wl1271_sdio_set_block_size,
>   };
>
> -static int __devinit wl1271_probe(struct sdio_func *func,
> +static int wl1271_probe(struct sdio_func *func,
>   				  const struct sdio_device_id *id)
>   {
>   	struct wl12xx_platform_data *wlan_data;
> diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
> index b183001..ee39484 100644
> --- a/drivers/net/wireless/ti/wlcore/spi.c
> +++ b/drivers/net/wireless/ti/wlcore/spi.c
> @@ -324,7 +324,7 @@ static struct wl1271_if_operations spi_ops = {
>   	.set_block_size = NULL,
>   };
>
> -static int __devinit wl1271_probe(struct spi_device *spi)
> +static int wl1271_probe(struct spi_device *spi)
>   {
>   	struct wl12xx_spi_glue *glue;
>   	struct wl12xx_platform_data *pdata;
> diff --git a/drivers/net/wireless/ti/wlcore/wlcore.h b/drivers/net/wireless/ti/wlcore/wlcore.h
> index 68584aa..adc6152 100644
> --- a/drivers/net/wireless/ti/wlcore/wlcore.h
> +++ b/drivers/net/wireless/ti/wlcore/wlcore.h
> @@ -414,7 +414,7 @@ struct wl1271 {
>   	struct completion nvs_loading_complete;
>   };
>
> -int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev);
> +int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev);
>   int __devexit wlcore_remove(struct platform_device *pdev);
>   struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size, u32 aggr_buf_size);
>   int wlcore_free_hw(struct wl1271 *wl);
>
