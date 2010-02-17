From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/7] net: remove old tcp_optlen function
Date: Wed, 17 Feb 2010 15:43:32 -0800 (PST)
Message-ID: <20100217.154332.137835825.davem@davemloft.net>
References: <4B7791CF.9030201@gmail.com>
	<4B7793A7.1010500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, mchan@broadcom.com
To: william.allen.simpson@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7793A7.1010500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sun, 14 Feb 2010 01:09:43 -0500

> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 65df1de..45452c5 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6352,6 +6352,8 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
>  /* Called with netif_tx_lock.
>   * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
>   * netif_wake_queue().
> + *
> + * No TCP or IP length checking, per David Miller (see commit log).
>   */

This is not appropriate, please do not do this.

We do not refer to commit log messages from the source code.  Many
people have the sources via some other means (tarball, distribution
source package, etc.) and won't have any idea where to get this
information.

Also, you don't need to single me out personally.  This is an
implication of the structure of the code that I've merely explained to
you, it's not some rule I've personally decided upon.

Thanks.
