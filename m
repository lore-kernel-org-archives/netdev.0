From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: constify brcmf_bus_ops structures
Date: Tue, 17 Nov 2015 09:47:03 +0100
Message-ID: <564AE987.60709@broadcom.com>
References: <1447518127-1994-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-janitors@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447518127-1994-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2015 05:22 PM, Julia Lawall wrote:
> The brcmf_bus_ops structures are never modified, so declare them as const.
>
> Done with the help of Coccinelle.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/bus.h  |    2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/pcie.c |    2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c |    2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/usb.c  |    2 +-
>   4 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bus.h b/drivers/net/wireless/brcm80211/brcmfmac/bus.h
> index 230cad7..36093f9 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/bus.h
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bus.h
> @@ -137,7 +137,7 @@ struct brcmf_bus {
>   	bool always_use_fws_queue;
>   	bool wowl_supported;
>
> -	struct brcmf_bus_ops *ops;
> +	const struct brcmf_bus_ops *ops;
>   	struct brcmf_bus_msgbuf *msgbuf;
>   };
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c b/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
> index 83d8042..65ae3b0 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
> @@ -1419,7 +1419,7 @@ static int brcmf_pcie_get_memdump(struct device *dev, void *data, size_t len)
>   }
>
>
> -static struct brcmf_bus_ops brcmf_pcie_bus_ops = {
> +static const struct brcmf_bus_ops brcmf_pcie_bus_ops = {
>   	.txdata = brcmf_pcie_tx,
>   	.stop = brcmf_pcie_down,
>   	.txctl = brcmf_pcie_tx_ctlpkt,
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> index 7e74ac3..01f359e 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> @@ -4025,7 +4025,7 @@ brcmf_sdio_watchdog(unsigned long data)
>   	}
>   }
>
> -static struct brcmf_bus_ops brcmf_sdio_bus_ops = {
> +static const struct brcmf_bus_ops brcmf_sdio_bus_ops = {
>   	.stop = brcmf_sdio_bus_stop,
>   	.preinit = brcmf_sdio_bus_preinit,
>   	.txdata = brcmf_sdio_bus_txdata,
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> index 689e64d..4bdd3b3 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> @@ -1163,7 +1163,7 @@ static void brcmf_usb_wowl_config(struct device *dev, bool enabled)
>   		device_set_wakeup_enable(devinfo->dev, false);
>   }
>
> -static struct brcmf_bus_ops brcmf_usb_bus_ops = {
> +static const struct brcmf_bus_ops brcmf_usb_bus_ops = {
>   	.txdata = brcmf_usb_tx,
>   	.stop = brcmf_usb_down,
>   	.txctl = brcmf_usb_tx_ctlpkt,
>
