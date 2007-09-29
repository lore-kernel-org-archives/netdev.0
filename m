From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc91x Hitachi Solution Engine (SuperH) Support
Date: Sat, 29 Sep 2007 01:29:25 -0400
Message-ID: <46FDE2B5.8050803@garzik.org>
References: <20070919210752.5b211317.iwamatsu@nigauri.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@cam.org,
	Paul Mundt <lethal@linux-sh.org>
To: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47956 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbXI2F32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:29:28 -0400
In-Reply-To: <20070919210752.5b211317.iwamatsu@nigauri.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nobuhiro Iwamatsu wrote:
> Hi, all.
> 
> This patch supports Hitachi Solution Engine (SuperH) of smc91x. 
> Please apply this patch .

> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 6ff3a16..af9e6bf 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -284,6 +284,7 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  #elif   defined(CONFIG_SUPERH)
>  
>  #ifdef CONFIG_SOLUTION_ENGINE
> +#define SMC_IRQ_FLAGS		(0)
>  #define SMC_CAN_USE_8BIT       0
>  #define SMC_CAN_USE_16BIT      1
>  #define SMC_CAN_USE_32BIT      0


Does the SuperH maintainer ACK this?

