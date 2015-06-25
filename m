From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/4] mlx4 driver fixes, June 24, 2015
Date: Thu, 25 Jun 2015 02:09:03 -0700 (PDT)
Message-ID: <20150625.020903.224478685991864150.davem@davemloft.net>
References: <1435220984-16295-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbbFYI5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 04:57:12 -0400
In-Reply-To: <1435220984-16295-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 25 Jun 2015 11:29:40 +0300

> Some fixes that we made recently, all need to go into stable.
> 
> patch #1 "net/mlx4_en: Release TX QP when destroying TX ring" and patch #3 
> "Fix wrong csum complete report when rxvlan offload is disabled" to >= 3.19
> 
> patch #2 "Wake TX queues only when there's enough room" addressing a bug 
> which is there from day one... should go to whatever kernels it's still applicable
> 
> patch #4 "mlx4: Disable HA for SRIOV PF RoCE devices" to >= 4.0
> 
> The patches are marked with net but are made against net-next,
> as the net tree still doesn't contain all the net-next bits.

Series applied, thanks.
