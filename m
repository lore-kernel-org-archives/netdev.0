From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 03/18] netdevice: safe convert to netdev_priv() #part-3
Date: Fri, 05 Sep 2008 09:58:14 -0400
Message-ID: <1220623094.7854.75.camel@obelisk.thedillows.org>
References: <48C0A219.2030004@cn.fujitsu.com>
	 <48C0A34E.4030905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:59206 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262AbYIEN6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 09:58:18 -0400
In-Reply-To: <48C0A34E.4030905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-05 at 11:11 +0800, Wang Chen wrote:
> diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
> index 734ce09..44a85be 100644
> --- a/drivers/net/typhoon.c
> +++ b/drivers/net/typhoon.c
> @@ -1798,7 +1798,7 @@ static irqreturn_t
>  typhoon_interrupt(int irq, void *dev_instance)
>  {
>         struct net_device *dev = dev_instance;
> -       struct typhoon *tp = dev->priv;
> +       struct typhoon *tp = netdev_priv(dev);
>         void __iomem *ioaddr = tp->ioaddr;
>         u32 intr_status;

For what it's worth
Acked-by: Dave Dillow <dave@thedillows.org>

Thanks for the diffstats on the broken up patches -- I missed this patch
to typhoon last time around. It was easy to find this time.

