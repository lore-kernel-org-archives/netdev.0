From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192se: Fix wrong assignment
Date: Fri, 18 Oct 2013 20:35:58 -0500
Message-ID: <5261E1FE.2030304@lwfinger.net>
References: <1382143960-4594-1-git-send-email-felipensp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Felipe Pena <felipensp@gmail.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382143960-4594-1-git-send-email-felipensp@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18/2013 07:52 PM, Felipe Pena wrote:
> There is a typo in the struct member name on assignment when checking
> rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40, the check uses pwrgroup_ht40
> for bound limit and uses pwrgroup_ht20 when assigning instead.
>
> Signed-off-by: Felipe Pena <felipensp@gmail.com>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192se/rf.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
> index 5061f1d..92d38ab 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
> @@ -265,7 +265,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
>   				    rtlefuse->pwrgroup_ht40
>   				    [RF90_PATH_A][chnl - 1]) {
>   					pwrdiff_limit[i] =
> -					  rtlefuse->pwrgroup_ht20
> +					  rtlefuse->pwrgroup_ht40
>   					  [RF90_PATH_A][chnl - 1];
>   				}
>   			} else {
> --

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

John: I forgot to mention this earlier, but when you add your s-o-b, please add 
a Cc for Stable [3.0 +].

Thanks,

Larry
