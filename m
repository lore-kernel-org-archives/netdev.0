From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] mlx4: remove unused fields
Date: Fri, 30 Sep 2016 01:57:09 -0400 (EDT)
Message-ID: <20160930.015709.1828493203935150678.davem@davemloft.net>
References: <1475085604-101493-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yishaih@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        edumazet@google.com, decot@googlers.com
To: ddecotig@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935602AbcI3F5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 01:57:14 -0400
In-Reply-To: <1475085604-101493-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <ddecotig@gmail.com>
Date: Wed, 28 Sep 2016 11:00:04 -0700

> From: David Decotigny <decot@googlers.com>
> 
> This also can address following UBSAN warnings:
> [   36.640343] ================================================================================
> [   36.648772] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:857:26
> [   36.656853] shift exponent 64 is too large for 32-bit type 'int'
> [   36.663348] ================================================================================
> [   36.671783] ================================================================================
> [   36.680213] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:861:27
> [   36.688297] shift exponent 35 is too large for 32-bit type 'int'
> [   36.694702] ================================================================================
> 
> Tested:
>   reboot with UBSAN, no warning.
> 
> Signed-off-by: David Decotigny <decot@googlers.com>

Applied to net-next, thanks.
