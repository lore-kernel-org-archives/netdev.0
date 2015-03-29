From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 57/86] brcm80211: use uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 18:45:46 +0200
Message-ID: <55182C3A.7020302@broadcom.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com> <1427635734-24786-58-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"Pieter-Paul Giesberts" <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Daniel (Deognyoun) Kim" <dekim-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>,
	Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427635734-24786-58-git-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/29/15 15:41, Michael S. Tsirkin wrote:
> Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
> use the new header directly so we can drop
> the wrapper in include/linux/pci_ids.h.

Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Michael S. Tsirkin<mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>   drivers/net/wireless/brcm80211/include/brcm_hw_ids.h | 2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c     | 2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c       | 2 +-
>   drivers/net/wireless/brcm80211/brcmsmac/main.c       | 2 +-
>   4 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h b/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
> index 2124a17..bd1370e 100644
> --- a/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
> +++ b/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
> @@ -17,7 +17,7 @@
>   #ifndef	_BRCM_HW_IDS_H_
>   #define	_BRCM_HW_IDS_H_
>
> -#include<linux/pci_ids.h>
> +#include<uapi/linux/pci_ids.h>
>   #include<linux/mmc/sdio_ids.h>
>
>   #define BRCM_USB_VENDOR_ID_BROADCOM	0x0a5c
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> index 7944224..227cb33 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> @@ -18,7 +18,7 @@
>   #include<linux/types.h>
>   #include<linux/netdevice.h>
>   #include<linux/pci.h>
> -#include<linux/pci_ids.h>
> +#include<uapi/linux/pci_ids.h>

I was surprised seeing this include here, but you deal with that in 
subsequent patches. Thanks.

Regards,
Arend
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
