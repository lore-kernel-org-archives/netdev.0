From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: remove return in _rtl_pci_switch_clk_req
Date: Tue, 31 Jan 2012 09:52:23 -0600
Message-ID: <4F280E37.8030803@lwfinger.net>
References: <1327991295-6258-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Devendra.Naga" <devendra.aaru@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327991295-6258-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2012 12:28 AM, Devendra.Naga wrote:
> From: "Devendra.Naga"<devendra.aaru@gmail.com>
>
> the return value from _rtl_pci_switch_clk_req is not used by any of its callers.
>
> Signed-off-by: Devendra.Naga<devendra.aaru@gmail.com>
> ---
>   drivers/net/wireless/rtlwifi/pci.c |    4 +---
>   1 files changed, 1 insertions(+), 3 deletions(-)

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> index 5cb2199..9a01909 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -198,7 +198,7 @@ static bool _rtl_pci_platform_switch_device_pci_aspm(
>   }
>
>   /*When we set 0x01 to enable clk request. Set 0x0 to disable clk req.*/
> -static bool _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
> +static void _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
>   {
>   	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>   	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
> @@ -207,8 +207,6 @@ static bool _rtl_pci_switch_clk_req(struct ieee80211_hw *hw, u8 value)
>
>   	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192SE)
>   		udelay(100);
> -
> -	return true;
>   }
>
>   /*Disable RTL8192SE ASPM&  Disable Pci Bridge ASPM*/
