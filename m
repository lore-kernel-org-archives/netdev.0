From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] rtlwifi: Use is_zero_ether_addr, remove line continuation
Date: Sat, 17 Mar 2012 16:14:53 -0500
Message-ID: <4F64FECD.9000802@lwfinger.net>
References: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/17/2012 02:13 PM, Joe Perches wrote:
> Use the normal kernel facilities and use %pM
> to print the all zero mac address.
>
> Remove unnecessary line continuation.
>
> Signed-off-by: Joe Perches<joe@perches.com>
> ---
>   drivers/net/wireless/rtlwifi/cam.c |    5 ++---
>   1 files changed, 2 insertions(+), 3 deletions(-)

ACKed-by: Larry.Finger@lwfinger.net

Is there a PATCH 2/2? I did not receive it.

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
> index 5c7d579..3d8cc4a 100644
> --- a/drivers/net/wireless/rtlwifi/cam.c
> +++ b/drivers/net/wireless/rtlwifi/cam.c
> @@ -328,10 +328,9 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
>   		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
>   	}
>
> -	if ((sta_addr[0]|sta_addr[1]|sta_addr[2]|sta_addr[3]|\
> -				sta_addr[4]|sta_addr[5]) == 0) {
> +	if (is_zero_ether_addr(sta_addr)) {
>   		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
> -			 "sta_addr is 00:00:00:00:00:00\n");
> +			 "sta_addr is %pM\n", sta_addr);
>   		return;
>   	}
>   	/* Does STA already exist? */
