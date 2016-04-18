From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2] carl9170: Clarify kconfig text
Date: Mon, 18 Apr 2016 18:45:09 +0300
Message-ID: <87shyiyl8a.fsf@purkki.adurom.net>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
	<1466768.7dLuLFSDol@debian64>
	<20160416171856.1769c0e16bcc75372407e06f@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lauri Kasanen <cand-KK0ffGbhmjU@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160416171856.1769c0e16bcc75372407e06f-KK0ffGbhmjU@public.gmane.org> (Lauri
	Kasanen's message of "Sat, 16 Apr 2016 17:18:56 +0300")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Lauri Kasanen <cand-KK0ffGbhmjU@public.gmane.org> writes:

> The previous text was confusing, leading readers to think this
> driver was a duplicate, and so didn't need to be enabled.
>
> After the removal of the older staging driver, this is the only
> driver in mainline for these devices.
>
> Signed-off-by: Lauri Kasanen <cand-KK0ffGbhmjU@public.gmane.org>
> ---
> v2: Remove the mention of the previous driver, suggested by Christian.
>
>  drivers/net/wireless/ath/carl9170/Kconfig | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/carl9170/Kconfig b/drivers/net/wireless/ath/carl9170/Kconfig
> index 1a796e5..2e34bae 100644
> --- a/drivers/net/wireless/ath/carl9170/Kconfig
> +++ b/drivers/net/wireless/ath/carl9170/Kconfig
> @@ -5,12 +5,10 @@ config CARL9170
>  	select FW_LOADER
>  	select CRC32
>  	help
> -	  This is another driver for the Atheros "otus" 802.11n USB devices.
> +	  This is the mainline driver for the Atheros "otus" 802.11n USB devices.
>  
> -	  This driver provides more features than the original,
> -	  but it needs a special firmware (carl9170-1.fw) to do that.
> -
> -	  The firmware can be downloaded from our wiki here:
> +	  It needs a special firmware (carl9170-1.fw), which can be downloaded
> +	  from our wiki here:
>  	  <http://wireless.kernel.org/en/users/Drivers/carl9170>

Why even mention anything about a "special firmware" as the firmware is
already available from linux-firmware.git? That's default location for
all firmware images and I think most, if not all, distros should have it
available. So wouldn't it be better not to mention anything about
firmware at all?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
