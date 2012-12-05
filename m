From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH -next v2] ipw2200: return error code on error in ipw_wx_get_auth()
Date: Wed, 5 Dec 2012 01:44:50 -0800
Message-ID: <CA++WF2OmLMP3NHvN44yVzsnWEHjeZVGfgG9CfC2CkZGyNQFLLw@mail.gmail.com>
References: <CAPgLHd_AN+Tr5EQFBZMH0FZCp6ESHVURZHvd9SuW=a2PYkPoXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46372 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab2LEJow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 04:44:52 -0500
In-Reply-To: <CAPgLHd_AN+Tr5EQFBZMH0FZCp6ESHVURZHvd9SuW=a2PYkPoXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 December 2012 00:08, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> We have assinged error code to 'ret' when get auth from some
> option is not supported but never used it, but we'd better return
> the error code.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Looks fine, thanks.

Stanislav.

> ---
>  drivers/net/wireless/ipw2x00/ipw2200.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
> index 482f505..b0879ad 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2200.c
> @@ -6812,7 +6812,6 @@ static int ipw_wx_get_auth(struct net_device *dev,
>         struct libipw_device *ieee = priv->ieee;
>         struct lib80211_crypt_data *crypt;
>         struct iw_param *param = &wrqu->param;
> -       int ret = 0;
>
>         switch (param->flags & IW_AUTH_INDEX) {
>         case IW_AUTH_WPA_VERSION:
> @@ -6822,8 +6821,7 @@ static int ipw_wx_get_auth(struct net_device *dev,
>                 /*
>                  * wpa_supplicant will control these internally
>                  */
> -               ret = -EOPNOTSUPP;
> -               break;
> +               return -EOPNOTSUPP;
>
>         case IW_AUTH_TKIP_COUNTERMEASURES:
>                 crypt = priv->ieee->crypt_info.crypt[priv->ieee->crypt_info.tx_keyidx];
>
>
