From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] SMC91x: delete unused local variable "lp"
Date: Tue, 04 Nov 2008 01:45:11 +0900 (JST)
Message-ID: <20081104.014511.108120668.anemo@mba.ocn.ne.jp>
References: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:52274 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876AbYKCQpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:45:08 -0500
In-Reply-To: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 09:56:06 -0400, Mike Frysinger <vapier@gentoo.org> wrote:
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  drivers/net/smc91x.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index c70870e..6f9895d 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -2060,7 +2060,6 @@ static int smc_request_attrib(struct platform_device *pdev,
>  			      struct net_device *ndev)
>  {
>  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> -	struct smc_local *lp = netdev_priv(ndev);
>  
>  	if (!res)
>  		return 0;

The local variable 'lp' is actually used on some platforms (via
SMC_IO_SHIFT).

Please revert this change and do another way ("unused" marker or
something) to fix the warnings.

---
Atsushi Nemoto
