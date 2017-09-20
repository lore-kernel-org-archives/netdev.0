From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: aquantia: default to no in config
Date: Wed, 20 Sep 2017 13:28:25 +0300
Message-ID: <aee8c2bd-5a2a-cb51-adb5-9106b2b7a787@cogentembedded.com>
References: <20170919224315.GA17797@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vito Caputo <vcaputo@pengaru.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919224315.GA17797@shells.gnugeneration.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 9/20/2017 1:43 AM, Vito Caputo wrote:

> NET_VENDOR_AQUANTIA was "default y" for some reason, which seems
> obviously inappropriate.
> ---
>   drivers/net/ethernet/aquantia/Kconfig | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/Kconfig b/drivers/net/ethernet/aquantia/Kconfig
> index cdf78e069a39..6167b13cf349 100644
> --- a/drivers/net/ethernet/aquantia/Kconfig
> +++ b/drivers/net/ethernet/aquantia/Kconfig
> @@ -4,7 +4,7 @@
>   
>   config NET_VENDOR_AQUANTIA
>   	bool "aQuantia devices"
> -	default y
> +	default n

    Just remove it -- 'n' is the default default. :-)

[...]

MBR, Sergei
