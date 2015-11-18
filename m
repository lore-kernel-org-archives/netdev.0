From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2 21/27] realtek: create separate Kconfig file
Date: Wed, 18 Nov 2015 10:30:20 -0600
Message-ID: <564CA79C.9050308@lwfinger.net>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
 <1447857966-19560-22-git-send-email-kvalo@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447857966-19560-22-git-send-email-kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/18/2015 08:46 AM, Kalle Valo wrote:
> Add new a Kconfig file and a vendor config for realtek. Also update MAINTAINERS
> which we missed to do when earlier moving rtlwifi.
>
> Signed-off-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> ---

Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Thanks,

Larry

>   MAINTAINERS                          |    8 ++++----
>   drivers/net/wireless/Kconfig         |    5 +----
>   drivers/net/wireless/Makefile        |    3 +--
>   drivers/net/wireless/realtek/Kconfig |   18 ++++++++++++++++++
>   4 files changed, 24 insertions(+), 10 deletions(-)
>   create mode 100644 drivers/net/wireless/realtek/Kconfig
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2c41981e4fdd..a9f7f968f64e 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9035,7 +9035,7 @@ L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>   W:	http://wireless.kernel.org/
>   T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing.git
>   S:	Orphan
> -F:	drivers/net/wireless/rtl818x/rtl8180/
> +F:	drivers/net/wireless/realtek/rtl818x/rtl8180/
>
>   RTL8187 WIRELESS DRIVER
>   M:	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> @@ -9045,7 +9045,7 @@ L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>   W:	http://wireless.kernel.org/
>   T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing.git
>   S:	Maintained
> -F:	drivers/net/wireless/rtl818x/rtl8187/
> +F:	drivers/net/wireless/realtek/rtl818x/rtl8187/
>
>   RTL8192CE WIRELESS DRIVER
>   M:	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> @@ -9054,8 +9054,8 @@ L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>   W:	http://wireless.kernel.org/
>   T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing.git
>   S:	Maintained
> -F:	drivers/net/wireless/rtlwifi/
> -F:	drivers/net/wireless/rtlwifi/rtl8192ce/
> +F:	drivers/net/wireless/realtek/rtlwifi/
> +F:	drivers/net/wireless/realtek/rtlwifi/rtl8192ce/
>
>   RTL8XXXU WIRELESS DRIVER (rtl8xxxu)
>   M:	Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index c92671f8b1c6..28af8b10a66e 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -24,6 +24,7 @@ source "drivers/net/wireless/cisco/Kconfig"
>   source "drivers/net/wireless/intel/Kconfig"
>   source "drivers/net/wireless/intersil/Kconfig"
>   source "drivers/net/wireless/marvell/Kconfig"
> +source "drivers/net/wireless/realtek/Kconfig"
>   source "drivers/net/wireless/st/Kconfig"
>   source "drivers/net/wireless/zydas/Kconfig"
>
> @@ -81,8 +82,6 @@ config USB_NET_RNDIS_WLAN
>
>   	  If you choose to build a module, it'll be called rndis_wlan.
>
> -source "drivers/net/wireless/realtek/rtl818x/Kconfig"
> -
>   config MAC80211_HWSIM
>   	tristate "Simulated radio testing tool for mac80211"
>   	depends on MAC80211
> @@ -99,8 +98,6 @@ config MAC80211_HWSIM
>   source "drivers/net/wireless/ath/Kconfig"
>   source "drivers/net/wireless/rt2x00/Kconfig"
>   source "drivers/net/wireless/mediatek/Kconfig"
> -source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
> -source "drivers/net/wireless/realtek/rtl8xxxu/Kconfig"
>   source "drivers/net/wireless/ti/Kconfig"
>   source "drivers/net/wireless/rsi/Kconfig"
>
> diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
> index 679a1a0a048d..12f6c59668a5 100644
> --- a/drivers/net/wireless/Makefile
> +++ b/drivers/net/wireless/Makefile
> @@ -9,11 +9,10 @@ obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
>   obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
>   obj-$(CONFIG_WLAN_VENDOR_INTERSIL) += intersil/
>   obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
> +obj-$(CONFIG_WLAN_VENDOR_REALTEK) += realtek/
>   obj-$(CONFIG_WLAN_VENDOR_ST) += st/
>   obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
>
> -obj-$(CONFIG_WLAN)		+= realtek/
> -
>   # 16-bit wireless PCMCIA client drivers
>   obj-$(CONFIG_PCMCIA_RAYCS)	+= ray_cs.o
>   obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
> diff --git a/drivers/net/wireless/realtek/Kconfig b/drivers/net/wireless/realtek/Kconfig
> new file mode 100644
> index 000000000000..8a8ba2003964
> --- /dev/null
> +++ b/drivers/net/wireless/realtek/Kconfig
> @@ -0,0 +1,18 @@
> +config WLAN_VENDOR_REALTEK
> +	bool "Realtek devices"
> +	default y
> +	---help---
> +	  If you have a wireless card belonging to this class, say Y.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about  cards. If you say Y, you will be asked for
> +	  your specific card in the following questions.
> +
> +if WLAN_VENDOR_REALTEK
> +
> +source "drivers/net/wireless/realtek/rtl818x/Kconfig"
> +source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
> +source "drivers/net/wireless/realtek/rtl8xxxu/Kconfig"
> +
> +endif # WLAN_VENDOR_REALTEK
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
