From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] carl9170: Clarify kconfig text
Date: Sat, 16 Apr 2016 17:32:52 +0200
Message-ID: <1577999.zXsTfgyz3l@debian64>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com> <1466768.7dLuLFSDol@debian64> <20160416171856.1769c0e16bcc75372407e06f@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lauri Kasanen <cand@gmx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160416171856.1769c0e16bcc75372407e06f@gmx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, April 16, 2016 05:18:56 PM Lauri Kasanen wrote:
> The previous text was confusing, leading readers to think this
> driver was a duplicate, and so didn't need to be enabled.
> 
> After the removal of the older staging driver, this is the only
> driver in mainline for these devices.
> 
> Signed-off-by: Lauri Kasanen <cand@gmx.com>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>

> ---
> v2: Remove the mention of the previous driver, suggested by Christian.

Thanks!
 
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
>  
>  	  If you choose to build a module, it'll be called carl9170.
> 
