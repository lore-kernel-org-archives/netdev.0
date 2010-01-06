From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] Fix spelling in log messages
Date: Thu, 7 Jan 2010 00:59:42 +0100 (CET)
Message-ID: <alpine.LRH.2.00.1001070059230.15694@twin.jikos.cz>
References: <1262819137-16775-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Dave Young <hidave.darkstar@gmail.com>,
	Matthew Garrett <mjg@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stefan Weil <weil@mail.berlios.de>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1262819137-16775-1-git-send-email-weil@mail.berlios.de>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jan 2010, Stefan Weil wrote:

> Replace platfrom -> platform.
> 
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>
> ---
>  drivers/input/serio/i8042.c |    2 +-
>  drivers/net/davinci_emac.c  |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/input/serio/i8042.c b/drivers/input/serio/i8042.c
> index d84a36e..33f3541 100644
> --- a/drivers/input/serio/i8042.c
> +++ b/drivers/input/serio/i8042.c
> @@ -430,7 +430,7 @@ static bool i8042_filter(unsigned char data, unsigned char str,
>  	}
>  
>  	if (i8042_platform_filter && i8042_platform_filter(data, str, serio)) {
> -		dbg("Filtered out by platfrom filter\n");
> +		dbg("Filtered out by platform filter\n");
>  		return true;
>  	}
>  
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 107bc5f..4741ade 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -2652,7 +2652,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>  
>  	pdata = pdev->dev.platform_data;
>  	if (!pdata) {
> -		printk(KERN_ERR "DaVinci EMAC: No platfrom data\n");
> +		printk(KERN_ERR "DaVinci EMAC: No platform data\n");
>  		return -ENODEV;
>  	}

This is now in trivial queue.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

