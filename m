From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] smsc: Enabling SMSC LAN911 driver for ARM64 as well.
Date: Mon, 11 Jan 2016 17:10:15 +0300
Message-ID: <5693B7C7.8040202@cogentembedded.com>
References: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pankaj.m@samsung.com
To: Manjeet Pawar <manjeet.p@samsung.com>, davem@davemloft.net,
	paul.gortmaker@windriver.com, schmitzmic@gmail.com,
	geert@linux-m68k.org, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akhilesh.k@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/11/2016 12:02 PM, Manjeet Pawar wrote:

> This patch enable network driver support for ARM64
>
> Signed-off-by: Akhilesh Kumar <akhilesh.k@samsung.com>
> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
> ---
>   drivers/net/ethernet/smsc/Kconfig |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
> index eb9230e..6e73c73 100644
> --- a/drivers/net/ethernet/smsc/Kconfig
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -77,7 +77,7 @@ config SMC911X
>   	tristate "SMSC LAN911[5678] support"
>   	select CRC32
>   	select MII
> -	depends on (ARM || SUPERH || MN10300)
> +	depends on (ARM || ARM64 || SUPERH || MN10300)

    Could as well drop useless parens...

[...]

MBR, Sergei
