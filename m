From: Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] mwifiex: advertise low priority scan feature
Date: Mon, 21 Mar 2016 16:09:39 +0800
Message-ID: <CABicQ-UBhk9pdY1EsT1wp6+ZqabbBv47wsciCFbPzzPuOzOFbg@mail.gmail.com>
References: <1458547622-1632-1-git-send-email-wnhuang@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Daniel Kurtz <djkurtz-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458547622-1632-1-git-send-email-wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

On Mon, Mar 21, 2016 at 4:07 PM, Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> =
wrote:
> From: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>
> Low priority scan handling code which delays or aborts scan
> operation based on Tx traffic is removed recently. The reason
> is firmware already takes care of it in our new feature scan
> channel gap. Hence we should advertise low priority scan
> support to cfg80211.
>
> This patch fixes a problem in which OBSS scan request from
> wpa_supplicant was being rejected by cfg80211.
>
> Signed-off-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/cfg80211.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/driver=
s/net/wireless/marvell/mwifiex/cfg80211.c
> index bb7235e..7dafc5b 100644
> --- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> +++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> @@ -4086,6 +4086,7 @@ int mwifiex_register_cfg80211(struct mwifiex_ad=
apter *adapter)
>
>         wiphy->features |=3D NL80211_FEATURE_HT_IBSS |
>                            NL80211_FEATURE_INACTIVITY_TIMER |
> +                          NL80211_FEATURE_LOW_PRIORITY_SCAN |
>                            NL80211_FEATURE_NEED_OBSS_SCAN;
>
>         if (ISSUPP_TDLS_ENABLED(adapter->fw_cap_info))
> --
> 2.8.0.rc3.226.g39d4020
>



--=20
Wei-Ning Huang, =E9=BB=83=E5=81=89=E5=AF=A7 | Software Engineer, Google=
 Inc., Taiwan |
wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org | Cell: +886 910-380678
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
