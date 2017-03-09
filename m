From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Fix bug while selecting sysfs node size
Date: Wed, 8 Mar 2017 17:50:25 -0800
Message-ID: <c6c3f9dd-2d17-95c2-a857-82e3164e2243@gmail.com>
References: <1489023829-2545-1-git-send-email-urusov@granch.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Lev Urusov <urusov@granch.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35150 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754559AbdCIBu3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 20:50:29 -0500
Received: by mail-io0-f196.google.com with SMTP id f103so2649774ioi.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 17:50:28 -0800 (PST)
In-Reply-To: <1489023829-2545-1-git-send-email-urusov@granch.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2017 05:43 PM, Lev Urusov wrote:
> From: Lev Urusov <urusov@granch.ru>
> 
> The driver will not be able to take into account the correct number
> of device SPI registers if it is not equal to 128.

You would want to fix a couple of things with this patchset, since you
are fixing a bug, can you provide the proper Fixes: tag information that
indicates which commit you are fixing (so it can be backported to stable
kernels), and the subject should be something like:

net: phy: ks8995: Fix bug while selecting sysfs node size

Thanks!

> 
> Signed-off-by: Lev Urusov <urusov@granch.ru>
> ---
>  drivers/net/phy/spi_ks8995.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
> index 93ffedf..f084725 100644
> --- a/drivers/net/phy/spi_ks8995.c
> +++ b/drivers/net/phy/spi_ks8995.c
> @@ -491,8 +491,8 @@ static int ks8995_probe(struct spi_device *spi)
>  	if (err)
>  		return err;
>  
> -	ks->regs_attr.size = ks->chip->regs_size;
>  	memcpy(&ks->regs_attr, &ks8995_registers_attr, sizeof(ks->regs_attr));
> +	ks->regs_attr.size = ks->chip->regs_size;
>  
>  	err = ks8995_reset(ks);
>  	if (err)
> 


-- 
Florian
