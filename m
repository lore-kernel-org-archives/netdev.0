From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net 1/8] net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
Date: Fri, 03 Oct 2014 22:39:12 +0400
Message-ID: <542EED50.9040309@cogentembedded.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com> <1412352169-14414-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42186 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaJCSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 14:39:17 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so1523564lbi.9
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 11:39:15 -0700 (PDT)
In-Reply-To: <1412352169-14414-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/03/2014 08:02 PM, Claudiu Manoil wrote:

> The UCC specific code included in fsl_pq_mdio.c (with
> function calls from asm/ucc.h) is already guarded
> by these config options, so this ARM build fix provides
> consistency with the rest UCC specific code.

> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>   drivers/net/ethernet/freescale/fsl_pq_mdio.c | 2 ++
>   1 file changed, 2 insertions(+)

> diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> index 583e71a..89b3fea 100644
> --- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> +++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> @@ -28,7 +28,9 @@
>   #include <linux/of_device.h>
>
>   #include <asm/io.h>
> +#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)

    Use IS_ENABLED(CONFIG_UCC_GETH) instead.

WBR, Sergei
