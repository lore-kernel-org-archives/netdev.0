From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Sun, 30 May 2010 13:35:51 -0400
Message-ID: <4C02A1F7.6030701@garzik.org>
References: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45849 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740Ab0E3Rf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 13:35:58 -0400
Received: by gwaa12 with SMTP id a12so2170593gwa.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 10:35:56 -0700 (PDT)
In-Reply-To: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2010 08:22 AM, Junchang Wang wrote:
> ioread32() returns a 32-bit integer on all platforms.
> There is no need to cast its return value.
>
> Signed-off-by: Junchang Wang<junchangwang@gmail.com>
> ---
>   drivers/net/8139too.c |    8 ++++----
>   1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index 4ba7293..cc7d462 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -662,7 +662,7 @@ static const struct ethtool_ops rtl8139_ethtool_ops;
>   /* read MMIO register */
>   #define RTL_R8(reg)		ioread8 (ioaddr + (reg))
>   #define RTL_R16(reg)		ioread16 (ioaddr + (reg))
> -#define RTL_R32(reg)		((unsigned long) ioread32 (ioaddr + (reg)))
> +#define RTL_R32(reg)		ioread32 (ioaddr + (reg))

Have you verified this matches all architectures definition of readl()?

	Jeff



