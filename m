From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/3] rtlwifi: make MSI support a module parameter
Date: Mon, 05 May 2014 09:56:16 -0500
Message-ID: <5367A690.7010305@lwfinger.net>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: Adam Lee <adam.lee@canonical.com>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:57296 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbaEEO4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 10:56:19 -0400
In-Reply-To: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/2014 03:33 AM, Adam Lee wrote:
> This makes MSI support a module parameter, for debugging and workaround
> convenience.
>
> Signed-off-by: Adam Lee <adam.lee@canonical.com>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net> (for all 3 patches)

I would have made the default for the MSI option to be true, but that is a 
matter of preference, and only experience would show which default leads to the 
fewer failures. On my laptop, both rtl8188ee and rtl8723be work either way. I am 
now working on a driver for the RTL8192EE that also can use MSI - that has only 
been tested with the option on.

Larry

> ---
>   drivers/net/wireless/rtlwifi/wifi.h | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
> index 6965afd..eef93d1 100644
> --- a/drivers/net/wireless/rtlwifi/wifi.h
> +++ b/drivers/net/wireless/rtlwifi/wifi.h
> @@ -2030,6 +2030,10 @@ struct rtl_mod_params {
>
>   	/* default: 1 = using linked fw power save */
>   	bool fwctrl_lps;
> +
> +	/* default: 0 = not using MSI interrupts mode */
> +	/* submodules should set their own defalut value */
> +	bool msi_support;
>   };
>
>   struct rtl_hal_usbint_cfg {
>
