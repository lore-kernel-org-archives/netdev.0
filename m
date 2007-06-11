From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 14:54:40 -0700
Message-ID: <1181598880.6020.8.camel@localhost>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, shemminger@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4221 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755587AbXFKVyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 17:54:50 -0400
In-Reply-To: <20070611213721.23014.4812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-11 at 14:37 -0700, Auke Kok wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3a70f55..d185f41 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -540,6 +540,8 @@ struct net_device
>  	struct device		dev;
>  	/* space for optional statistics and wireless sysfs groups */
>  	struct attribute_group  *sysfs_groups[3];
> +
> +	int			msg_enable;
>  };
>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>  

msg_enable is more frequently defined in drivers/net as u32 not int.

egrep -r -w --include=*.[ch] "u32[[:space:]]+msg_enable" drivers/net | wc -l
egrep -r -w --include=*.[ch] "int[[:space:]]+msg_enable" drivers/net | wc -l

29 to 5

cheers, Joe

