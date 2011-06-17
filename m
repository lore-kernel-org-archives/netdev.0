From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next V2] drivers/net: Remove casts of void *
Date: Fri, 17 Jun 2011 10:14:12 -0400
Message-ID: <1308320052.2198.1.camel@obelisk.thedillows.org>
References: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-06-16 at 22:08 -0700, Joe Perches wrote:
> Unnecessary casts of void * clutter the code.
> 
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.

> diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
> index 3de4283..1d5091a 100644
> --- a/drivers/net/typhoon.c
> +++ b/drivers/net/typhoon.c
> @@ -2367,7 +2367,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	dev->irq = pdev->irq;
>  	tp = netdev_priv(dev);
> -	tp->shared = (struct typhoon_shared *) shared;
> +	tp->shared = shared;
>  	tp->shared_dma = shared_dma;
>  	tp->pdev = pdev;
>  	tp->tx_pdev = pdev;

Acked-by: David Dillow <dave@thedillows.org>
