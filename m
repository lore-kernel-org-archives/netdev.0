From: Jeff Garzik <jeff@garzik.org>
Subject: Re: macmace: use "unsigned long flags;"
Date: Tue, 10 Jul 2007 12:42:40 -0400
Message-ID: <4693B700.8050302@garzik.org>
References: <20070706145713.GC11067@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fthain@telegraphics.com.au
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60195 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755928AbXGJQmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:42:45 -0400
In-Reply-To: <20070706145713.GC11067@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Code will do local_irq_save() on it.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> ---
> 
>  drivers/net/macmace.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/macmace.c
> +++ b/drivers/net/macmace.c
> @@ -577,7 +577,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
>  	struct mace_data *mp = netdev_priv(dev);
>  	volatile struct mace *mb = mp->mace;
>  	int intr, fs;
> -	unsigned int flags;
> +	unsigned long flags;

applied


