From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] mlx5: Add ndo_poll_controller()
 implementation
Date: Fri, 30 Sep 2016 02:11:43 -0400 (EDT)
Message-ID: <20160930.021143.1313342833238196185.davem@davemloft.net>
References: <20160928.045409.1002159444377863778.davem@davemloft.net>
        <f7bb6739eabb508d5393a26a542797563d386b17.1475123641.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-team@fb.com
To: calvinowens@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935528AbcI3GLs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 02:11:48 -0400
In-Reply-To: <f7bb6739eabb508d5393a26a542797563d386b17.1475123641.git.calvinowens@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Calvin Owens <calvinowens@fb.com>
Date: Wed, 28 Sep 2016 21:46:39 -0700

> This implements ndo_poll_controller in net_device_ops callbacks for mlx5,
> which is necessary to use netconsole with this driver.
> 
> Acked-By: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>
> ---
> Changes in v2:
> 	* Only iterate channels to avoid redundant napi_schedule() calls

Applied, thanks.
