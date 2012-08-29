From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Wed, 29 Aug 2012 14:53:41 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
 <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38516 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab2H2Mxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 08:53:42 -0400
In-Reply-To: <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012, Or Gerlitz wrote:

> new file mode 100644
> index 0000000..18d6ac9
> --- /dev/null
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
> ...
> +
> +enum {
> +	IFLA_IPOIB_UNSPEC,
> +	IFLA_IPOIB_CHILD_PKEY,
> +	__IFLA_IPOIB_MAX
> +};
> +
> +#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)

This should go into include/linux/if_link.h
