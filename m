From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 0/4 linux-next] drivers/net: use container_of where possible
Date: Sun, 14 Sep 2014 09:32:38 +0200
Message-ID: <54154496.3070809@broadcom.com>
References: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410640709-18295-1-git-send-email-fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/13/14 22:38, Fabian Frederick wrote:
> Small patchset using container_of instead of casting on first structure member address.

Hi Fabian,

I think you need to split up this series. One for the ethernet drivers 
and one for the wireless driver. As there is not dependency between the 
patches they can each go through their own subsystem git tree. Generally 
I tend to submit patches to the subsystem maintainer and Cc the 
appropriate mailing lists.

Regarding the patches for brcmsmac, you can add

Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Regards,
Arend

> Fabian Frederick (4):
>    net: fec: use container_of to resolve bufdesc_ex from bufdesc
>    bna: use container_of to resolve bufdesc_ex from bufdesc
>    brcm80211: use container_of to resolve brcms_phy from brcms_phy_pub
>    brcm80211: use container_of to resolve dma_info from dma_pub
>
>   drivers/net/ethernet/brocade/bna/bna_enet.c        |   9 +-
>   drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   4 +-
>   drivers/net/ethernet/freescale/fec_main.c          |   4 +-
>   drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  38 +++----
>   .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  | 122 ++++++++++-----------
>   .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   6 +-
>   .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   8 +-
>   7 files changed, 97 insertions(+), 94 deletions(-)
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
