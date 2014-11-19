From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Add VXLAN ndo calls to the PF net
 device ops too
Date: Wed, 19 Nov 2014 15:11:55 -0500 (EST)
Message-ID: <20141119.151155.2119587385505880097.davem@davemloft.net>
References: <1416325887-14704-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, amirv@mellanox.com,
	saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbaKSUL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:11:58 -0500
In-Reply-To: <1416325887-14704-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 18 Nov 2014 17:51:27 +0200

> This is currently missing, which results in a crash when one attempts
> to set VXLAN tunnel over the mlx4_en when acting as PF.
> 
> 	[ 2408.785472] BUG: unable to handle kernel NULL pointer dereference at (null)
> 	[...]
> 	[ 2408.994104] Call Trace:
> 	[ 2408.996584]  [<ffffffffa021f7f5>] ? vxlan_get_rx_port+0xd6/0x103 [vxlan]
> 	[ 2409.003316]  [<ffffffffa021f71f>] ? vxlan_lowerdev_event+0xf2/0xf2 [vxlan]
> 	[ 2409.010225]  [<ffffffffa0630358>] mlx4_en_start_port+0x862/0x96a [mlx4_en]
> 	[ 2409.017132]  [<ffffffffa063070f>] mlx4_en_open+0x17f/0x1b8 [mlx4_en]
> 
> While here, make sure to invoke vxlan_get_rx_port() only when VXLAN
> offloads are actually enabled and not when they are only supported.
> 
> Reported-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, -stable material?  If so for what releases?

In the future, if you add an appropriated Fixes: tag I can figure most
of this out without asking you.

Thanks.
