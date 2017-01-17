From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [net, 6/6] net: korina: version bump
Date: Tue, 17 Jan 2017 19:55:58 +0100
Message-ID: <e607e3a1-8227-7768-2234-6a3340f4a368@nbd.name>
References: <1484674393-22515-1-git-send-email-roman@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Roman Yeryomin <leroi.lists@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:56118 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdAQS5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 13:57:25 -0500
In-Reply-To: <1484674393-22515-1-git-send-email-roman@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-17 18:33, Roman Yeryomin wrote:
> Signed-off-by: Roman Yeryomin <roman@advem.lv>
> ---
>  drivers/net/ethernet/korina.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
> index 83c994f..c8fed01 100644
> --- a/drivers/net/ethernet/korina.c
> +++ b/drivers/net/ethernet/korina.c
> @@ -66,8 +66,8 @@
>  #include <asm/mach-rc32434/dma_v.h>
>  
>  #define DRV_NAME	"korina"
> -#define DRV_VERSION	"0.10"
> -#define DRV_RELDATE	"04Mar2008"
> +#define DRV_VERSION	"0.20"
> +#define DRV_RELDATE	"15Jan2017"
I think it would make more sense to remove this version instead of
bumping it. Individual driver versions are rather pointless, the kernel
version is more meaningful anyway.

- Felix
