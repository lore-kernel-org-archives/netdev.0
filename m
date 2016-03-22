From: Wei-Ning Huang <wnhuang@google.com>
Subject: Re: [PATCH v2] mwifiex: advertise low priority scan feature
Date: Tue, 22 Mar 2016 12:12:58 +0800
Message-ID: <CABicQ-US2Vs6CEgOeWDjb7=ZHn8i2GthT2M_ZPbwM0vgDkZb9g@mail.gmail.com>
References: <1458619796-7694-1-git-send-email-wnhuang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Daniel Kurtz <djkurtz@chromium.org>,
	Wei-Ning Huang <wnhuang@chromium.org>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org
To: Linux Wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458619796-7694-1-git-send-email-wnhuang@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested-by: Wei-Ning Huang <wnhuang@chromium.org>

On Tue, Mar 22, 2016 at 12:09 PM, Wei-Ning Huang <wnhuang@chromium.org>=
 wrote:
> From: Amitkumar Karwar <akarwar@marvell.com>
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
> Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
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
wnhuang@google.com | Cell: +886 910-380678
