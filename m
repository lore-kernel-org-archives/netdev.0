From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: ks8995: Fix bug while selecting sysfs node size
Date: Thu, 9 Mar 2017 16:10:34 -0800
Message-ID: <b90f6157-b8d1-a49f-dbba-8bcc301229cb@gmail.com>
References: <1489047937-11798-1-git-send-email-urusov@granch.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Lev Urusov <urusov@granch.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36371 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdCJAKj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 19:10:39 -0500
Received: by mail-wm0-f65.google.com with SMTP id v190so13324978wme.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 16:10:38 -0800 (PST)
In-Reply-To: <1489047937-11798-1-git-send-email-urusov@granch.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 12:25 AM, Lev Urusov wrote:
> From: Lev Urusov <urusov@granch.ru>
> 
> The driver will not be able to take into account the correct number
> of device SPI registers if it is not equal to 128.
> 
> Signed-off-by: Lev Urusov <urusov@granch.ru>

Well, seems like someone already fixed that:

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=239870f2a0ebf75cc8f6d987dc528c5243f93d69

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
