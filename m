From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH -v3 16/23] drivers/net: rename random32() to
 prandom_u32()
Date: Mon, 4 Mar 2013 14:37:01 +0100
Message-ID: <5134A37D.9000704@broadcom.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
 <1362401911-14074-17-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Thomas Sailer" <t.sailer-aAjG49QhEdKVRmA6MYkXiA@public.gmane.org>,
	"Jean-Paul Roubelat" <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>,
	"Bing Zhao" <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Hante Meuleman" <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Akinobu Mita" <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1362401911-14074-17-git-send-email-akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/04/13 13:58, Akinobu Mita wrote:
> Use more preferable function name which implies using a pseudo-random
> number generator.
>
> Signed-off-by: Akinobu Mita<akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Thomas Sailer<t.sailer-aAjG49QhEdKVRmA6MYkXiA@public.gmane.org>
> Acked-by: Bing Zhao<bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>  [mwifiex]
> Cc: "David S. Miller"<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Michael Chan<mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: Thomas Sailer<t.sailer-aAjG49QhEdKVRmA6MYkXiA@public.gmane.org>
> Cc: Jean-Paul Roubelat<jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>
> Cc: Bing Zhao<bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
> Cc: Brett Rudley<brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: Arend van Spriel<arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: "Franky (Zhenhui) Lin"<frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: Hante Meuleman<meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
> * Changes from v2
> - add Acked-by: line
> - add rename for brcm80211
>
>   drivers/net/ethernet/broadcom/cnic.c          | 4 ++--
>   drivers/net/hamradio/baycom_epp.c             | 2 +-
>   drivers/net/hamradio/hdlcdrv.c                | 2 +-
>   drivers/net/hamradio/yam.c                    | 2 +-
>   drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 2 +-
>   drivers/net/wireless/mwifiex/cfg80211.c       | 4 ++--
>   6 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> index 4166e64..bca31a8 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> @@ -1118,7 +1118,7 @@ static void brcmf_p2p_afx_handler(struct work_struct *work)
>   	if (afx_hdl->is_listen&&  afx_hdl->my_listen_chan)
>   		/* 100ms ~ 300ms */
>   		err = brcmf_p2p_discover_listen(p2p, afx_hdl->my_listen_chan,
> -						100 * (1 + (random32() % 3)));
> +					100 * (1 + (prandom_u32() % 3)));

Seems like indentation is wrong now. Please retain the alignment.

Regards,
Arend

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
