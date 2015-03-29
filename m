From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 83/86] brcm80211: drop pci dependency
Date: Sun, 29 Mar 2015 18:46:47 +0200
Message-ID: <55182C77.1000706@broadcom.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com> <1427635734-24786-84-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"Pieter-Paul Giesberts" <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Hans de Goede <hdegoede@redhat.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427635734-24786-84-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/29/15 15:43, Michael S. Tsirkin wrote:
> This file does not use any pci APIs, drop
> pci header includes.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c | 2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> index 227cb33..9331486 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> @@ -17,8 +17,6 @@
>
>   #include<linux/types.h>
>   #include<linux/netdevice.h>
> -#include<linux/pci.h>
> -#include<uapi/linux/pci_ids.h>
>   #include<linux/sched.h>
>   #include<linux/completion.h>
>   #include<linux/scatterlist.h>
