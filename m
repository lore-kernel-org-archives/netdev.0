From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 3/3] [RFC] ARM: shmobile: genmai: Enable r7s72100-gether
Date: Sun, 15 Dec 2013 23:31:35 +0300
Message-ID: <52AE11A7.6090407@cogentembedded.com>
References: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au> <1387095886-15163-4-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1387095886-15163-4-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/15/2013 11:24 AM, Simon Horman wrote:

    You forgot to sign off.

[...]

> diff --git a/arch/arm/mach-shmobile/board-genmai.c b/arch/arm/mach-shmobile/board-genmai.c
> index 3e92e3c..838325b 100644
> --- a/arch/arm/mach-shmobile/board-genmai.c
> +++ b/arch/arm/mach-shmobile/board-genmai.c
> @@ -20,15 +20,35 @@
>
>   #include <linux/kernel.h>
>   #include <linux/platform_device.h>
> +#include <linux/sh_eth.h>
>   #include <mach/common.h>
> +#include <mach/irqs.h>
>   #include <mach/r7s72100.h>
>   #include <asm/mach-types.h>
>   #include <asm/mach/arch.h>
>
> +/* GEther */
> +static const struct sh_eth_plat_data gether_pdata __initconst = {
> +	.phy			= 0x00, /* PD60610 */
> +	.edmac_endian		= EDMAC_LITTLE_ENDIAN,
> +	.phy_interface		= PHY_INTERFACE_MODE_MII,

    Does MII work for Gigabit Ethernet?

WBR, Sergei

