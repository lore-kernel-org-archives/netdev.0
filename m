From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/7 v3] au1000-eth: fix bad printk usages
Date: Wed, 08 Sep 2010 14:24:51 -0700
Message-ID: <1283981091.2479.51.camel@Joe-Laptop>
References: <201009082311.45685.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1532 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542Ab0IHVYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 17:24:53 -0400
In-Reply-To: <201009082311.45685.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-08 at 23:11 +0200, Florian Fainelli wrote:
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> @@ -1199,7 +1203,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
>  	netdev_info(dev, "Au1xx0 Ethernet found at 0x%lx, irq %d\n",
>  			(unsigned long)base->start, irq);
>  	if (version_printed++ == 0)
> -		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
> +		pr_info("%s version %s %s\n",
> +					DRV_NAME, DRV_VERSION, DRV_AUTHOR);

You could also remove version_printed and use
printk_once(KERN_INFO etc...)


