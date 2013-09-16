From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/8 V2] [PATCH 5/7: rtlwifi: Fix smatch warning in pci.c
Date: Mon, 16 Sep 2013 23:04:13 +0400
Message-ID: <5237562D.4080509@cogentembedded.com>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net> <1379357722-17687-6-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379357722-17687-6-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/16/2013 10:55 PM, Larry Finger wrote:

> Smatch reports the following:
>    CHECK   drivers/net/wireless/rtlwifi/pci.c
> drivers/net/wireless/rtlwifi/pci.c:739 _rtl_pci_rx_interrupt() warn: assigning (-98) to unsigned variable 'stats.noise'

> This variable is not used and is removed.

    It is not a variable but a structure field initializer you're removing.

> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/pci.c | 1 -
>   1 file changed, 1 deletion(-)

> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> index 703f839..6295ed2 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -736,7 +736,6 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
>
>   	struct rtl_stats stats = {
>   		.signal = 0,
> -		.noise = -98,
>   		.rate = 0,
>   	};

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
