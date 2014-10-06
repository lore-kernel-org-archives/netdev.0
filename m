From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] net/mlx4_en: Optimizations to TX flow
Date: Mon, 06 Oct 2014 01:04:43 -0400 (EDT)
Message-ID: <20141006.010443.1949137356747020714.davem@davemloft.net>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, idos@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaJFFEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 01:04:45 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  5 Oct 2014 12:35:08 +0300

> This patchset contains optimizations to TX flow in mlx4_en driver. It also introduce
> setting/getting tx copybreak, to enable controlling inline threshold dynamically.
> 
> TX flow optimizations was authored and posted to the mailing list by Eric
> Dumazet [1] as a single patch. I splitted this patch to smaller patches,
> Reviewed it and tested.
> Changed from original patch:
> - s/iowrite32be/iowrite32/, since ring->doorbell_qpn is stored as be32
> 
> The tx copybreak patch was also suggested by Eric Dumazet, and was edited and
> reviewed by me. User space patch will be sent after kernel code is ready.
> 
> I am sending this patchset now since the merge window is near and don't want to
> miss it.
> 
> More work need to do:
> - Disable BF when xmit_more is in use
> - Make TSO use xmit_more too. Maybe by splitting small TSO packets in the
>   driver itself, to avoid extra cpu/memory costs of GSO before the driver
> - Fix mlx4_en_xmit buggy handling of queue full in the middle of a burst
>   partially posted to send queue using xmit_more
> 
> Eric, I edited the patches to have you as the Author and the first
> signed-off-by. I hope it is ok with you (I wasn't sure if it is ok to sign by
> you), anyway all the credit to those changes should go to you.
> 
> Patchset was tested and applied over commit 1e203c1 "(net: sched:
> suspicious RCU usage in qdisc_watchdog")
> 
> [1] - https://patchwork.ozlabs.org/patch/394256/

Looks great, nice work everyone.
