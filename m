From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] rtlwifi: misspelled code and comments corrected.
Date: Sun, 12 Apr 2015 17:56:26 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1504121756050.2408@hadrien>
References: <1428850206-1303-1-git-send-email-pch851130@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	kvalo@codeaurora.org, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cheolhyun Park <pch851130@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428850206-1303-1-git-send-email-pch851130@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 12 Apr 2015, Cheolhyun Park wrote:

> Signed-off-by: Cheolhyun Park <pch851130@gmail.com>
> ---
>  drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/dm.c       | 2 +-
>  drivers/net/wireless/rtlwifi/rtl8821ae/dm.c       | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
> index f5ee67c..1273997 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
> @@ -312,7 +312,7 @@ static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
>  	struct dig_t *digtable = &rtlpriv->dm_digtable;
>  	u32 isbt;
>
> -	/* modify DIG lower bound, deal with abnorally large false alarm */
> +	/* modify DIG lower bound, deal with abnormally arge false alarm */

You have converted large to arge.

julia

>  	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
>  		digtable->large_fa_hit++;
>  		if (digtable->forbidden_igi < digtable->cur_igvalue) {
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
> index a1be5a6..f209cda 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
> @@ -420,7 +420,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
>  		 "dm_DIG() Before: Recover_cnt=%d, rx_gain_min=%x\n",
>  		 de_digtable->recover_cnt, de_digtable->rx_gain_min);
>
> -	/* deal with abnorally large false alarm */
> +	/* deal with abnormally large false alarm */
>  	if (falsealm_cnt->cnt_all > 10000) {
>  		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
>  			 "dm_DIG(): Abnormally false alarm case\n");
> diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
> index 0b2082d..342678d 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
> @@ -873,7 +873,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
>
>  	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
>  		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
> -			 "Abnornally false alarm case.\n");
> +			 "Abnormally false alarm case.\n");
>
>  		if (dm_digtable->large_fa_hit != 3)
>  			dm_digtable->large_fa_hit++;
> --
> 1.9.1
>
>
