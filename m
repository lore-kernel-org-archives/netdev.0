From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: fix spelling mistake: "contry" -> "country"
Date: Thu, 29 Dec 2016 14:58:34 -0600
Message-ID: <c2eb46b3-5f4c-bbe6-0adb-b78ca50cfb4c@lwfinger.net>
References: <20161229160029.22117-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161229160029.22117-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/29/2016 10:00 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> trivial fix to spelling mistake in RT_TRACE message
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry

> ---
>  drivers/net/wireless/realtek/rtlwifi/regd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/regd.c b/drivers/net/wireless/realtek/rtlwifi/regd.c
> index 6ee6bf8..558c31b 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/regd.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/regd.c
> @@ -440,7 +440,7 @@ int rtl_regd_init(struct ieee80211_hw *hw,
>
>  	if (rtlpriv->regd.country_code >= COUNTRY_CODE_MAX) {
>  		RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
> -			 "rtl: EEPROM indicates invalid contry code, world wide 13 should be used\n");
> +			 "rtl: EEPROM indicates invalid country code, world wide 13 should be used\n");
>
>  		rtlpriv->regd.country_code = COUNTRY_CODE_WORLD_WIDE_13;
>  	}
>
