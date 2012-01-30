From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1] wireless: in _rtl92c_phy_calculate_bit_shift remove
 comparing bitmask against 1
Date: Mon, 30 Jan 2012 17:36:50 -0600
Message-ID: <4F272992.9000502@lwfinger.net>
References: <1327917655-6494-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	paul.gortmaker@windriver.com, joe@perches.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Devendra.Naga" <devendra.aaru@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327917655-6494-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 04:00 AM, Devendra.Naga wrote:
> From: "Devendra.Naga"<devendra.aaru@gmail.com>
>
> in _rtl92c_phy_calculate_bit_shift everytime the right shifted bitmask
> is AND with 1 and compared against 1. i.e.
>          if ((bitmask>>  i)&  0x1 == 1)
>                  break;
> which in the if condition is anyway becomes a 1 or 0.
>
> Signed-off-by: Devendra.Naga<devendra.aaru@gmail.com>

Once again, the patch is OK, but the subject is not good.

Larry

> ---
>   drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> index 22e998d..a76b223 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> @@ -177,7 +177,7 @@ u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask)
>   	u32 i;
>
>   	for (i = 0; i<= 31; i++) {
> -		if (((bitmask>>  i)&  0x1) == 1)
> +		if ((bitmask>>  i)&  0x1)
>   			break;
>   	}
>   	return i;
