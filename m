From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1] rtlwifi: remove superfluous condition
Date: Sun, 31 Jul 2016 09:14:40 -0500
Message-ID: <4e6de16f-b42c-920a-60a2-fcc88e282dc0@lwfinger.net>
References: <1469961015-1888-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36089 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbcGaOOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 10:14:43 -0400
In-Reply-To: <1469961015-1888-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2016 05:30 AM, Heinrich Schuchardt wrote:
> If sta == NULL, the changed line will not be reached.
> So no need to check if stat == NULL here.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

I agree. If sta were NULL, we would never have reached this statement. There is, 
however, a typo in the last line of the commit message. Once this is fixed, you 
may add the line "Acked-by: Larry Finger <Larry.Finger@lwfinger.net>"

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
> index 41f77f8..7aee5ebb1 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/core.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/core.c
> @@ -1135,7 +1135,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
>  					mac->mode = WIRELESS_MODE_AC_24G;
>  			}
>
> -			if (vif->type == NL80211_IFTYPE_STATION && sta)
> +			if (vif->type == NL80211_IFTYPE_STATION)
>  				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
>  			rcu_read_unlock();
>
>
