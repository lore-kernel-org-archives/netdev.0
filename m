From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi/rtl8192de: remove redundant else if check
Date: Tue, 13 Jan 2015 11:19:38 -0600
Message-ID: <54B553AA.50505@lwfinger.net>
References: <1421158054-22566-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:59085 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbbAMRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:19:41 -0500
In-Reply-To: <1421158054-22566-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 08:07 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The else if check condition checks for the opposite of the
> if check, hence the else if check is redundant and can be
> replaced with a simple else:
>
> if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
> 	..
> } else if (rtlpriv->rtlhal.macphymode != SINGLEMAC_SINGLEPHY) {
> 	..
> }
>
> replaced with:
>
> if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
> 	..
> } else {
> 	..
> }
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

> ---
>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> index 280c3da..01bcc2d 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> @@ -546,7 +546,7 @@ static bool _rtl92de_llt_table_init(struct ieee80211_hw *hw)
>   		txpktbuf_bndy = 246;
>   		value8 = 0;
>   		value32 = 0x80bf0d29;
> -	} else if (rtlpriv->rtlhal.macphymode != SINGLEMAC_SINGLEPHY) {
> +	} else {
>   		maxPage = 127;
>   		txpktbuf_bndy = 123;
>   		value8 = 0;
>
